# MASTER PLAN — LCA Modeling & Reporting Tool

> Documento vivente. Sorgente unica di verità per architettura, scope, roadmap.
> Mantenuto dalla **chat Architect**. Letto da tutte le chat dev all'inizio di ogni sprint.
> Ultimo update: **2026-05-05** (post merge M3.1.0.x + M3.1.1 in code + Kimi GUI research dossier integrato).
> **Supersedes** prior `MASTER_PLAN.md` id `1JvwMYKy6tr2qNx9o_5WVxCpFRy3IUXXx` (datato 2026-05-03).

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
- NON sostituisce ecoinvent/altri DB. Resta BYOL (memo: `reference_licensing_findings`).

### Posizionamento competitivo
- vs **iQ Cortex** (€290/mo): non solo matching, copertura full-stack modeling+reporting
- vs **OpenLCA** (free): UX guidata + ISO/ILCD compliance by construction (vero valore aggiunto)
- vs **SimaPro/GaBi**: prezzo + apertura + AI-assisted modeling

### Tier strategy (2026-05-03)
- **V1 base (target ~99 EUR/mo)**: matcher + wizard ISO+ILCD + xlsx template + .zolca build + report draft. Volume play, mercato ampio (consulenti R&D, EU innovation, ricercatori).
- **V1.5 premium (target ~399-599 EUR/mo)**: tutto V1 + **AI Grant Parser** (vedi §11) + uncertainty Monte Carlo + multi-DB + PEFCR completa + **GUI redesign Kimi-style** (vedi §12). Mercato selettivo (studi grossi, 10+ studi/anno, consortium leader EU innovation).
- Mantenere il tier alto ristretto (white-glove onboarding, no self-service) protegge margine e qualità delle deliverable.

---

## 2. Roadmap aggiornata (status 2026-05-05)

### Roadmap originale 6 mesi (riferimento storico)

| Mese | Milestone originale | Status |
|---|---|---|
| M1 (apr→mag) | Matching engine v1 + UI base + project store | ✅ done |
| M1.5 (mag) | Wizard ISO 14040/44 + BoM canonical | ✅ done |
| M2 (mag→giu) | Process Editor + G&S Editor | ✅ rivisto in M2.x.* |
| M3 (giu→lug) | Product System Builder + Export OpenLCA | 🔄 in lavorazione M3.1.x |
| M4 (lug→ago) | Import LCIA + Chart engine | ⏳ M3.2 |
| M5 (ago→set) | PEFCR Rule Engine + Report PEF | ⏳ V1.5 (rinviato) |
| M6 (set→ott) | Hardening + caso reale | ⏳ V1 release |

### Roadmap M2.x dettagliata (post HANDOFF v3 repositioning)

| Sprint | Status | Descrizione |
|---|---|---|
| M2.1 | ✅ merged main | Foundation: StudyContext + pre-wizard + migration v2→v3 |
| M2.x.1 | ✅ merged main | Parametric data model: Quantity, Parameter, Scenario, DqrScore + asteval parser |
| M2.x.1.1 | ✅ merged main | Rebase + inventory + cleanup proposal |
| M2.x.1.2 | ✅ merged main | Cleanup execute (9 fixture cancellati, dev box pulita) |
| M2.x.2 | ✅ merged main (atomic) | Wizard ILCD + UI parametri + BomRow refactor + cleanup banner + ILCD enrichment Kimi |
| M2.3 | ✅ merged main | Data collection template xlsx + disclosure flag + 9_ii edge fix |
| M2.3.1 | ✅ merged main | Modelling Guide PDF generator (output documentale V1) |

### Roadmap M3.x — bridge OpenLCA

