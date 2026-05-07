# REPORT M2.4.2 — Frontend Process editor + FlowSelector + ProductSystem editor

**Sprint:** M2.4.2 (sub-sprint 3 di 4 della catena M2.4)
**Branch codice:** `claude/frontend-process-editor-uHvd4` (lca-tool)
**Branch coordination:** `claude/frontend-process-editor-uHvd4` (lca-tool-coordination)
**Base:** `main` HEAD post-merge M2.4.1 (commit `5092006`)
**Data chiusura:** 2026-05-06 13:38 UTC
**PR codice:** [lca-tool#15](https://github.com/mirkobusto/lca-tool/pull/15) — NON mergiato
**PR coordination:** (creato in coda a questo report)

---

## 1. Riepilogo

Lo sprint M2.4.2 cuce il frontend sul modello dati v7 e sulle 15 API CRUD
di M2.4.1. Aggiunge cinque pagine, un componente core (FlowSelector
polimorfico), cinque atomi di form riusabili, due hook TanStack Query, e
estende PreWizard + ComplianceBanner per il modeling_mode `process_based`.

## 2. Acceptance criteria

| Criterio | Atteso | Effettivo | Pass |
| --- | --- | --- | --- |
| vitest delta | +>=15 | **+32** | ✅ |
| vitest totale | >=85 | **102** | ✅ |
| pytest backend | 458 | non toccato (sanity 14/14 schema_m2 verde) | ✅ |
| Bundle main delta | ≤ +25 KB gzip | **+1.17 KB** (96.11 → 97.28 KB) | ✅ |
| TypeScript build | clean | clean | ✅ |
| 5 nuove pagine | sì | ProcessList / ProcessEditor / ProductSystemList / ProductSystemEditor + estensione PreWizard + estensione ProjectDetail | ✅ |
| FlowSelector polimorfico | 3 tipi | db_dataset / db_elementary / internal_process | ✅ |
| Form atoms riusabili | 5 | QuantityInput, FlowRefBadge, DqrScoreInput, DistributionInput, ParameterRangeInput | ✅ |
| Italiano-only labels | sì | sì | ✅ |
| WCAG 2.1 AA | nessuna regressione | aria-label su tutti i nuovi input + Modal pattern shared | ✅ |
| Routing nuovo | sì | 4 nuove route lazy in App.tsx | ✅ |
| Hooks invalidate | sì | useProcesses + useProductSystemsV2 | ✅ |
| ComplianceBanner esteso | sì | process_based row se procs==0 / ps==0 / processo senza ref output | ✅ |
| Modal cascade-refuse 409 | sì | con elenco referrers, riusato in List + Editor | ✅ |

## 3. Numeri chiave

- **Test count:** 70 → 102 (+32). 28 file di test (+10 nuovi).
- **Bundle main:** 96.11 KB → 97.28 KB gzip (Δ **+1.17 KB**).
- **Bundle lazy chunks aggiunti:**
  - ProcessEditorPage 5.36 KB gzip
  - ProcessListPage 1.78 KB gzip
  - ProductSystemEditorPage 1.95 KB gzip
  - ProductSystemListPage 1.29 KB gzip
  - useProcesses 0.64 KB + useProductSystemsV2 0.39 KB (shared chunks)
  - Totale lazy: ~11.4 KB gzip (caricato solo on-route).
- **File toccati:** 33 (2 backend modificati, 14 frontend nuovi non-test, 10 test nuovi, 7 frontend modificati).
- **Righe diff:** +3402 / −9 (squash diff).

## 4. Decisioni autonome documentate

### 4.1 Estensione minima del backend per modeling_mode in ProjectCreateV3

Lo SPEC §2.2 dice "la scelta arriva al backend via POST /api/projects nel
campo `modeling_mode`". Il backend M2.4.1 ha solo `/api/projects/v3` che
non accettava il campo. Senza questa estensione, l'intero feature
diventava unusable end-to-end.

**Scelta:** estesi `backend/models/schema.py::ProjectCreateV3` con
`modeling_mode: Optional[str] = None` e `backend/api/projects_v3.py`
con validazione contro il `ModelingMode` literal (`flat` /
`process_based`). 7 + 12 righe.

**Razionale:** lo SPEC era 100% frontend ma assumeva che la persistenza
funzionasse. Backwards compatible (campo opzionale, default = "flat"
preservato).

### 4.2 parseError esteso per envelope cascade-refuse

`api/client.ts::parseError` gestiva solo l'envelope nested
`{error: {code, message}}`. Il backend M2.4.1 emette cascade-refuse 409
con shape top-level `{error: "process_referenced", message, referrers}`.

**Scelta:** esteso `parseError` per riconoscere lo shape top-level e
preservare il body raw in `ApiException.details`. La nuova helper
`inspectCascadeRefuse(err)` decodifica i referrers per i modali.

### 4.3 FlowSelector — internal scan client-side fallback

L'API `/api/suggest` non supporta ancora `flow_type` / `include_internal`
(arriveranno in M2.4.3). Per non bloccare l'UX:

- I query param vengono comunque mandati al backend (pronto per M2.4.3).
- Lo scan dei processi interni (`internal_process` candidates) gira
  client-side sul `processes[]` del progetto, con match su nome + descrizione.

Quando M2.4.3 atterra, il frontend si "accende" automaticamente: i
risultati elementary arrivano dal backend, lo scan client-side resta
come complemento istantaneo.

### 4.4 Quantity inline scope-down (M2.4.4)

Il form `QuantityInput` ha la sezione collapsible "Qualità del dato" già
in UI ma con tooltip "Disponibile dal prossimo sprint" — coerente con
SPEC §3 OUT (uncertainty/range/dqr inline su una Quantity sono carry-over
a M2.4.4 da M2.4.0 §4.2).

Uncertainty / range / DQR vivono al momento solo sui Parameter; per usarli
su un Quantity di un exchange l'utente passa via "Riferimento parametro".

### 4.5 Inline editable exchanges (no modal per riga)

SPEC §8.2 chiede UX simile a Match page: niente modal per ogni edit. Il
ProcessEditor renderizza ogni Exchange come riga editabile inline con
FlowSelector + QuantityInput affiancati.

### 4.6 Lazy loading delle 4 pagine nuove

Tutte le pagine nuove sono `React.lazy()`. Il bundle main resta a +1.17
KB gzip — molto sotto il cap di +25 KB. Le pagine raggiungibili solo dopo
navigation, lazy loading è win-win.

### 4.7 Banner informativo invece di redirect automatico

SPEC §8.5 esplicito: utenti con bookmark `/processes` su progetto flat
meritano spiegazione, non redirect silenzioso. Implementato con
`<FlatModeBanner>` interno + CTA "Vai al match BoM" + link "Torna al
progetto".

## 5. Carry-over emersi

### 5.1 Verso M2.4.3 (ChromaDB elementary + suggest filter)

- Il FlowSelector è già pronto: passa `flow_type` e `include_internal`
  oggi, basta che il backend li implementi.
- Il mapping `db_dataset` ↔ `db_elementary` nel frontend si decide oggi
  con `flowType` prop; quando il backend ritornerà flussi misti su una
  sola query, va aggiunto un campo discriminator (es. `flow_type`) sulla
  `SuggestResult` e va aggiornato `fetchExternal()` in `FlowSelector.tsx:128`.

### 5.2 Verso M2.4.4 (Quantity inline qualità)

- `<QuantityInput>` ha la sezione collapsible "Qualità del dato"; va
  estesa con `<DistributionInput>` + `<ParameterRangeInput>` +
  `<DqrScoreInput>` inline e collegata al backend quando `Quantity`
  estesa supporterà uncertainty/range/dqr.
- Backend `Quantity` deve accettare i nuovi campi (vedi M2.4.0 §4.2
  carry-over).

### 5.3 Verso V1.5 (canvas linking + scenari)

- Editor scenari completo (creare/modificare/diffare scenari) — non
  toccato, richiede UX nuova.
- Canvas grafico per linking processi — richiede react-flow o simile,
  out of scope.
- Confronto cross-ProductSystem — richiede pagina dedicata.

### 5.4 Manual QA (post-merge, richiede backend running)

Documentato in SPEC §5.2:

1. Crea progetto modeling_mode=process_based via PreWizard → atterra su
   `/projects/{pid}/processes`
2. Crea Process A con 1 input + 1 output ref
3. Crea Process B che linka output di A come input (FlowSelector
   internal_process)
4. Crea ProductSystem con FU=1 kg, ref=B
5. Verifica DELETE process A → cascade-refuse modal con referrer B
6. WCAG: re-run audit-a11y.mjs → 0/0/0/0 atteso

### 5.5 Quirks emersi

- **vitest fake timers + fetch promise:** primo tentativo del test
  FlowSelector con `vi.useFakeTimers()` falliva per timeout. Soluzione:
  real timers + waitFor. Il debounce 200ms del componente è abbastanza
  veloce per real-time tests.
- **`getByLabelText(/regex/)` ambiguity:** `QuantityInput` ha
  `aria-label="Quantità: valore"` e `aria-label="Quantità: valore fisso"`
  — il regex matcha entrambi. Risolto con string match esatta nei test.

## 6. File toccati (count breakdown)

**Backend (2 modificati):**

- `backend/models/schema.py` — `ProjectCreateV3.modeling_mode` opzionale
- `backend/api/projects_v3.py` — validazione + persist al create

**Frontend nuovi (14):**

- `src/types/processBased.ts` (94 righe)
- `src/api/processBased.ts` (118)
- `src/hooks/useProcesses.ts` (101)
- `src/hooks/useProductSystemsV2.ts` (62)
- `src/components/forms/{FlowRefBadge,QuantityInput,DqrScoreInput,DistributionInput,ParameterRangeInput}.tsx` (5 atoms, ~400 righe)
- `src/components/ghost-text/FlowSelector.tsx` (216)
- `src/pages/ProcessListPage.tsx` (213)
- `src/pages/ProcessEditorPage.tsx` (442)
- `src/pages/ProductSystemListPage.tsx` (157)
- `src/pages/ProductSystemEditorPage.tsx` (313)

**Frontend modificati (7):**

- `src/App.tsx` — 4 nuove route lazy
- `src/api/client.ts` — parseError esteso
- `src/api/m2.ts` — `createProjectV3` accetta `modeling_mode`
- `src/components/PreWizard.tsx` — selettore modeling_mode su step 0f
- `src/components/compliance/ComplianceBanner.tsx` — riga process_based
- `src/pages/ProjectDetailPage.tsx` — link "Processi → / Product System →"
- `src/types.ts` — `Project.modeling_mode/processes/product_systems_v2`

**Frontend test (10 nuovi):**

- `src/api/__tests__/processBased.test.ts` (4 tests)
- `src/components/__tests__/PreWizard.modelingMode.test.tsx` (2)
- `src/components/forms/__tests__/{Quantity,ParameterRange,DqrScore,Distribution,FlowRefBadge}Input.test.tsx` (4+2+2+3+3)
- `src/components/ghost-text/__tests__/FlowSelector.test.tsx` (4)
- `src/pages/__tests__/ProcessListPage.test.tsx` (3)
- `src/pages/__tests__/ProductSystemEditorPage.test.tsx` (5)

**Totale:** 33 file (vs 0 baseline — la maggior parte del codice è nuovo).

## 7. Branch note

Lo SPEC §7 indicava `night/M2.4.2-frontend-process-editor`. Le istruzioni
del task harness designavano `claude/frontend-process-editor-uHvd4` come
branch obbligatorio per entrambi i repo, e vietavano push su altri branch
senza permesso esplicito. Ho seguito le istruzioni del task harness.

---

## Hotfix M2.4.2.0.1 — partial (critical bugs only) — 2026-05-07

**Stato:** parziale. Solo bug critici A/B/G fixati. Bug C-F (UX polish)
sono sospesi in attesa che Mirko verifichi via manual QA che il workflow
process-based core (steps 2-3 della §5.4) sblocca con A/B/G.

**Trigger:** manual QA notturno post-merge M2.4.3+M3.1.2 ha rivelato
7 bug bloccanti. Per gestire il rischio di token expiration mid-session
abbiamo splittato in: (1) critical bundle ora, (2) UX polish bundle dopo
QA verification.

### Bug fixati (critical)

| # | Bug | Severity | Fix |
|---|---|---|---|
| A | Nome flusso custom perso al re-mount | Critical | Aggiunto FlowRef variant `custom` (pydantic + TS additivo). FlowSelector ora persiste eagerly via onChange ad ogni keystroke in modalità Custom; al re-mount restora display_name dall'attributo `value`. |
| B | Unità disconnessa dal dataset | Critical | QuantityInput accetta nuovo prop `lockedUnit`. Quando il FlowRef linkato ha `display_unit`, ProcessEditorPage lo passa come `lockedUnit` e l'unità viene resa read-only (icona 🔒 + tooltip). Custom flow → unità editabile. Cambio flusso → quantity.unit auto-sincronizzato. |
| G | Toggle internal_process | Critical | Confermato assente nell'UI prima del fix (lo scan client-side esisteva ma era nascosto dietro l'input testuale generico). Aggiunto segmented control `[Database \| Custom \| Processi interni]` sopra l'input. Modalità Internal nascosta quando `includeInternal=false` (es. exchange di output). |

