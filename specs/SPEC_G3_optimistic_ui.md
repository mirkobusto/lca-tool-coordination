# SPEC G3 — Optimistic UI

> **Sprint**: V1.5 partial — G3 (~2 settimane)
> **Branch**: `night/G3-optimistic-ui`
> **Autore SPEC**: Architect-GUI
> **Data**: 2026-05-05
> **Implementer target**: Claude Code Ubuntu

NOTA: Questa è la versione abbreviata. SPEC completa (~440 righe) vive su /mnt/user-data/outputs/SPEC_G3_optimistic_ui.md e nel repo GitHub https://github.com/mirkobusto/lca-tool-coordination/blob/main/specs/SPEC_G3_optimistic_ui.md una volta committata.

---

## 1. Goal

Materializzare P3 "Reversibile" del Kimi dossier su mutations già esistenti del frontend V1: BoMRow quantity edit, parameter set, scenario create/rename, project rename, replace matched process. Pattern TanStack Query `onMutate` (cache update locale immediato) + `onError` (rollback con toast) + `onSettled` (invalidate refetch).

**Scope stretto Opzione 1** (confermata Mirko 2026-05-05): solo mutations esistenti. Niente undo/redo globale, niente Cmd+Z system-wide, niente history visualizer (V2).

Valore: latency percepita da ~200-800ms a ~16ms (re-render React locale). Strategicamente: chiudere V1.5 partial con UX "sciolta come Linear/Notion".

## 2. Pre-flight

- Verifica G2+G2.1 squash mergiato in main (1 PR cattura entrambi commits)
- Verifica TanStack Query v4 o v5 (onMutate/onError/onSettled disponibili)
- Inventory mutations target via `grep -rn "useMutation"` + classificazione 3 categorie:
  - (a) target G3: edit immediato visibile (BomRow, parameter, scenario, project)
  - (b) carry-over G3.x: mutations con UI feedback dedicata (import xlsx con SSE, run match streaming)
  - (c) fuori scope: background sync, telemetry
- Verifica toast system esistente (sonner / react-hot-toast / custom). Se assente, integrare sonner (3 KB)
- Baseline: vitest 31, pytest 379+4

No-go: TanStack Query v3 → escalation Mirko per upgrade. Categoria (a) con 0 elementi → riconsiderare scope.

## 3. Architettura

### 3.1 Mutations target (lista preliminare, conferma Claude Code in pre-flight)

1. useUpdateBomRow — edit quantity/unit row post-ingest (ALTA)
2. useUpdateParameter — set/edit parameter value (ALTA)
3. useCreateScenario, useRenameScenario (MEDIA)
4. useRenameProject (MEDIA)
5. useReplaceMatchedProcess — cambia matched_process_id (MEDIA)

Niente in scope: import xlsx, run match streaming, create project (redirect), delete (V2 pattern), build .zolca.

### 3.2 Pattern optimistic universale

```typescript
useMutation({
  mutationFn: (vars) => api.patch(...),
  onMutate: async (vars) => {
    await qc.cancelQueries({ queryKey });
    const previous = qc.getQueryData(queryKey);
    qc.setQueryData(queryKey, (old) => applyOptimistic(old, vars));
    return { previous };
  },
  onError: (err, vars, ctx) => {
    if (ctx?.previous) qc.setQueryData(queryKey, ctx.previous);
    toastMutationError(operationLabel, err);
  },
  onSettled: () => qc.invalidateQueries({ queryKey }),
});
```

### 3.3 Helper hook reusable

`useOptimisticMutation` riduce boilerplate da 30 a 15 righe per mutation. Modulo NUOVO `frontend/src/lib/optimistic/`:
- `useOptimisticMutation.ts` (helper)
- `toast-helpers.ts` (parseErrorReason, toastMutationError)
- `__tests__/`

### 3.4 Toast system

