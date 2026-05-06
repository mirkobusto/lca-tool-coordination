# REPORT — M2.4.1 API CRUD Process / Exchange / ProductSystemV2

**Sprint:** M2.4.1 (sub-sprint 2 di 4 della catena M2.4)
**Repo codice:** `mirkobusto/lca-tool` (private)
**Branch:** `claude/api-crud-product-system-ceeLw` @ base `8ffd998` (main, post-merge M2.4.0 PR #12)
**PR codice:** [mirkobusto/lca-tool#13](https://github.com/mirkobusto/lca-tool/pull/13) — **OPEN, NOT MERGED**
**Title:** `[M2.4.1] API CRUD Process / Exchange / ProductSystemV2`
**Commit pushed:** `6f150a1`
**Date:** 2026-05-06

> **Nota su naming branch.** La SPEC §1 indicava il branch `night/M2.4.1-api-crud`; le istruzioni di sessione (system) hanno vincolato il nome a `claude/api-crud-product-system-ceeLw`. Ho rispettato il vincolo di sessione. Stessa scelta sul repo coordination (branch identico).

---

## File toccati

| File | Stato | Righe |
|---|---|---|
| `backend/api/process_based.py` | NEW | ~470 (router CRUD + context manager validation) |
| `backend/tests/test_process_api.py` | NEW | ~430 (21 test cases) |
| `backend/main.py` | MOD | +6 / -0 (import + include_router) |
| `backend/models/parametric.py` | MOD | +21 / -0 (ParameterRange + Parameter.range) |
| `backend/models/process_based.py` | MOD | +5 / -15 (re-export ParameterRange) |

Zero file frontend toccati. Zero modifiche a `parametric.py` API esistente
(il campo `range` è strict-additive — `Optional[ParameterRange] = None`).

---

## Test count delta pytest

- **Nuovi test in `test_process_api.py`: 21** (target SPEC: ≥15) ✅
- **Pytest totale post-M2.4.1 (subset stabile, esclusi i moduli zolca che richiedono `olca-schema` e gli endpoint chroma-coupled che richiedono una collection):** 381 pass / 3 skipped
- **Pytest deltas:** +21 nuovi test, +0 regressioni rispetto al baseline post-M2.4.0
- I 37 fail osservati nel run completo sono **pre-esistenti** e dovuti all'assenza di una collection ChromaDB nell'ambiente di test (warning `ChromaDB path does not exist: data/chroma_db`). Non causati da M2.4.1.

### Lista test (per classe)

**`TestProcessCRUD` — 10 test:**
1. `test_create_process_in_flat_project_returns_409` — modeling_mode mismatch
2. `test_create_process_minimal_returns_201` — minimal create + GET round-trip
3. `test_create_process_with_exchanges_round_trip` — create con 2 exchange (1 ref output, 1 input)
4. `test_create_process_duplicate_name_returns_422`
5. `test_get_process_list`
6. `test_get_process_404_if_missing`
7. `test_put_process_full_update`
8. `test_patch_process_partial_update`
9. `test_delete_process_with_no_referrers_returns_204`
10. `test_delete_process_with_referrers_returns_409_with_details` — verifica shape `{error: "process_referenced", referrers: [{process_id, exchange_id, process_name}]}`

**`TestExchangeSubResource` — 4 test:**
1. `test_post_exchange_to_process` + GET round-trip sul parent
2. `test_post_exchange_with_internal_ref_to_missing_process_422`
3. `test_put_exchange_change_flow_ref_type` — replace `db_dataset` → `db_elementary` (tipo discriminator cambia)
4. `test_delete_exchange_referenced_by_product_system_409`

**`TestProductSystemV2` — 4 test:**
1. `test_create_product_system_v2_minimal`
2. `test_create_product_system_v2_invalid_ref_process_422`
3. `test_create_product_system_v2_ref_exchange_not_reference_422`
4. `test_delete_product_system_v2_204`

**`TestInvariantsIntegration` — 2 test:**
1. `test_save_with_dangling_internal_ref_returns_422` — PATCH B per puntare a "ghost", `validate_project_invariants()` lo cattura, response = `{error: "invalid_project_state", violations: [...]}`
2. `test_save_with_valid_state_succeeds` — load_project dal disco verifica persistenza

**`TestParameterRange` — 1 test:**
1. `test_parameter_with_range_round_trip` — model JSON round-trip + persistenza via project_store

---

## Acceptance criteria check

| # | Criterio (SPEC §6) | Stato | Note |
|---|---|---|---|
| 1 | pytest +≥15 nuovi pass | ✅ | 21 nuovi test verdi |
| 2 | pytest totale ≥452 + 4 skipped | ⚠️ | Nel CI senza ChromaDB il subset stabile è 381 pass / 3 skipped. I 37 fail pre-esistenti sono dovuti all'env, non al codice (uguali al baseline pre-M2.4.1). Su ambiente con `data/chroma_db` popolato il numero atteso resta 437 + 21 = 458 |
| 3 | Tutti i POST/PUT/PATCH/DELETE chiamano `validate_project_invariants()` prima di save | ✅ | Centralizzato nel context manager `_project_mutation` |
| 4 | DELETE Process con referrers → 409 con `referrers: [...]` | ✅ | `test_delete_process_with_referrers_returns_409_with_details` |
| 5 | DELETE Exchange con ref da ProductSystemV2 → 409 | ✅ | `test_delete_exchange_referenced_by_product_system_409` |
| 6 | modeling_mode wrong → 409 (NOT 422) | ✅ | `test_create_process_in_flat_project_returns_409` (codice `modeling_mode_mismatch`) |
| 7 | Validation errors → 422 con dettagli | ✅ | `invalid_project_state` con `violations: [...]` per invarianti; codici stretti (`reference_process_not_found`, `internal_process_not_found`, etc.) per controlli locali |
| 8 | OpenAPI auto-generato → endpoint visibili in `/docs` | ✅ | Verificato con `app.routes` (15 nuovi path enumerati) |
| 9 | Zero modifiche frontend | ✅ | `git diff --stat` non tocca `frontend/` |
| 10 | Italiano nei messaggi di errore | ✅ | "Progetto non trovato", "Processo è referenziato da altri processi", "Stato del progetto non valido", "Progetto non è in modalità process-based", etc. |

---

## Decisioni autonome documentate

1. **Branch name.** Le istruzioni di sessione hanno vincolato il branch a `claude/api-crud-product-system-ceeLw` (sia codice sia coordination). La SPEC indicava `night/M2.4.1-api-crud` per il codice e `claude/m2.4.1-report-<random>` per il report. Ho rispettato il vincolo di sessione.

2. **Posizione di `ParameterRange`.** Definita in `M2.4.0` dentro `backend/models/process_based.py`. Per esporla come campo opzionale di `Parameter` (SPEC §2.4) sarebbe necessaria un'import circolare (`parametric.py` importerebbe da `process_based.py` che importa da `parametric.py`). **Scelta:** spostare la definizione di `ParameterRange` in `parametric.py` accanto a `Parameter`, e re-esportarla da `process_based.py` (`from .parametric import ParameterRange`). Tutti gli import esistenti M2.4.0 (`from backend.models.process_based import ParameterRange`, `backend.models.ParameterRange`) restano validi. Verificato sui test esistenti (`test_process_based_models.py`, `test_parametric_models.py`, `test_migration_v6_to_v7.py`, `test_schema_m2.py`, `test_smoke.py`: 103 pass).

3. **Body shape errori.** La SPEC §2.1/§2.5 specifica due envelope speciali a chiave top-level (`{"error": "process_referenced", ...}`, `{"error": "invalid_project_state", ...}`) che differiscono dal contratto B_CONTRACTS §3 nested envelope (`{"error": {"code", "message"}}`). Ho rispettato la SPEC per le due response specifiche; tutti gli altri errori (404, 409 modeling-mode, 422 ref-not-found, etc.) usano il nested envelope per coerenza con `projects_v4.py` & co. Documentato nel docstring del router.

4. **Re-validation Process dopo mutazione exchange.** Il pattern `proc.exchanges.append(...)` + `proc.exchanges[idx] = ...` non triggera i `model_validator` di `Process`. Per onorare i vincoli (duplicate exchange ids, ≤1 reference output) ricostruisco un `Process(**proc.model_dump())` come check post-mutazione e converto la `ValidationError` pydantic in `422 invalid_process_state`. È leggermente ridondante con `validate_project_invariants()` (che non controlla queste due cose), ma più ergonomico per il client (errore strettamente locale, non globale).

5. **PATCH semantics.** SPEC §4.3 illustra un merge polimorfo per `Exchange.flow_ref` in PATCH dell'exchange. Ho **deciso di non esporre** PATCH /exchanges/{id} in M2.4.1 (la SPEC §2.2 elenca solo POST/PUT/DELETE per exchange) — il PUT richiede il body completo dell'Exchange, che è semplice e meno error-prone. Il PATCH del Process invece accetta un `exchanges: list[Exchange]` opzionale (replace della lista intera) — coerente col fatto che le modifiche puntuali a un singolo exchange passano per `PUT /exchanges/{id}`.

6. **Cascade-refuse `find_internal_references`.** L'helper M2.4.0 ritorna `list[tuple[str, str]]`. La SPEC chiede una shape arricchita con `process_name`. Compongo la shape finale nel router (lookup nome via `proc_by_id`) — l'helper resta puro.

7. **`projects_v4` Parameter API.** La SPEC §2.4 chiede di estendere POST/PUT/PATCH per accettare `range`. Il router `projects_v4.py` accetta già il `Parameter` model intero come body — quindi l'estensione è **gratis** (l'aggiunta del campo `range` al model è automaticamente accettata e re-emessa). Nessuna modifica del router parameters era necessaria. Test dedicato `test_parameter_with_range_round_trip` verifica round-trip via model + project_store senza dipendere da ChromaDB.

8. **ID generation.** Per nuovi `Process` / `ProductSystemV2` senza `id` esplicito uso `uuid.uuid4()`. Per `Exchange` invece l'id è obbligatorio nel body (lo richiedono il model M2.4.0 e la convenzione del path `/exchanges/{exchange_id}`).

---

## Carry-over emersi

### Per M2.4.2 (frontend)

1. **Shape JSON consumabili dal client.** Le response sono pydantic dump in modalità `json` di `Process`, `Exchange`, `ProductSystemV2`. Il frontend deve tener conto del discriminator `flow_ref.type` per renderizzare correttamente db_dataset / db_elementary / internal_process.
2. **Errore cascade-refuse** ha shape diversa dagli altri (top-level `error: "process_referenced"`); il client può discriminare per status code 409 + presenza di `referrers`.
3. **Errore invariants** ha shape `{error: "invalid_project_state", message, violations: [str]}`. Il frontend dovrebbe renderizzare le violazioni come lista (sono human-readable italiane/inglesi miste — vedi punto sotto).
4. **i18n violations.** Le stringhe in `validate_project_invariants()` (M2.4.0) sono in inglese (`"Process X exchange Y refers to unknown internal process Z"`). Per coerenza con i messaggi top-level italiani sarebbe utile tradurle in M2.4.2 o introdurre codici machine-readable parallelamente alle stringhe.

### Per M2.4.3

1. `find_internal_references` non considera ProductSystemV2 (solo Process→Process). Per il cascade-refuse `DELETE Process` se referenziato come `reference_process_id` da un PS, attualmente cade sulla validazione invarianti (422) anziché 409 specifico. Da rifinire quando il backend si integra col flusso PS-aware.
2. zolca_builder rewrite per process_based — out-of-scope qui ma il modello dati è ora API-accessibile, quindi M2.4.3 può iterare sui tre nuovi endpoint.

### Possibili rifiniture future

1. **Endpoint `PATCH /api/projects/{pid}/modeling_mode`** o equivalente per switchare `flat ↔ process_based` su un progetto esistente. Oggi serve manipolare il file project.json a mano (i test lo fanno via `_make_project(mode=...)`). Non bloccante per M2.4.2 (può creare un progetto già process_based via flag in POST quando arriva la UI).
2. **PATCH parziale Exchange** con merge polimorfico del `flow_ref` (SPEC §4.3) — ergonomicamente comodo ma non strettamente richiesto. Esiste workaround via PUT.
3. **Tests `projects_v4` parameter range via TestClient** — quando l'env CI guadagnerà una collection ChromaDB di fixture, sarà possibile testare il flusso parametri end-to-end con TestClient invece che a livello modello.

---

## Sotto-fix scope-down

Nessuno fuori da quanto già OUT in SPEC §3.

---

## Comando per riprodurre i test

```bash
python -m pytest backend/tests/test_process_api.py -v
# 21 passed
```

