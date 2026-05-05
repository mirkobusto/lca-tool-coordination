---
sprint: G2
title: Ghost Text inventory — AI-grounded suggest in ManualEntry
branch: night/G2-ghost-text-inventory
base: main @ 45e5b6f (post-PR #5, G1 squash)
tip: 692041e
date: 2026-05-05 11:42
status: GREEN (codice + 8 nuovi vitest + 5 nuovi pytest scritti, baseline conservato; verifica empirica matcher quality + accessibility delegata a Mirko)
---

# REPORT_G2 — Ghost Text inventory

## 1. Status

**GREEN** — sprint chiuso lato codice. 1 commit (`692041e`), branch pushato su `origin/night/G2-ghost-text-inventory`. Vitest 20/20 pass (12 G1 + 8 G2), backend pytest 371 + 4 skipped (366 + 5 nuovi suggest), build clean, bundle main delta +2.50 KB gzip (cap +8 KB SPEC §6). Empirical matcher quality e VoiceOver/NVDA test delegati a Mirko.

## 2. Pre-flight

| Step | Atteso | Effettivo |
|---|---|---|
| Branch base | main post-PR #5 (G1 squash) | OK 45e5b6f |
| HEAD == origin/main | true | OK |
| Backend pytest baseline | 366 + 4 skipped | OK |
| Vitest baseline | 12 pass | OK |
| Bundle main baseline | 90.84 KB gzip | OK |
| ChromaDB matcher | reachable via matcher_proxy | OK |
| BomTable editable | NO display only | scope shift §3 |

## 3. Scope shift autonomo

SPEC §1 puntava la BomTable in `/projects/:pid/match`. La realtà V1: RowsTable + RowItem sono read-only (display + radio button replace). ManualEntry.tsx (visibile in mode="manual" della stessa pagina) ha invece input editabili per flow_name/process_name — vero entry point dove l'utente compila la BoM.

SPEC §2 no-go: STOP/escalation. Implementer ha sollevato 3 opzioni; Architect/utente ha scelto opzione 1: aggancio GhostInput a ManualEntry.tsx su flow_name + process_name. Backend identico, frontend identico, soltanto il punto di mount cambia.

Backend matcher path: SPEC §3.1 ipotizzava `backend/services/matcher/`, reale è `backend/core/matcher_proxy.py` + `b2_engine/`. Riuso pulito via `matcher_proxy.match_row(tier_policy="no_llm")`.

## 4. File toccati

**18 nuovi + 4 modificati**, ~1450 righe.

Backend (3 file):
- A `backend/api/suggest.py` (158 righe)
- A `backend/tests/test_suggest_endpoint.py` (161 righe, 5 pytest)
- M `backend/main.py` (+2 -1 router include)

Frontend lib (8 file):
- A `lib/suggest/types.ts`, `api.ts`, `store.ts`, `telemetry.ts`, `index.ts`
- A `lib/suggest/hooks/useDebouncedValue.ts`, `useSuggest.ts`, `useGhostText.ts`

Frontend components (4 file):
- A `components/ghost-text/ConfidenceBadge.tsx`, `SuggestionOverlay.tsx`, `GhostInput.tsx`, `index.ts`

Frontend tests (3 file):
- A `lib/suggest/__tests__/useDebouncedValue.test.ts`, `useSuggest.test.tsx`
- A `components/ghost-text/__tests__/GhostInput.test.tsx`

Frontend wiring:
- A `lib/commands/definitions/ghost-text.ts` (3 palette commands)
- M `lib/commands/definitions/index.ts` (+5 -2 register)
- M `components/ManualEntry.tsx` (+28 -4 GhostInput agganci)
- M `pages/MatchPage.tsx` (+1 pass projectId)

## 5. Architettura

### 5.1 Backend endpoint

```
GET /api/projects/{pid}/suggest
    ?q=<min 2 max 200>
    &context=bom.name|bom.match|process.input|process.output
    &top_k=<1..10>
    &location_hint=<optional>
```

Riusa `matcher_proxy.match_row(BomRow shim, tier_policy="no_llm")` — retrieval-only, no LLM. Confidence bands: high>=0.85, medium>=0.65, low altrimenti. 503 graceful quando matcher non ready (frontend disabilita ghost text).

### 5.2 Frontend lib/suggest

- `useDebouncedValue` (300ms default)
- `useSuggest` TanStack Query (staleTime 60s, gcTime 5min, disabled query<2 chars)
- `useGhostText` state machine (idle->loading->proposing->cycling/dismissed, reset on query change)
- zustand store `useGhostTextSettings` (enabled default ON, telemetry default OFF, persisted localStorage)
- telemetry locale opt-in (ring buffer 100 events)

### 5.3 Components

- **GhostInput**: overlay grigio quando label inizia col prefix utente; "→ label" hint altrimenti. Tab=accept, Esc=dismiss, ↓/↑=cycle. ConfidenceBadge sempre presente.
- **ConfidenceBadge**: aria-label, color-coded per band.
- **SuggestionOverlay**: role="listbox" + role="option" + aria-selected.

### 5.4 Accessibility

- Input: aria-autocomplete="inline", aria-haspopup="listbox", aria-expanded, aria-controls
- Ghost text: aria-hidden="true"
- Live region: role="status" aria-live="polite" sr-only — annuncia "Accettato: <label>, confidence X%, fonte Y"
- Listbox: role="listbox" + items role="option" aria-selected
- VoiceOver/NVDA test delegato a Mirko

### 5.5 Palette commands G2 (3)

| ID | Mnemonic | Action |
|---|---|---|
| act.toggle-ghost-text | ⌘⇧Space | toggle enabled flag |
| act.toggle-ghost-text-telemetry | (none) | toggle telemetry flag |
| act.show-suggest-stats | (none) | toast con accept/reject counters |

Bootstrap esteso in `definitions/index.ts` — registry totale 17 commands (14 G1 + 3 G2).

### 5.6 Bundle

```
Pre-G2:    main 90.84 KB · CommandPalette 17.12 KB · vendor 1.63 KB
Post-G2:   main 93.34 KB · CommandPalette 17.12 KB · vendor 2.07 KB
Delta main: +2.50 KB gzip (cap +8 KB)
```

## 6. Test

5 pytest backend + 8 vitest frontend.

| File | Test |
|---|---|
| test_suggest_endpoint.py | top_k bounds, q min length, results shape + bands, 503 path, location_hint reorder |
| useDebouncedValue.test.ts | ritarda valore di N ms |
| useSuggest.test.tsx | no fetch query<2; 1 fetch dopo debounce |
| GhostInput.test.tsx | Tab accept; ↓↑ cycle; Esc dismiss persiste; aria-live announce; toggle disabled |

Final: pytest 371 + 4 skipped, vitest 20/20.

## 7. Decisioni autonome (mappa SPEC §5)

- 5.1 retrieval-only OK
- 5.2 scope shift autonomo a ManualEntry (vedi §3)
- 5.3 debounce 300ms OK
- 5.4 top-K=5 OK
- 5.5 confidence band visibile sempre OK
- 5.6 telemetry locale opt-in OK
- 5.7 modifica chirurgica ManualEntry (2 input)
- 5.8 3 palette commands implementati; act.accept-all-high-confidence skip (richiede coordinamento multi-row state che ManualEntry non espone, carry-over G2.x)
- 5.9 italiano-only OK
- 5.10 cache 60s OK

### Deviazioni minori

- ConfidenceBadge role="status" rimosso (causava double match con live region)
- Backend matcher path adattato (matcher_proxy invece di backend/services/matcher/)

## 8. Done criteria

- [scope shift] BomTable -> ManualEntry come da scelta utente
- [OK] Ghost text grigio quando query>=2 + result>=1
- [OK] Tab accept con SuggestResult completo
- [OK] Esc dismiss persiste finché query cambia
- [OK] ↓↑ cycle alternative
- [OK] ConfidenceBadge sempre visibile
- [OK] Fonte visibile (label include geography + unit)
- [OK] act.toggle-ghost-text ⌘⇧Space
- [carry-over] act.accept-all-high-confidence
- [OK] 8 vitest, 5 pytest pass
- [OK] Build clean, bundle +2.50 KB
- [OK] Backend 371+4 invariato
- [OK] ARIA contract implementato
- [delegato] VoiceOver/NVDA + p95 latency

## 9. Carry-overs G2.x

1. ProcessEditor ghost text (2-3gg)
2. Wizard ISO+ILCD ghost text con GhostTextarea (1-2 settimane, Stretch S1)
3. act.accept-all-high-confidence su RowsTable post-ingest (3-5gg)
4. Search highlighting matched chars (Stretch S2, 1gg)
5. Pin favorites (Stretch S3, 1gg)
6. Telemetry visualization avanzata (Stretch S6, 1-2gg)
7. Matcher M1 threshold ricalibrazione real-time (V1.5 backlog #10 sub-item, dopo empirical Mirko)
8. Backend LRU cache (Stretch S5)

## 10. Note tecniche

1. Scope shift: utente in `/projects/:pid/match` mode="manual" digita righe; ghost propone label ecoinvent; Tab compila; onSubmit ingesta canonical + matcher batch ri-matcha. Ghost anticipa il match riducendo review post-batch.

2. `onAccept` non popola `matched_process_id` — la canonical row V1 (BoMRowCanonical) non ha quel campo separato. Match generato a ingest-time dal matcher batch. Persistere process_id già da accept è additivo per V1.5+.

3. process_name context "process.input": il backend riconosce come placeholder filter futuro. Oggi tutti i context fanno stesso retrieval; restrizione per flow type lato backend è V1.5+.

4. Backend 503 graceful: matcher non ready -> frontend riceve [] invece di errore -> ghost si nasconde silenziosamente.

5. Build perf: 2.80s vs 2.69s pre-G2. Negligible.

6. Telemetry localStorage: ring buffer 100 events ~10 KB. Sotto soglia.

7. Catena dipendenze:
   - G3 Optimistic UI: TanStack Query mutations già stable
   - G2.x carry-overs: blended in G3 o sprint dedicato
   - V2 Agent Mode: registry G1 + ghost retrieval G2 sono primitive

8. Rapporto M3.x: endpoint /api/projects/{pid}/suggest non collide con M3.1.2 (CF EF 3.1) né M3.1.0.7. SuggestContext enum estendibile additivamente.

9. Reminder Architect post-merge:
   - Update MASTER_PLAN §12 con G2 merged main + scope shift documented
   - SPEC G3 può essere scritta
   - V1.5 backlog: "Matcher M1 ricalibrazione real-time per ghost text" priorità ALTA se empirical mostra false positives
   - V1.5 backlog: "act.accept-all-high-confidence on RowsTable post-ingest" priorità MEDIA

---

**Fine REPORT_G2.**