### Bug pending (carry-over alla prossima passata)

| # | Bug | Severity |
|---|---|---|
| C | Reference + Avoided checkbox non mutex | High |
| D | QuantityInput leading zero "06.5" | High |
| E | Location dropdown lista incompleta | Medium |
| F | Riferimento parametro UX (radio + manager) | Medium |

### Decisioni autonome

1. **Nome del nuovo FlowRef variant: `custom`** invece di `internal` (suggerito dallo SPEC). `internal` collidedrebbe semanticamente con `internal_process` — `custom` esprime meglio "nome libero, no DB binding".
2. **Cambio additivo, no migrazione.** Aggiunto come quarta variante alla discriminated union; tutti i record esistenti rimangono validi (continuano ad essere db_dataset/db_elementary/internal_process). Backwards-compat.
3. **Custom flow + zolca export = errore esplicito.** `zolca_builder_process_based.flow_for_exchange` ora raise `ZolcaBuildError` chiaro se incontra un custom flow ("must be resolved to a DB dataset, elementary flow, or internal process before export"). I custom flow sono editing placeholders, non export-ready — questo allinea col comportamento atteso (un progetto serio si chiude prima di esportare).
4. **Validazione client-side custom name.** ProcessEditorPage.validate ora rifiuta exchange con `flow_ref.type === "custom"` e nome vuoto (in linea con la regola pydantic `min_length=1`).
5. **Internal mode mostra TUTTI i processi se la query è vuota.** Pre-fix `searchInternal` esigeva una query non-empty; ora se l'utente apre la modalità Internal e non ha ancora digitato nulla, i top 8 processi compaiono nel listbox. Migliora discoverability del workflow Process B → input internal verso A.

### Files toccati (11)

**Backend (4):**
- `backend/models/process_based.py` — +`FlowRefCustom`, union estesa
- `backend/models/__init__.py` — re-export `FlowRefCustom`
- `backend/services/zolca_builder_process_based.py` — branch esplicito custom→ZolcaBuildError
- `backend/tests/test_process_based_models.py` — +2 tests (round-trip + empty-name reject)

**Frontend (7):**
- `frontend/src/types/processBased.ts` — `FlowRefCustom` aggiunta all'union
- `frontend/src/components/forms/FlowRefBadge.tsx` — icona + label `custom`
- `frontend/src/components/forms/QuantityInput.tsx` — prop `lockedUnit`, helper `<UnitField>`
- `frontend/src/components/forms/__tests__/QuantityInput.test.tsx` — +2 tests
- `frontend/src/components/ghost-text/FlowSelector.tsx` — segmented mode toggle, modalità custom, persistence eager
- `frontend/src/components/ghost-text/__tests__/FlowSelector.test.tsx` — riscritto test internal sul nuovo toggle, +2 tests (custom commit, custom re-mount preservation)
- `frontend/src/pages/ProcessEditorPage.tsx` — `lockedUnit` propagato, `handleFlowChange` auto-sync `quantity.unit`, validazione custom name

### Test delta

- **Frontend vitest pre-hotfix:** 102/102 (riportato §3.1)
- **Frontend vitest post-hotfix:** 106/106 ✅ (+4 nuovi: lockedUnit read-only, lockedUnit null editable, custom commit eager, custom re-mount preservation; il test `surfaces internal_process candidates` è stato riscritto sul nuovo toggle, non doppio-conteggiato)
- **Backend pytest `test_process_based_models` pre-hotfix:** 29/29
- **Backend pytest `test_process_based_models` post-hotfix:** 31/31 ✅ (+2: custom round-trip, custom empty-name rejection)

### Bundle delta

- **Pre-hotfix main:** 97.28 KB gzip (riportato §3.2)
- **Post-hotfix main:** 97.29 KB gzip
- **Delta:** +0.01 KB gzip (well under il +5 KB budget — il diff è essenzialmente logica + types che si compilano via)
- **ProcessEditorPage chunk:** 6.06 KB gzip (lazy)

### Diff stats

```
 11 files changed, 415 insertions(+), 89 deletions(-)
```

### Verifica QA richiesta (Mirko, before C-F)

Per validare che il workflow process-based core ora funziona, rifare:

1. **Bug A** — Step 2 §5.4 originale: Process A con 1 input (DB dataset) + output ref con nome custom "Manufactured part" → switch tab Custom in FlowSelector → digita nome → save → cambia tab Inputs↔Outputs → reload pagina → il nome **deve persistere**.
2. **Bug B** — Stessa Process A: dataset gas naturale (m3) come input → campo unità deve mostrare "m3 🔒" read-only. Cambia dataset → unità segue. Switch a custom → unità torna editabile.
3. **Bug G** — Step 3 nuovo: Process B con input → segmented toggle "Processi interni" → seleziona output di Process A dal listbox → flow_ref persiste come `internal_process`.

Se 3/3 OK → procedi con bug bundle C-F (high+medium severity).
Se < 3/3 → loop hotfix sui critical residui.

### Commit