Riusa esistente o aggiunge `sonner`. Toast errore italiano con ragione estratta dal response (axios `error.response.data.error.message` → fallback `error.message`). `role="alert"` per screen reader. Durata 5s default.

### 3.5 Edge cases gestiti

E1 network offline → rollback + toast "Connessione assente"
E2 conflict 422 → rollback + toast con motivo server
E3 race 2 edit veloci → cancelQueries previene
E4 concorrenza tab → cache per-tab (V1.5 accept), broadcast V2.x
E5 server canonical version → onSettled invalidate sostituisce optimistic
E6 mutation pending >2s → opacity 0.7 row in edit (UX clarity)

## 4. Test design

≥6 vitest nuovi:
1. cache aggiornata immediatamente in onMutate
2. rollback su onError ritorna a snapshot
3. cancelQueries previene race
4. onSettled invalida query
5. parseErrorReason estrae axios message
6. parseErrorReason fallback su Error.message
7. e2e useUpdateBomRow optimistic + rollback

Backend pytest invariato (zero modifiche backend). Vitest atteso 31 → 37+.

## 5. Decisioni autonome

- Opzione 1 stretta confermata Mirko
- Pattern TanStack Query standard, no custom state
- Helper useOptimisticMutation reusable
- Toast existente OR sonner (decisione Claude Code)
- Loading indicator solo se >2s (opacity 0.7 row)
- Italiano-only labels
- Bundle cap +5 KB gzip
- Niente backend, niente palette commands nuovi, niente migration zustand

## 6. Done criteria

Funzionalità:
- [ ] 5 mutation target convertiti
- [ ] Re-render <50ms al click
- [ ] Rollback <500ms con toast italiano
- [ ] cancelQueries + invalidateQueries
- [ ] Loading opacity se pending >2s

Tecnico:
- [ ] ≥6 vitest nuovi
- [ ] Bundle main +<5 KB
- [ ] Vitest 31→37+, pytest 379+4 invariato
- [ ] Build clean

Quality:
- [ ] Helper riduce boilerplate ≥40%
- [ ] Mutation hooks: contratto pubblico invariato
- [ ] WCAG AA mantained

## 7. Constraints

NON:
- undo/redo globale, history, Cmd+Z system (V2)
- nuovo backend, nuovo state manager
- i18n, broadcast cross-tab
- delete optimistic
- major version bump TanStack Query

PUÒ toccare:
- 5 mutation hooks esistenti (chirurgicamente)
- frontend/src/lib/optimistic/ (NUOVO)
- toast system

Tempo: 2 settimane. Escalation se >2.5 settimane.

## 8. Branch & merge

Branch: `night/G3-optimistic-ui` (nuovo da main post-G2/G2.1 merge)
PR title: `[G3] Optimistic UI — TanStack Query mutations su BomRow/Parameter/Scenario/Project`
1 PR squash, ADR 37 atteso.

## 9. Stretch

S1 optimistic delete (V2 conferma toast)
S2 conflict resolution UI dialog
S3 mutation queue diagnostic palette
S4 cross-tab BroadcastChannel
S5 smart retry on network error

## 10. Note

- G3 è primo sprint che NON aggiunge primitive AI-native, applicazione pulita pattern noto
- Carry-over G3.x: optimistic create (per ManualEntry submit, RowsTable add row), optimistic delete con conferma timer, conflict resolution UI, cross-tab sync
- Post-merge G3: V1.5 partial DONE → decisione strategica G1.x search globale entità (ALTA carry-over) vs V2 full redesign vs release V1.5 alpha
- Manual QA empirical V1.5 partial completo: workflow consulente reale dall'inizio (project create) alla fine (build .zolca + modelling guide). Numeri concreti time-to-completion vs V1 baseline
- Zero overlap con M3.x backend (M3.1.2 CF EF 3.1 in progress)

---

**Fine SPEC G3 v1.0 — 2026-05-05.**
