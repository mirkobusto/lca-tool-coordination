# REPORT M2.4.0 — Process-based modeling foundation (sub-sprint 1 of 4)

**Sprint:** M2.4.0 (foundation) — first of a planned 4-step chain
**Branch codice:** `night/M2.4.0-schema-and-process-model`
**PR codice:** https://github.com/mirkobusto/lca-tool/pull/12
**Branch coordination:** `claude/m2.4.0-report`
**Data:** 2026-05-06
**Stima:** ~3-4 giorni di lavoro logico (vs ~3 settimane stimate per il M2.4 monolitico)

---

## 1. Scope split — perché M2.4.0 e non M2.4 monolitico

La SPEC M2.4 originale autorizzava esplicitamente lo split spontaneo se lo sprint fosse "troppo grosso per un commit unico (file diff > 5000 righe, scope troppo ampio per una singola review)". Ho applicato lo split per due ragioni concrete:

1. **Scope tecnico irrealistico in singola sessione.** Il monolite richiede:
   - schema v6→v7 (backend)
   - 6 nuovi model pydantic + migration (backend)
   - 10+ endpoint CRUD (backend)
   - estensione ChromaDB con ~1500-3000 elementary flows + embeddings (backend, lento ~5-15min)
   - Process editor + ProductSystem editor + FlowSelector + PreWizard (frontend, ~2000-3000 LOC TS/TSX)
   - 20+ vitest test
   - 15+ pytest test
   - rewrite zolca_builder per process-based mode
   - empirico round-trip openLCA Desktop

   Anche con delegazione aggressiva agli agenti, produrre tutto ciò *con verifica reale* (build TS, test green, bundle delta misurato) in una singola sessione avrebbe prodotto codice non testato di quantità non revisionabile (>5000 righe diff). La SPEC esige `vitest +>=20 pass`, `pytest +>=15 pass`, `bundle delta <= +25 KB gzip` — claim che non posso fare onestamente senza eseguire la pipeline completa.

2. **Foundation prima, costruzione sopra.** I sub-sprint M2.4.1+ dipendono dal modello dati. Spedire prima la foundation (schema + migration) consente:
   - revisione mirata di Mirko sul modello dati (decisione architetturale chiave)
   - manual QA del migration prima di merge (idempotenza, --cleanup-smoke comportamento atteso)
   - possibilità di iterare sul modello prima di costruire frontend e zolca builder sopra

Catena pianificata:

| Sub-sprint | Scope | Stato |
|------------|-------|-------|
| **M2.4.0** | Schema v7 + Process model backend + migration + tests | **questa PR** |
| M2.4.1 | API CRUD Process / Exchange / ProductSystemV2 + tests | carry-over |
| M2.4.2 | Frontend Process editor + FlowSelector + ProductSystem editor | carry-over |
| M2.4.3 | ChromaDB elementary flows + zolca builder rewrite + integration test | carry-over |

---

## 2. Cosa contiene M2.4.0 (questa PR)

### 2.1 Nuovi pydantic model — `backend/models/process_based.py`

- `Process`, `Exchange` con validator:
  - `is_reference=True` valido solo su output (errore se input)
  - `is_avoided_product=True` valido solo su output
  - max 1 reference output per processo
  - id exchange unici nel processo
  - name non vuoto
- `FlowRef` discriminated union su 3 varianti:
  - `FlowRefDataset` (db_dataset, product flow ecoinvent)
  - `FlowRefElementary` (db_elementary, emissioni/risorse caratterizzabili)
  - `FlowRefInternal` (internal_process, link tra processi locali)
- `ProductSystemV2` + `FunctionalUnit`
  - **Decisione**: nominato `ProductSystemV2` per coesistere con il legacy `ProductSystem` graph-shaped già usato da `zolca_preflight.py`. Vedi §4 decisioni autonome.
- `ParameterRange` (min/max + validator min<=max)
- helper `validate_project_invariants()` — referential integrity cross-collection (process_id orfani, ref_exchange deve essere output is_reference, duplicati)
- helper `find_internal_references()` — usato dalla futura DELETE API per implementare la strategia *cascade refuse* (M2.4 §10.2)

### 2.2 Project esteso — `backend/models/schema.py`

- nuovi campi:
  - `modeling_mode: Literal["flat", "process_based"] = "flat"`
  - `processes: list[Process] = []`
  - `product_systems_v2: list[ProductSystemV2] = []`
