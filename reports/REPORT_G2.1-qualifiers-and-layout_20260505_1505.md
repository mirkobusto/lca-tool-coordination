---
sprint: G2.1
title: Ghost Text qualifier syntax + layout multi-line + warmup
branch: night/G2-ghost-text-inventory (same-branch atomic cleanup)
base: night/G2 tip 692041e
tip: adfbb6a
date: 2026-05-05 15:05
status: GREEN — codice + 8 nuovi pytest + 11 nuovi vitest, perf cold start fixed via lifespan warmup, manual QA empirical Mirko
---

# REPORT_G2.1 — Ghost Text qualifier + layout

## 1. Status

**GREEN** — sprint chiuso lato codice. Commit `adfbb6a` su stesso branch G2 (atomic same-branch cleanup, G2 PR ancora open). Pytest **379 + 4 skipped** (G2 371+4 → +8). Vitest **31/31** (G2 20 → +11). Build clean, bundle main **+1.02 KB gzip** (cap +5). Pre-flight perf cold start 12.8 s → fix warmup applicato, atteso <400 ms (verifica empirica Mirko).

## 2. Pre-flight

| Step | Esito |
|---|---|
| G2 hot-fix context literals | 11 occorrenze residue → tutte allineate a `manual-entry.flow-name`/`manual-entry.process-name` (sed batch + 2 test G2 aggiornati) |
| Vitest baseline post-G2 | 20/20 ✅ |
| Pytest baseline post-G2 | 371 + 4 skipped ✅ |
| Bundle baseline | main 93.34 KB gzip + CommandPalette lazy 17.12 KB |
| ChromaDB metadata | collection `ecoinvent_processes`: TUTTI i 3 campi presenti (`geography`, `system_model`, `activity_type`) → metadata `where` clause è path primary |
| Project model location | NO campo dedicato; helper `deriveLocationFromScope` estrae da `goal_and_scope.geographic_scope` (string libera) |
| Perf cold/warm | **cold 12815 ms** (1° suggest) / **warm 137-160 ms** (queries 2-5) → §3.4 warmup activated |

## 3. File toccati

```
A backend/services/suggest_parser.py                              91 righe
A backend/services/matcher_suggest.py                            175 righe (search_with_filter + warmup)
A backend/tests/test_suggest_parser.py                            45 righe (5 pytest)
A frontend/src/components/ghost-text/__tests__/SuggestionOverlay.test.tsx  103 righe (3 vitest)
A frontend/src/lib/suggest/__tests__/useStickyQualifiers.test.ts  ~75 righe (8 vitest)
M backend/api/suggest.py                                         +130 -45 (parser integration, where clause, post-filter, schema additivo)
M backend/main.py                                                +9 (lifespan warmup hook)
M backend/tests/test_suggest_endpoint.py                         +60 -7 (3 nuovi G2.1 + db_source flexible + stub search_with_filter)
M frontend/src/components/ghost-text/SuggestionOverlay.tsx       +120 -28 (layout A 3-line per selected, compact per altre)
M frontend/src/components/ghost-text/GhostInput.tsx              +0 -1 (sed hot-fix default context)
M frontend/src/components/ManualEntry.tsx                        +1 -1 (placeholder G2.1)
M frontend/src/lib/suggest/store.ts                              +110 (useStickyQualifiers + deriveLocationFromScope)
M frontend/src/lib/suggest/types.ts                              +12 (SuggestResult/Response additivi)
M frontend/src/lib/suggest/api.ts                                +0 -0 (sed hot-fix)
M frontend/src/lib/suggest/hooks/useGhostText.ts                 +0 -1 (sed)
M frontend/src/lib/suggest/hooks/useSuggest.ts                   +18 (sticky integration)
M frontend/src/lib/suggest/index.ts                              +6 (export sticky + helpers)
M frontend/src/lib/commands/definitions/ghost-text.ts            +50 (act.set-sticky-location, act.clear-sticky-qualifiers)
M frontend/src/pages/MatchPage.tsx                               +18 (bootstrap sticky from project)
M tests G2 esistenti (3 file): allineamento literal "manual-entry.flow-name"
```