| Sprint | Status | Descrizione |
|---|---|---|
| M3.1.0 | ✅ merged main | PoC build .zolca via olca-ipc |
| M3.1.0.1-4 | ✅ merged main PR #1 | Catena fix runtime: UnitGroups embed, manifest filename, DEFLATE corruption, Process @id Derby VARCHAR(36) |
| M3.1.0.5 | ✅ done (no-code) | Re-upload rclone path mount |
| M3.1.0.6 | ✅ merged main PR #2 | openLCA-strict integration test harness |
| M3.1.0.7 | ✅ merged main PR #3 | zolca preflight via olca-ipc Python |
| M3.1.1 | ✅ merged main PR #4 | zolca full mapping — actors / locations / sources / lcia_method / lcia_categories / nw_sets |
| **M3.1.2** | **🔧 in progress (parallelo)** | **Real Characterization Factors (path JRC EF 3.1 CC-BY-4.0, ~5 MB embedded JSON)** |
| M3.2 | ⏳ V1 | Re-import LCIA + report draft DOCX |
| **V1 release** | ⏳ post-M3.2 | Release pubblica tier base |
| **V1.5 partial** | ✅ **COMPLETE 2026-05-06** | G1+G2+G2.1+G2.2+G3+B1+A1+A2+A2.1 — UX AI-native + WCAG 2.1 AA compliant |
| **V1.5 release** | ⏳ post-V1 | AI Grant Parser premium + multi-DB + uncertainty MC + PEFCR completa + GUI redesign Kimi-style |

#### Roadmap V1.5 partial — ✅ COMPLETE 2026-05-06

| Sprint | Status | Commit / PR |
|---|---|---|
| G1 — Command Palette ⌘K | ✅ DONE | `45e5b6f` PR #5 |
| G2 + G2.1 — Ghost Text + qualifier + layout | ✅ DONE | `6c9f618` PR #6 |
| G3 — Optimistic UI | ✅ DONE | `51b70e7` PR #8 |
| G2.2 — Process_name retrieval split + SuggestionOverlay overflow | ✅ DONE | `d05e350` PR #10 |
| B1 — Global entity search backend | ✅ DONE | `d98447d` PR #9 |
| A1 — Audit a11y baseline | ✅ DONE | report-only, PR coord #1 |
| A2 + A2.1 — a11y Critical + Serious + link contrast hot fix | ✅ DONE | post-PR #11 |

**Stato V1.5 partial complete**: tool con UX AI-native (Command Palette + Ghost Text + Optimistic UI) + WCAG 2.1 AA compliance verificato empirico. Pronto per pitch istituzionale EU procurement.

### Risultato cumulativo M3.1.0.x

- **main HEAD** ha tutti i 3 sprint M3.1.0.x mergeati (incluso fix empirici post Claude Code: FlowMap non listable, RefType enum, smoke test fail_on_collision=False).
- File `.zolca` (`DESSERT_smoke_20260504_1534_FIXED5.zip`, md5 `66c620d7348fa8fb1512d2ccb89b05e3`) validato bit-by-bit + 359 + 3 preflight pytest.
- **4 livelli di catch dei bug** ora attivi: build-time (zolca_builder.py) + CI structural (3 pytest M3.1.0.6 strict-zip Java equivalents) + CI semantic opt-in workstation (3 pytest M3.1.0.7 via IPC reale) + Empirical openLCA Desktop import GUI (manuale, ora rare).

### Scope cuts dichiarati per V1
- PEFCR coverage rinviata V1.5 (HANDOFF v3 repositioning).
- UI funzionale, non polished. **GUI redesign Kimi-style → V1.5/V2 (§12)**.
- Reporting via template fissi.
- Multi-user/multi-tenant: post-V1.
- Mobile: out of scope.
- AI grant parser (§11): premium tier V1.5+.
- LCIA Characterization Factors reali (§3.3): V1.5 path JRC EF 3.0.

---

## 3. Architettura — moduli

### 3.1 Layer esistente
| Modulo | Stato | Note |
|---|---|---|
| DB extraction (zolca→processes) | DONE M1 | 23k processi indicizzati |
| Embedding index (ChromaDB) | DONE M1 | multilingual-e5-large 1024-dim |
| Matching engine (BOM→ecoinvent) | DONE M1 | LLM tier ladder cache→Mistral→Sonnet |
| FastAPI backend | DONE M2.x.* + M3.1.0.x | 359 default + 3 preflight test (skip silente senza `OLCA_IPC_PORT`) |
| Web frontend (React 18 + Vite + TS + Tailwind + TanStack Query + zustand) | DONE M2.x.* | 120 modules |
| Project store | DONE M2.x.* | JSON-blob, schema_version=6, atomic write |

