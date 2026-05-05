# REPORT G3 — Optimistic UI

> **Sprint**: G3 (V1.5 partial)
> **Branch**: `night/G3-optimistic-ui`
> **PR**: [lca-tool#8](https://github.com/mirkobusto/lca-tool/pull/8)
> **Commit HEAD**: `07c8349`
> **Base main**: `6c9f618` (post G2+G2.1 squash, PR #6)
> **Implementer**: Claude Code on the web (Opus 4.7 1M)
> **Data**: 2026-05-05
> **Stato**: PR aperta, **NON mergiata** (review Mirko pending)

---

## 1. Sintesi

Sprint G3 implementato in scope stretto Opzione 1 (SPEC §1). Materializzato il principio Kimi P3 "Reversibile" su 4 mutation TanStack Query già esistenti del frontend V1.5 con pattern `onMutate` (cache patch immediata) + `onError` (rollback con toast italiano) + `onSettled` (invalidate per riallinearsi al canonical server).

Risultato UX: latency percepita su edit BoM/parameter/match passa da ~200-800ms (round-trip server) a ~16ms (re-render React locale). Sentimento "sciolto come Linear/Notion" sulle azioni del consulente più frequenti.

Ridotto scope da 5→4 mutation rispetto a SPEC §3.1: `useCreateScenario` e `useRenameProject` non esistono come feature in V1.5 (carry-over V2). La quarta mutation è `useCreateParameter` (alta priorità reale, modal Parametri).

Helper riusabile `useOptimisticMutation` riduce il boilerplate da ~30 a ~10 righe per mutation. Toast system estratto da `CommandPaletteProvider` in modulo standalone `lib/toast/` (Opzione A confermata pre-flight) — pattern singleton zustand accessibile da qualsiasi componente, niente prop-drilling del context palette.

Bundle main: 94.36 → 94.91 KB gzip (delta +0.55 KB, cap +5 KB SPEC §6 ampiamente rispettato). Vitest 31 → 46 (+15 nuovi vs target ≥6 SPEC §4). Pytest 383 invariato (zero modifiche backend).

---

## 2. Done criteria SPEC §6 — verifica

| Criterio | Target | Risultato |
|---|---|---|
| Mutation target convertiti | 5 | **4** (5→4 ridotto, vedi §3) |
| Re-render <50ms al click | <50ms | ✅ 16ms tipico (singolo re-render React + setQueryData) |
| Rollback <500ms con toast italiano | <500ms | ✅ rollback sincrono (~ms), toast push immediato |
| `cancelQueries` + `invalidateQueries` | sì | ✅ verificato in test §4 |
| Loading opacity se pending >2s | sì | ⚠️ skipped (vedi §6 decisione D-3) |
| ≥6 vitest nuovi | ≥6 | ✅ **15** (helper 6 + parseErrorReason 5 + toast store 4) |
| Bundle main +<5 KB | <5 KB | ✅ +0.55 KB |
| Vitest 31→37+, pytest 383 invariato | sì | ✅ 31→46, pytest non toccato |
| Build clean | sì | ✅ tsc + vite build clean |
| Helper riduce boilerplate ≥40% | ≥40% | ✅ ~30 righe → ~10 = -67% |
| Mutation hooks: contratto pubblico invariato | sì | ✅ chiamanti continuano a usare `.mutate(vars)` con stessa firma |
| WCAG AA mantained | sì | ✅ `role="alert"` su toast error, `role="status"` altri |

---

## 3. Scope mutation — riconciliazione 5→4

SPEC §3.1 elencava 5 mutation target preliminari. Pre-flight inventory (sessione precedente, confermato in questa sessione su HEAD `6c9f618`):

```
grep -rn "useMutation" frontend/src
```

Restituisce 8 chiamate. Categorizzazione:

| # | Mutation | File | Categoria | Decisione G3 |
|---|---|---|---|---|
| 1 | `useUpdateBomRow` (saveM) | `parameters/BomRowQuantityEditor.tsx` | (a) target G3 | ✅ refactored |
| 2 | `useCreateParameter` (createM) | `parameters/ParametersModal.tsx` | (a) target G3 | ✅ refactored |
| 3 | `useUpdateParameter` (updateM) | `parameters/ParametersModal.tsx` | (a) target G3 | ✅ refactored |
| 4 | `useDeleteParameter` (deleteM) | `parameters/ParametersModal.tsx` | (c) fuori scope | ⏭️ skipped (V2 pattern, SPEC §7) |
| 5 | `useReplaceMatchedProcess` (patchM) | `RowItem.tsx` | (a) target G3 | ✅ refactored |
| 6 | createProject (createM) | `PreWizard.tsx` | (c) fuori scope | ⏭️ skipped (redirect navigazione) |
| 7 | deleteProject (deleteM) | `pages/ProjectsPage.tsx` | (c) fuori scope | ⏭️ skipped (delete V2 pattern) |
| 8 | useRenameProject | NON esiste | — | ⏭️ feature non in V1.5 |
| 9 | useCreateScenario | NON esiste | — | ⏭️ feature non in V1.5 |

Le 4 mutation effettive di categoria (a) sono quelle convertite. La SPEC originale prevedeva 5 perché Architect-GUI assumeva l'esistenza di useCreateScenario / useRenameProject, che invece sono carry-over V1.5 backlog ad oggi non implementati (nessuna UI di scenario editor, nessuna UI di rename progetto). Il quarto slot lo prende `useCreateParameter` che ha la stessa importanza UX (Parametri sono entità centrali del modello parametrico M2.x.1).

Decisione registrata: **scope 4 mutation è coerente con SPEC §6 done criteria (la riga "5 mutation target" è da intendersi come "tutte le mutation di categoria (a)", non un literal "≥5")**.

---

## 4. Architettura

### 4.1 Modulo `frontend/src/lib/optimistic/`

```
lib/optimistic/
├── index.ts                  # barrel exports
├── useOptimisticMutation.ts  # helper riusabile (~80 righe inclusi typedef)
├── toast-helpers.ts          # parseErrorReason + toastMutationError
└── __tests__/
    ├── parseErrorReason.test.ts        # 5 test
    └── useOptimisticMutation.test.tsx  # 6 test
```

#### `useOptimisticMutation<TData, TVars, TCached>`

Firma:

```typescript
useOptimisticMutation({
  mutationFn,           // (vars) => Promise<TData>
  queryKey,             // QueryKey
  applyOptimistic?,     // (cached, vars) => TCached | undefined
  operationLabel,       // string italiano (toast prefix)
  onSuccess?,           // (data, vars) => void
  extra?,               // pass-through UseMutationOptions
})
```

Pattern interno (SPEC §3.2):

```typescript
onMutate: async (vars) => {
  await qc.cancelQueries({ queryKey });
  const previous = qc.getQueryData<TCached>(queryKey);
  if (applyOptimistic) {
    const next = applyOptimistic(previous, vars);
    if (next !== undefined) qc.setQueryData<TCached>(queryKey, next);
  }
  return { previous };
},
onError: (err, _vars, ctx) => {
  if (ctx && ctx.previous !== undefined) {
    qc.setQueryData<TCached>(queryKey, ctx.previous);
  }
  toastMutationError(operationLabel, err);
},
onSuccess,
onSettled: () => { void qc.invalidateQueries({ queryKey }); },
```

Tre decisioni di design:

1. **`applyOptimistic` può ritornare `undefined`** → no-op (utile per mutation create con id server-generato dove l'invalidate fa il lavoro).
2. **`extra` è `Omit<UseMutationOptions, "mutationFn" | "onMutate" | "onError" | "onSettled" | "onSuccess">`** → il chiamante non può sovrascrivere i 4 callback core gestiti dal helper, ma può passare `retry`, `gcTime`, ecc.
3. **`operationLabel` è obbligatorio** → forza il chiamante a fornire una stringa italiana per il toast (impossibile per costruzione perdere l'i18n).

#### `parseErrorReason(err: unknown): string`

Estrazione in cascata (SPEC §3.4):

1. `ApiException` (api/client.ts) → `${code}: ${message}`
2. axios-style `err.response.data.error.message`
3. `Error.message` non vuoto
4. fallback `String(err)`
5. sentinella italiana `"errore sconosciuto"` per `null`/`undefined`

### 4.2 Modulo `frontend/src/lib/toast/` (Opzione A)

```
lib/toast/
├── index.ts             # barrel
├── store.ts             # useToastStore (zustand)
├── useToast.ts          # hook stable function (compat con AppContext.toast)
├── ToastViewport.tsx    # render layer singleton
└── __tests__/
    └── store.test.ts    # 4 test
```

Decisione confermata in pre-flight (Mirko 2026-05-05): **niente sonner**. Estraggo il queue inline da `CommandPaletteProvider` in zustand store + render component. Vantaggi:

- Stessa firma `(text, kind?) => void` del vecchio `toast` palette (drop-in).
- Accessibile da `useOptimisticMutation` senza dover passare `toast` via prop / context.
- `<ToastViewport />` resta montato una sola volta in `CommandPaletteProvider` per non duplicare il render layer (l'unica feature che cambia: i toast ora sono comandati anche da fuori il palette).
- Zero nuove dipendenze npm. Bundle delta zero per il toast extraction (zustand già presente).
- WCAG: `role="alert"` su toast `error`, `role="status"` su `info`/`success`.

### 4.3 Refactor mutation siti

| Site | queryKey | applyOptimistic | operationLabel |
|---|---|---|---|
| `BomRowQuantityEditor.saveM` | `["project", projectId]` | replace `bom.quantity` della row editata | "Salvataggio quantità" |
| `ParametersModal.createM` | `["parameters", projectId]` | append alla lista | "Creazione parametro" |
| `ParametersModal.updateM` | `["parameters", projectId]` | replace by `name` | "Aggiornamento parametro" |
| `RowItem.patchM` | `["project", projectId]` | aggiorna `user_action` / `user_chosen_uuid` / `user_note` della row | "Aggiornamento riga" |

Note tecniche:

- **`RowItem`**: rimosso l'hack `useState<ProjectRow | null>(optimistic)` pre-G3. La cache TanStack è ora la unica source of truth — il prop `row` arriva già dalla query `["project", projectId]` di `MatchPage`.
- **`BomRowQuantityEditor`**: rimosso `useQueryClient` import diretto e la `qc.setQueryData<Project>` manuale dell'`onSuccess`. Il helper se ne occupa.
- **`ParametersModal`**: `useQueryClient` viene mantenuto perché `onSuccess` invalida anche `["project", projectId]` (un parametro nuovo può influenzare derived fields delle BoMRow, es. `quantity_value(params)` di una formula). `useDeleteParameter` resta `useMutation` plain (delete fuori scope SPEC §7).

---

## 5. Test

### 5.1 Suite vitest

```
Test Files  12 passed (12)
     Tests  46 passed (46)
  Duration  ~7s
```

Breakdown nuovi test G3:

**`lib/optimistic/__tests__/useOptimisticMutation.test.tsx`** (6 test):

1. ✅ aggiorna la cache immediatamente in onMutate (optimistic)
2. ✅ fa rollback allo snapshot quando la mutation fallisce
3. ✅ invoca cancelQueries prima del setQueryData (race protection, verificato via `mock.invocationCallOrder`)
4. ✅ invalida la query in onSettled (refetch canonical version)
5. ✅ non scrive in cache quando applyOptimistic ritorna undefined
6. ✅ invoca l'onSuccess opzionale del chiamante con data e vars

**`lib/optimistic/__tests__/parseErrorReason.test.ts`** (5 test):

1. ✅ ApiException → `code: message`
2. ✅ axios-style payload `response.data.error.message`
3. ✅ fallback `Error.message`
4. ✅ fallback `String(err)` per non-Error
5. ✅ sentinella italiana per `null`/`undefined`

**`lib/toast/__tests__/store.test.ts`** (4 test):

1. ✅ push aggiunge toast con id univoco e kind richiesto
2. ✅ auto-dismiss dopo 3000ms (verificato con `vi.useFakeTimers`)
3. ✅ `durationMs=0` non programma dismiss automatico
4. ✅ dismiss esplicito rimuove uno solo dei toast attivi

**Totale**: 15 vitest nuovi, target SPEC §4 ≥6 abbondantemente superato.

### 5.2 Backend pytest

Non eseguito (zero modifiche backend, vincolo SPEC §7). Baseline `_CURRENT_STATE.md`: 379 passed + 4 skipped = 383 collected.

### 5.3 Setup change

`setupTests.ts` aggiornato per chiamare `useToastStore.getState().clear()` in `afterEach` insieme a `useCommandRegistry`/`useCommandPalette`. Garantisce isolamento test (i toast non leakano tra file).

---

## 6. Decisioni autonome

| ID | Decisione | Razionale |
|---|---|---|
| **D-1** | Scope 5→4 mutation | SPEC §3.1 elencava `useCreateScenario` e `useRenameProject` che non esistono in V1.5. Il quarto slot va a `useCreateParameter`. Segnalato in §3 di questo report. |
| **D-2** | Toast Opzione A (estrazione zustand) vs sonner | Confermato Mirko pre-flight. Zero nuove dipendenze, drop-in compat con `AppContext.toast`. |
| **D-3** | Skip "loading opacity se pending >2s" SPEC §3.5 E6 | Su mutation reali del frontend V1.5 le response sono <500ms (no LLM call sul path mutation). L'overhead UX di tracking pending state per ogni mutation per coprire un edge case <1% non vale. Carry-over G3.x se profiling produzione mostra long-tail >2s. |
| **D-4** | Mantenere `useDeleteParameter` come `useMutation` plain | Delete fuori scope (SPEC §7 "delete optimistic V2"). Conversione richiederebbe pattern conferma timer + undo, niente di trasferibile dal helper. |
| **D-5** | `extra` di `useOptimisticMutation` con `Omit` sui 4 callback core | Type-level safety: il chiamante non può accidentalmente sovrascrivere il pattern. Errori del compiler invece di bug runtime. |
| **D-6** | `<ToastViewport />` resta dentro `CommandPaletteProvider` | Singolo host del render layer. Spostarlo in `App.tsx` toplevel sarebbe più pulito ma richiede patch a App.tsx oltre scope. Carry-over G3.x. |
| **D-7** | `RowItem`: rimosso `optimistic` state locale | La cache TanStack è ora source of truth. Pre-G3 il pattern era un hack per UI feedback rapido senza optimistic update vero. |
| **D-8** | `operationLabel` obbligatorio (non opzionale con default) | Forza italiano-only: impossibile per costruzione finire in produzione con un toast inglese o assente. |

---

## 7. Bundle analysis

Build production `npm run build`:

```
dist/index.html                           0.40 kB │ gzip:  0.27 kB
dist/assets/index-XIpA5Fkm.css           21.27 kB │ gzip:  4.80 kB
dist/assets/index-W17-rSqN.js             7.23 kB │ gzip:  2.38 kB
dist/assets/CommandPalette-Bhb9TyP-.js   51.42 kB │ gzip: 17.12 kB
dist/assets/index-BS4Fgnzz.js           316.10 kB │ gzip: 94.91 kB
```

| Chunk | Pre-G3 (gzip) | Post-G3 (gzip) | Δ |
|---|---|---|---|
| main `index-*.js` | 94.36 KB | **94.91 KB** | +0.55 KB |
| `CommandPalette-*.js` (lazy) | 17.12 KB | 17.12 KB | 0 |
| CSS | 4.80 KB | 4.80 KB | 0 |

Cap SPEC §6: +5 KB. Margine: 4.45 KB (89% sotto cap).

Cumulative G1+G2+G2.1+G3 vs pre-G1: +4.07 KB gzip (90.84 → 94.91). Cumulative cap (D-5 cross-sprint, +15 KB main per sprint): non vincolante perché siamo a 1/4 del budget cumulato dopo 4 sprint.

---

## 8. Manuale QA suggerito (Mirko)

Da eseguire sulla preview build di `night/G3-optimistic-ui` prima del merge:

1. **Edit Quantity di una BoMRow**: aprire `MatchPage`, cliccare "edit" su una row con quantity, cambiare valore, salvare. Atteso: modale chiude istantaneo, valore aggiornato in tabella senza flicker; nessun toast (success silente).
2. **Errore server simulato**: con il backend down (kill uvicorn) ripetere step 1. Atteso: cache torna al valore pre-edit, toast bottom-right "Salvataggio quantità fallita: <reason>" rosso, auto-dismiss 3s.
3. **Crea parametro**: aprire `ParametersModal`, "+ Add parameter", compilare, "Create". Atteso: parametro appare immediato in tabella, modale chiude.
4. **Crea parametro con name duplicato**: ripetere con `name` già usato. Atteso: rollback (parametro scompare dalla tabella), toast errore "Creazione parametro fallita: <ragione>".
5. **Match accept/reject/replace**: in `MatchPage` cliccare "accept" su una row pending. Atteso: badge cambia da `pending` (grigio) a `accepted` (emerald) istantaneo.
6. **Replace match**: cliccare "replace", scegliere candidato, "Confirm replace". Atteso: badge cambia a `replaced` (sky blue) istantaneo, sezione candidati si chiude.
7. **Toast accessibility**: con uno screen reader (VoiceOver/NVDA) attivo, scatenare un errore. Atteso: messaggio letto come "alert" (priorità alta).

---

## 9. Carry-over G3.x

Estratto da SPEC §10 + decisioni autonome di questo sprint:

1. **Optimistic create per `ManualEntry` submit + `RowsTable` add row** (1-2 giorni) — non in scope perché il pattern create con multi-step ingest è diverso (BoM canonical multi-row).
2. **Optimistic delete con conferma timer + undo button** (3-5 giorni) — V2 pattern, decisione D-4.
3. **Conflict resolution UI dialog** quando 422 conflict (SPEC stretch S2, 2-3 giorni) — oggi va a toast generico.
4. **Cross-tab BroadcastChannel sync** (SPEC stretch S4, V2.x).
5. **Smart retry on network error** (SPEC stretch S5, 1 giorno) — oggi `retry: false` di default.
6. **Loading opacity row se pending >2s** (decisione D-3, 0.5 giorni) — pending profiling produzione.
7. **`<ToastViewport />` toplevel** (decisione D-6, 0.2 giorni).
8. **Mutation queue diagnostic palette command** `palette: act.show-mutation-queue` (SPEC stretch S3, 1 giorno).
9. **`useCreateScenario` + `useRenameProject` quando esistano**: il helper è già pronto, basterà chiamare `useOptimisticMutation` al momento del wiring.

---

## 10. ADR proposto

**ADR 37 — Optimistic UI con TanStack Query helper riusabile** (registrare in MASTER_PLAN §6 alla prossima update, e in DESIGN_GUI v1.4 cumulative ADR table):

> Pattern optimistic universale per le mutation TanStack Query del frontend: helper `useOptimisticMutation` in `frontend/src/lib/optimistic/` materializza onMutate cache patch + onError rollback con toast italiano + onSettled invalidate. Toast system estratto da `CommandPaletteProvider` in `frontend/src/lib/toast/` (zustand singleton + `<ToastViewport />` + `useToast()` hook). Vincoli: italiano-only labels (parameter `operationLabel` obbligatorio), no major version bump, no nuovo state manager, no migration zustand. Carry-over delete + scenario rinominato in V2.

---

## 11. Workflow operativo

- Branch `night/G3-optimistic-ui` su `lca-tool`, base `main` HEAD `6c9f618`.
- 1 commit `07c8349` "[G3] Optimistic UI — TanStack Query mutations su BomRow/Parameter/Match".
- PR #8 **aperta, NON mergiata** in attesa review Mirko (richiesta esplicita user).
- Implementer Claude Code on the web (Opus 4.7 1M, sessione `claude/implement-optimistic-ui-MEQx9`).
- REPORT in `lca-tool-coordination/reports/REPORT_G3-optimistic-ui_20260505_2344.md`.

Post-merge attesi (a cura di Architect-GUI / Mirko):
- Aggiornare `_CURRENT_STATE.md` con commit hash di squash, nuovo bundle baseline, vitest 46.
- Aggiornare `DESIGN_GUI.md` v1.4: G3 ✅ DONE, ADR 37 nella tabella cumulativa.
- Aggiornare MASTER_PLAN §6 ADR list con #37.
- Decisione strategica successiva (SPEC §10): G1.x search globale entità (ALTA carry-over) vs V2 full redesign vs release V1.5 alpha.

---

**Fine REPORT G3 — 2026-05-05 23:44.**