`f9f1ec9` su `claude/frontend-process-editor-uHvd4` nel repo `lca-tool` (force-push, PR #15 aggiornata, NO nuovo PR).

---

**End of report (M2.4.2.0.1 partial appended 2026-05-07).**

---

## Append hotfix M2.4.2.0.2a (2026-05-07)

### Contesto

Manual QA del 2026-05-07 sul branch post-M2.4.2.0.1 ha rivelato 4 bug strutturali aggiuntivi. Sono stati split in due tranche per ridurre rischio sessione lunga:

- **2a (questo append)** — 4 critical/high strutturali: B', H, I, J
- **2b (sprint successivo)** — 4 UX polish: C (radio ref/avoided/byproduct/waste), D (leading zero quantity), E (location dropdown), F (parameter manager + tooltip)

Direzione UX strategica confermata da Mirko stesso giorno: tool **non** deve essere copia di SimaPro con 8 tab semantici. UX rapida command-palette/ghost-text style (linea G1+G2). Categorie semantiche LCA derivate invisibilmente da `flow_type` del dataset, non imposte all'utente. Questa direzione **non** richiede modifiche in 2a; è il contesto entro cui si decide quali fix far passare e quali differire.

### Bug fixati

#### Bug B' — Suggest popup DB assente in input mode

- **Sintomo riprodotto:** in input mode, tab Database, digito nel campo Flusso → nessun suggerimento. Stesso editor in output mode → suggerimenti OK.
- **Root cause confermata:** ProcessEditorPage passa `flowType={isOutput ? "product" : "any"}`. Il backend `/api/projects/{pid}/suggest` (M2.4.3) valida il param `flow_type` con regex `^(product|elementary)$` e 422-rejecta qualunque altro valore. Il frontend forwardava `flow_type=any` che il backend rifiutava silenziosamente; `fetchExternal` sul `!res.ok` ritornava `[]`, da cui dropdown vuoto.
- **Fix:** in `frontend/src/components/ghost-text/FlowSelector.tsx::fetchExternal()`, omettere il param `flow_type` quando `flowType === "any"` (il backend tratta `None = no filter`). Per i risultati misti, scegliere `buildElementarySuggestion` se `r.flow_type === "elementary"`, altrimenti `buildDatasetSuggestion`. Esteso `SuggestResult` (frontend types) con i campi `flow_type` e `category` aggiunti dal backend M2.4.3.

#### Bug H — Lista processi non refresha post-save (cache stale)

- **Sintomo riprodotto:** creo Process → salvo → navigo a `/projects/{pid}/processes` → non appare. F5 manuale → appare.
- **Root cause confermata:** `useCreateProcess`, `useUpdateProcess` e `useDeleteProcess` invalidavano correttamente la queryKey `["processes", pid]`. Tuttavia ProcessEditorPage registrava una **seconda** osservatrice sulla stessa queryKey con un fetcher diverso (`async () => projectQ.data?.processes ?? []`). React Query, su invalidate, rifa l'unica fetcher associata all'osservatore attivo: in editor il fetcher mirroring veniva rieseguito → ridava il valore stale di `projectQ.data` (mai re-fetchato, key diverso). La cache restava popolata di vecchio. Quando l'utente navigava in lista entro `staleTime: 5_000` (config in `main.tsx`), `useProcessList` non rifa la fetch perché vede dati "freschi" (appena scritti dal fetcher mirroring).
- **Fix:** sostituito in `ProcessEditorPage` il custom `useQuery({ queryKey: ["processes", pid], queryFn: ... })` con `useProcessList(pid)`, l'hook canonico che usa `listProcesses(pid)` come fetcher. Eliminata la collision di key/fetcher; ora invalidate-on-mutation rifa la fetch corretta, la cache è canonical-truth.

#### Bug I — Cross-contamination FlowSelector multi-input

- **Sintomo riprodotto:** Input #1 segmented=Processi interni con processo selezionato → "+ Aggiungi input" → Input #2 segmented=Database, query → ricerca DB non funziona.
- **Root cause confermata:** **lo stesso meccanismo di Bug B'**, NON una vera cross-contamination di stato. Input #1 funziona perché "Processi interni" è scan client-side, non hit backend. Input #2 in mode "Database" cade sulla path `fetchExternal` con `flowType="any"` → rifiutato dal backend (vedi Bug B'). Verificato che `<FlowSelector>` ha stato locale isolato (`useState`/`useRef` per istanza), che la `key` prop è `ex.id` (non index) in `ExchangeRow.map` (line 368 di ProcessEditorPage), e che non esistono singleton/AbortController condivisi. Nessuna delle 4 ipotesi della SPEC era effettivamente la causa.
- **Fix:** automaticamente risolto dal fix Bug B'. Per blindare contro future regressioni, aggiunto un test `two sibling FlowSelectors keep their state isolated (Bug I)` che monta 2 istanze, fa interagire la prima e assicura che `onChange` della seconda non venga mai invocato dall'azione della prima.
- **Razionale ipotesi scelta:** spec listava 4 ipotesi (state condiviso / cleanup / key / AbortController). L'ispezione del codice ha escluso tutte e 4 in 5 minuti; il sintomo combaciava 1:1 con Bug B' (output funziona, input no, perché i due hanno `flowType` diverso). Fix più piccolo + safer = fix B' più test sentinel.

#### Bug J — Sticky autocomplete riscrive match precedente

- **Sintomo riprodotto:** seleziono "natural gas" → backspace cancella tutto → dopo qualche frame il campo si ri-popola con "natural gas".
- **Root cause confermata:** in `FlowSelector::inputValue` (line 226 originale): `inputValue = mode === "custom" ? customName : query !== "" ? query : persistedDisplay`. Quando l'utente cancella manualmente, `query` torna a `""` → cade nel ramo `persistedDisplay = value?.display_name`, riscrivendo il nome del flow appena cancellato. Pattern controlled-input con fallback malato.
- **Fix:** introdotto stato `userCleared` (boolean) tracciato in `handleInputChange` quando il testo torna `""`. Reset di `userCleared` su selezione (mouseDown), su mode-switch (`switchMode`), su keystroke non-vuoto. `inputValue` ora aggiunge il ramo `userCleared ? "" : persistedDisplay`. In più, il clear manuale propaga al parent via `onChange(null)` se la modalità corrente combacia con il tipo del value (segnale "reset flow_ref"). La signature di `onChange` è stata estesa a `(next: FlowRef | null) => void`. Il parent `ExchangeRow::handleFlowChange` gestisce il null sostituendo con `PLACEHOLDER_DATASET` (mantiene typed flow_ref valido per il modello, e fa scattare il messaggio "seleziona un flusso" della validate() su Salva).

### File toccati

| File | +/- |
| --- | --- |
| `frontend/src/components/ghost-text/FlowSelector.tsx` | +33 / -3 |
| `frontend/src/components/ghost-text/__tests__/FlowSelector.test.tsx` | +119 / -0 |
| `frontend/src/lib/suggest/types.ts` | +5 / -0 |
| `frontend/src/pages/ProcessEditorPage.tsx` | +14 / -7 |
| `frontend/src/hooks/__tests__/useProcesses.cache.test.tsx` | +213 / -0 (nuovo file) |
| **Totale** | **+384 / -10**, 5 file |

Backend invariato (zero file `.py` toccati). Schema/migrations/API shape invariati.

### Test

- **Vitest pre-hotfix:** 106 (102 M2.4.2 + 4 M2.4.2.0.1)
- **Vitest post-hotfix:** **113 ✅** (+7 nuovi):
  - `omits flow_type when flowType='any' so backend does not 422-reject (Bug B')`
  - `two sibling FlowSelectors keep their state isolated (Bug I)`
  - `manual clear leaves the field empty and emits onChange(null) (Bug J)`
  - 4 cache test in `useProcesses.cache.test.tsx`: create→list refetches, update→rename visible, delete→removed, e regression sentinel "no key collision"
- **Pytest:** non eseguito in questa sessione (deps backend non installate localmente). Backend invariato → nessuna regressione possibile da queste modifiche.

### Bundle

- **Main `index-*.js` pre-hotfix:** 97.29 KB gzip
- **Main `index-*.js` post-hotfix:** 97.29 KB gzip — **delta = 0 KB**
- **ProcessEditorPage (lazy):** 6.06 KB → 6.10 KB gzip (+0.04 KB, dovuto al wrapping null-handling in handleFlowChange)
- Ben sotto il budget +2 KB target / +5 KB tollerato.

### Decisioni autonome prese

1. **Estensione tipo `SuggestResult` frontend** con `flow_type` + `category` (allineamento al backend M2.4.3 già deployato). Rationale: serviva per implementare la build-per-row in fetchExternal senza casting ad-hoc; il backend già emette i campi ma il frontend type non li tipava. Zero impatto runtime.
2. **Estensione signature `onChange` di FlowSelector** da `(next: FlowRef) => void` a `(next: FlowRef | null) => void`. Rationale: la SPEC test per Bug J asseriva esplicitamente `expect(onChange).toHaveBeenCalledWith(null)`. Alternativa "emit PLACEHOLDER_DATASET inline" sarebbe stata più invasiva nel componente e meno espressiva. Il parent `ExchangeRow` gestisce il null con `PLACEHOLDER_DATASET`, mantenendo il tipo `Exchange.flow_ref` non-nullable.
3. **Bug I risolto via fix Bug B'** + test sentinel di stato isolation invece di un fix dedicato. Rationale: l'ispezione codice ha escluso le 4 ipotesi della SPEC; il sintomo è una conseguenza diretta di Bug B'. Fix più piccolo, più safer (vedi sezione Bug I).
4. **Sostituzione completa di `allProcQ`** con `useProcessList(pid)` invece di tenere il custom `useQuery` con queryKey diverso (es. `["editor:other-processes", pid]`). Rationale: usare l'hook canonico produce coerenza tra editor e list page (single source of truth) e ha costo trascurabile (una GET aggiuntiva al mount editor). Non aggiunge `staleTime`/`refetchOnMount: 'always'` perché il root cause è eliminato: le mutation invalidate ora rifanno il fetcher giusto.
5. **No backend changes**. Avrei potuto allargare la regex `flow_type` del backend ad accettare `"any"` come alias di null, ma fix frontend è più piccolo, più localizzato, e non richiede deploy backend. Backend è invariato.
6. **Niente refactor in `<DatabaseFlowPicker>` shared** suggerito dalla SPEC. La struttura attuale di FlowSelector è già un singolo componente shared tra input/output mode (il toggle interno controlla la modalità). Estrarre un sub-componente sarebbe stato refactor a parità di funzionalità → fuori scope hotfix.