### 3.2 Modeling Layer
| Modulo | Stato | Note |
|---|---|---|
| Goal & Scope wizard ISO+ILCD | DONE M2.1+M2.x.2 | Situation A/B/C1/C2 filtering attivo |
| Parametric data model | DONE M2.x.1 | Quantity / Parameter / Scenario |
| BomRow.quantity Quantity-native | DONE M2.x.2 | helper `quantity_value(params)` |
| Compliance check minimal | DONE M2.x.2 | banner UI ComplianceBanner.tsx |
| Data Collection Template xlsx | DONE M2.3 | 6 tab, DQR ISO/ILCD, dropdown |
| Modelling Guide PDF | DONE M2.3.1 | output documentale V1 |
| Process Editor avanzato | rinviato V1.5 | UI minimale presente |
| Multi-functional / Allocation handler | rinviato M3.1.x | parametric model lo supporta |
| Product System Builder | in lavorazione M3.1.x | |

### 3.3 Bridge OpenLCA
| Modulo | Stato | Note |
|---|---|---|
| Build .zolca + export via olca-ipc | ✅ DONE M3.1.0.x | importable in openLCA Desktop 2.6.1 verificato empirico |
| **zolca full mapping** (actors, locations, lcia_method, ...) | 🔄 M3.1.1 in code | scaffolding LCIA importabile, no CF reali |
| **CF reali (JRC EF 3.0)** | ⏳ M3.1.2 / V1.5 | path: ~5 MB embedded JSON CC-BY-4.0 da [eplca.jrc.ec.europa.eu](https://eplca.jrc.ec.europa.eu) |
| Preflight via IPC pytest | ✅ DONE M3.1.0.7 | opt-in con marker `@pytest.mark.preflight`, gate `OLCA_IPC_PORT` env var |
| openLCA-strict integration test harness | ✅ DONE M3.1.0.6 | 3 pytest CI structural (DEFLATE strict, Derby VARCHAR, manifest diff) |
| Reference-first protocol per features formato | ✅ DONE M3.1.0.6 | documentato in `backend/services/_format_features_README.md` |
| Import LCIA results parser | ⏳ M3.2 | |
| Report draft DOCX | ⏳ M3.2 | |

### 3.4 Compliance Layer
| Modulo | Stato | Note |
|---|---|---|
| ISO + ILCD compliance check | DONE M2.x.2 | aspect_scores 5 dim |
| `requires_disclosure_context` flag | DONE M2.3 | rule 5 SHALL-public ILCD |
| PEFCR rule engine | rinviato V1.5 | |
| `premise` integration (prospective LCA) | parking V2 | |

### 3.5 Reporting Layer
| Modulo | Stato | Note |
|---|---|---|
| Modelling Guide PDF | DONE M2.3.1 | |
| Data Collection Template xlsx | DONE M2.3 | |
| Report draft DOCX | ⏳ M3.2 | jinja2 + python-docx |
| Compliance Snapshot ricco | rinviato V1.5 | |

### 3.6 Premium tier (V1.5)
| Modulo | Status | Note |
|---|---|---|
| **AI Grant Parser** | parking V1.5, vedi §11 | killer differenziante |
| **GUI redesign Kimi-style** | parking V1.5, vedi §12 | dossier ricerca esistente, 7 principi + 30 pattern |
| Multi-DB matching | rinviato V1.5 | EF/Agri-footprint/IDEMAT prep workstream attivo |
| Uncertainty Monte Carlo UI | rinviato V1.5 | |
| PEFCR completa (CFF, DQR weighted) | rinviato V1.5 | |
| Real LCIA Characterization Factors | rinviato V1.5 (M3.1.2) | path JRC EF 3.0 |
| Scenari prospective via `premise` | parking V2 | |

---

## 4. Working agreement — chat dev autonome

(invariato — vedi versione precedente §4 per dettagli escalation policy)

Reminder breve:
- Decisioni autonome OK, escalation solo per: prodotto, architettura cross-modulo, blocchi >2h, ambiguità compliance, spending API non previsto.
- Test verde → si prosegue.
- Ogni sprint REPORT con decisioni autonome documentate.

---

## 5. Contratti d'interfaccia

(invariato — vedi versione precedente §5)

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
| 15 | 2026-05-03 | Schema bump rhythm ~1/sprint M2.x. Migration script template stabile, refactor `_migration_lib.py` V1.5 | active |
| 16 | 2026-05-03 | DESIGN docs senza §Approval interna; decisioni in chat | active |
| 17 | 2026-05-03 | Endpoint download pattern: GET + Content-Disposition + frontend `<a href download>` | active |
| 18 | 2026-05-03 | Premium tier strategy: V1 base + V1.5 premium con AI Grant Parser come differenziante killer (§11) | active |
| 19 | 2026-05-03 | Idempotency è non-negotiable: ogni script mutativo con idempotency test in PR iniziale | active |
| 20 | 2026-05-03 | Kimi output pattern: archivio `kb/migrated/M<sprint>_<topic>/` committato | active |
| 21 | 2026-05-03 | M2.3.1 Modelling Guide come sprint dedicato (NON dentro M3.1) | active |
| **22** | **2026-05-04** | **M3.1.0 split in 5 sub-sprint sequenziali. Pattern micro-fix branch chain `night/M<sprint>.N-<scope>` per debug runtime, max 5 nodi.** | **active** |
| **23** | **2026-05-04** | **Reference-first protocol obbligatorio per features di formato. Documentato in `backend/services/_format_features_README.md` da M3.1.0.6 (4-step: Reference-first → Strict validators → Pytest coverage → Empirical loop).** | **active** |
| **24** | **2026-05-04** | **NO mcp Drive API per upload payload binari (`.zolca`, `.zip`). Drive REST trunca 48 byte EOCD. Solo rclone path mount (`~/drive/`).** | **active** |
| **25** | **2026-05-04** | **Test integration Java-strict pre-merge per features formato. Implementato in M3.1.0.6: 3 pytest in `test_zolca_openlca_strict.py` (DEFLATE strict, Derby VARCHAR(36), manifest diff vs reference).** | **active** |
| **26** | **2026-05-05** | **Preflight via olca-ipc Python in pytest opt-in con marker `@pytest.mark.preflight`, gate `OLCA_IPC_PORT` env var. NO setup CI cloud in questa fase. Implementato in M3.1.0.7.** | **active** |
| **27** | **2026-05-05** | **Skip M3.1.0.7 v2 (gdt-server Docker / olca-server JAR): AGPL-v3 viral incompatibile commerciale chiuso (gdt-server) + costo medio (olca-modules MPL build standalone). Da rivedere quando team cresce o CI cloud diventa critico.** | **active** |
| **28** | **2026-05-05** | **Workflow dev preflight**: Mirko apre openLCA Desktop GUI + `Tools → Developer Tools → IPC Server` porta 8080, lancia `OLCA_IPC_PORT=8080 .venv/bin/pytest -m preflight -v`. Loop "edit builder → validate" 5s vs 2-3 min click empirici. | **active** |
| **29** | **2026-05-05** | **PR strategy post-M3.1.0.x**: 1 PR squash per sprint singolo (M3.1.0.7 model). Catene multi-sprint giustificano 2+ PR squash (M3.1.0.x model). | **active** |
| **30** | **2026-05-05** | **M3.1.1 LCIA scope = scaffolding only**. ImpactCategory popolate ma `impact_factors=[]`. CF reali in M3.1.2/V1.5 path JRC EF 3.0 CC-BY-4.0. Tradeoff: zolca importabile + LCIA computabile (con valori 0) vs scope creep e licensing question ecoinvent. | **active** |
| **31** | **2026-05-05** | **GUI redesign Kimi research dossier**: dossier completo (~80 pagine, 9 file MD) in folder Drive `Substitute HiQ cortex/Kimi_Agent_gui/`. Ingaggio = V1.5/V2 (post-V1 release). Vedi §12. | **active** |
| 38 | 2026-05-06 | Workflow operativo: SPEC e REPORT scambiati via repo coordination, NO copia-incolla manuale tra chat | active |
| 39 | 2026-05-06 | WCAG 2.1 AA compliance milestone — verifica empirica obbligatoria pre-release via axe-core su tutte le route principali | active |
| 40 | 2026-05-06 | Design tokens semantici separati per `bg-` vs `text-` quando il tool è dark theme (lezione A2.4 → A2.1) | active |

---

## 7. Mappa chat → modulo

(invariato — vedi versione precedente)

---

## 8. Rischi e mitigation

| Rischio | Impatto | Mitigation |
|---|---|---|
| OpenLCA JSON-LD schema cambia | alto | versioning + integration test (M3.1.0.6 strict harness copre baseline 2.6.1) |
| PEFCR spec ambigue | medio | rinviata V1.5 (mitigato) |
| Eval matching non raggiunge target | medio | tier LLM più potente come fallback |
| Scope creep | alto | HANDOFF v3 freeze + V1.5 backlog + ADR 30 (LCIA scaffolding scope cut M3.1.1) |
| Mirko bottleneck domain knowledge | alto | escalation policy + memory aggiornata |
| AI Grant Parser hallucination su clausole legali | medio | suggest-and-review pattern + confidence score + citation page (vedi §11) |
| Privacy grant agreement (confidenziale) | medio | Anthropic zero-retention API tier; nessuna persistence sui server |
| **Drift tra builder zolca e openLCA Desktop versioni future** | medio | Reference-first protocol + refresh fixture quando openLCA bump major (M3.1.0.6 documenta refresh policy) |
| **CI cloud headless preflight non disponibile (gdt-server AGPL viral)** | medio | Solo opt-in workstation oggi (M3.1.0.7). Path V1.5 = build standalone import-tool da olca-modules MPL (~3-5gg). |
| **GUI legacy vs Kimi-style — cliente premium si aspetta UX moderna** | medio-alto | Tier V1 con UI funzionale (no polish), V1.5 introduce GUI redesign sezioni più visibili (command palette + ghost text). Comunicazione chiara nel pricing. |

---

## 9. Backlog parking lot (V1.5 / V2)

### V1.5 (post V1 release, ~3-4 mesi)

**Top priority post-V1 release**:
- **AI Grant Parser premium** (vedi §11)
- **GUI redesign Kimi-style** (vedi §12)
- **CF reali (JRC EF 3.1)** — sprint M3.1.2 in progress parallelo

**Carry-over post V1.5 partial complete (priorità per sprint successivi)**:

| Priorità | Sprint candidato | Stima | Note |
|---|---|---|---|
| ALTA | G1.x search globale entità — frontend integration palette | 0.5-1 settimana | B1 backend pronto, manca solo wire-up |
| ALTA | Matcher M1 threshold ricalibrazione | 0.5-1 settimana | pending Mirko 15 BoM rows manual QA |
| MEDIA | A3 Fix a11y Moderate + Minor (i18n stringhe ~120, scope th, focus indicator, font-size minimo, skip-link) | 3-5 gg | non blocker pitch |
| MEDIA | G2.x Filter chips UI alternative a qualifier syntax | 3-4 gg | pattern Linear/Notion |
| MEDIA | G2.x Match-replace popup di RowItem con ghost search | 3-5 gg | riusa GhostInput G2 |
| MEDIA | G2.x ProcessEditor / Wizard ghost text (multiline) | 1-2 settimane | GhostTextarea |
| MEDIA | ECOINVENT_FLOW_UUIDS lookup table | TBD | sblocca match rate ghost reali |

**Multi-DB / uncertainty / compliance**:
- Multi-DB matching (EF, Agri-footprint, ELCD, IDEMAT/Carbon Minds) — workstream prep attivo
- Uncertainty Monte Carlo UI
- PEFCR completa (CFF formula engine, DQR weighted, verification rules)
- DQR auto-translation a Distribution (pedigree matrix → lognormal sigma)

**Carry-over V2 (richiede design review)**:
- Inline @-mention syntax
- Highlight matched chars nel dataset name
- Statistiche qualifier usage
- Smart suggestion proattivo
- Optimistic delete con conferma timer
- Conflict resolution UI
- Cross-tab BroadcastChannel sync mutations
- Audit utenti reali screen reader (NVDA + VoiceOver Italian voices)

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

---

## 10. Come si usa questo documento

(invariato)

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
- Estensione V2: parsing di **inventario partner** (es. partner manda spreadsheet messy con dati di processo) → LLM estrae e mappa alla canonical BoM. Però qui il pain è minore perché il template xlsx M2.3 già struttura la raccolta.

---

## 12. GUI Redesign — Kimi research dossier (NEW 2026-05-05)

### Idea

L'UI attuale del tool è funzionale (React + Tailwind + TanStack + zustand) ma segue paradigmi tradizionali form-based. Il **dossier strategico Kimi** prodotto 2026-05-04 traccia la direzione di un redesign profondo per V1.5/V2 che porta il tool da "miglior alternativa funzionale a SimaPro" a "primo tool LCA AI-native con UX moderna" — differenziante commerciale forte vs SimaPro/GaBi (paradigma '90s) e vs nuova generazione cloud (One Click LCA, Ecochain Mobius, Carbon Maps).