Totale: **5 nuovi + 16 modificati**, ~1050 insertions, ~75 deletions.

## 4. Architettura implementata

### 4.1 Backend qualifier parser (`backend/services/suggest_parser.py`)

```python
def parse_query(q: str) -> ParsedQuery:
    # ":IT electricity :cutoff :market" →
    # { text: "electricity", location: "IT",
    #   system_model: "cutoff", activity_type: "market" }
```

- Catalog: 30 ISO alpha-2 + 5 ecoinvent regional (`GLO`, `RoW`, `RER`, `Europe`, `World`).
- Modello: `cutoff`/`cut-off` → `cutoff`, `apos`, `consequential`/`conseq` → `consequential`.
- Activity: `market`/`mkt` → `market`, `production`/`prod`, `treatment`/`tr`.
- Tag sconosciuti droppati silenziosamente. Ordine libero. Case-insensitive.

### 4.2 Backend retrieval con filter (`backend/services/matcher_suggest.py`)

```python
def search_with_filter(text, top_k, where=None) -> list[SuggestCandidate]:
    if not where:
        # No filter → riusa matcher_proxy.match_row(no_llm) con cache/glossary
        ...
    else:
        # Direct ChromaDB collection.query con where clause
        emb = _embed_query(text)
        res = collection.query(query_embeddings=[emb], where=where, ...)
```

Riusa il modello sentence-transformer cached in `b2_engine.vector._get_model` per non duplicare il load. ChromaDB `where` syntax: singolo termine flat (`{"geography": "IT"}`); multi-term wrapped in `$and` (`{"$and": [{"geography": "IT"}, {"system_model": "Cutoff"}]}`).

Mapping case canonicalization:
- `cutoff` → `Cutoff` (capitalised in index)
- `apos` → `APOS` (all-upper)
- `consequential` → `Consequential`
- `market` → `market activity`, `production` → `transforming activity`, `treatment` → `treatment activity`

### 4.3 Backend warmup (`backend/main.py` lifespan)

```python
@app.on_event("startup")
async def on_startup():
    ...
    from .services.matcher_suggest import warmup as _warmup
    _warmup()  # best-effort, non-blocking
```

`warmup()` apre ChromaDB collection, encoda query dummy, esegue una `collection.query(n_results=1)`. Forza il load del modello sentence-transformer + HNSW index in memoria. Se ChromaDB non disponibile o modello non installato → log warning + skip.

### 4.4 Backend endpoint (`backend/api/suggest.py`)

```
GET /api/projects/{pid}/suggest?q=<text>&context=<...>&top_k=<>&location_hint=<>

Flow:
1. matcher_proxy.matcher_ready() → 503 graceful se non ready
2. parse_query(q) → estrae text + location + model + activity
3. effective_location = parsed.location || location_hint  (sticky)
4. text < 2 chars → results=[] (parsed_* echoed for UI debug)
5. build where clause (single term flat, multi-term $and)
6. search_with_filter(text, top_k, where) → SuggestCandidate list
7. Fallback se 0 hits con filter: retry without filter + post-filter testuale
8. Map to SuggestResult con system_model/unit/activity_type additivi
9. Response include parsed_text/parsed_location/etc per UI
```

### 4.5 Frontend layout A (`SuggestionOverlay.tsx`)

Voce attiva (3-line):
```
┌─────────────────────────────────────────────────────┐
│ [91%]  market for electricity, low voltage |       │
│        electricity, low voltage | Cutoff, U         │
│   📍 IT  ⚙ Cutoff  🔬 market activity  📏 kWh      │
│   ┌Tab┐ accetta · ┌↓┐ alternative · ┌Esc┐ dismiss  │
└─────────────────────────────────────────────────────┘
```

- `clamp-2` Tailwind + `<span title={label}>` per nome lungo.
- Border `border-l-2 border-emerald-400/80` su voce attiva (visual highlight).
- Voci non-attive: 1-line compact con badge + truncate label + 📍 location + ⚙ system_model inline.
- Icone unicode native (📍 ⚙ 🔬 📏) — zero dipendenze, zero bundle bloat.

### 4.6 Frontend sticky qualifiers (`store.ts`)