- default `schema_version` bump 6 → 7
- v1..v6 payload continuano a caricare via `extra="ignore"` + field default

### 2.3 Migration — `scripts/migrate_v6_to_v7.py` + `scripts/rollback_v7_to_v6.py`

- idempotente: re-run su v7 = no-op
- seed conservativo `modeling_mode="flat"` su tutti i progetti esistenti (l'utente sceglie esplicitamente process_based su nuovi progetti)
- `--cleanup-smoke` flag (off by default) cancella i progetti smoke noti via match nome:
  - substring (case-insensitive): `testadiquiz`, `dessert smoke real match`, `zolca-smoke`, `mg-smoke`
  - exact-match: `test`
- backup tar.gz simmetrico al pattern `migrate_v5_to_v6.py`
- rollback script speculare

### 2.4 Test (43 nuovi, tutti green)

- `backend/tests/test_process_based_models.py` — 29 test:
  - ParameterRange (min<=max validator)
  - FlowRef discriminator round-trip per le 3 varianti + reject su type sconosciuto + reject su required field mancante
  - Exchange validator (is_reference, is_avoided_product)
  - Process validator (max 1 reference output, duplicate exchange ids, empty name)
  - FunctionalUnit (quantity > 0)
  - ProductSystemV2 minimale
  - validate_project_invariants (graph valido, ref orfana, ref to input, ref a output non-reference, duplicate process ids)
  - find_internal_references (referrer multipli, no referrer)
  - Project extension (default flat, v6 legacy load, process_based round-trip con FlowRef discriminator preservato)
- `backend/tests/test_migration_v6_to_v7.py` — 14 test:
  - migrate per-project (v6→v7 seed, already v7 noop, below v6 skip, esistente preservato)
  - integration run (dry-run no writes, real run, idempotency, backup tar.gz, pydantic round-trip post-migration)
  - smoke cleanup (delete known, dry-run no-delete, off by default, real-name substring non match)
  - rollback (restore pre-migration state)
- `backend/tests/test_schema_m2.py::test_project_legacy_load_without_study_context` — aggiornato per riflettere v7 default (stesso refactor mechanic fatto in v5→v6)

### 2.5 File toccati

```
A backend/models/process_based.py            (~280 righe)
M backend/models/__init__.py                 (+29 righe)
M backend/models/schema.py                   (+18 righe)
A backend/tests/test_process_based_models.py (~340 righe)
A backend/tests/test_migration_v6_to_v7.py   (~210 righe)
M backend/tests/test_schema_m2.py            (+7 righe)
A scripts/migrate_v6_to_v7.py                (~190 righe)
A scripts/rollback_v7_to_v6.py               (~55 righe)
```

Totale: **~1100 righe nette** (foundation, sotto la soglia 5000 righe SPEC §9).

---

## 3. Acceptance criteria check (vs SPEC originale M2.4)

| Criterio | Stato M2.4.0 | Note |
|----------|--------------|------|
| pytest +>=15 nuovi pass | ✅ **+43** | (29 model + 14 migration) |
| Schema v7 attivo con migration testata | ✅ | idempotenza + rollback verificati |
| Smoke project cancellati con --cleanup-smoke | ✅ | testato con 6 smoke + 1 reale → 6 deleted, real preserved |
| Process / Exchange / FlowRef / ProductSystem / ParameterRange documentati in OpenAPI | ✅ (foundation) | I model esistono e sono pydantic; FastAPI li espone automaticamente quando le API CRUD li referenziano (M2.4.1) |
| vitest +>=20 nuovi pass | ⏳ carry-over M2.4.2 |  |
| Bundle main delta <= +25 KB gzip | n/a M2.4.0 | nessuna modifica frontend |
| API CRUD Process + ProductSystem completi | ⏳ carry-over M2.4.1 |  |
| ChromaDB esteso con elementary flows | ⏳ carry-over M2.4.3 |  |
| /api/suggest supporta flow_type filter | ⏳ carry-over M2.4.3 |  |
| FlowSelector frontend implementato | ⏳ carry-over M2.4.2 |  |
| Process editor + ProductSystem editor | ⏳ carry-over M2.4.2 |  |
| Italiano-only labels | n/a M2.4.0 | nessun nuovo testo UI |
| WCAG 2.1 AA niente regressione | n/a M2.4.0 | nessuna modifica UI |
| TypeScript build clean | n/a M2.4.0 | nessuna modifica TS |
| zolca builder esteso | ⏳ carry-over M2.4.3 |  |
| Test round-trip empirico documentato | ⏳ carry-over M2.4.3 | richiede openLCA Desktop, fuori sandbox |

**Status del totale M2.4 sprint:** ~25% completato (foundation ✓, costruzione sopra ⏳).

---

## 4. Decisioni autonome documentate

### 4.1 ProductSystem → ProductSystemV2 (naming clash)
La SPEC chiamava il nuovo modello `ProductSystem`. Ma `backend/models/schema.py` ha già una `ProductSystem` (graph di nodes/edges, M3.1 era zolca_preflight). Sostituirla in-place avrebbe rotto:
- `backend/services/zolca_preflight.py` (importa `schema.ProductSystem` come ref olca)
- progetti flat-mode esistenti che hanno `Project.product_system: Optional[ProductSystem]` salvato

**Scelta:** ho introdotto `ProductSystemV2` come nuovo nome, lasciando il legacy `ProductSystem` intoccato. Project ora ha sia `product_system` (legacy graph) sia `product_systems_v2: list[ProductSystemV2]` (process-based). Quando il frontend M2.4.2 verrà costruito, userà solo V2; il legacy resta come "dead field" finché non viene rimosso in V1.5+ con migration esplicita.

Rationale: zero rischio di regressione su zolca_preflight, isolamento del cambio.

### 4.2 Quantity NON ancora esteso con uncertainty/range/dqr inline
La SPEC §2.5 richiedeva di estendere `Quantity` per accettare uncertainty/range/dqr inline (oggi solo a livello Parameter). Ho **scope-out** questa estensione da M2.4.0 e la riporto a M2.4.2 (frontend) o M2.4.4.

Rationale: estendere `Quantity` modifica un model usato da `BomRow.quantity_per_fu`, `BomRowCanonical.quantity_per_fu`, e una catena di servizi (`bom_ingest.py`, `formula_parser.py`, `compliance_check.py`). È un cambio orizzontale che inquinerebbe il diff di M2.4.0 senza necessità (i nuovi model `Exchange.quantity` accettano già il `Quantity` esistente — lo si potrà estendere dopo). `ParameterRange` è invece introdotto come tipo standalone, riutilizzabile sia da Parameter (carry-over) sia da Quantity (carry-over).

### 4.3 Smoke project pattern matching
La SPEC indicava 5 smoke (`testadiquiz`, `DESSERT smoke real match`, `test`, `zolca-smoke`, `mg-smoke-B con eventuale duplicato`). Ho implementato un pattern semplice:
- substring case-insensitive match per i 4 con nome distinto
- exact-match per `test` (perché altrimenti matcherebbe qualunque project con "test" nel nome)

Test dedicato (`test_real_project_substring_does_not_match`) verifica che un nome reale italiano contenente "test" come parte di altre parole (es. "Contesto produttivo Italia") non viene matchato.

### 4.4 Cascade-refuse strategy per DELETE
SPEC §10.2 lasciava la scelta tra cascade refuse / cascade null / cascade warn. Ho seguito il consiglio della SPEC ("Scelta consigliata: cascade refuse") implementando solo l'helper `find_internal_references()`. La logica HTTP 409 vivrà nelle API M2.4.1 — qui c'è solo la pure function.

### 4.5 Pydantic `extra="forbid"` sui nuovi model
Tutti i nuovi model hanno `extra="forbid"` (a differenza di `Project` che ha `extra="ignore"` per backward compat). Rationale: i nuovi model non hanno legacy da supportare, e forbid catcha typo precoci.

---

## 5. Carry-over emersi

### Per M2.4.1 (API CRUD)
- `GET/POST/PUT/PATCH/DELETE /api/projects/{pid}/processes` + sub-resource exchanges
- `GET/POST/PUT/DELETE /api/projects/{pid}/product_systems_v2`
- DELETE process con cascade-refuse 409 (usa `find_internal_references`)
- Validazione runtime con `validate_project_invariants` su save
- Estensione Parameter API per `range: ParameterRange`
- pytest >=10 nuovi (CRUD endpoints)

### Per M2.4.2 (frontend)
- Selettore `modeling_mode` in PreWizard.tsx
- Lista Process del progetto + Process editor (3 sezioni: header, exchanges, parameters)
- `FlowSelector` componente che wrappa `GhostInput` con prop `flowType` polimorfico
- ProductSystem editor con FunctionalUnit form + dropdown ref_process / ref_exchange
- Compliance check estensione per modello process_based
- Estensione Quantity form con sezione "Data quality" collapsible (uncertainty/range/dqr inline)
- Italiano-only labels per i nuovi testi
- vitest >=20 nuovi
- Bundle delta misurazione (+25 KB cap)

### Per M2.4.3 (zolca + ChromaDB)
- `backend/services/index_extension.py` — estrazione + indexing elementary flows da .zolca ecoinvent (~1500-3000 records)
- `/api/suggest` parametro `flow_type: "product" | "elementary"` + `include_internal: bool`
- `zolca_builder.py` rewrite per process_based mode:
  - emit N Process openLCA distinti
  - flowType: PRODUCT_FLOW vs ELEMENTARY_FLOW corretto (critical per LCIA)
  - ProductSystem openLCA con FU + reference_process + linked_processes auto-resolved
- estensione `test_zolca_openlca_strict.py` con fixture process-based
- pytest >=5 nuovi (zolca + index)

### Empirico round-trip openLCA Desktop
**Scope-out documentato.** Non eseguibile in sandbox Claude Code (richiede openLCA Desktop). Documento qui la procedura attesa per Mirko empirico:

1. Crea Project nuovo `modeling_mode="process_based"` via UI M2.4.2
2. Process A "Raw material PET":
   - Output: 1 kg PET granulate (db_dataset ecoinvent)
   - Output: 0.05 kg CO2 fossile (db_elementary)
3. Process B "Bottle production":
   - Input: 0.95 kg internal_process(A, "PET granulate")
   - Input: 0.5 kWh electricity low voltage IT (db_dataset)
   - Output: 1 kg PET bottle (is_reference=True)
4. ProductSystem "Bottle LCA" con FU=1 kg, ref=B/PET bottle
5. Esporta .zolca → importa in openLCA Desktop
6. Lancia LCIA con EF 3.1
7. Verifica:
   - 2 Process distinti visibili in openLCA
   - Contribution analysis mostra A e B con percentuali distinte (non blob)
   - LCIA totale > 0
   - CO2 fossile contata nel GWP

### Decisione di prodotto residua
La SPEC §2.5 estensione Quantity inline è scope-out da M2.4.0. **Mirko sceglierà** se affrontarla in M2.4.2 (frontend con form Quantity esteso) o se diventa un sub-sprint dedicato M2.4.4. Carry-over flag.

---

## 6. Stato test empirici round-trip

**Scope-out**, eseguito da Mirko empirico una volta che M2.4.3 sarà mergiata. Procedura attesa documentata in §5 sopra.

---

## 7. Numeri riepilogativi

- **PR codice:** https://github.com/mirkobusto/lca-tool/pull/12
- **PR coordination:** vedi sotto (questa)
- **File toccati:** 8 (3 modificati, 5 nuovi)
- **Test count delta vitest:** 0 (M2.4.0 è solo backend)
- **Test count delta pytest:** **+43** (target M2.4 era +15 cumulativo, già over-delivered solo con foundation)
- **Bundle main delta KB gzip:** 0 (M2.4.0 è solo backend)
- **Acceptance criteria check (M2.4 totale):** ~25% (vedi tabella §3)
- **Decisioni autonome documentate:** 5 (vedi §4)
- **Carry-over emersi:** 4 sub-sprint pianificati (M2.4.1, M2.4.2, M2.4.3, opzionale M2.4.4)
- **Stato test empirici round-trip:** scope-out con procedura documentata

## 8. Prossimi step suggeriti per Mirko

1. Review PR #12 sul lca-tool
2. Manual QA: `python scripts/migrate_v6_to_v7.py --dry-run` su `data/projects/v2/` reale per verificare il count atteso
3. Manual QA: `python scripts/migrate_v6_to_v7.py --cleanup-smoke` (dopo backup, ovviamente) per la fresh-start cleanup
4. Merge PR #12 + merge questa PR coordination
5. Decidere: M2.4.1 (API CRUD) come prossimo task autonomo, o aspettare per consolidare il modello dati con feedback empirico