### Cose da fare (referenze ai file)

**Folder Drive**: `Substitute HiQ cortex/Kimi_Agent_gui/` (id `1pT-t-kUc4oLLWUjxW1EQLzTkqlVPBJTm`).

| File | Contenuto | Status azione |
|---|---|---|
| `plan.md` (2.6 KB) | Piano di esecuzione ricerca (deep-research-swarm + report-writing) | letto, archiviato |
| `lca_ui_studio_sec01.md` (62 KB) | Landscape — 27 software LCA mappati | da rileggere pre-V1.5 sprint |
| `lca_ui_studio_sec02.md` (53 KB) | Analisi UI/UX dettagliata 8 schede (SimaPro, GaBi, openLCA, One Click, Makersite, Mobius, Activity Browser, AI-native) | da rileggere pre-V1.5 sprint |
| `lca_ui_studio_sec03.md` (50 KB) | Benchmarking cross-domain — 60+ tool, 30 pattern UI (73% trasferibilità alta) | da rileggere pre-V1.5 sprint |
| `lca_ui_studio_sec04.md` (41 KB) | Gap analysis — top 20 frustrazioni quantificate (learning curve 90%, UI datata 75%, costi 70%, performance 55%) | da rileggere pre-V1.5 sprint |
| `lca_ui_studio_sec05.md` (48 KB) | **7 principi di design fondanti** — Intent-First / Search-First / Reversibile / Multiple Views / AI Grounding / Keyboard-First / Progressive Disclosure | **da rileggere pre-V1.5 sprint** |
| `lca_ui_studio_sec06.md` (68 KB) | **Mockup concettuali + roadmap** — 5 wireframe testuali (Home, Process Editor, ...), 3 user journey, MoSCoW, stack tech, rischi | **da rileggere pre-V1.5 sprint** |
| `lca_ui_studio_sec07.md` (33 KB) | Bibliografia annotata (80+ fonti documentazione, paper, forum) | reference |
| `lca_ui_studio_sec08.md` (26 KB) | Glossario 30 pattern UI (Command Palette, Ghost Text, Agent Mode, Block-Based Editing, Optimistic UI, Node-Graph Canvas, ...) | reference |
| `research/` (sottocartella) | Materiale grezzo dei swarm di ricerca | reference |

