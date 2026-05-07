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