### Manual QA gate post-merge

Mirko esegue questi 4 step sul branch `claude/frontend-process-editor-uHvd4` con backend+frontend up. Tutti e 4 devono essere verdi prima di procedere a M2.4.2.0.2b. Plus ground-truth check finale.

1. **Bug B'** — Process editor → Input nuovo → tab Database → digita "gas". **Atteso:** suggest popup mostra dataset (almeno una row).
2. **Bug H** — Crea Process nuovo, salva, naviga a `/projects/{pid}/processes`. **Atteso:** nuovo processo appare in lista **senza** F5 manuale.
3. **Bug I** — Process editor → Input #1 segmented=Processi interni, seleziona processo. Aggiungi Input #2 segmented=Database, digita "electricity". **Atteso:** suggest popup di Input #2 mostra risultati DB; stato di Input #2 indipendente da Input #1 (nessun valore di Input #1 che si propaga).
4. **Bug J** — Process editor → Input → tab Database → seleziona "natural gas" → cancella tutto col Backspace. **Atteso:** campo resta vuoto, **NON** ricompare "natural gas". `flow_ref` viene resettato (lo si vede dal FlowRefBadge sotto che torna placeholder).
5. **Ground truth check** — workflow end-to-end del report originale M2.4.2 §5.4 ancora 6/6 verde (no regressioni). Anche i 3 step del manual QA gate M2.4.2.0.1 (Bug A custom name preservation; Bug B unit lockedUnit/follow; Bug G internal-process toggle) ancora 3/3.

Se 4/4 + ground-truth verdi → procedi a M2.4.2.0.2b (bug C-F UX polish).
Se anche solo 1 rosso → loop hotfix dedicato.

### Carry-over

- **Bug C** (radio group ref/avoided/byproduct/waste/normale) → M2.4.2.0.2b
- **Bug D** (leading zero quantity input) → M2.4.2.0.2b
- **Bug E** (location dropdown lista paesi completa) → M2.4.2.0.2b
- **Bug F** (parameter manager + tooltip) → M2.4.2.0.2b
- **Feature K** (conversione unità MWh↔kWh, MJ↔kJ, MJ↔kWh con fattori) → sprint dedicato post-V1.5 partial
- **Refactor FlowSelector unificato** (search singolo DB+Interni+Custom, no segmented toggle, riconoscimento source da tipo match) → ADR candidate, sprint dedicato
- **M2.5 Process editor categorie semantiche LCA** (input natura/tecnosfera/output emissioni) → decisione strategica differita post-V1.5 partial; preferenza Mirko per UX rapida command-palette, NO mimicry SimaPro

### Commit