### 7 Principi sintetizzati

1. **Intent-First, non Graph-First** — la schermata iniziale è dashboard "cosa devo fare oggi?", il grafo è risposta a un intento (no canvas vuoto). Risolve frustrazione #1, #2, #15.
2. **Search-First, non Navigation-First** — command palette ⌘K universale per tutte le azioni. Pattern Linear/Raycast.
3. **Reversibile** — undo/redo, optimistic UI updates con rollback, no `.save()` mancante. Risolve frustrazione #14.
4. **Multiple Views** — stesso modello visualizzato come Tree / Canvas / Table / Sankey, switch istantaneo (1-5 shortcut). Pattern Houdini/Blender.
5. **AI Grounding** — ghost text inline (Cursor-style), agent mode con plan visibile (mitigation hallucination 37-40% su dati ambientali).
6. **Keyboard-First, Mouse-Optional** — j/k navigation, ⌘Enter calcolo, mnemonic mapping.
7. **Progressive Disclosure** — Layer 1 wizard (~1h primo modello vs ~8h SimaPro) → Layer 2 form parametri → Layer 3 node-graph esperto. Risolve frustrazione #1 a tutti i livelli di esperienza.

### Pattern UI principali da adottare (top trasferibilità)

- **Command Palette ⌘K** (Linear/Raycast) — entry point universale
- **Ghost Text** (Cursor) — auto-completamento dati inventario (flussi, unità, fattori emissione)
- **Agent Mode** (Cursor/Replit Agent) — pianificazione studio LCA: definizione FU → creazione processi → collegamento → calcolo → report, fase Plan visibile/editabile
- **Node-Graph Canvas** (Houdini/Blender) — minimap, quickmarks, dive-in breadcrumb, frame nodes ISO 14040, drag-link search, lazy connect
- **Block-Based Editing** (Notion) — report LCA come blocchi sincronizzati con modello (testo metodologico, tabella inventario, grafico contributo, Sankey)
- **Optimistic UI Updates** (Linear) — modifica flusso → subito visibile in grafo + impatti
- **Performance Monitor** (Houdini) — cook time per nodo, dirty flags red edges, calcolo incrementale (vs "premi Calculate e aspetta 10-48 min")