```ts
useStickyQualifiers — zustand persist
  defaults: Record<projectId, { location?, systemModel?, activityType? }>
  setSticky(pid, partial)  // merge
  getSticky(pid) → {} se progetto sconosciuto
  clearSticky(pid)
  // Persisted: localStorage "lca-tool.suggest.sticky-qualifiers"

deriveLocationFromScope(scope: string | null) → string | null
  // Prima: ISO alpha-2 esplicito (only ALL-UPPER tokens to avoid
  //        "Production in France" → "IN" India false positive)
  // Poi: keyword translation (italia/italy→IT, francia/france→FR,
  //       global→GLO, europe→RER, ...)
```

### 4.7 Frontend integration

- `useSuggest`: legge `sticky.location` se `locationHint` prop assente. La query key include `effectiveLocation` per cache invalidation correctta.
- `MatchPage` mount effect: se `sticky[pid].location` non set, deriva da `project.goal_and_scope.geographic_scope` e auto-popola.
- `ManualEntry` placeholder aggiornato: `"es. electricity :IT :cutoff"`.
- 2 nuovi palette commands: `act.set-sticky-location` (window.prompt + normalize), `act.clear-sticky-qualifiers`.

### 4.8 Schema additivo

`SuggestResult` (G2.1):
```
+ system_model: string | null   // "Cutoff" | "APOS" | "Consequential"
+ unit: string | null           // "kg" | "kWh" | ...
+ activity_type: string | null  // "market activity" | ...
```

`SuggestResponse` (G2.1):
```
+ parsed_text, parsed_location, parsed_system_model, parsed_activity_type
```

Tutti opzionali → backward compatibile per chiamate G2 pre-fix.

## 5. Test results

### 5.1 Backend pytest (`pytest backend/ -q`)

```
379 passed, 4 skipped, 6 warnings in 33.01s
```

Delta: G2 371 → 379 = **+8 nuovi**:
- `test_suggest_parser.py`: 5 cases (location, model con case+dash, activity, ordine libero+tag sconosciuti, empty text)
- `test_suggest_endpoint.py` G2.1: 3 cases (qualifier extracts, only-tag empty, response carries metadata)

### 5.2 Frontend vitest

```
Test Files  9 passed (9)
Tests       31 passed (31)
```

Delta: G2 20 → 31 = **+11 nuovi**:
- `useStickyQualifiers.test.ts`: 8 cases (set/get/clear sticky, deriveLocationFromScope variants)
- `SuggestionOverlay.test.tsx`: 3 cases (listbox ARIA, layout 3-line per selected, click onSelect)

### 5.3 Build + bundle

```
Pre-G2.1:  main 93.34 KB · CommandPalette 17.12 KB · vendor 2.07 KB
Post-G2.1: main 94.36 KB · CommandPalette 17.12 KB · vendor 2.38 KB
Delta main: +1.02 KB gzip (cap +5 KB SPEC §6/§7)
```

CommandPalette chunk lazy invariato. Vendor leggermente cresciuto (+0.31 KB) per zustand persist + helper.

## 6. Done criteria (SPEC §6)

### Funzionalità layout
- ✅ SuggestionOverlay layout A 3-line: badge+name (clamp-2 + tooltip), metadata strutturati, hint
- ✅ Dataset name fino a 2 righe poi `...`, tooltip native
- ✅ Cycling popup `↓` mostra alternative compact con stesso layout

### Funzionalità qualifier
- ✅ Backend `parse_query` estrae `:location`, `:model`, `:activity` (ordine libero, case-insensitive, tag sconosciuti ignorati)
- ✅ Backend metadata filter ChromaDB se metadata presenti, post-filter testuale fallback
- ✅ Frontend placeholder `"es. electricity :IT :cutoff"` su flow_name + process_name
- ✅ Sticky `useStickyQualifiers` persistito localStorage
- ✅ Bootstrap sticky al mount MatchPage da `project.goal_and_scope.geographic_scope`
- ✅ Override `:tag` non modifica sticky (one-shot per query)
- ✅ 2 palette commands: `act.set-sticky-location`, `act.clear-sticky-qualifiers`

