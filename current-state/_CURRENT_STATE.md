# 🟢 CURRENT STATE — LCA Tool — 2026-05-05 post-merge M3.1.1

⚠ **Drive folder ha ≥10 file titolati `STATE.md`**. Questo è la **versione canonical e autoritaria** post-merge M3.1.1. Tutti gli altri sono storia, incluso `_CURRENT_STATE_20260505_0030.md`.

**Last updated**: 2026-05-05 ~01:00 (post merge PR #4 in main + empirical PASS preflight 4/4 in 20.33s)

---

## Sprint corrente

**Catena M3.1.0.x + M3.1.1 completamente chiusa.** Tutti gli sprint M3.1.0.{1,2,3,4,5,6,7} + M3.1.1 mergeati in main. main HEAD = `b8d6002`.

**Next sprint — decisione Mirko pendente**. Tre opzioni concrete:

1. **M3.1.2 — Real Characterization Factors (JRC EF 3.0)**: estende M3.1.1 con CF reali da JRC CC-BY-4.0 (~5 MB embedded JSON). Sblocca LCIA computation con valori non-zero in openLCA Desktop. Sprint ~2-3 settimane. Path concreto verso V1.5.
2. **M3.2 — Re-import LCIA results + Report draft DOCX**: chiude V1 release path. Re-importa numeri LCIA da openLCA dopo computation, genera DOCX template-based. Sprint ~3-4 settimane. Pre-requisito V1.
3. **Pivot V1.5 partial — GUI G1 (Command Palette ⌘K)**: parallelo all'apertura della seconda chat Architect-GUI, sblocca differenziazione UX vs competitor. Sprint ~3 settimane.

L'Architect main attende decisione e procede a scrivere SPEC del prescelto.

---

## Stato sprint

| Sprint | Status | SHA |
|---|---|---|
| M1, M1.5 | ✅ merged main | `f844012` |
| M2.1 | ✅ merged main | `dfb9cd4` |
| M2.x.1, M2.x.1.2 | ✅ merged main | `1489455`, `13e8d8b` |
| M2.x.2 | ✅ merged main | `1975ccf` |
| M2.3 | ✅ merged main | `4357700` |
| M2.3.1 | ✅ merged main | `957d651` |
| **M3.1.0** | ✅ merged main | `d202083` (pre-2026-05-04) |
| **M3.1.0.1-4** | ✅ merged main | PR #1 squash (`4fe29a6`) |
| **M3.1.0.5** | ✅ done (no-code) | nessun branch |
| **M3.1.0.6** | ✅ merged main | PR #2 squash (`e0a9a03`) |
| **M3.1.0.7** | ✅ merged main | PR #3 squash (`67a2ec4`) |
| **M3.1.1** | ✅ **merged main** | **PR #4 squash (`b8d6002`)** — `M3.1.1: zolca full mapping` |
| **M3.1.2** | ⏳ futuro | candidato CF reali JRC EF 3.0 |
| **M3.2** | ⏳ V1 | re-import LCIA + report DOCX |
| **G1** | ⏳ V1.5 partial | Command Palette ⌘K (chat GUI separata) |

---

## File `.zolca` ATTIVO

Drive folder: `Substitute HiQ cortex` (id `1SiERp6tJWLDDgvNzE9i7JANMraIrp7Pz`).

**File validato in openLCA Desktop 2.6.1 + preflight pytest** (pre-M3.1.1, smoke project senza LCIA method):
- `DESSERT_smoke_20260504_1534_FIXED5.zip` (7899 byte, md5 `66c620d7348fa8fb1512d2ccb89b05e3`)
- alias `.zolca` con stesso md5

**File post-M3.1.1 con LCIA method** (smoke project con `lcia_method="EF 3.0"` + IT/DE locations):
- size: 12313 byte
- **md5 idempotency byte-perfect**: `a06ebad29d428f41a8f6418df69750f7` (verificato su 5 rebuild consecutivi)
- 30+ entries (10 top-level dirs: actors, locations, sources, lcia_categories, lcia_methods, processes, flows, unit_groups, flow_properties, parameters)

**Reference exports**:
- `2018_ecoinvent3_1_cutoff.zip` — id `1i23cbmvnHixjzP7KQZqLrbGweoorFZx9` (8475 B) — fixture committata in M3.1.0.6
- `ecoinvent v3.10 Cutoff System-Processes 2024-06-19.zip` — id `1-gmy9TtoYd2-UuYigGJS0NtRr6_VDOMr` (13 MB) — REAL ecoinvent 3.10, NON committato (on-demand per V1.5)
- `reference_with_lcia_dummy.zip` — committato in M3.1.1 a `backend/tests/fixtures/openlca_reference/` (6550 byte) — generato da `scripts/build_lcia_dummy_fixture.py`, target del test 3 strict diff post-M3.1.1

---

## Pending action items

| Owner | Item | Status |
|---|---|---|
| Architect (main chat) | Update `DESIGN_M2_v3.1_deterministic_build_contract.md` con learnings catena M3.1.0.x → M3.1.1 | ✅ done (questo update) |
| Architect (main chat) | Scrivi `SPEC_M3.1.1.1_readme_contract_section.md` (micro-SPEC ~30min, doc-only) | ✅ done (questo update) |
| Mirko | **Decidi next sprint**: M3.1.2 (CF reali JRC) vs M3.2 (LCIA re-import + DOCX) vs G1 (Command Palette V1.5 partial) | ⏳ blocking |
| Mirko (opzionale, non bloccante) | Lancia Claude Code su SPEC M3.1.1.1 (~30 min, doc-only sprint) per chiudere README §7 | ⏳ on-demand |
| Architect-GUI (chat parallela) | Aperta con `_GUI_BOOTSTRAP_20260505.md` (id `11XKpMipADPnV19h-_FIcfRMsPw6dJwkV`), attende "vai" | ⏳ idle |

---

## M3.1.0.6 — bug coverage CI structural (invariato post-M3.1.1)

| Test | Riproduce regressione | Sprint storico | File |
|---|---|---|---|
| `test_zolca_decompresses_with_inflater_strict` | DEFLATE drift compress_size mismatch | M3.1.0.2 | `test_zolca_openlca_strict.py` |
| `test_zolca_field_lengths_match_derby_constraints` | Derby VARCHAR(36) overflow su @id | M3.1.0.4 | `test_zolca_openlca_strict.py` |
| `test_zolca_structural_diff_against_reference` | manifest filename + dir layout | M3.1.0 + M3.1.0.1 | `test_zolca_openlca_strict.py` (repointed M3.1.1 → `reference_with_lcia_dummy.zip`) |

Documentation: `backend/services/_format_features_README.md` — protocol 4-step. M3.1.1 ha aggiunto §6 "Full mapping". §7 "Deterministic Build Contract" da scrivere via SPEC M3.1.1.1.

---

## M3.1.0.7 — bug coverage CI semantic (invariato post-M3.1.1, +1 test)

| Test | Cosa cattura | File |
|---|---|---|
| `test_preflight_validates_dummy_reference` | parsing JSON-LD schema dummy 2018 + put + cleanup | `test_zolca_preflight.py` |
| `test_preflight_builds_and_validates_smoke_project` | end-to-end build → put → counts → cleanup | `test_zolca_preflight.py` |
| `test_preflight_detects_id_collision` | collision detection con `fail_on_collision=True` | `test_zolca_preflight.py` |
| **`test_preflight_validates_full_smoke_project`** (NEW M3.1.1) | smoke project con `EF 3.0` + IT/DE locations + 6 nuovi tipi via IPC | `test_zolca_preflight_full.py` |

Marker `@pytest.mark.preflight`, skip silenzioso senza `OLCA_IPC_PORT` env var.

---

## M3.1.1 — full mapping coverage (NEW)

### 7 nuovi pytest default (`test_zolca_full_mapping.py`)

| # | Test | Cosa verifica |
|---|---|---|
| 1 | `test_zolca_includes_actors_dir` | dir `actors/` ≥1 entry, JSON valido |
| 2 | `test_zolca_includes_locations_dir` | BomRow IT+DE → 3 location codes (GLO+IT+DE) |
| 3 | `test_zolca_includes_sources_dir` | dir `sources/` ≥1 entry |
| 4 | `test_zolca_includes_lcia_method_when_requested` | `lcia_method=None` → no LCIA dirs; `EF 3.0` → entrambe presenti |
| 5 | `test_zolca_includes_lcia_categories_count_matches_method` | EF 3.0 → 16 cat; TRACI 2.1 → 10 cat |
| 6 | `test_zolca_lcia_method_id_is_deterministic` | rebuild ReCiPe 2016 Midpoint H → stesso `@id` UUIDv5 + 18 cat |
| 7 | `test_zolca_locations_resolve_unknown_iso_to_glo` | `BomRow.extra["location_iso"]="ZZ"` → fallback GLO senza eccezione |

### 1 nuovo pytest preflight

`test_preflight_validates_full_smoke_project` — vedi M3.1.0.7 sopra.

### Idempotency byte-perfect

5 rebuild su stesso project produce md5 identico `a06ebad29d428f41a8f6418df69750f7` (12313 byte). Verificato e committato.

---

## Deterministic Build Contract (NEW post-M3.1.1)

I 4 pattern emersi dalla catena M3.1.0.x → M3.1.1 costituiscono il contratto formale di idempotency byte-perfect del builder. **Da non rompere senza versione+migrazione**.

| # | Pattern | Where enforced | Why |
|---|---|---|---|
| 1 | **Catalog statico Python** in `backend/services/_*.py` | `_lcia_methods_catalog.py`, `_locations_catalog.py`, `_actors_default.py`, `_olca_reference_units.py` | Reference data inline al codice, no external fetch, audit-friendly |
| 2 | **UUIDv5 con namespace fisso `_NAMESPACE_LCATOOL = uuid.UUID("8a4c7e1b-0d3f-5b2a-9e6c-1f4a8b7d2e30")`** | tutti i catalog M3.1.1 + builder per output_flow_id e flow_id_for_row | Deterministic id, rerun → stesso uuid; cambiare il namespace invalida ogni @id ed è breaking change |
| 3 | **ZipInfo.date_time = `(2026, 1, 1, 0, 0, 0)` fisso** invece di `time.localtime()` | `zolca_builder.py::_make_zinfo` | zipfile usa default mtime corrente che breaks idempotency byte-perfect tra rebuild |
| 4 | **`lastChange` field strippato dal payload JSON** prima del write | `zolca_builder.py::_finalize_zolca_package` + `_strip_last_change` + serialize helpers (`pop("lastChange", None)`) | `olca_schema.zipio.ZipWriter` stamps `datetime.now()` per ogni entity, breaks idempotency |

**Documentazione full**: `DESIGN_M2_v3.1_deterministic_build_contract.md` (Drive). Vedi anche `_format_features_README.md` §7 (da scrivere via SPEC M3.1.1.1).

---

## Bug discovery cronologia M3.1.0.x → M3.1.1

| Sprint | Bug / Feature | Layer | Symptom / Goal | Caught by future runs? |
|---|---|---|---|---|
| M3.1.0 | Missing UnitGroups embed | structural | Navigator vuoto | ⚠ partial (test 3 manifest, M3.1.0.6) |
| M3.1.0.1 | Manifest filename + parameters/ missing | structural | Freeze al click Finish | ✅ test 3, M3.1.0.6 |
| M3.1.0.2 | DEFLATE corruption | Java zip strict | `ZipException: invalid literal/lengths set` | ✅ test 1, M3.1.0.6 |
| M3.1.0.4 | Process @id 44 char Derby VARCHAR(36) | Derby JDBC | `SQLDataException truncation` | ✅ test 2, M3.1.0.6 |
| M3.1.0.5 (canale) | Drive API trunca 48 byte EOCD | Drive REST upload | `ZipException: invalid END header` | ❌ canale, no pytest. Mitigazione = NO Drive API |
| M3.1.0.7 (empirical) | FlowMap / RefType / collision | preflight implementation | -32602 / AttributeError / collision | ✅ commit di fix in M3.1.0.7 |
| **M3.1.1** | actors / locations / sources / lcia_method / lcia_categories / nw_sets missing | structural + semantic | navigator senza Method/Actor/Location/Source = LCIA non eseguibile + audit zero | ✅ test 1-7 default + 1 preflight + repoint test 3 strict diff |
| **M3.1.1** | Idempotency drift (4 cause: 2 uuid4, ZipInfo mtime, lastChange) | structural | rebuild stesso project produceva md5 diversi | ✅ md5 byte-perfect verified su 5 rebuild |

---

## Decisioni Architect cumulative

1-30. (Vedi STATE precedenti — pre-M3.1.1)

31. **(2026-05-05) GUI redesign Kimi research dossier**: dossier completo (~80 pagine, 9 file MD) in folder `Substitute HiQ cortex/Kimi_Agent_gui/`. Ingaggio = V1.5/V2 (post-V1 release). Vedi MASTER_PLAN §12 + `_GUI_BOOTSTRAP_20260505.md` per chat GUI dedicata.

32. **(2026-05-05) M3.1.1 LCIA scope = scaffolding only**. ImpactCategory popolate ma `impact_factors=[]`. CF reali in M3.1.2/V1.5 path JRC EF 3.0 CC-BY-4.0. Tradeoff: zolca importabile + LCIA computabile (con valori 0) vs scope creep e licensing question ecoinvent.

33. **(2026-05-05) Deterministic Build Contract — 4 pattern non-negotiable**: catalog statico Python + UUIDv5 con `_NAMESPACE_LCATOOL` fisso + ZipInfo `date_time` fissa + `lastChange` strip. Ogni nuovo sprint che tocca builder DEVE rispettare questi 4. Documentato in `DESIGN_M2_v3.1` + README §7 (TODO via SPEC M3.1.1.1).

34. **(2026-05-05) Convention "verify merge before branch delete"**: prima di `git push origin --delete <branch>`, controllare con `git log origin/main..<branch> --oneline` che il branch sia stato assorbito in main. Alternativa più solida (V1.5 onboarding): GitHub branch protection su `main` con `Require pull request before merging`. Triggered da incidente 2026-05-05 dove M3.1.1 branch era stato cancellato pre-merge (recoverable, ma fragile).

---

## openLCA Desktop import path GUI (verificato empirico)

- ✅ `File → Import → Other → JSON-LD package`
- ❌ `Database → Import → From exported .zolca file → Into the active database` (crea NEW DB)
- Update mode wizard: `NEVER` (default)

---

## Codice — fatti empirici aggiornati post-M3.1.1

### Backend

- `backend/services/zolca_builder.py`: builder `.zolca`. POST `/api/projects/v4/{pid}/build_zolca` ritorna binary application/zip. Process @id UUID puro (36 char), manifest `openlca.json` con `{"schemaVersion": 5}`, dir `parameters/` STORED, rebuild zip con `_make_zinfo(filename)` (ZipInfo date fissa), 6 nuovi `_build_*` (actors/sources/locations/lcia_method/lcia_categories/nw_sets), `_strip_last_change` per idempotency.
- `backend/services/_olca_reference_units.py`: 3 UnitGroup (Mass, Energy, Mass*Length) + 3 FlowProperty canonici openLCA. `lastChange` stripped inline da serialize helpers.
- **NEW M3.1.1**: `backend/services/_lcia_methods_catalog.py` (178 righe, 3 metodi: EF 3.0 + ReCiPe 2016 Midpoint H + TRACI 2.1).
- **NEW M3.1.1**: `backend/services/_locations_catalog.py` (129 righe, ~45 codici ISO + ecoinvent regional).
- **NEW M3.1.1**: `backend/services/_actors_default.py` (63 righe, default Actor + Source).
- `backend/services/_format_features_README.md`: protocol 4-step + §5 Preflight via IPC + §6 Full mapping (M3.1.1) + §7 Deterministic Build Contract (TODO M3.1.1.1).
- `backend/services/zolca_preflight.py` (224 righe + 14 da M3.1.1): `validate_zolca` + `PreflightResult` con 9 counters (4 originali + 5 da M3.1.1: actors/locations/sources/impact_methods/impact_categories) + `IMPORT_ORDER` (18 tipi) + cleanup chirurgico.

### Test infrastructure

#### M3.1.0.6 (structural)
- `backend/tests/_openlca_strict.py` (193 righe): `decompress_strict_inflater`, `validate_derby_constraints`, `diff_against_reference`
- `backend/tests/test_zolca_openlca_strict.py` (165 + 35 +/- 19 da M3.1.1 = ~181 righe): 3 pytest. Test 3 repointed a `reference_with_lcia_dummy.zip` da M3.1.1.
- `backend/tests/fixtures/openlca_reference/reference_2018_dummy.zip` (8 KB committed) — non più referenziato post-M3.1.1, mantenuto per backward compat
- **NEW M3.1.1**: `backend/tests/fixtures/openlca_reference/reference_with_lcia_dummy.zip` (6550 byte committed) — generato da `scripts/build_lcia_dummy_fixture.py` (233 righe)

#### M3.1.0.7 (semantic)
- `backend/tests/test_zolca_preflight.py` (218 righe): 3 pytest marker `@pytest.mark.preflight`
- **NEW M3.1.1**: `backend/tests/test_zolca_preflight_full.py` (151 righe): 1 pytest preflight `test_preflight_validates_full_smoke_project`
- `pytest.ini` (3 righe): registra marker `preflight`
- `requirements.txt`: `+olca-schema>=2.6.0`

#### M3.1.1 (full mapping coverage)
- **NEW**: `backend/tests/test_zolca_full_mapping.py` (180 righe): 7 pytest default

### Test count

345 → 350 (M3.1.0.1) → 353 (M3.1.0.2) → 355 (M3.1.0.3) → 356 (M3.1.0.4) → 359 (M3.1.0.6) → 362 (M3.1.0.7, 3 preflight skip) → **370 (M3.1.1)** = **366 default + 4 preflight skip senza env var**

### Project DESSERT pilota

- pid: `9772eb1e-1972-4e7e-98ac-c8059a48ee10`
- 6 row matcher: 4/6 mismatch semantici (V1.5 backlog #2)
- Empirical: openLCA Desktop import OK + preflight 4/4 PASS in 20.33s contro IPC reale (2026-05-05)

---

## V1.5 backlog (carry-over + nuove voci)

### Pre-M3.1.0.x (1-9)
1-9. Vedi STATE precedenti

### NEW da M3.1.0.x (10-15)
10. **Matcher M1 quality ricalibrazione** (PRIORITÀ ALTA): 4/6 mismatch DESSERT BoM specialistico
11. `parameters/` populated quando project ha Parameter rows
12. Embed-only-used UnitGroup (-1.2 KB)
13. Custom UnitGroup per unità esotiche (m3, MJ heating, kg dry matter, kg P, kg N)
14. Determinismo `lastChange` field — **✅ RISOLTO M3.1.1** (strip inline da `_finalize_zolca_package`)
15. Multi-UnitGroup coverage: Volume, Items, Area, Time, Person*km

### NEW da M3.1.0.6 (16-20)
16. Diff test su reference 13 MB — **✅ parzialmente risolto M3.1.1** (fixture custom 6.5 KB sufficiente per shape contract). Voce mantenuta per upgrade futuro a 13 MB ecoinvent reale.
17. olca-ipc headless integration test → **✅ chiusa M3.1.0.7**
18. Coverage extra Derby columns (oggi solo `ref_id` VARCHAR 36)
19. `_ilcd_strict.py` con XSD validator quando arriva ILCD output
20. CI integration verifica fixture path

### NEW da M3.1.0.7 (21-23)
21. `force_track_overwrites=True` parameter in `validate_zolca` per CI cloud DB ephemeral
22. olca-modules Java build for CI headless (sblocca CI cloud true headless, AGPL-free)
23. `dry_run=True` parameter (skipped in M3.1.0.7 stretch)

### NEW da M3.1.1 (24-26)
24. **`ECOINVENT_LOCATION_UUIDS` lookup table**: hardcoded mapping da ISO code (RER, GLO, IT, ...) ad UUID canonico ecoinvent reference data. Risolve drift cosmetico Location duplicate in DB con ecoinvent caricato. Sprint dedicato ~1-2gg quando si tocca M3.1.2.
25. **JRC EF 3.0 CF reali** (M3.1.2): ~5 MB embedded JSON CC-BY-4.0 da [eplca.jrc.ec.europa.eu](https://eplca.jrc.ec.europa.eu). Sprint ~2-3 settimane. Path concreto verso V1.5 commerciale.
26. Multi-method support: `Project.goal_and_scope.lcia_methods: list[str]` invece che singolo. Skipped V1.5+.

### NEW V1 generale (top priority post-M3.1.x)
- **AI Grant Parser premium** (Sonnet 4.6, suggest-and-review, ~0.50-2 EUR/progetto)
- **GUI redesign Kimi-style** (chat parallela aperta, sprint G1/G2/G3 ~7 settimane V1.5 partial + V2 full ~8-12 settimane)

---

## Convenzioni (cumulative)

- Branch `night/M<sprint>-<scope>`. Mai main diretto.
- Atomic same-branch cleanup ≤1h. Branch chain max 5.
- **NEW (M3.1.0.x)**: micro-fix branch chain `night/M<sprint>.N-...` per debug runtime.
- Italiano, concreto, niente preamboli.
- DESIGN docs senza §Approval. Versioning vN.M.
- SPEC operative: format fisso 10 sezioni.
- Idempotency non-negotiable.
- Drive scambio docs / GitHub code / rclone Ubuntu→Drive.
- **NEW (M3.1.0.5)**: NO mcp Drive API per upload payload binari (truncate 48 B EOCD).
- **NEW (M3.1.0.6)**: Reference-first protocol per features di formato.
- **NEW (M3.1.0.6)**: Test integration Java-strict pre-merge per features formato.
- **NEW (M3.1.0.7)**: Test preflight via IPC reale (opt-in workstation, gate env var).
- **NEW (M3.1.0.7)**: PR strategy 1 squash per sprint singolo.
- **NEW (M3.1.1)**: Deterministic Build Contract — 4 pattern non-negotiable (catalog statico + UUIDv5 namespace + ZipInfo date fissa + lastChange strip).
- **NEW (M3.1.1, ADR 34)**: Verify merge before branch delete con `git log origin/main..<branch>`.

---

## Dev box state

- 0 progetti reali in `data/projects/v2/` (solo pilota DESSERT)
- **370 test backend** su tip post-M3.1.1 (366 default + 4 preflight skip senza env var)
- 4 backup tar.gz disponibili
- Backend uvicorn `:8000` / Frontend Vite `:5173` avviabili
- rclone mount Drive: `~/drive/Substitute HiQ cortex/` (fuse.rclone)
- venv: `.venv/` alla root del repo (NON in `backend/`)
- openLCA Desktop path: `/home/bittoloso/Documents/openLCA_mkl_Linux_x64_2.6.1_2026-02-19/openLCA/openLCA`
- `olca-ipc 2.6.2` + `olca-schema 2.6.2` installati nel venv
- Branch attivo: `main` post-merge PR #4 a `b8d6002` (consigliato `git checkout main && git pull` a inizio sessione)

---

**Fine STATE.**
