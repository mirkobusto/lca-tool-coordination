# REPORT G2.2 — Process_name retrieval split + SuggestionOverlay overflow fix

- **Sprint**: G2.2 (atomic same-branch hot fix di G2/G2.1, ADR 36 / D-13)
- **Branch codice**: `night/G2.2-process-split-and-overflow`
- **Base**: `main` @ `6c9f618`
- **PR**: https://github.com/mirkobusto/lca-tool/pull/10 — **APERTA, NON MERGIATA**
- **Stato**: pronta, in attesa che G3 (PR #8 su `night/G3-optimistic-ui`) sia mergiato. Dopo G3 merge → rebase G2.2 su nuovo main.

## File toccati

### Backend (2 file)

| File | Righe modificate | Descrizione |
|---|---|---|
| `backend/api/suggest.py` | +24 / −0 | `FieldKind` literal + `ACTIVITY_TYPES_PROCESS` const (L40-50); nuovo query param `field_kind: str = Query("flow_name", regex="^(flow_name\|process_name)$")` (L92-94); branch `elif field_kind == "process_name"` aggiunge `{"activity_type": {"$in": ACTIVITY_TYPES_PROCESS}}` al `where` (L167-175) |
| `backend/tests/test_suggest_endpoint.py` | +85 / −15 | Stub `_stub_search` esteso con `activity_type` diversificato per indice + supporto operatore `$in` di ChromaDB; 3 nuovi test G2.2 (L266-322) |

### Frontend (9 file)

| File | Righe modificate | Descrizione |
|---|---|---|
| `frontend/src/lib/suggest/api.ts` | +7 / −0 | tipo `FieldKind` esportato; prop `fieldKind` in `SuggestRequest`; serializzazione `field_kind=…` |
| `frontend/src/lib/suggest/hooks/useSuggest.ts` | +6 / −1 | prop `fieldKind?: FieldKind` (default `"flow_name"`); inclusa nella `queryKey` (cache separata per kind); propagata a `fetchSuggest` |
| `frontend/src/lib/suggest/hooks/useGhostText.ts` | +5 / −0 | prop `fieldKind` propagata a `useSuggest` |
| `frontend/src/lib/suggest/index.ts` | +1 / −0 | re-export `type FieldKind` |
| `frontend/src/components/ghost-text/GhostInput.tsx` | +10 / −1 | prop `fieldKind?: "flow_name" \| "process_name"` (default `"flow_name"`); container outer `<div>` ora `relative w-full` (era `relative`) per ancoraggio overlay |
| `frontend/src/components/ghost-text/SuggestionOverlay.tsx` | +1 / −1 | className `"absolute left-0 right-0 top-full z-50 mt-1 max-h-80 overflow-y-auto rounded-md border border-gray-700 bg-gray-900 py-1 text-xs shadow-lg"`; `aria-label="Suggerimenti ecoinvent"` (era `"Suggerimenti AI"`) |
| `frontend/src/components/ManualEntry.tsx` | +1 / −0 | L222 `fieldKind="process_name"` sul `<GhostInput>` di Process_name |
| `frontend/src/components/ghost-text/__tests__/GhostInput.test.tsx` | +46 / −0 | 2 nuovi test G2.2 (default `field_kind=flow_name` nell'URL; `fieldKind="process_name"` propagato) |
| `frontend/src/components/ghost-text/__tests__/SuggestionOverlay.test.tsx` | +44 / −1 | aria-label aggiornato + 2 nuovi test G2.2 (`absolute z-50`, non spinge giù i siblings) |

**Totale: 11 file, +231 / −20 righe** (1 commit squash sulla PR).

## Test count delta

### pytest

- Baseline `main` (env CI sandbox): 337 pass / 40 fail / 6 skipped
- G2.2: **340 pass** / 40 fail / 6 skipped
- **Delta: +3 nuovi pass** ✅ (target ≥2)
  - `test_suggest_field_kind_process_name_filters_activity_type`
  - `test_suggest_field_kind_flow_name_no_activity_filter`
  - `test_suggest_user_qualifier_overrides_field_kind_default`

> Nota ambiente: i 40 fail pre-esistenti sono identici prima/dopo G2.2 (verificato via `git stash` su main). Riguardano `test_endpoints_m2` / `test_modelling_guide` / `test_zolca_*` per dipendenze runtime non installate nel sandbox CI di questa run (DB locale, weasyprint render). Non introdotti dal patch. SPEC §8 dichiara baseline 379 + 4 skipped: questo riflette un environment più completo, ma il delta relativo (+3 pass) è valido.

### vitest

- Baseline G2.1: 31 pass
- G2.2: **35 pass** ✅
- **Delta: +4 nuovi pass** (target ≥4)
  - `GhostInput`: default fieldKind invia `field_kind=flow_name` al backend
  - `GhostInput`: `fieldKind="process_name"` invia `field_kind=process_name`
  - `SuggestionOverlay`: usa `position absolute` con `z-50`
  - `SuggestionOverlay`: non spinge giù form fields (overlap, non stack)

## Bundle main delta

| Bundle | Size gzip |
|---|---|
| Baseline G2.1 (riferimento SPEC §8) | 94.91 KB |
| G2.2 build prod | **94.42 KB** |
| **Delta** | **−0.49 KB** ✅ |

Sotto cap **+1 KB** (hard +5 KB / D-5). Lieve miglioramento per via di: dead code removal su SuggestionOverlay className (rimozione `max-w-2xl shadow-2xl`) e factoring del param `field_kind` come singola query string.

## Acceptance criteria check

| Criterio (SPEC §8) | Stato | Evidenza |
|---|---|---|
| Backend pytest ≥2 nuovi pass | ✅ | +3 nuovi pass (`test_suggest_field_kind_*`) |
| Frontend vitest ≥4 nuovi pass | ✅ | +4 nuovi pass (GhostInput +2, SuggestionOverlay +2) |
| Bundle main delta ≤ +1 KB gzip vs 94.91 | ✅ | −0.49 KB (94.42 KB) |
| Pytest totale: 379 + ≥2 invariati skipped | ⚠️ | sandbox CI: 340 pass / 6 skipped. Baseline ambientale diverso da SPEC, ma delta +3 pass conforme |
| WCAG: SuggestionOverlay `role/aria` preservati | ✅ | `role="listbox"` + `aria-label="Suggerimenti ecoinvent"` |
| Italiano-only labels invariato | ✅ | nessuna stringa nuova in EN |
| Retrocompat: `field_kind` opzionale, default `flow_name` | ✅ | endpoint default → comportamento G2/G2.1 |
| Qualifier utente vince su `field_kind=process_name` default | ✅ | `test_suggest_user_qualifier_overrides_field_kind_default` |
| G3 files non toccati (mutations BomRow/Parameter/Match, lib/optimistic/, lib/toast/) | ✅ | nessuno di quei path appare nel diff |

## Carry-over emersi

1. **Wizard ISO** non è stato verificato per stesso bug Process_name (fuori scope SPEC §11). Sospetto stesso retrieval semantico errato. → Da catturare in **V1.5 backlog #9 (ProcessEditor / Wizard ghost text)**.
2. **`regex=` deprecation**: l'API FastAPI installata nel sandbox emette `FastAPIDeprecationWarning: regex has been deprecated, please use pattern instead`. SPEC G2.2 §4 prescrive esplicitamente `regex=…` quindi lasciato com'è. → Cleanup separato per migrare tutti i `Query(regex=…)` del backend.
3. **`aria-label` rebrand**: `"Suggerimenti AI"` → `"Suggerimenti ecoinvent"` (richiesto da SPEC §5). Nessun consumer esterno noto. Verificato: solo il test `SuggestionOverlay.test.tsx` referenzia la stringa, già aggiornato. Se altre suite (e2e Playwright?) la linkano, vanno aggiornate.
4. **`popupOpen` decoupled da `fieldKind`**: se in futuro vorremo aprire automaticamente il popup quando `fieldKind="process_name"` (UX più aggressiva sui process, dato che l'utente è meno familiare con i nomi canonici delle activity ecoinvent), va aggiunto come **V1.5 backlog item**. Out-of-scope G2.2.
5. **Stub backend test diversificato**: il `_stub_search` ora ritorna 3 candidati con `activity_type` distinti (`market activity`, `transforming activity`, `None`). Tutti i test G2/G2.1 esistenti continuano a passare grazie alla rimozione del primo candidato (uuid-A) tramite filtri `where`. Se in futuro arriveranno altri test che assumono `activity_type == "market activity"` su tutti, vanno aggiornati allo stub diversificato.

## PR

🔗 **https://github.com/mirkobusto/lca-tool/pull/10**

- Title: `[G2.2] Process_name retrieval split + SuggestionOverlay overflow fix`
- Branch: `night/G2.2-process-split-and-overflow` → `main`
- Strategia: **squash merge**
- Stato: APERTA, NON MERGIATA
- Blocker: G3 PR #8 (`night/G3-optimistic-ui`) deve essere mergiato per primo. G2.2 NON ha conflitti attesi con G3 (set di file disgiunti), ma ordine di merge fissato per disciplina D-13.