### Posizionamento V1.5/V2

- **V1**: UI funzionale invariata. Zero rischio di scope creep.
- **V1.5**: introduce **Command Palette ⌘K** + **Ghost Text** + **Optimistic UI** (3 pattern alta trasferibilità, costo medio ~3-4 settimane). Differenziante visibile vs competitor.
- **V2**: full redesign Intent-First dashboard + Multiple Views + Agent Mode. Sprint 8-12 settimane. Possibile pivot a stack moderno (mantenere TS + zustand, valutare TanStack-router + radix-ui per design system + Tldraw o ReactFlow per node-graph canvas).

### Engineering estimate (V1.5 partial)

- **Sprint G1** (~3 settimane): Command Palette ⌘K — fuzzy search globale su processi/flussi/azioni, mnemonic shortcut, accessible via `kbd` package o `cmdk` library
- **Sprint G2** (~2 settimane): Ghost Text per inventory entry — inline autocomplete unità + fattori emissione da ecoinvent, accept con Tab
- **Sprint G3** (~2 settimane): Optimistic UI per modifiche BoM rows e parametri — TanStack Query mutation con onMutate update + onError rollback

Totale V1.5 GUI partial: ~7 settimane. Inserimento in roadmap: post-AI Grant Parser, prima di multi-DB.

### Stato

- **Backlog parking V1.5 (partial) + V2 (full redesign)**.
- ADR #31 registra l'esistenza del dossier come asset di product strategy.
- Pre-condizione sprint G1: rilettura `lca_ui_studio_sec05.md` + `_sec06.md` + `_sec08.md` per design system + DESIGN_GUI.md scritto da Architect prima di Claude Code.

### Note ulteriori

- Il dossier identifica anti-pattern espliciti: form modali multi-tab profondi (SimaPro 60-120s/processo), tree-only navigation (openLCA Eclipse RCP perspectives), `.save()` esplicito (data loss risk).
- Sezione 6 contiene 5 wireframe testuali pronti come spec base per implementation: Home/Project Overview, Process Editor, Wizard ISO+ILCD, Results Dashboard, Comparison View. Questi sono il bridge naturale design→implementation per V1.5/V2.
- Il dossier cita >80 fonti accademiche e di settore — base solida per pitch commerciale a clienti premium e per eventuali domande di revisori EU su scelte UX.

---

**Fine MASTER_PLAN.**