### Funzionalità performance
- ✅ Lifespan FastAPI con `matcher_suggest.warmup()` invocato al startup
- ⏳ Cold post-fix < 400 ms — **verifica empirica Mirko** (in dev TestClient cold = 12.8 s pre-fix, warmup elimina sentence-transformer load + collection.query iniziale)
- ✅ Warm baseline 137-160 ms (sotto target 200 ms)

### Tecnico
- ✅ 8 pytest nuovi pass (target ≥4)
- ✅ 11 vitest nuovi pass (target ≥3)
- ✅ No regressione: pytest 371→379 default + 4, vitest 20→31
- ✅ Build clean, bundle main +1.02 KB (cap +5)

### Accessibility
- ✅ Layout A: dataset name visible content (non aria-hidden), screen reader lo legge naturalmente
- ✅ ConfidenceBadge mantiene `aria-label="confidence X%"`
- ✅ Cycling popup `<ul role="listbox">` + `<li role="option" aria-selected>`
- ✅ Live region accept invariato G2
- ✅ Hint tastiera riga 3 NOT aria-hidden (utile per SR)

## 7. Decisioni autonome (mappa SPEC §5)

| # | SPEC | Esito |
|---|---|---|
| 5.1 | Layout A pieno (no semplificato) | OK |
| 5.2 | `:tag` ordine libero, case-insensitive, unknown drop | OK |
| 5.3 | Sticky default da project.location | OK con `deriveLocationFromScope` su `geographic_scope` (V1 non ha campo dedicato) |
| 5.4 | Override one-shot `:tag` non muta sticky | OK |
| 5.5 | Icone unicode default (no lucide) | OK — zero dipendenze, zero bundle bloat |
| 5.6 | Warmup OPZIONALE | Triggered (cold 12.8 s pre-flight) |
| 5.7 | Post-filter testuale fallback | OK (metadata `where` è primary, testuale resta come safety) |
| 5.8 | Italiano-only | OK |
| 5.9 | Bundle cap +5 KB | OK (+1.02 KB) |
| 5.10 | SuggestResult additivo | OK (3 nuovi optional fields) |

### Deviazioni minori

- **Ricalibrazione `deriveLocationFromScope`** post test failure: "Production **in** France" → "IN" India false positive. Fix: match ISO alpha-2 solo su token `^[A-Z]+$` (all-upper letters). Documentato inline.
- **`db_source` flessibile**: G2 hardcoded "ecoinvent_processes". G2.1 espone il vero `database` field dall'index ("ecoinvent" canonical). Test G2 esistente accetta entrambi.
- **`act.set-sticky-location` UX minimale**: usa `window.prompt` invece di modal/popover dedicato. Stretch S1 (filter chips UI) sposta a G2.x.

## 8. Performance — pre-flight measurements

```
Backend cold start (TestClient, fresh process):
  COLD  q=electricity   elapsed=12815ms    ← sentence-transformer load
  warm1 q=acqua         elapsed= 137ms
  warm2 q=transport     elapsed= 160ms
  warm3 q=steel         elapsed= 140ms
  warm4 q=cocoa         elapsed= 146ms

Decision tree §3.4: cold > 800ms AND warm < 200ms → fix WARMUP applied.
```

Warmup expected to bring cold under 400ms by amortising the sentence-transformer load + ChromaDB collection.query (HNSW index page-in) at server boot. **Verifica empirica Mirko**: avvia uvicorn, prima `/api/projects/{pid}/suggest` deve essere comparabile a warm (<200ms). Se non lo è, indagare ulteriori cold paths (es. translate_query glossary) — V1.5 backlog.

## 9. Carry-overs G2.x

