# MASTER PLAN — LCA Modeling & Reporting Tool

> Documento vivente. Sorgente unica di verità per architettura, scope, roadmap.
> Mantenuto dalla **chat Architect web (claude.ai)**. Letto da Claude Code (VSCode extension dal 2026-05-07) all'inizio di ogni sprint via workspace multi-root.
> **Ultimo update**: 2026-05-07 (post-merge V1.5 partial — PR #15 + PR #12 mergiate, tag `v1.5-partial`, workflow VSCode adottato).
> **Supersedes** prior versioni (datate 2026-05-03, 2026-05-05).

---

## 1. Vision

Costruire un tool che sostituisce un software LCA tradizionale (SimaPro/GaBi/OpenLCA come UI) per il workflow del consulente LCA, **delegando il solo calcolo LCIA a OpenLCA via olca-ipc**.

Il tool copre:
1. Goal & Scope definition (con scelta PEFCR/PEF template — V1.5)
2. Modellazione processi (input/output, reference flows, multi-functional)
3. Costruzione Product System (con auto-completion via matching BOM↔ecoinvent)
4. Export modello completo verso OpenLCA (.zolca via olca-ipc)
5. Import risultati LCIA da OpenLCA
6. Generazione report PEFCR/PEF-compliant (DOCX/PDF)

### Cosa NON è
- NON è un motore LCIA. Il calcolo resta su OpenLCA.
- NON è una libreria di metodi di valutazione (usiamo quelli di OpenLCA/ecoinvent).
- NON sostituisce ecoinvent/altri DB. Resta BYOL.
- **NON copia SimaPro/GaBi nelle interazioni UI.** UX rapida command-palette/ghost-text style. Categorie semantiche LCA derivate invisibilmente da `flow_property` del dataset, non imposte come tab. Vantaggio competitivo = velocità di immissione (ADR 41).

### Posizionamento competitivo
- vs **iQ Cortex** (€290/mo): non solo matching, copertura full-stack modeling+reporting.
- vs **OpenLCA** (free): UX guidata + ISO/ILCD compliance by construction (vero valore aggiunto).
- vs **SimaPro/GaBi**: prezzo + apertura + AI-assisted modeling + UX moderna (post-V1.5 dossier Kimi).

### Tier strategy
- **V1 base (target ~99 EUR/mo)**: matcher + wizard ISO+ILCD + xlsx template + .zolca build + report draft. Volume play, mercato ampio (consulenti R&D, EU innovation, ricercatori).
- **V1.5 premium (target ~399-599 EUR/mo)**: tutto V1 + **AI Grant Parser** (§11) + uncertainty Monte Carlo + multi-DB + PEFCR completa + **GUI redesign Kimi-style** (§12). Mercato selettivo (studi grossi, 10+ studi/anno, consortium leader EU innovation).
- Mantenere il tier alto ristretto (white-glove onboarding, no self-service) protegge margine e qualità delle deliverable.

### Stato attuale (snapshot 2026-05-07)

✅ **V1.5 partial mergiata** — `v1.5-partial` tag su main (`9eff3b3`).

Cosa è incluso:
- Process-based modeling end-to-end (M2.4.0 → M2.4.1 → M2.4.2 → M2.4.3)
- LCIA reali EF 3.1 (M3.1.2, FULL dataset 113k characterization factors)
- Units closed-set openLCA (schema v8: 21 unit_groups + ~179 units, UUID stabili)
- UX rapid-input baseline (Command Palette G1, Ghost Text G2/G2.1/G2.2, Optimistic UI G3, a11y baseline + Critical/Serious fix)

V1 release pubblica gating: M3.2 + hardening + V1 release. Vedi §2 roadmap.

---

## 2. Roadmap aggiornata (status 2026-05-07)

### Roadmap originale 6 mesi (riferimento storico)

| Mese | Milestone originale | Status |
|---|---|---|
| M1 (apr→mag) | Matching engine v1 + UI base + project store | ✅ done |
| M1.5 (mag) | Wizard ISO 14040/44 + BoM canonical | ✅ done |
| M2 (mag→giu) | Process Editor + G&S Editor | ✅ rivisto in M2.x.* + M2.4.x |
| M3 (giu→lug) | Product System Builder + Export OpenLCA | ✅ M3.1.x done |
| M4 (lug→ago) | Import LCIA + Chart engine | ⏳ M3.2 (gating V1) |
| M5 (ago→set) | PEFCR Rule Engine + Report PEF | ⏳ V1.5 (rinviato) |
| M6 (set→ott) | Hardening + caso reale | ⏳ V1 release |

### Roadmap M2.x dettagliata

| Sprint | Status | Descrizione |
|---|---|---|
| M2.1 | ✅ merged main | Foundation: StudyContext + pre-wizard + migration v2→v3 |
| M2.x.1 | ✅ merged main | Parametric data model: Quantity, Parameter, Scenario, DqrScore + asteval parser |
| M2.x.1.1 | ✅ merged main | Rebase + inventory + cleanup proposal |
| M2.x.1.2 | ✅ merged main | Cleanup execute (9 fixture cancellati, dev box pulita) |
| M2.x.2 | ✅ merged main (atomic) | Wizard ILCD + UI parametri + BomRow refactor + cleanup banner + ILCD enrichment Kimi |
| M2.3 | ✅ merged main | Data collection template xlsx + disclosure flag + 9_ii edge fix |
| M2.3.1 | ✅ merged main | Modelling Guide PDF generator (output documentale V1) |
| **M2.4.0** | ✅ merged main | **Schema v7 + Process model + ProductSystemV2 + migration BomRow→Process** |
| **M2.4.1** | ✅ merged main | **API CRUD Process / ProductSystemV2** |
| **M2.4.3** | ✅ merged main | **ChromaDB elementary flows + zolca builder process-based rewrite + UUIDv5 sharing** |
| **M2.4.2** | ✅ merged main `v1.5-partial` (PR #15) | **Frontend Process editor + FlowSelector + ProductSystem editor + tripletta hotfix (0.1 + 2a + 2b + 2c + 2d + 2e). Chiusura 2026-05-07.** |
| **M2.4.6** | 📝 next-up | **BoM editor parity con Process editor** + probabile refactor componenti shared (FlowSelector + UnitPicker + SuggestionOverlay) |
| **M2.4.4** | ⏳ post-M2.4.6 | **Parameter manager UI + `output_type` enum** (chiude carry-over Bug C/F/T) |
| M2.5 | ⏳ differita | Process editor + categorie semantiche LCA (decisione strategica: NO mimicry SimaPro, ADR 41) |

### Roadmap M3.x — bridge OpenLCA

| Sprint | Status | Descrizione |
|---|---|---|
| M3.1.0 | ✅ merged main pre-2026-05-04 (`d202083`) | PoC build .zolca via olca-ipc |
| M3.1.0.1-4 | ✅ merged main PR #1 (`4fe29a6`) | Catena fix runtime: UnitGroups embed, manifest filename, DEFLATE corruption, Process @id Derby VARCHAR(36) |
| M3.1.0.5 | ✅ done (no-code) | Re-upload rclone path mount |
| M3.1.0.6 | ✅ merged main PR #2 (`e0a9a03`) | openLCA-strict integration test harness (3 pytest CI structural) + reference fixture 2018 dummy 8 KB |
| M3.1.0.7 | ✅ merged main PR #3 | zolca preflight via olca-ipc Python (3 pytest @preflight opt-in workstation) |
| M3.1.1 | ✅ merged main PR #4 | zolca full mapping — actors / locations / sources / lcia_method / lcia_categories / nw_sets |
| **M3.1.2** | ✅ merged main PR #14 (`d05af14`) | **Real Characterization Factors EF 3.1 (FULL dataset, 113k factors), 2026-05-07** |
| M3.2 | ⏳ V1 (gating) | Re-import LCIA + chart engine + report draft DOCX |
| Hardening | ⏳ V1 (gating) | Test integrazione caso reale |
| **V1 release** | ⏳ post-M3.2+hardening | Release pubblica tier base |
| **V1.5** | ⏳ post-V1 | **AI Grant Parser premium** (§11) + multi-DB + uncertainty MC + PEFCR completa + **GUI redesign Kimi-style** (§12) |

### Roadmap GUI — V1.5 partial (mergiata)

| Sprint | Status | Descrizione |
|---|---|---|
| G1 — Command Palette ⌘K | ✅ merged main PR #5 | Fuzzy search globale processi/flussi/azioni, cmdk lib |
| G2 + G2.1 — Ghost Text | ✅ merged main PR #6 | Inventory + qualifier + layout |
| G3 — Optimistic UI | ✅ merged main PR #8 | TanStack Query helper riusabile |
| G2.2 — Process_name split + overflow | ✅ merged main PR #10 | Hot fix layout suggest popup |
| B1 — Global entity search backend | ✅ merged main PR #9 | `/api/search/entities` indicizza Project/Process/Parameter |
| A1 — a11y baseline audit | ✅ merged coord PR #1 | axe-core baseline |
| A2 + A2.1 — a11y Critical/Serious | ✅ merged main PR #11 | Hot fix link contrast incluso |

### Roadmap GUI — V1.5 partial extension carry-over (post V1.5 partial release)

| Sprint | Priority | Status | Descrizione |
|---|---|---|---|
| **G1.x** — Search globale entità frontend integration | High | ⏳ carry-over | Frontend integration del backend B1 già mergiato |
| Refactor FlowSelector unificato (DB+Interni+Custom singolo) | Medium | ⏳ post-V1.5 partial | ADR candidate, fonde con M2.4.6 se strada refactor componenti shared |
| Bug R — modeling_mode immutabile post-creazione | Medium | ⏳ post-V1.5 | UX, permettere cambio con warning |
| Bug S — combobox blur cancella stato | Medium | ⏳ post-V1.5 | UX a livello primitive |
| Bug L+ — ristrutturazione pagina progetto entry-point modeling_mode | Medium | ⏳ post-V1.5 | UX strategica |
| Bug U — contrasto testo dropdown unità | Low (a11y) | ⏳ post-V1.5 | Possibile WCAG 2.1 AA contrast violation |
| A3 follow-up Moderate+Minor | Low | ⏳ post-V1.5 | i18n stringhe ~120, scope th, focus indicator |

### Roadmap GUI — V2 (full Kimi redesign)

Vedi §12. Sprint 8-12 settimane post-V1 release.

### Scope cuts dichiarati per V1
- PEFCR coverage rinviata V1.5 (HANDOFF v3 repositioning).
- UI funzionale, GUI redesign Kimi-style **partial in V1.5 (G1/G2/G3 done)**, full in V2.
- Reporting via template fissi.
- Multi-user/multi-tenant: post-V1.
- Mobile: out of scope.
- AI grant parser (§11): premium tier V1.5+.

---

## 3. Architettura — moduli

### 3.1 Layer esistente

| Modulo | Stato | Note |
|---|---|---|
| DB extraction (zolca→processes) | DONE M1 | 23k processi indicizzati |
| Embedding index (ChromaDB) | DONE M1 | multilingual-e5-large 1024-dim. **Esteso M2.4.3 con elementary flows index parallelo.** |
| Matching engine (BOM→ecoinvent) | DONE M1 | LLM tier ladder cache→Mistral→Sonnet |
| FastAPI backend | DONE M2.x.* + M3.1.0.x + M2.4.x | ~510-520 pytest baseline post V1.5 partial |
| Web frontend (React 18 + Vite + TS + Tailwind + TanStack Query + zustand) | DONE M2.x.* + GUI sprint | 188 vitest baseline post V1.5 partial |
| Project store | DONE M2.x.* + M2.4.0 + M2.4.2.0.2c | JSON-blob, **schema_version=8**, atomic write. v7 = process-based modeling, v8 = units closed-set. |

### 3.2 Modeling Layer

| Modulo | Stato | Note |
|---|---|---|
| Goal & Scope wizard ISO+ILCD | DONE M2.1+M2.x.2 | Situation A/B/C1/C2 filtering attivo |
| Parametric data model | DONE M2.x.1 | Quantity / Parameter / Scenario |
| BomRow.quantity Quantity-native | DONE M2.x.2 | helper `quantity_value(params)` |
| Compliance check minimal | DONE M2.x.2 | banner UI ComplianceBanner.tsx |
| Data Collection Template xlsx | DONE M2.3 | 6 tab, DQR ISO/ILCD, dropdown |
| Modelling Guide PDF | DONE M2.3.1 | output documentale V1 |
| **Process Editor process-based** | **✅ DONE M2.4.0/.1/.2** | **Frontend completo + tripletta hotfix; UX rapid-input command-palette/ghost-text style** |
| **ProductSystem editor** | **✅ DONE M2.4.0/.1/.2** | **Multi-process linking via UUIDv5 deterministico shared (M2.4.3)** |
| **Discriminated union flow_ref** | **✅ DONE M2.4.0/.1/.2** | **`db_dataset` (PRODUCT_FLOW ecoinvent UUID) / `db_elementary` (ELEMENTARY_FLOW + CF EF 3.1) / `internal_process` / `custom`** (ADR 38) |
| **UnitPicker closed-set** | **✅ DONE M2.4.2.0.2c+d+e** | **21 unit_groups + ~179 units openLCA. Reverse-lookup unit→group. Auto-conversion intra-gruppo + toast undo 5s.** (ADR 42, 43) |
| **BoM editor parity** | 🔄 **next-up M2.4.6** | **Sprint dedicato post-V1.5 partial. Probabilmente fonde con refactor componenti shared.** |
| Multi-functional / Allocation handler | rinviato M3.x | parametric model lo supporta |
| Product System Builder GUI | DONE M2.4.x | |

### 3.3 Bridge OpenLCA

| Modulo | Stato | Note |
|---|---|---|
| Build .zolca + export via olca-ipc | ✅ DONE M3.1.0.x | importable in openLCA Desktop 2.6.1 verificato empirico |
| zolca full mapping (actors, locations, lcia_method, ...) | ✅ DONE M3.1.1 | scaffolding LCIA importabile |
| **CF reali (JRC EF 3.1)** | ✅ **DONE M3.1.2** (PR #14, 2026-05-07) | **FULL dataset 113k characterization factors integrato** |
| Preflight via IPC pytest | ✅ DONE M3.1.0.7 | opt-in con marker `@pytest.mark.preflight`, gate `OLCA_IPC_PORT` env var |
| openLCA-strict integration test harness | ✅ DONE M3.1.0.6 | 3 pytest CI structural (DEFLATE strict, Derby VARCHAR, manifest diff) |
| Reference-first protocol per features formato | ✅ DONE M3.1.0.6 | documentato in `backend/services/_format_features_README.md` |
| **zolca builder process-based** | ✅ **DONE M2.4.3** | **Riscritto per supportare discriminated union flow_ref + UUIDv5 sharing su processi interni shared** |
| **zolca builder con units closed-set** | ✅ **DONE M2.4.2.0.2c** | **Usa `unit_ref_id` UUID openLCA stabile, errore esplicito su Process flag `not_export_ready`** |
| Import LCIA results parser | ⏳ M3.2 (gating V1) | |
| Chart engine | ⏳ M3.2 (gating V1) | |
| Report draft DOCX | ⏳ M3.2 (gating V1) | |

### 3.4 Compliance Layer

| Modulo | Stato | Note |
|---|---|---|
| ISO + ILCD compliance check | DONE M2.x.2 | aspect_scores 5 dim |
| `requires_disclosure_context` flag | DONE M2.3 | rule 5 SHALL-public ILCD |
| WCAG 2.1 AA baseline audit | DONE A1+A2+A2.1 | 0/0/0/0 axe-core verificato (ADR 36) |
| PEFCR rule engine | rinviato V1.5 | |
| `premise` integration (prospective LCA) | parking V2 | |

### 3.5 Reporting Layer

| Modulo | Stato | Note |
|---|---|---|
| Modelling Guide PDF | DONE M2.3.1 | |
| Data Collection Template xlsx | DONE M2.3 | |
| Report draft DOCX | ⏳ M3.2 (gating V1) | jinja2 + python-docx |
| Compliance Snapshot ricco | rinviato V1.5 | |

### 3.6 GUI Layer (V1.5 partial)

| Modulo | Stato | Note |
|---|---|---|
| Command Palette ⌘K | ✅ DONE G1 | cmdk lib, fuzzy search globale (ADR 35) |
| Ghost Text inventory + qualifier | ✅ DONE G2 + G2.1 | Cursor-style autocomplete |
| Process_name split + suggest popup overflow | ✅ DONE G2.2 | Hot fix layout |
| Optimistic UI | ✅ DONE G3 | TanStack Query helper riusabile (ADR 33) |
| Global entity search backend | ✅ DONE B1 | `/api/search/entities` (ADR 35) |
| a11y axe-core baseline 0/0/0/0 | ✅ DONE A1+A2+A2.1 | (ADR 36) |
| **UX rapid-input direction** | **✅ DONE M2.4.2** | **NO mimicry SimaPro, command-palette/ghost-text style (ADR 41)** |

### 3.7 Premium tier (V1.5)

| Modulo | Status | Note |
|---|---|---|
| **AI Grant Parser** | parking V1.5, vedi §11 | killer differenziante |
| **GUI redesign Kimi full** | parking V2, vedi §12 | dossier ricerca esistente |
| Multi-DB matching | rinviato V1.5 | EF/Agri-footprint/IDEMAT prep workstream attivo |
| Uncertainty Monte Carlo UI | rinviato V1.5 | |
| PEFCR completa (CFF, DQR weighted) | rinviato V1.5 | |
| Scenari prospective via `premise` | parking V2 | |

---

## 4. Working agreement — workflow VSCode (dal 2026-05-07)

### Ruoli

- **Architect (chat web claude.ai)**: design strategico, decisioni di scope, scrittura SPEC. Le SPEC vengono committate in `lca-tool-coordination/specs/` (dal 2026-05-07 sostituiscono il vecchio paste-ready workflow).
- **Mirko**: orchestratore. Apre Claude Code in VSCode, fa leggere la SPEC committata dal repo, supervisiona esecuzione, manual QA pre-merge.
- **Claude Code (VSCode extension)**: legge knowledge base direttamente dalla workspace VSCode (`lca-tool-coordination/` accanto a `lca-tool/`), implementa, commit, push, apre PR.

### Workflow per uno sprint

1. Mirko discute con Architect, decide cosa fare
2. Architect scrive SPEC in `/mnt/user-data/outputs/`
3. Mirko committa SPEC in `lca-tool-coordination/specs/`
4. Mirko apre Claude Code VSCode, dice "Leggi `specs/SPEC_<nome>.md` ed eseguila"
5. Claude Code implementa, apre PR codice + append report coordination
6. Architect rilegge report dal repo coordination
7. Loop

### Workspace setup (una volta)

```bash
cd ~/lca
git clone https://github.com/mirkobusto/coordination.git lca-tool-coordination
# (lca-tool / STEP_A_DB_extraction già presente)

cat > workspace.code-workspace <<'EOF'
{
  "folders": [
    { "path": "STEP_A_DB_extraction", "name": "lca-tool (codice)" },
    { "path": "lca-tool-coordination", "name": "coordination (KB)" }
  ]
}
EOF

code workspace.code-workspace
```

### Decisioni autonome / escalation policy

- Decisioni autonome OK su: naming, refactor minimi, test design, posizione helper.
- Escalation richiesta solo per: prodotto, architettura cross-modulo, blocchi >2h, ambiguità compliance, spending API non previsto, scope creep.
- Test verde + manual QA verde → si prosegue.
- **Ogni sprint REPORT con sezione "Domande/dubbi emersi durante l'implementazione" obbligatoria** (con severity low/medium/high) — ADR 40.
- Manual QA pre-merge obbligatorio per sprint frontend pesanti — ADR 39.

### 8 Lezioni operative apprese (cumulato 2026-05-06/07)

1. **Token MCP scade mid-session su sessioni lunghe** — superato dal workflow VSCode dal 2026-05-07. Per task >2h split logico resta valido.
2. **Manual QA pre-merge gate**: vitest 100% pass non garantisce funzionalità. Esempio: M2.4.2 baseline aveva 32/32 vitest verdi e 7 bug rivelati al primo manual QA (ADR 39).
3. **Workflow paste-ready completo include sempre PR coordination** — superato dal workflow VSCode (Claude Code apre PR direttamente).
4. **Force-push update PR esistente, NON nuovo branch** — superato dal workflow VSCode.
5. **Override harness branch assignment esplicito** — obsoleto dal workflow VSCode.
6. **Tracking dubbi pre-decisione obbligatorio**: SPEC deve richiedere sezione "Domande/dubbi emersi" con severity. Decisioni autonome ≠ Domande aperte (ADR 40).
7. **Diagnostica prima di SPEC su bug critical complessi**: fare diagnostica diretta (DevTools, curl, log) PRIMA di scrivere SPEC. Evita SPEC con assunzioni sbagliate.
8. **Test integration end-to-end multi-componente**: per bug "controlled vs uncontrolled" classici React, vitest unit pass al 100% non basta. Servono test integration multi-componente che catch wiring bugs (esempio Bug Y, M2.4.2.0.2e: ADR 44).

---

## 5. Contratti d'interfaccia

### 5.1 Schema modello dati v8 (post M2.4.x)

```
Project
  ├── modeling_mode: "flat" | "process_based"
  ├── (flat) BomRow[]
  ├── (process_based) Process[], ProductSystemV2[]
  └── Parameter[] (esteso con range)

Process
  ├── id, name, location, description
  ├── exchanges: Exchange[]
  ├── not_export_ready: boolean (flag aggregato, true se anche solo 1 Exchange ha unit non matchabile)
  └── ...

Exchange (parte di Process.exchanges)
  ├── flow_ref: discriminated union
  │   ├── db_dataset       (PRODUCT_FLOW, ecoinvent uuid)
  │   ├── db_elementary    (ELEMENTARY_FLOW, CF da EF 3.1)
  │   ├── internal_process (PRODUCT_FLOW, UUIDv5 deterministico shared)
  │   └── custom           (nome libero, no DB binding, NOT export-ready)
  ├── unit_ref_id: FK → units.id (UUID openLCA stabile)
  ├── quantity: Quantity (value | parameter_ref)
  ├── output_type: TBD M2.4.4 (carry-over Bug C — reference / avoided / byproduct / waste / normal)
  ├── unit (legacy string, deprecated, drop migration v9)
  └── ...

units (tabella seed, popolata da CSV openLCA refdata)
  ├── id (UUID openLCA stabile)
  ├── name, description, conversion_factor (verso ref unit del gruppo)
  ├── synonyms (semicolon-separated)
  ├── unit_group_id (FK → unit_groups.id)
  └── is_reference (boolean)

unit_groups (tabella seed, 21 righe)
  ├── id (UUID openLCA stabile)
  ├── name, category, default_flow_property
  └── reference_unit_id
```

### 5.2 Endpoint principali

- `GET /api/units` — catalog completo (21 groups + ~179 units), cacheable 24h
- `GET /api/projects/v4/{pid}` — project con schema_version=8
- `GET /api/projects/v4/{pid}/parameters` — list parameters
- `POST /api/processes` / `PUT /api/processes/{pid}` — CRUD Process
- `POST /api/product_systems_v2` / `PUT /api/product_systems_v2/{pid}` — CRUD ProductSystemV2
- `GET /api/suggest?q=&context=...` — suggest popup process-name + qualifier
- `GET /api/search/entities` — global entity search (B1)
- `POST /api/zolca/build` — export .zolca
- `POST /api/preflight` — preflight via IPC (gate `OLCA_IPC_PORT`)

---

## 6. ADR — running list

| # | Data | Decisione | Status |
|---|---|---|---|
| 1 | 2026-04-27 | Mistral Small 4 come LLM principale | active |
| 2 | 2026-04-27 | React stack frontend | active |
| 3 | 2026-04-27 | DB BYOL only per ecoinvent | active |
| 4 | 2026-04-29 | OpenLCA resta motore LCIA | active |
| 5 | 2026-04-29 | PEFCR coverage selettiva | superseded by HANDOFF v3 (PEFCR → V1.5) |
| 6 | 2026-04-29 | Dev chat autonome con escalation policy | active |
| 7 | 2026-04-30 | Frontend stack Vite + TS + Tailwind + TanStack + zustand | active |
| 8 | 2026-04-30 | Calibrazione B2 margin-based | active |
| 9 | 2026-04-30 | `backend/main.py` come entry point | active |
| 10 | 2026-04-30 | `/api/health` con prefix `/api` | active |
| 11 | 2026-05-01 | Canonical BoM template v1 ingest contract | active |
| 12 | 2026-05-01 | Wizard ISO baseline, PEF rinviato | superseded → wizard ISO+ILCD attivo (M2.x.2) |
| 13 | 2026-05-02 | HANDOFF v3 repositioning: tool come layer end-to-end attorno openLCA, no PEF in V1 | active |
| 14 | 2026-05-03 | Atomic same-branch cleanup pattern (≤1h, in-sprint) | active |
| 15 | 2026-05-03 | Schema bump rhythm ~1/sprint M2.x. Migration script template stabile | active |
| 16 | 2026-05-03 | DESIGN docs senza §Approval interna; decisioni in chat | active |
| 17 | 2026-05-03 | Endpoint download pattern: GET + Content-Disposition + frontend `<a href download>` | active |
| 18 | 2026-05-03 | Premium tier strategy: V1 base + V1.5 premium con AI Grant Parser (§11) | active |
| 19 | 2026-05-03 | Idempotency è non-negotiable: ogni script mutativo con idempotency test in PR iniziale | active |
| 20 | 2026-05-03 | Kimi output pattern: archivio `kb/migrated/M<sprint>_<topic>/` committato | active |
| 21 | 2026-05-03 | M2.3.1 Modelling Guide come sprint dedicato (NON dentro M3.1) | active |
| 22 | 2026-05-04 | M3.1.0 split in 5 sub-sprint sequenziali. Pattern micro-fix branch chain `night/M<sprint>.N-<scope>` per debug runtime | active |
| 23 | 2026-05-04 | Reference-first protocol obbligatorio per features di formato (4-step: Reference → Strict validators → Pytest coverage → Empirical loop) | active |
| 24 | 2026-05-04 | NO mcp Drive API per upload payload binari (`.zolca`, `.zip`). Solo rclone path mount (`~/drive/`) | active |
| 25 | 2026-05-04 | Test integration Java-strict pre-merge per features formato (M3.1.0.6) | active |
| 26 | 2026-05-05 | Preflight via olca-ipc Python in pytest opt-in con marker `@pytest.mark.preflight`, gate `OLCA_IPC_PORT` env var | active |
| 27 | 2026-05-05 | Skip M3.1.0.7 v2 (gdt-server Docker / olca-server JAR): AGPL-v3 viral incompatibile | active |
| 28 | 2026-05-05 | Workflow dev preflight: openLCA Desktop GUI + IPC Server porta 8080 + `pytest -m preflight` | active |
| 29 | 2026-05-05 | PR strategy post-M3.1.0.x: 1 PR squash per sprint singolo; catene multi-sprint giustificano 2+ PR squash | active |
| 30 | 2026-05-05 | M3.1.1 LCIA scope = scaffolding only. CF reali in M3.1.2/V1.5 path JRC EF | superseded by M3.1.2 done (FULL dataset 113k factors) |
| 31 | 2026-05-05 | GUI redesign Kimi research dossier come asset di product strategy. Ingaggio V1.5/V2 | active |
| 32 | 2026-05-06 | G2/G2.1 split atomic same-branch hot fix pattern (estende ADR 14) | active |
| 33 | 2026-05-06 | G3 Optimistic UI con TanStack Query helper riusabile, pattern per CRUD project/wizard | active |
| 34 | 2026-05-06 | Workflow REPORT-on-repo: report sprint committati in `lca-tool-coordination/reports/`, no copia-incolla in chat | active |
| 35 | 2026-05-06 | B1 Global entity search backend-first; endpoint `/api/search/entities` indicizza Project/Process/Parameter | active |
| 36 | 2026-05-06 | WCAG 2.1 AA verifica empirica obbligatoria axe-core: ogni sprint frontend produce report axe-core 0/0/0/0 prima del merge | active |
| 37 | 2026-05-06 | Tokens semantici separati `bg-` vs `text-` su dark theme, evita contrast violations | active |
| 38 | 2026-05-07 | Process-based modeling builder con discriminated union `flow_ref`: db_dataset / db_elementary / internal_process / custom. Migration v6→v7 | active |
| 39 | 2026-05-07 | Manual QA workflow end-to-end pre-merge come gate strutturato per sprint frontend (lezione 2 nottata) | active |
| 40 | 2026-05-07 | Override harness branch + sezione "Domande/dubbi emersi" obbligatoria nelle SPEC (lezione 5+6 nottata) | active (rilevanza ridotta dopo workflow VSCode 2026-05-07) |
| 41 | 2026-05-07 | UX rapid-input direction — NO mimicry SimaPro con tab semantici. UX rapida command-palette/ghost-text style. Categorie semantiche LCA derivate invisibilmente da `flow_property` del dataset | active |
| 42 | 2026-05-07 | Units closed-set openLCA: 21 unit_groups + ~179 units canonici (CSV ufficiali GreenDelta/data committati). UUID stabili = export zolca-ready out of the box. Auto-conversion intra-gruppo via factor con toast undo 5s. Schema v8 | active |
| 43 | 2026-05-07 | Reverse-lookup unit→group nel UnitPicker Database mode: dato dataset response con sola stringa `unit`, frontend fa reverse-lookup nel catalog `/api/units` per derivare il gruppo. NIENTE fallback Mass hardcoded | active |
| 44 | 2026-05-07 | Test integration end-to-end multi-componente per bug controlled-vs-uncontrolled: per bug React state-sync, unit test al 100% non basta. Servono integration test multi-componente in harness stateful (lezione 8) | active |
| 45 | 2026-05-07 | Tripletta hotfix split anti-token-scaduto: per sprint Claude Code on the web stimati >1h, splittare in sub-sprint logici (es. M2.4.2.0.2 → 2a/2b/2c/2d/2e). Manual QA tra ciascuno, force-push branch della PR esistente | active (rilevanza ridotta dopo workflow VSCode) |
| 46 | 2026-05-07 | Workflow VSCode + Claude Code extension sostituisce paste-ready SPEC nel browser. Workspace multi-root (`lca-tool/` + `lca-tool-coordination/` affiancati). Architect (chat web) per design strategico + SPEC; Claude Code VSCode esegue | active |

---

## 7. Mappa chat → modulo

(invariato)

---

## 8. Rischi e mitigation

| Rischio | Impatto | Mitigation |
|---|---|---|
| OpenLCA JSON-LD schema cambia | alto | versioning + integration test (M3.1.0.6 strict harness copre baseline 2.6.1) |
| PEFCR spec ambigue | medio | rinviata V1.5 (mitigato) |
| Eval matching non raggiunge target | medio | tier LLM più potente come fallback |
| Scope creep | alto | HANDOFF v3 freeze + V1.5 backlog + ADR 30 (LCIA scope cut M3.1.1, ora superseded da M3.1.2 done) |
| Mirko bottleneck domain knowledge | alto | escalation policy + memory aggiornata |
| AI Grant Parser hallucination su clausole legali | medio | suggest-and-review pattern + confidence score + citation page (vedi §11) |
| Privacy grant agreement (confidenziale) | medio | Anthropic zero-retention API tier; nessuna persistence sui server |
| Drift tra builder zolca e openLCA Desktop versioni future | medio | Reference-first protocol + refresh fixture quando openLCA bump major (M3.1.0.6 documenta refresh policy) |
| CI cloud headless preflight non disponibile (gdt-server AGPL viral) | medio | Solo opt-in workstation oggi (M3.1.0.7). Path V1.5 = build standalone import-tool da olca-modules MPL (~3-5gg). |
| GUI legacy vs Kimi-style — cliente premium si aspetta UX moderna | medio-alto | Tier V1 con UI funzionale + V1.5 partial GUI (G1+G2+G3+UX rapid-input direction M2.4.2). V2 full Kimi redesign |
| **BoM editor diverge dal Process editor (M2.4.6 mancante)** | medio | Sprint M2.4.6 next-up. Probabile fusione con refactor componenti shared per evitare divergenza future. |
| **Bug T (409 parameters) non assorbito** | low | Carry-over a M2.4.4 (parameter manager UI dedicato) |

---

## 9. Backlog parking lot (V1.5 / V2)

### V1.5 (post V1 release, ~3-4 mesi)

**Top priority post-V1**:
- **AI Grant Parser premium** (vedi §11)
- **GUI redesign Kimi-style full** (vedi §12) — V1.5 partial già mergiato (G1+G2+G3), V2 full redesign
- **Multi-DB matching** (EF, Agri-footprint, ELCD, IDEMAT/Carbon Minds) — workstream prep attivo

**Multi-DB / uncertainty / compliance**:
- Uncertainty Monte Carlo UI
- PEFCR completa (CFF formula engine, DQR weighted, verification rules)
- DQR auto-translation a Distribution (pedigree matrix → lognormal sigma)
- Re-import compiled data collection template (BoM v2 ingestion)
- GoalAndScope hydration from answers (PUT endpoint)
- Process-local + database-scoped parameters UI validation
- Migration boilerplate refactor `scripts/_migration_lib.py`
- Compliance Snapshot ricco (matrice standard × aspect)
- Multi-tenant SaaS infra
- Editor scenari (UI lista + form)
- Layout designer per report (custom branding tier alto)
- Modelling Guide editor utente (template custom)
- Expert level Kimi enrichment per delta_ILCD.json
- Edge case rule 3 regex tightening multifunctionality co-occurrence
- DQR per-process dim diverse da row-level

**Carry-over da catena M3.1.0.x**:
- Matcher M1 quality ricalibrazione (4/6 mismatch DESSERT BoM specialistico) — sprint dedicato pre-release
- `parameters/` populated quando project ha Parameter rows
- Embed-only-used UnitGroup (-1.2 KB)
- Custom UnitGroup per unità esotiche (m3, MJ heating, kg dry matter, kg P, kg N)
- Determinismo `lastChange` field (CI cache stability)
- Multi-UnitGroup coverage (Volume, Items, Area, Time, Person*km) — gran parte risolto da ADR 42
- Diff test su reference 13 MB (M3.1.0.6 §9.1) — esteso quando builder popola tutti i tipi
- Coverage extra Derby columns (oggi solo `ref_id` VARCHAR(36))
- `_ilcd_strict.py` con XSD validator (quando arriva ILCD output)
- olca-modules Java build for CI headless (sblocco CI cloud true headless, costo ~3-5gg, ADR 27 path)
- `force_track_overwrites=True` parameter in zolca_preflight (per CI cloud DB ephemeral, M3.1.0.7 §10.1)
- Locations UUID canonical openLCA reference data (oggi UUIDv5 tool-namespace, drift cosmetico — M3.1.1 §10.2)

**Carry-over da M2.4.2 (V1.5 partial release)**:
- DROP della colonna legacy `Exchange.unit` → migration v9 future (dopo confidence v8 in produzione)
- Bug C byproduct/waste persistence — richiede `output_type` enum in Exchange model → M2.4.4
- Bug F `/parameters` route + UI dedicata → M2.4.4
- Bug T (409 Conflict parameters) → M2.4.4
- Bug R (modeling_mode immutabile post-creazione)
- Bug S (combobox blur cancella stato)
- Bug U (contrasto testo dropdown unità — possibile WCAG violation)
- Bug L+ (ristrutturazione pagina progetto entry-point modeling_mode)
- Refactor FlowSelector unificato (search singolo DB+Interni+Custom, no segmented toggle) — fonde con M2.4.6
- Feature K conversione unità (assorbita in M2.4.2.0.2c via closed-set + factor)
- N suggest "usati altrove" scaling problem
- O Browse/Explore DB modality (sfoglia 23k dataset, filter chips)
- G1.x search globale entità frontend integration (priority HIGH, integrazione del backend B1 già mergiato)
- A3 follow-up Moderate+Minor (i18n stringhe ~120, scope th, focus indicator)
- ECOINVENT_FLOW_UUIDS lookup
- Mapping ecoinvent ↔ JRC EF UUID (M3.1.2.2)
- Quantity inline uncertainty/range/dqr (decisione M2.4.0 §4.2 differita, M2.4.4)
- M2.4.3.1 — Full elementary_flows.json da real ecoinvent extraction (sample 25 → ~3000-8000)

### V2 (post V1.5, ~6+ mesi)
- Editor multi-livello standards (viewer/author/user paid)
- `premise` integration UI (scenari prospective IAM REMIND/IMAGE/TIAM-UCL)
- Compliance lifecycle versioning (deprecation, fork user, validation pipeline)
- Brightway2 integration (alternativa olca)
- LCA sociale / S-LCA
- Mobile/iPad
- Visualizzazione grafo Product System (D3/Cytoscape) — sostituibile da node-graph canvas Kimi-style (§12)
- Comparazioni multi-progetto
- Versioning collaborativo (git-like)
- Marketplace template PEFCR community
- Multi-language i18n del wizard
- M2.5 Process editor + categorie semantiche LCA (decisione strategica differita, ADR 41)
- Inline @-mention nel suggest popup

---

## 10. Come si usa questo documento

(invariato)

- File **autoritativo** per vision strategica + ADR + roadmap a lungo termine.
- Aggiornato dopo merge di sprint significativi (es. V1.5 partial → questa release).
- In caso di conflitto operativo con `current-state/_CURRENT_STATE.md`, **CURRENT_STATE vince** (più aggiornato day-by-day).
- Letto da Architect web all'inizio di ogni nuova chat. Letto da Claude Code VSCode all'inizio di sprint complessi.

---

## 11. AI Grant Parser — premium tier feature (2026-05-03)

### Idea

L'utente carica nel tool il **grant agreement** (o DoA, project proposal, deliverable scope document) come PDF. Un LLM con retrieval-augmented prompt analizza il documento e **propone valori di compilazione** per le question del wizard Goal & Scope ISO + ILCD. L'utente vede ogni proposta con confidence score + citation alla pagina del grant + bottone Accept/Reject/Edit.

### Pain risolto

Il wizard Goal & Scope con 30-50+ question SHALL/SHOULD richiede oggi 4-8 ore di lavoro consulente, anche per progetti dove **molte risposte sono già scritte nel grant agreement** (FU implicita nella descrizione dello studio, system boundaries dichiarati a inizio progetto, temporal scope = durata progetto, geographical scope = consortium countries, intended audience, comparative assertion, critical review obligation, stakeholders).

LLM con buon retrieval su PDF lungo (50-100 pagine) può estrarre tutto questo con confidenza alta, e il consulente passa da "compilo da zero" a "valido proposte AI". Speed-up 5-10x sul wizard, che è il choke-point principale del workflow consulente.

### Quale modello LLM

- **Sonnet 4.6 o successivo** (output structure quality + reasoning su clausole legali). Cost ~50-200k token input per grant 50-100 pagine = ~0.50-2 EUR per progetto. Margine 10x → 5-20 EUR per analisi nel pricing premium. Economically sano.
- Nessun stack nuovo: Anthropic SDK già nel tooling LLM tier alto del progetto.

### Approach tecnico

1. Upload PDF grant in UI dedicata (premium tier only).
2. Backend: estrazione testo via `pypdf` (o `pdfplumber` per layout complesso). Chunking strategico per sezione (Executive Summary, Objectives, Methodology, ecc.).
3. Per ogni question del wizard ISO+ILCD applicabile:
   - Build prompt con context = relevant chunks + question text + obligation_level + applies_to_situations.
   - Call Sonnet con structured output (JSON schema = answer + confidence 0-1 + citation_pages: [N,M,...] + rationale).
4. UI mostra wizard pre-compilato con badge AI per ogni proposed answer.
5. Utente review: accept (mantiene), reject (svuota), edit (modifica). Bottone bulk "Accept all confidence > 0.8".
6. Log analytics: % accept rate, % edit rate per tracking qualità modello.

### Pattern: suggest-and-review (NON auto-fill)

Stessa logica del matcher AI M1: **AI propone, consulente valida**. Non è un auto-pilot. Consulente resta accountability owner della deliverable.

### Posizionamento commerciale

- Tier base V1: matcher + wizard manuale (pricing volume).
- Tier premium V1.5: tutto base + grant parser. Pricing 3-5x base.
- Restricted access: white-glove onboarding (Mirko personalmente o partner certificato), no self-service signup. Protegge margine e qualità delle deliverable.

### Mitigation rischi

- **Hallucination su clausole legali** (es. "comparative assertion") → suggest-and-review + confidence score + citation forzata. Consulente non può accettare proposta senza vedere la pagina del grant.
- **Privacy grant agreement** (spesso confidenziale) → Anthropic zero-retention API tier (nessuna persistence sui server LLM). Documentare in TOS premium tier.
- **Costi runaway** (utenti che caricano libri da 500 pagine) → cap a 200 pagine per documento. Token budget per progetto premium.

### Engineering estimate

- 3-4 settimane (1 sprint M2.x equivalente):
  - Settimana 1: PDF parser + chunking + prompt design + structured output schema
  - Settimana 2: integrazione wizard pre-fill + UI badge AI + accept/reject/edit flow
  - Settimana 3: confidence scoring + citation linking + analytics logging
  - Settimana 4: testing su 5-10 grant reali + tuning prompt + edge cases

### Stato

- **Backlog parking V1.5 high-priority**. Primo candidato post-V1 release.
- ADR #18 registra la decisione di tier strategy.
- Sprint dedicato dopo M3.2 (V1 release) e prima di multi-DB / uncertainty MC.

### Note ulteriori

- Estensione naturale: parsing automatico anche di **deliverable templates EU** (es. WP4 deliverable description) per estrarre processi rilevanti. Sblocca anche modellazione preliminare automatica.
- Estensione V2: parsing di **inventario partner** (es. partner manda spreadsheet messy con dati di processo) → LLM estrae e mappa alla canonical BoM.

---

## 12. GUI Redesign — Kimi research dossier (NEW 2026-05-05, partial mergiata 2026-05-07)

### Idea

L'UI attuale del tool è funzionale (React + Tailwind + TanStack + zustand). Il **dossier strategico Kimi** prodotto 2026-05-04 traccia la direzione di un redesign profondo per V1.5/V2 che porta il tool da "miglior alternativa funzionale a SimaPro" a "primo tool LCA AI-native con UX moderna" — differenziante commerciale forte vs SimaPro/GaBi (paradigma '90s) e vs nuova generazione cloud (One Click LCA, Ecochain Mobius, Carbon Maps).

### Stato — V1.5 partial mergiata 2026-05-07

✅ **3 pattern alta trasferibilità implementati e mergiati**:
- **G1 — Command Palette ⌘K** (PR #5)
- **G2 + G2.1 + G2.2 — Ghost Text** (PR #6 + #10)
- **G3 — Optimistic UI** (PR #8)

✅ **Direzione UX rapid-input confermata** in M2.4.2 (ADR 41): NO mimicry SimaPro tab semantici. Categorie LCA derivate invisibilmente.

⏳ **Carry-over post V1.5 partial → V2**: Intent-First dashboard, Multiple Views (Tree/Canvas/Table/Sankey), Agent Mode con Plan visibile, Block-Based Editing report, Node-Graph Canvas Product System.

### Cose da fare (referenze ai file)

**Folder Drive**: `Substitute HiQ cortex/Kimi_Agent_gui/` (id `1pT-t-kUc4oLLWUjxW1EQLzTkqlVPBJTm`).

| File | Contenuto | Status azione |
|---|---|---|
| `plan.md` (2.6 KB) | Piano di esecuzione ricerca (deep-research-swarm + report-writing) | letto, archiviato |
| `lca_ui_studio_sec01.md` (62 KB) | Landscape — 27 software LCA mappati | da rileggere pre-V2 sprint |
| `lca_ui_studio_sec02.md` (53 KB) | Analisi UI/UX dettagliata 8 schede (SimaPro, GaBi, openLCA, One Click, Makersite, Mobius, Activity Browser, AI-native) | da rileggere pre-V2 sprint |
| `lca_ui_studio_sec03.md` (50 KB) | Benchmarking cross-domain — 60+ tool, 30 pattern UI (73% trasferibilità alta) | da rileggere pre-V2 sprint |
| `lca_ui_studio_sec04.md` (41 KB) | Gap analysis — top 20 frustrazioni quantificate | da rileggere pre-V2 sprint |
| `lca_ui_studio_sec05.md` (48 KB) | **7 principi di design fondanti** | **da rileggere pre-V2 sprint** |
| `lca_ui_studio_sec06.md` (68 KB) | **Mockup concettuali + roadmap** — 5 wireframe testuali | **da rileggere pre-V2 sprint** |
| `lca_ui_studio_sec07.md` (33 KB) | Bibliografia annotata (80+ fonti) | reference |
| `lca_ui_studio_sec08.md` (26 KB) | Glossario 30 pattern UI | reference |

### 7 Principi sintetizzati

1. **Intent-First, non Graph-First** — la schermata iniziale è dashboard "cosa devo fare oggi?", il grafo è risposta a un intento.
2. **Search-First, non Navigation-First** — command palette ⌘K universale per tutte le azioni. ✅ DONE V1.5 partial (G1).
3. **Reversibile** — undo/redo, optimistic UI updates con rollback, no `.save()` mancante. ✅ DONE V1.5 partial (G3).
4. **Multiple Views** — stesso modello visualizzato come Tree / Canvas / Table / Sankey, switch istantaneo (1-5 shortcut).
5. **AI Grounding** — ghost text inline (Cursor-style), agent mode con plan visibile. ✅ partial DONE V1.5 partial (G2 ghost text), agent mode V2.
6. **Keyboard-First, Mouse-Optional** — j/k navigation, ⌘Enter calcolo, mnemonic mapping. ✅ partial DONE V1.5 partial (cmdk).
7. **Progressive Disclosure** — Layer 1 wizard (~1h primo modello vs ~8h SimaPro) → Layer 2 form parametri → Layer 3 node-graph esperto.

### Pattern UI principali — stato implementazione

| Pattern | Sprint | Stato |
|---|---|---|
| **Command Palette ⌘K** (Linear/Raycast) | G1 | ✅ DONE V1.5 partial |
| **Ghost Text** (Cursor) | G2/G2.1/G2.2 | ✅ DONE V1.5 partial |
| **Optimistic UI Updates** (Linear) | G3 | ✅ DONE V1.5 partial |
| **UX rapid-input direction** (no SimaPro mimicry) | M2.4.2 | ✅ DONE V1.5 partial (ADR 41) |
| Agent Mode (Cursor/Replit Agent) | V2 | ⏳ V2 |
| Node-Graph Canvas (Houdini/Blender) | V2 | ⏳ V2 |
| Block-Based Editing (Notion) per report | V2 | ⏳ V2 |
| Performance Monitor (Houdini) — cook time per nodo | V2 | ⏳ V2 |
| Multiple Views (Tree/Canvas/Table/Sankey) | V2 | ⏳ V2 |
| Intent-First Dashboard | V2 | ⏳ V2 |

### Posizionamento V1.5/V2

- **V1**: UI funzionale invariata. Zero rischio di scope creep. ✅ TARGET RAGGIUNTO.
- **V1.5 partial (mergiato 2026-05-07)**: Command Palette ⌘K + Ghost Text + Optimistic UI + UX rapid-input direction. Differenziante visibile vs competitor. ✅ DONE.
- **V2**: full redesign Intent-First dashboard + Multiple Views + Agent Mode + Node-Graph Canvas. Sprint 8-12 settimane. Possibile pivot a stack moderno (mantenere TS + zustand, valutare TanStack-router + radix-ui per design system + Tldraw o ReactFlow per node-graph canvas).

### Stato

- **V1.5 partial: ✅ MERGIATO** (2026-05-07, tag `v1.5-partial`).
- **V2 full redesign**: backlog parking dopo V1 release pubblica.
- ADR #31 registra l'esistenza del dossier come asset di product strategy.
- ADR #41 registra direzione UX rapid-input confermata in M2.4.2.

### Note ulteriori

- Il dossier identifica anti-pattern espliciti: form modali multi-tab profondi (SimaPro 60-120s/processo), tree-only navigation (openLCA Eclipse RCP perspectives), `.save()` esplicito (data loss risk).
- Sezione 6 contiene 5 wireframe testuali pronti come spec base per implementation: Home/Project Overview, Process Editor, Wizard ISO+ILCD, Results Dashboard, Comparison View.
- Il dossier cita >80 fonti accademiche e di settore — base solida per pitch commerciale a clienti premium.

---

**Fine MASTER_PLAN. Ultimo update 2026-05-07 post V1.5 partial release.**