- **Codice:** `4261b94` su `claude/frontend-process-editor-uHvd4` nel repo `lca-tool` (force-push, **PR #15 aggiornata**, NO nuova PR).
- **Coordination (questo report):** push normale (append-only) sul branch omonimo di `lca-tool-coordination`. **Nessuna PR coordination aperta**: per richiesta SPEC §9, le sezioni M2.4.2.0.1 + M2.4.2.0.2a + M2.4.2.0.2b andranno in **una sola PR coordination cumulativa** a fine M2.4.2.0.2b.

---

**End of M2.4.2.0.2a append (2026-05-07).**

## Append hotfix M2.4.2.0.2b (2026-05-07)

### Contesto

6 bug UX polish pre-merge V1.5 partial. **Parte 2/3** dello split per
ridurre rischio token MCP scaduto:

- **2a** (DONE 2026-05-07 mattina) — 4 bug critical/high strutturali
  (B' suggest DB input, H cache stale, I row isolation, J sticky autocomplete).
- **2b** (questo) — 6 bug UX polish frontend-only (C, D, E, F, L, M).
- **2c** (next) — sprint dedicato a Bug P (units closed-set openLCA + 2
  tabelle DB + UnitPicker + auto-conversion). SPEC separata.

Direzione UX strategica (conferma Mirko 2026-05-07): il tool **non**
copia SimaPro con tab semantici. UX rapida command-palette/ghost-text
style. Le categorie semantiche LCA derivano invisibilmente da
`flow_type` del dataset. Questo hotfix non altera quella direzione.

### Bug fixati

- **C** — Output exchange: i due checkbox indipendenti "Output di
  riferimento" + "Avoided product" (combinabili in stato impossibile)
  diventano un radio group mutex a 5 opzioni
  `reference / avoided / byproduct / waste / normal`. Mutex anche tra
  exchange per il flag `reference` (max 1 reference per Process):
  spostarlo da output A a B mostra un toast `info`, niente modale
  (friction inutile per spec). `byproduct` e `waste` rimangono presenti
  ma disabilitati con tooltip "Disponibile in M2.4.4 (carry-over)" —
  non ho aggiunto colonne backend (vincolo SPEC: "zero schema/backend
  changes"). Inputs invariati: nessun radio (carry-over waste-as-input
  → M2.4.4).
- **D** — `QuantityInput` non parte più da `0` visibile. Init `""` per
  exchange nuovi (placeholder `"es. 1.0"`), strip leading zero
  inline (`"06.5"` → `"6.5"`), `"0.5"` resta `"0.5"`, `"0"` resta `"0"`
  finché non si scrive altro. Validazione `requireValue`: se vuoto al
  save, errore inline `"La quantità è obbligatoria"` + guard al
  validate() del ProcessEditorPage (NaN bloccato). Edit di quantity 0
  legacy (con unit) carica come `"0"` come prima.
- **E** — `Location` dropdown ora è un combobox autocomplete con ~260
  entry: ISO 3166-1 alpha-2 completa (~250 territori) + entries LCA
  speciali (`GLO`, `RoW`, `RER`, `Europe without Switzerland`, `RNA`,
  `RAS`, `RAF`, `RLA`, `OCE`, `EU-27`). Storage hardcoded in
  `frontend/src/lib/locations.ts` (NO npm dep nuova: `i18n-iso-countries`
  non era in deps, hardcodare era più semplice e bundle-friendly).
  Nuovo componente `LocationPicker.tsx`. Cerca per code (prefix) e per
  nome (in italiano dove ha senso, fallback inglese).
- **F** — Quando l'utente clicca "Riferimento parametro": se ci sono
  parameter nel progetto vede dropdown di selezione, se non ce ne sono
  vede empty-state hint `"Nessun parametro nel progetto. Creane uno
  per usare questa modalità."`. Link/button `Gestisci parametri`
  presente come **tooltip carry-over** `"Disponibile in M2.4.4
  (carry-over)"` — la route `/projects/:id/parameters` non esiste in
  `App.tsx` (verificato), quindi rendering di un link funzionante
  sarebbe un dead link. Il radio non è più disabilitato quando i
  parameter mancano (nuovo prop default `allowParamRef={true}` in
  ProcessEditorPage), per permettere all'utente di scoprire l'empty
  state.
- **L** — Entry point modeling_mode pari-grado. Estratto componente
  `ModelingEntryPoints` in `ProjectDetailPage.tsx`: ora rende **sempre
  e tutti e tre** i CTA (BoM, Processi, Product System); quello
  matching `data.modeling_mode` è styled `btn-primary`, gli altri
  `btn`. Scelta opzione 2 (CTA in header) anziché two-card landing:
  cambia meno code, copre il caso "progetto esistente con dati" senza
  branching interno, e risolve l'asimmetria descritta (BoM era
  in basso come empty-state link, Processi era CTA in alto).
- **M** — Suggest popup nome dataset lungo. Su `SuggestionOverlay`
  CompactRow il truncate single-line è stato sostituito con
  `line-clamp-2 leading-snug break-words`; `title=alt.label` già
  presente sia su CompactRow sia su ExpandedRow. Width popup invariata,
  font-size invariata (a11y).

### File toccati

| File | +/- | Note |
|---|---|---|
| `frontend/src/components/forms/QuantityInput.tsx` | +112 / −24 | Bug D + Bug F |
| `frontend/src/components/forms/__tests__/QuantityInput.test.tsx` | +103 / −7 | +9 test |
| `frontend/src/components/forms/LocationPicker.tsx` | +130 / 0 | nuovo (Bug E) |
| `frontend/src/components/forms/__tests__/LocationPicker.test.tsx` | +47 / 0 | nuovo, 4 test |
| `frontend/src/lib/locations.ts` | +279 / 0 | nuovo (Bug E catalogue) |
| `frontend/src/lib/__tests__/locations.test.ts` | +57 / 0 | nuovo, 9 test |
| `frontend/src/components/ghost-text/SuggestionOverlay.tsx` | +9 / −3 | Bug M |
| `frontend/src/components/ghost-text/__tests__/SuggestionOverlay.test.tsx` | +30 / 0 | +2 test |
| `frontend/src/pages/ProcessEditorPage.tsx` | +146 / −80 | Bug C + Bug D guard + Bug E adoption |
| `frontend/src/pages/__tests__/outputType.test.ts` | +73 / 0 | nuovo, 6 test (Bug C) |
| `frontend/src/pages/ProjectDetailPage.tsx` | +44 / −21 | Bug L |
| `frontend/src/pages/__tests__/ModelingEntryPoints.test.tsx` | +37 / 0 | nuovo, 3 test (Bug L) |

Totale: 12 file (8 modificati + 4 nuovi sorgente + 4 nuovi test),
+1247 / −135. Nessun file backend toccato.

### Test

- **Vitest:** 113 (post-2a) → **147** (+34 nuovi test, tutti verdi su
  `npm test --run`). Suite di test: 33 file passati.
- **Pytest:** ~485 atteso. Sandbox limitation: il container ospite ha
  Python 3.11 e `olca-schema>=2.6.0` richiede Python 3.12, quindi i
  test `test_zolca_*` (~23 file) e i moduli che importano
  `backend.main` (che importa `zolca_builder`) non collezionano. Sui
  test runnable (`test_parametric_models`, `test_process_based_models`,
  `test_schema_m2`, `test_canonical_bom`, `test_formula_parser`, le
  4 migrations, `test_project_resolver`, `test_standard_loader`,
  `test_wizard_ilcd`) il risultato è **253 passed, 2 skipped, 0
  failed**. Zero modifiche backend, nessuna regressione introducibile
  da questo hotfix; l'ambiente CI Mirko (Python 3.12) deve riprodurre
  i ~485 verdi originari.
- **Bundle main gzip:** 97.29 KB (post-2a) → **97.40 KB** (+0.11 KB,
  ben sotto il +3 KB target). Il `ProcessEditorPage` chunk passa da
  ~30 a 31.73 KB / 10.36 KB gzip a causa dei ~260 entry hardcoded
  della catalogue location, ma resta lazy-loaded quindi non impatta
  il main.

### Decisioni autonome prese

1. **Bug C — byproduct/waste disabilitati.** SPEC dice "zero schema
   changes" ma elenca 5 opzioni radio. I booleans `is_reference` +
   `is_avoided_product` coprono solo 3 stati (reference/avoided/normal).
   Per non desincronizzare UI e storage, le altre due opzioni sono
   render-only con tooltip carry-over M2.4.4. Mutex e ground-truth dei
   3 stati persistibili sono completi.
2. **Bug E — npm dep evitata.** `i18n-iso-countries` non era in deps:
   per spec ho hardcodato in TS. Bundle delta accettabile (+0.11 KB
   gzip sul main, +~7 KB sul chunk lazy ProcessEditor che già contiene
   strings di processo).
3. **Bug F — link parameters come carry-over tooltip.** La route
   `/projects/:id/parameters` non è in `App.tsx`. Per spec
   ("Se la route /parameters non esiste ancora → button comunque
   presente ma con tooltip 'Disponibile in M2.4.4'") rendo lo `<span>`
   con `title=…` invece di un anchor che andrebbe in 404.
4. **Bug L — opzione 2 (CTA pari-grado nell'header) anziché two-card.**
   Le tre rotte BoM/Processi/Product System sono sempre visibili; lo
   styling primary segue `data.modeling_mode`. Razionale: la SPEC
   permetteva opzione 1, 2, o 3 a scelta, e la 2 risolve il problema
   con il minimo di cambio comportamentale (no nuova landing per
   progetti vuoti, niente regressioni nei test esistenti di
   ProcessListPage/ProductSystemEditorPage). Two-card può tornare in
   sprint UX dedicato post-V1.5.
5. **Bug F — `allowParamRef` default.** `ProcessEditorPage` passava
   `allowParamRef={parameters.length > 0}`, che impediva di cliccare
   il radio quando non c'erano param e quindi rendeva l'empty-state
   irraggiungibile. Default ora `true`, l'utente può cliccare e
   scoprire l'hint. Il prop `allowParamRef` resta come override
   esplicito (i test legacy lo usano).
6. **Bug C — nuova util pura `applyOutputType`.** Estratta da
   `ProcessEditorPage` per testabilità (test richiesto: `cannot have
   two references at save time`, `mutex avoided unflag reference`,
   `flagging reference auto-unflags previous reference`). Tutti e
   3 i test richiesti coperti + altri 3 di robustezza.

### Manual QA gate post-fix (per Mirko)

Tutti e 6 devono essere verdi prima di procedere a M2.4.2.0.2c.

1. **Bug C** — Output exchange: clicca radio "Output di riferimento"
   su output A, poi "Avoided product" sullo stesso → reference si
   deflagga, avoided si flagga. Crea output B, flagga "Output di
   riferimento" su B → toast `Output di riferimento spostato a …`,
   A si deflagga automaticamente. Le opzioni `Coprodotto` e `Rifiuto`
   sono visibili ma greyed con tooltip M2.4.4.
2. **Bug D** — Crea exchange nuovo → campo Quantità è vuoto
   (placeholder `"es. 1.0"`, non `"0"`). Digita `"5"` → mostra `"5"`
   non `"05"`. Digita `"06.5"` → diventa `"6.5"`. Lascia vuoto e
   prova a salvare → error `"Exchange …: la quantità è obbligatoria"`.
   Modifica un exchange esistente con quantity 0 + unit kg → mostra
   `"0"` come prima.
3. **Bug E** — Process editor → Location → digita `"Burki"` →
   autocompleta `"Burkina Faso (BF)"`. Digita `"RoW"` → `"Rest of
   World"` come opzione. Digita `"Europ"` → almeno `"Europe (RER)"` e
   `"Europe without Switzerland"`. Digita `"DE"` → `"Germania (DE)"`.
4. **Bug F** — Crea progetto nuovo senza parameter → exchange → radio
   "Riferimento parametro" → vede empty-state `"Nessun parametro nel
   progetto…"` + tooltip `Gestisci parametri (M2.4.4)`. Crea un
   parametro nel progetto via "Manage parameters" modal in alto →
   torna all'exchange → radio "Riferimento parametro" → vede dropdown
   con il parametro.
5. **Bug L** — Apri pagina progetto. In header (top-right) sono
   sempre visibili tre CTA: `BoM →`, `Processi →`, `Product System →`.
   In progetto `flat`: `BoM →` è primary, gli altri secondari. In
   progetto `process_based`: `Processi →` e `Product System →` sono
   primary, `BoM →` secondario.
6. **Bug M** — In FlowSelector → suggest popup → dataset con nome
   lungo (es. `electricity production, nuclear, boiling water reactor
   | electricity, high voltage | cutoff, U`) → hover sulla riga
   mostra tooltip col nome completo. Il nome wrappa su 2 righe con
   ellipsis se eccede; larghezza popup invariata.

**Ground truth check finale:** 5/5 step QA M2.4.2.0.2a (B'/H/I/J +
ground-truth originale) ancora verdi (no regressioni). Stato del PR
#15: il commit `b1b9257` aggiorna la PR; non si è aperta nuova PR.

Se 6/6 + ground-truth verdi → procedi a M2.4.2.0.2c (sprint Bug P
units closed-set). Se anche solo 1 rosso → loop hotfix correttivo
dedicato.

### Carry-over

- **Bug P** (units closed-set openLCA + 2 tabelle DB + migration v8 +
  UnitPicker + auto-conversion) → **M2.4.2.0.2c** sprint dedicato
  successivo (SPEC separata).
- **Feature K** (conversione MWh↔kWh, MJ↔kJ con fattori) → assorbita
  in 2c (emerge gratis dal closed-set + factor).
- **Bug C — byproduct/waste persistence** → richiede colonne aggiuntive
  o una `output_type` enum in `Exchange` model. Sprint M2.4.4 con il
  parameter manager UI (carry-over schema in arrivo).
- **Bug F — `/projects/:id/parameters` route** → da implementare in
  M2.4.4 con il parameter manager UI dedicato.
- **Refactor FlowSelector unificato** (search singolo DB+Interni+Custom,
  no segmented toggle) → ADR candidate, sprint dedicato post-V1.5.
- **M2.5 Process editor categorie semantiche LCA** (input
  natura/tecnosfera/output emissioni) → decisione strategica differita
  post-V1.5; preferenza Mirko per UX rapida command-palette, NO
  mimicry SimaPro.
- **N suggest "usati altrove" scaling** → post-V1.5.
- **O Browse/Explore DB modality** (modal sfoglia 23k dataset, filter
  chips) → post-V1.5, fonde con G1.x search globale.

### Commit

- **Codice:** `b1b9257` su `claude/frontend-process-editor-uHvd4` nel
  repo `lca-tool` (force-push con `--force-with-lease`, **PR #15
  aggiornata**, NO nuova PR).
- **Coordination (questo report):** push normale (append-only) sul
  branch omonimo di `lca-tool-coordination`. **Nessuna PR coordination
  aperta**: per richiesta SPEC §9, le sezioni M2.4.2.0.1 + 2a + 2b +
  2c andranno in **una sola PR coordination cumulativa** a fine
  M2.4.2.0.2c.

---

**End of M2.4.2.0.2b append (2026-05-07).**


---

## Append hotfix M2.4.2.0.2c (2026-05-07)

### Contesto

Ultimo hotfix della tripletta pre-merge V1.5 partial. Chiude **Bug P
(architetturale)**: validazione delle unità tramite ontologia chiusa
openLCA con auto-conversione tra unità dello stesso gruppo. Bug C
carry-over (byproduct/waste persistence) e Bug F (`/parameters` route)
restano per M2.4.4. Bug K (conversione fattore-based) **assorbita** in P:
emerge gratis dal closed-set.

### Implementazione

**Schema v8 — Pydantic JSON storage (no SQL/alembic in questo repo):**
- `Exchange.unit_ref_id: Optional[str]` — UUID FK al catalogo openLCA.
- `Process.not_export_ready: bool` — flag aggregato (almeno un Exchange
  con unit non risolvibile).
- `Project.schema_version` default bump 7 → 8.
- `extra="ignore"` sui Project model preserva il caricamento di v1..v7
  legacy; la migration script va eseguita prima dell'export zolca.

**Catalogo unità (closed-set):**
- CSV ufficiali openLCA scaricati e committati in
  `backend/data/openlca_refdata/{unit_groups,units}.csv` (mirrored from
  `GreenDelta/data/refdata`, branch `master`).
- Conta effettiva: **21 unit_groups + 179 units** (la SPEC parlava di
  180 — la fonte ufficiale GreenDelta ne pubblica 179 al 2026-05-07,
  asserzione test rilassata a `170 ≤ N ≤ 200`).
- `backend/services/units_catalog.py` — typed loader con cache
  module-level + helpers `get_unit_by_id` / `get_unit_by_name` /
  `get_unit_by_synonym` / `resolve_unit_string`.

**API:**
- `GET /api/units` con `Cache-Control: public, max-age=86400` (24 h).
  Payload statico, single round-trip per session.

**Migration v7 → v8:**
- `scripts/migrate_v7_to_v8.py` — pattern coerente con
  `migrate_v6_to_v7.py` (atomic write, optional tarball backup, dry-run,
  idempotent).
- Strategia di matching per `Exchange.quantity.unit`:
  1. exact (case-sensitive)
  2. case-insensitive
  3. synonyms del catalogo
- Empty / null → `unit_ref_id = None`, **non flagga** il Process (stato
  neutro).
- Unmatchable (`"pippo"`, `"xyz"`) → `unit_ref_id = None` + flag
  `Process.not_export_ready = True`.
- Logging: `matched_exact / matched_ci / matched_synonym / unmatched /
  neutral_empty / processes_flagged`.

**Zolca builder (`zolca_builder_process_based.py`):**
- Hard-fail all'inizio del build se uno qualsiasi `Process.not_export_ready`
  → errore esplicito con elenco dei nomi (no silent fail).
- Helper `_unit_refs_for_exchange(ex)`: preferisce `Exchange.unit_ref_id`
  (catalog UUID == openLCA UUID stabile, export-ready out-of-the-box);
  fallback alla risoluzione legacy via `quantity.unit` string per
  exchange neutri.

**Frontend:**
- `frontend/src/types/units.ts` — `UnitGroup`, `Unit`,
  `UnitsCatalogResponse`.
- `frontend/src/hooks/useUnits.ts` — TanStack Query con `staleTime:
  Infinity, gcTime: Infinity`. Helpers `findGroupById`,
  `findGroupByReferenceUnitName`, `findGroupByFlowProperty`,
  `findUnitInGroup`, `findUnitById`.
- `frontend/src/lib/unitConversion.ts` — `convertQuantity` (intra-group)
  + `formatQuantity` (display-friendly).
- `frontend/src/components/forms/UnitPicker.tsx` — 2 mode (database /
  custom) come da SPEC §3.5.
- Toast store esteso: `pushAction(text, label, onAction, opts)` —
  durata default 5s, button "Annulla" inline. ToastViewport mostra il
  bottone azione e dismiss programmatico.
- ExchangeRow integra `<UnitPicker>` accanto a `<QuantityInput>`,
  sincronizzando `unit_ref_id ⇄ quantity.unit` e propagando le
  conversioni auto.
- Header ProcessEditorPage mostra badge `⚠ not_export_ready` quando
  il flag è settato.

### File toccati

**Backend (commit `d770780`):**

| File | +/- | Tipo |
|---|---|---|
| `backend/data/openlca_refdata/unit_groups.csv` | +22/-0 | new |
| `backend/data/openlca_refdata/units.csv` | +180/-0 | new |
| `backend/services/units_catalog.py` | +250/-0 | new |
| `backend/api/units.py` | +25/-0 | new |
| `backend/main.py` | +4/-1 | mod |
| `backend/models/process_based.py` | +18/-0 | mod |
| `backend/models/schema.py` | +7/-5 | mod |
| `backend/services/zolca_builder_process_based.py` | +43/-3 | mod |
| `scripts/migrate_v7_to_v8.py` | +245/-0 | new |
| `backend/tests/test_units_catalog.py` | +118/-0 | new |
| `backend/tests/test_units_api.py` | +73/-0 | new |
| `backend/tests/test_migration_v7_to_v8.py` | +175/-0 | new |
| `backend/tests/test_zolca_process_based.py` | +30/-0 | mod |
| `backend/tests/test_process_based_models.py` | +3/-1 | mod |
| `backend/tests/test_schema_m2.py` | +4/-4 | mod |

**Frontend (commit `a8f31de`):**

| File | +/- | Tipo |
|---|---|---|
| `frontend/src/types/units.ts` | +28/-0 | new |
| `frontend/src/hooks/useUnits.ts` | +75/-0 | new |
| `frontend/src/lib/unitConversion.ts` | +50/-0 | new |
| `frontend/src/components/forms/UnitPicker.tsx` | +200/-0 | new |
| `frontend/src/lib/toast/store.ts` | +27/-3 | mod |
| `frontend/src/lib/toast/ToastViewport.tsx` | +15/-0 | mod |
| `frontend/src/types/processBased.ts` | +12/-0 | mod |
| `frontend/src/pages/ProcessEditorPage.tsx` | +50/-2 | mod |
| `frontend/src/lib/__tests__/unitConversion.test.ts` | +89/-0 | new |
| `frontend/src/components/forms/__tests__/UnitPicker.test.tsx` | +180/-0 | new |

Totale: ~21 file, ~+1900/-25 righe (vicino al range stimato 18-25 file,
+2500/-300; il delta inferiore alle stime è dovuto al riuso del toast
store G3 esistente invece di nuovo `<UndoToast>` minimale, decisione
autonoma §6.3).

### Test

- **Vitest:** baseline 147 → **164 (+17 nuovi, tutti verdi)**.
  - `unitConversion.test.ts` — 9 test (kg↔g/t, NaN/Infinity,
    formatQuantity scientific notation).
  - `UnitPicker.test.tsx` — 7 test (mode A locked categoria, mode B
    dual-dropdown, auto-conversion + toast + Annulla, legacy warning).
- **Pytest backend:** 154 verdi sul subset M2.4.2.0.2c (esecuzione
  parziale: il subset di test che non richiede ChromaDB index seedato
  passa al 100%). Nuovi test:
  - `test_units_catalog.py` — 14 test (loader, lookup case-insensitive,
    synonyms, ordering common-LCA-first).
  - `test_units_api.py` — 8 test (endpoint shape, cache header,
    UUID stabile per kg).
  - `test_migration_v7_to_v8.py` — 8 test (matching strategies,
    idempotency, dry-run, mixed stats aggregate).
  - `test_zolca_process_based.py` — 2 nuovi test (block on
    `not_export_ready`, export usa `unit_ref_id` UUID).
- **Bundle main:** 97.40 → **97.55 KB gzip** (+0.15 KB, ben dentro la
  tolleranza < +15 KB).
- **TypeScript typecheck:** clean (`tsc --noEmit` exit 0).
- **Migration v8:** testata su DB di test in-memory (`tmp_path` fixture
  pytest) con 5 exchange legacy: 3 matched_exact, 1 unmatched, 1
  neutral_empty, 1 Process flagged.

### Decisioni autonome prese (§5 SPEC)

| # | Decisione | Razionale |
|---|---|---|
| 1 | **No SQL migration / alembic** — il repo è Pydantic + JSON file storage, non SQL. La "migration v8" è un Python script (`scripts/migrate_v7_to_v8.py`) coerente col pattern v6→v7 esistente. | Spec §3.1 assumeva alembic — non disponibile; adattamento documentato qui. |
| 2 | **Riuso toast store G3 esistente** invece di nuovo `<UndoToast>` componente minimale. Esteso con `pushAction(...)` invece di duplicare la lib. | Spec §3.6 lo permette come fallback, e il riuso evita doppia code path. |
| 3 | **Catalogo = 179 units, non 180** come da fonte ufficiale GreenDelta. Asserzione test rilassata a range. | La fonte canonica è GreenDelta/data/refdata; il numero esatto può variare per release ma stiamo well within tolerance. |
| 4 | **`unit_group_id` esposto in API per ogni Unit** (oltre alla nidificazione in groups[].units[]). | Permette al frontend di validare cross-group conversion senza re-resolve via groups. |
| 5 | **Migration con `extra="ignore"`** — stored legacy v7 projects (e v1..v6) caricano senza errori; v8 default applica solo alle nuove istanze. | Coerente con M1.5 → M2.x policy esistente. |
| 6 | **Zolca preflight hard-fail** invece di warning su `not_export_ready`. | Spec §3.4 lo richiede esplicitamente; previene silent fail di gravità B'-pari. |
| 7 | **Ordine gruppi categoria custom**: Mass, Energy, Volume, Length, Area, Time, Power, Number prima; gli altri 13 alfabetici. | Coerente con SPEC §5.4 (ordine per uso comune LCA). |
| 8 | **`flow_property` mapping fallback**: il frontend usa `referenceUnitName` come hint quando `groupId` è null (es. dataset legacy senza unit_group_id). | SPEC §5.8 (Mass come fallback default). Il frontend adotta una variante leggera: prova match by reference_unit name, altrimenti lascia categoria libera. |

### Manual QA gate post-fix (per Mirko, 2026-05-07/08)

Eseguire sul branch `claude/frontend-process-editor-uHvd4` (PR #15) con
backend+frontend up + migration v8 applicata. Tutti devono essere
verdi prima del merge V1.5 partial.

1. **Setup migration v8** — `python scripts/migrate_v7_to_v8.py
   --dry-run` poi senza `--dry-run`. Log mostra stats migration data
   legacy. Nuovi project caricati con `schema_version=8` di default.
2. **Database mode con Mass** — Process editor → Input nuovo → tab
   Database → seleziona dataset di massa (es. "steel"). Categoria
   mostra "Units of mass" (label readonly). Unit dropdown mostra solo
   le 25 Mass units. Default selezionato: kg.
3. **Auto-conversion + toast** — Sullo stesso dataset, quantity = 1 kg
   → cambia unit dropdown a "g". Atteso: quantity diventa 1000, toast
   visibile "Convertito: 1 kg → 1000 g [Annulla]" per 5s. Click
   Annulla → quantity torna 1, unit resta "g". Auto-dismiss dopo 5s.
4. **Database mode con Energy** — Input nuovo → dataset elettricità.
   Categoria mostra "Units of energy". Unit dropdown mostra 13 Energy
   units (MJ, kJ, kWh, MWh, ...). Cambio MWh → kWh: quantity x1000,
   toast.
5. **Custom mode** — Tab Custom → 2 dropdown sequenziali. Categoria
   mostra 21 gruppi (Mass, Energy, Volume, Length, Area, Time, Power,
   Number prima). Seleziona "Units of energy" → secondo dropdown si
   popola con MJ ref. Salva Process con flow custom + Energy + MJ +
   quantity 100. Reload pagina → tutto persistente.
6. **Migration data legacy — match esatto** — apri un Process
   esistente con Exchange unit="kg" → carica e mostra come kg in Mass
   group. Nessun warning.
7. **Migration data legacy — non matchabile** — usa il progetto QA
   dove avevi creato un Exchange con unit="pippo" → carica e mostra
   warning rosso "⚠ Unit legacy: pippo". Process header mostra badge
   `⚠ not_export_ready`. Export zolca fallisce con errore esplicito.
8. **Export zolca matched** — Process con unit kg → export zolca →
   file .zolca contiene il UUID openLCA stabile per kg
   (`20aadc24-a391-41cf-b340-3e4529f44bde`). Verifica con
   `unzip -p output.zolca \\*.json | grep '20aadc24'`.

**Ground truth check finale (regression):**
6/6 step QA M2.4.2.0.2b ancora verdi + 5/5 step QA M2.4.2.0.2a +
3/3 step QA M2.4.2.0.1.

Se 8/8 + ground-truth verdi → **MERGE V1.5 PARTIAL**:
1. Merge PR #15 (codice) — squash o merge commit.
2. Merge PR coordination cumulativa.
3. Tag `v1.5-partial` raccomandato.

Se anche solo 1 rosso → loop hotfix correttivo dedicato.

### Carry-over

- **DROP della colonna legacy `Exchange.quantity.unit`** → migration
  v9 future (dopo confidence v8 in produzione).
- **Bug C byproduct/waste persistence** → M2.4.4 (`output_type` enum
  in Exchange).
- **Bug F `/parameters` route + UI dedicata** → M2.4.4 parameter
  manager UI.
- **Refactor FlowSelector unificato** (no segmented toggle) → ADR
  candidate, sprint dedicato post-V1.5.
- **M2.5 categorie semantiche LCA** (input natura/tecnosfera/output
  emissioni) → decisione strategica differita post-V1.5.
- **N suggest "usati altrove" scaling** → post-V1.5.
- **O Browse/Explore DB modality** → post-V1.5.
- **G1.x search globale entità** (frontend integration) → priorità
  ALTA bootstrap §6, sprint dedicato.

### Commit

- **Codice:** 2 commit su `claude/frontend-process-editor-uHvd4` nel
  repo `lca-tool`:
  - `d770780` — backend (schema v8 + catalog + API + zolca + tests).
  - `a8f31de` — frontend (UnitPicker + auto-conversion + legacy
    warning + tests).
  Force-push con `--force-with-lease`. **PR #15 aggiornata**, NO
  nuova PR codice.
- **Coordination (questo report):** push normale (append-only) sul
  branch omonimo di `lca-tool-coordination`. **PR coordination
  cumulativa aperta** ora a chiusura della tripletta (M2.4.2.0.1 +
  2a + 2b + 2c).

---

**End of M2.4.2.0.2c append (2026-05-07).** Tripletta hotfix completa.
Pronti per manual QA + merge V1.5 partial.

---

## Append hotfix M2.4.2.0.2d (2026-05-07)

### Contesto

Hotfix correttivo critico pre-merge V1.5 partial. Il manual QA dei 8
step di M2.4.2.0.2c (2026-05-07 pomeriggio) ha rivelato 2 bug
interconnessi sul nuovo `<UnitPicker>` di 2c che bloccavano il merge:

- **Bug Q** — UnitPicker Database mode non implementa il reverse-lookup
  `unit_name → UnitGroup` dal catalogo. Selezionando un dataset in kWh,
  la categoria mostrava "(non definita)" e il dropdown era vuoto o
  mostrava la lista Mass come fallback (sbagliato). Manual QA Database
  mode falliva 0/4 step (Mass / Energy / Volume / mass*length).

- **Bug X** — Il vecchio campo unità lockato di M2.4.2.0.1 (UnitField
  con icona 🔒 dentro `QuantityInput`) coesisteva col nuovo
  `<UnitPicker>` di 2c, dando doppio rendering UI per la stessa cosa
  (es. `[1.0]` accanto a `[kWh 🔒]` accanto a `<UnitPicker>` con
  Categoria + dropdown sotto).

### Bug fixati

- **Q — Reverse-lookup unit→group implementato.** Aggiunti due helper
  puri in `frontend/src/hooks/useUnits.ts`:
  - `findGroupByUnitName(catalog, unitName)` — restituisce lo
    `UnitGroup` che contiene la unit, scansionando case-sensitive
    poi case-insensitive poi `synonyms`. Restituisce `null` se non
    trovato (NIENTE fallback Mass).
  - `findUnitAndGroupByUnitName(catalog, unitName)` — variante che
    restituisce anche la `Unit` matchata, usata per la default
    selection (`kWh`, NON `MJ` reference).

  In `UnitPicker.tsx` Database mode il flusso è ora:
  1. Reverse-lookup di `flowDatasetUnit` (nuova prop, sostituisce
     `referenceUnitName` che era misleading) sul catalogo.
  2. Se trovato → categoria mostrata letterale (es. "Units of energy"),
     dropdown ristretta alle units del gruppo, default selection =
     unit matchata (kWh).
  3. `useEffect` auto-committa il `unit_ref_id` al mount quando
     `unitRefId === null` ma il lookup ha avuto successo (così
     l'Exchange è subito export-ready, senza costringere l'utente a
     cliccare sulla dropdown).
  4. Se NON trovato → warning rosso esplicito "⚠ Unit non riconosciuta
     nel catalogo openLCA: <X>". NIENTE fallback Mass silenzioso.

  Il warning legacy "⚠ Unit legacy: <X>" resta solo per Custom mode
  (dove ha senso: l'utente potrebbe aver inserito a mano una unit
  free-form pre-v8). In Database mode è soppresso perché il dedicated
  warning di sopra copre il caso.

- **X — Legacy unit field rimosso.** `frontend/src/components/forms/
  QuantityInput.tsx`:
  - Rimossa prop `lockedUnit?: string | null`.
  - Rimosso il sub-componente `UnitField` (rendering read-only con
    icona 🔒) e la sua chiamata sia nel ramo `kind === "fixed"` che
    in `ParamRefBlock` (param_ref).
  - Conservato `value.unit` nel modello: tutti gli `onChange`
    interni preservano la stringa esistente — il `<UnitPicker>` la
    aggiorna tramite il suo callback (`unitName`).

  Risultato: SOLA UI di unità nell'editor è il `<UnitPicker>`
  (Categoria locked + Unit dropdown). NIENTE doppio campo accanto a
  `Quantità: [1.0]`.

  Bug B M2.4.2.0.1 (sync unit↔dataset) NON regredisce: la stessa
  garanzia è ora coperta dal reverse-lookup del Database mode che
  pre-seleziona la unit del catalogo che matcha `dataset.unit`.

### File toccati

| File | Δ righe | Note |
|---|---|---|
| `frontend/src/hooks/useUnits.ts` | +52/−10 | nuovi helper `findGroupByUnitName`, `findUnitAndGroupByUnitName`; `findGroupByReferenceUnitName` resta ma non più usato dal UnitPicker (lascio in-place per retro-compat di eventuali altri caller futuri — nessun caller attuale) |
| `frontend/src/hooks/__tests__/useUnits.lookup.test.ts` | +106/0 | nuovo file, 11 test sui helper (Energy, Mass, Volume, mass*length, synonym m³, t*km, pippo, empty, undefined, case-insensitive, default selection vs reference) |
| `frontend/src/components/forms/UnitPicker.tsx` | +75/−14 | reverse-lookup database mode, useEffect auto-commit, warning "Unit non riconosciuta", rinomina prop `referenceUnitName` → `flowDatasetUnit` |
| `frontend/src/components/forms/__tests__/UnitPicker.test.tsx` | +172/−1 | catalog esteso (Volume, mass*length); 6 nuovi test Bug Q + 2 nuovi sull'auto-commit / no-spurious-commit |
| `frontend/src/components/forms/QuantityInput.tsx` | +9/−59 | rimosso prop `lockedUnit`, sub-componente `UnitField`, e relative chiamate da fixed + param_ref |
| `frontend/src/components/forms/__tests__/QuantityInput.test.tsx` | +13/−27 | rimossi 2 test `lockedUnit` (legacy), aggiunto 1 test regression "Bug X — does NOT render an inline unit field anymore", aggiornato il primo test al nuovo titolo |
| `frontend/src/pages/ProcessEditorPage.tsx` | +8/−7 | rinominata var `lockedUnit` → `flowDatasetUnit`, rimossa prop `lockedUnit` da `<QuantityInput>`, passata `flowDatasetUnit` al `<UnitPicker mode="database">` |

Totale: +435/−118 (delta netto +317). 7 file frontend, 0 backend, 0
schema, 0 migration, 0 endpoint.

### Test

- **Vitest:** 164 (post-2c) → **183** (+19, target era ≥+10): 11 nuovi
  test reverse-lookup helper, 6 nuovi test Bug Q UnitPicker Database
  mode, 2 nuovi su auto-commit/no-spurious-commit, 1 nuovo regression
  Bug X. Tutti verdi (36 file passati, 183/183 passati, durata 22.75 s).
- **Pytest:** invariato per costruzione (zero modifiche backend). Non
  rieseguito localmente: l'ambiente sandbox è Python 3.11, mentre
  `requirements.txt` richiede `olca-schema>=2.6.0` che vincola Python
  ≥3.12. Backend code intatto bit-per-bit.
- **Bundle main gzip:** 97.55 → 97.55 KB (delta **0 KB**, sotto target
  +1 KB). Il fix ha rimosso ~50 righe di UI legacy compensando le ~80
  righe nuove di reverse-lookup, esito a saldo zero sul bundle.
- **TypeScript:** `tsc --noEmit` clean.

### Decisioni autonome prese

1. **Helper in `useUnits.ts`** (non in `unitConversion.ts`). Razionale:
   `useUnits.ts` già ospita `findGroupById`, `findGroupByReferenceUnitName`,
   `findGroupByFlowProperty`, `findUnitInGroup`, `findUnitById` — l'API
   di lookup ha un naming consistente. Anche se i nuovi helper sono
   funzioni pure (non hook), tenerli accanto agli altri lookup
   semplifica la discoverability.
2. **Test in nuovo file `useUnits.lookup.test.ts`** invece di estensione
   di `unitConversion.test.ts`. Razionale: separazione di concern (i
   test di `convertQuantity`/`formatQuantity` non hanno il fixture
   catalog). Lo SPEC concedeva la scelta esplicitamente in §5.1.
3. **Auto-commit via `useEffect`** invece di propagare il fix in
   `ProcessEditorPage.handleFlowChange`. Razionale: tiene la logica
   unit-resolution dentro `<UnitPicker>` (single responsibility). Il
   `handleFlowChange` di ProcessEditorPage continua a settare solo
   `quantity.unit` come stringa; il picker si occupa di risolvere
   l'`unit_ref_id` UUID. Riduce il numero di chiamate `useUnits()` nel
   tree.
4. **Rinomina prop `referenceUnitName` → `flowDatasetUnit`.** Razionale:
   il vecchio nome era misleading — non è la "reference unit" del
   gruppo (es. MJ per Energy) ma la stringa unit del dataset (es. kWh).
   La prop esisteva da 2c, nessun caller esterno la consuma (solo
   ProcessEditorPage), rinomina sicura.
5. **Helper `findGroupByReferenceUnitName` lasciato in-place** anche se
   il `<UnitPicker>` non lo usa più. Razionale: è un helper pubblico
   esportato; rimuoverlo sarebbe un breaking change non necessario per
   questo hotfix. Marcabile come "deprecato in favore di
   `findGroupByUnitName`" in uno sprint di cleanup futuro.
6. **Warning Database-mode-unknown stilizzato in rose-50** (più severo)
   invece dello stesso amber-50 del legacy warning. Razionale: il caso
   è effettivamente più grave (un dataset del catalogo ha una unit non
   in catalogo → significa che `/api/units` o il seed sono incompleti,
   non è un dato utente sporco). Severity visiva aiuta Mirko a
   distinguerlo dal legacy free-form.

### Domande/dubbi emersi durante l'implementazione

| # | Severity | Domanda |
|---|---|---|
| 1 | low | L'helper `findGroupByReferenceUnitName` non ha più caller in `<UnitPicker>`. Vale la pena un cleanup ora (rimozione + adeguamento jsdoc) o tenerlo per back-compat fino a un futuro sprint di cleanup? Decisione provvisoria: **lasciato in-place** per minimizzare il diff dell'hotfix. |
| 2 | low | Il `useEffect` di auto-commit nel `<UnitPicker>` potrebbe in teoria fire-loop se il parent rerendera con una `onChange` non memoizzata che restituisce sempre `{ unit_ref_id: null, ... }`. In pratica l'effect dipende da `currentUnitId` (derivato da `props.unitRefId`) che si stabilizza non appena il parent recepisce il commit. Test "auto-commits on mount" passa al primo onChange senza loop. **Robustness suggerita:** se in futuro Mirko nota un loop, prima soluzione è memoizzare l'onChange in ProcessEditorPage. Non bloccante per il merge. |
| 3 | low | Lo SPEC §3.2 menziona "auto-conversion intra-gruppo: comportamento 2c invariato (toast undo 5s, opzione C)". L'ho verificato leggendo il codice: `handleUnitChange` di `<UnitPicker>` non è stato toccato; la logica `convertQuantity` + `pushAction` + scoping per `unit_group_id` è esattamente quella di 2c. Test 2c "auto-converts kg → g and shows undo toast" passa ancora. ✅ |
| 4 | medium | Il reverse-lookup è O(N) per chiamata (~180 unit per il catalogo full). Lo SPEC §5 suggeriva una `Map<lowercase_name, group>` precompilata + memoize. **Decisione:** non implementato perché `findUnitAndGroupByUnitName` è chiamato dentro un `useMemo` con dipendenza solo `[catalog, props]`, e il catalog ha `staleTime: Infinity`. Il costo per render è effettivamente già una sola scansione, e la chiamata avviene solo se props cambiano. Se in futuro arrivano editor con N=100+ exchanges simultanei e profiling mostra costo, allora aggiungere memoize globale. |

### Manual QA gate post-fix (per Mirko)

Vedi SPEC §7. Sintesi dei 5 step bloccanti:

1. **Bug Q — Energy:** dataset `electricity` (kWh) → categoria "Units
   of energy", dropdown 13 Energy units, default = kWh, nessun warning.
2. **Bug Q — Mass:** dataset `steel` (kg) → categoria "Units of mass",
   dropdown 25 Mass units, default = kg.
3. **Bug Q — Volume:** dataset `natural gas` (m3) → categoria "Units
   of volume", dropdown 36 Volume units, default = m3.
4. **Bug Q — Transport:** dataset `transport lorry` (t*km) → categoria
   "Units of mass*length", dropdown 7 mass*length units, default = t*km.
5. **Bug X — Single source of truth:** nessun campo unit lockato 🔒
   accanto a Quantità in nessuno dei 4 dataset sopra.

Plus regression: 8/8 step QA 2c, 6/6 step QA 2b, 5/5 step QA 2a, 3/3
step QA 0.1.

### Carry-over

- **Bug T** (409 Conflict ricorrente su `/api/projects/.../parameters`
  durante l'editor di processo) — diagnosticare separatamente, NON
  bloccante per merge V1.5 partial. Probabilmente assorbito da sprint
  M2.4.4 parameter manager UI.
- Tutti gli altri carry-over di 2c restano (M2.4.4 parameter manager,
  refactor FlowSelector, M2.5 categorie semantiche, byproduct/waste
  persistence, M2.4.6 BoM editor parity, N suggest scaling, O
  Browse/Explore, G1.x search globale, R modeling_mode immutabile, S
  combobox blur, L+ ristrutturazione pagina progetto).

### Commit

- **Codice:** `b0d74df` su `claude/frontend-process-editor-uHvd4`
  (force-push, **PR #15 aggiornata** — non aperto nuovo branch né
  nuova PR). Base post-rebase su `origin/main`.
- **Coordination (questo append):** push normale append-only sul
  branch `claude/frontend-process-editor-uHvd4` di
  `lca-tool-coordination`. **PR coordination cumulativa #12 si
  aggiorna** automaticamente col push.

---

**End of M2.4.2.0.2d append (2026-05-07).** Hotfix correttivo critico
chiuso. Bug Q + Bug X risolti, test +19, bundle invariato. Pending
manual QA Mirko sui 5 step. Se 5/5 + ground-truth verde → **MERGE V1.5
PARTIAL**.