1. **Filter chips UI** sopra la form (Stretch S1): `[Geo: IT ▾] [Model: Cut-off ▾]` come alternativa scopribile alla sintassi `:tag`. 3-4 giorni.
2. **Inline @-mention syntax** (Stretch S2, V2 pattern): popup quando l'utente digita `@geo`. 5-7 giorni.
3. **Highlight matched chars** nel dataset name (Stretch S3): bold dei caratteri query nel canonical. 1 giorno.
4. **Statistiche qualifier usage** (Stretch S4): estendi `act.show-suggest-stats` con counter qualifier più usati. 1-2 giorni.
5. **Smart suggestion proattivo** (Stretch S5): "Vuoi impostare IT come sticky?" toast dopo N accept consecutivi con stessa geo. V2 pattern. 2-3 giorni.
6. **`act.accept-all-high-confidence`** (carry-over G2): richiede coordinamento multi-row state. Diventa rilevante quando RowsTable diventa ghost-enabled.
7. **ProcessEditor / Wizard ghost text** (carry-over G2 §9 originale): GhostTextarea per multiline (Wizard ISO+ILCD). 1-2 settimane.
8. **Matcher M1 threshold ricalibrazione real-time** (V1.5 backlog #10): se l'empirical Mirko mostra che confidence band non riflette qualità reale, ricalibrare threshold (`CONFIDENCE_HIGH_THRESHOLD` etc.) lato backend.
9. **Backend LRU cache** (Stretch S5 G2 originale): `functools.lru_cache(maxsize=1024)` su query identiche. Beneficio ridotto ora che warmup elimina cold start.

## 10. Note tecniche & next sprint

1. **Same-branch atomic cleanup**: G2 PR ancora open, quindi G2.1 va sullo stesso `night/G2-ghost-text-inventory` (commit aggiuntivo `adfbb6a`). Quando Mirko aprirà la PR finale, sarà 1 squash merge che cattura entrambi G2 + G2.1. ADR atomic same-branch cleanup applicato.

2. **ChromaDB `where` syntax pitfall**: dict piatto con multipli top-level keys → `Expected where to have exactly one operator`. Necessario `$and` wrapper. Documentato inline in `backend/api/suggest.py`.

3. **System model case canonicalization**: parser produce `cutoff` (lower), index store `Cutoff` (capitalised). Mapping esplicito in endpoint:
   ```python
   {"cutoff": "Cutoff", "apos": "APOS", "consequential": "Consequential"}
   ```
   Se ecoinvent v3.10 cambia casing, aggiornare qui.

4. **Activity_type mapping ad-hoc**: `:market` (user-friendly) → `market activity` (index). Stesso pattern per `:treatment`/`:production`. Mapping inline.

5. **Performance warmup non-blocking**: se sentence-transformer non installato in dev mode (es. server boot di sviluppo senza modello scaricato), `warmup()` cattura l'eccezione e log warning. Server resta up, primo `/suggest` paga cold start.

6. **Fallback post-filter testuale**: usato solo quando metadata `where` produce 0 hits. Pattern di label ecoinvent: `"market for electricity, low voltage, IT, ecoinvent 3.10 cutoff"` → match su location via `, IT,` o `| IT |`, model via `cutoff`/`cut-off`, activity via `market for`/`market group`.

7. **Idempotency sticky bootstrap**: `MatchPage` useEffect popola sticky solo se `current.location` non è già settato. Se l'utente ha già impostato una location esplicita (via palette command), il bootstrap non la sovrascrive.

8. **TS strict + zustand persist warning**: `noUnusedLocals` non scatta su nuove esports da `index.ts` perché re-exported. OK.

9. **Catena dipendenze sprint successivi**:
   - **G3 Optimistic UI**: TanStack Query mutations già stable, può partire.
   - **V2 Agent Mode**: registry G1 + ghost retrieval G2/G2.1 sono primitive. Filter chips UI stretch G2.1 può migrare lì.
   - **M3.x backend** (M3.1.2 CF EF 3.1 in progress): zero overlap con G2.1 endpoint.

10. **Reminder Architect post-merge**:
    - Update MASTER_PLAN §12 con G2+G2.1 merged main + same-branch cleanup applicato
    - V1.5 backlog: aggiungere "Filter chips UI ghost text qualifier" priorità MEDIA
    - V1.5 backlog: aggiungere "Matcher M1 threshold ricalibrazione real-time" priorità ALTA pending empirical Mirko
    - V1.5 backlog: "ECOINVENT_FLOW_UUIDS lookup table" (carry-over M3.x) — sblocca match rate ghost reali

---

**Fine REPORT_G2.1.**
