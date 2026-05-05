# DESIGN_GUI — master document Architect-GUI

> Documento vivente. Sorgente di verità per il workstream GUI (V1.5/V2).
> Mantenuto dalla **chat Architect-GUI** (parallela a Architect main).
> Letto da Claude Code dev all'inizio di ogni sprint G\*.
> Versione: **v1.3** (post-G2+G2.1 done atomic same-branch, 2026-05-05).

---

## 1. Purpose

Questo documento è la bussola del redesign GUI del tool LCA. Tiene insieme tre cose: la diagnosi del Kimi research dossier (perché V1 va evoluta), i sette principi di design che guidano le scelte sprint-by-sprint, e lo stato di avanzamento concreto degli sprint G\* (Gn = GUI sprint n) che materializzano quei principi nel codebase.

Si rivolge a tre lettori distinti. **Mirko**: ha qui in pagina lo stato GUI senza dover leggere ~80 pagine di dossier Kimi ogni volta. **Architect-GUI** (questa chat): usa il documento come memoria persistente delle decisioni cross-sprint per non rideciderle ad ogni SPEC. **Claude Code dev**: legge questo documento + la SPEC dello sprint corrente all'inizio del lavoro, e ha tutto il contesto strategico per le decisioni autonome di implementazione.

Il MASTER_PLAN principale (gestito da Architect main) resta autoritativo per architettura tool nel suo insieme, roadmap M\*, ADR cross-modulo. Questo documento è autoritativo solo per il sotto-dominio GUI: principi, pattern, sprint G\*, decisioni di design system. In caso di conflitto fra MASTER_PLAN §12 e questo documento, MASTER_PLAN §12 vince — questo documento si allinea.

## 2. Stack frontend V1 rilevato

Il V1 attuale del tool è uno stack React moderno con primitive AI-native introdotte in G1+G2+G2.1. Il dettaglio:

- **React 18.x** + **TypeScript** + **Vite** (build tool)
- **Tailwind CSS** (utility-first, no CSS files custom)
- **TanStack Query** per data fetching e mutations
- **zustand** per stato client (slice per dominio, no slice globale unica). Slice attivi: `useCommandRegistry` (G1), `useGhostTextSettings` (G2), `useStickyQualifiers` (G2.1)
- **react-router-dom 6.26.2** per routing client-side
- **Vitest 4.1.5** + **@testing-library/react 16.3.2** + **jsdom 29.1.1** per test (introdotto in G1)
- **cmdk 1.1.1** per command palette (introdotto in G1)
- **~120 modules** circa nel codebase frontend pre-G1; +~25 modules post-G2.1 (ghost-text, suggest hooks, sticky qualifiers)

Rotte effettive:
- `/` → Home/Project list
- `/projects` → elenco progetti
- `/projects/:pid` → dettaglio progetto (BoM, parametri, scenari)
- `/projects/:pid/match` → matching BoM↔ecoinvent (con `mode=manual` toggle che apre ManualEntry)
- `/projects/:pid/wizard` → wizard ISO+ILCD

Pattern "project-first" coerente con il workflow consulente reale.

Componenti rilevanti già in produzione:
- Wizard ISO+ILCD (M2.1 + M2.x.2) — situation A/B/C1/C2 filtering
- BomTable nel match page (RowsTable + RowItem read-only, radio-list selection per replace)
- ProcessEditor minimale
- ManualEntry (form text editing, agganciato G2/G2.1 con GhostInput su flow_name + process_name)
- ComplianceBanner.tsx (banner UI per rule 5 disclosure)
- Generatore Modelling Guide PDF (M2.3.1)
- Project store JSON-blob, schema_version=6

Backend FastAPI con prefisso `/api/...`. Endpoint rilevanti per GUI:
- `POST /api/projects/{pid}/build_zolca` (download .zolca)
- `GET /api/projects/{pid}/data_collection_template.xlsx`
- `GET /api/projects/{pid}/compliance`
- `POST /api/projects/{pid}/modelling_guide`
- `GET /api/projects/{pid}/suggest` ← **NUOVO G2/G2.1**: ghost text retrieval-only, qualifier syntax, location_hint sticky

ChromaDB embedding index del matcher M1 (multilingual-e5-large, 1024-dim, 23k processi ecoinvent indicizzati): presente, motore di retrieval per ghost text. Conferma post-G2.1 pre-flight: tutti e 3 i campi metadata (`geography`, `system_model`, `activity_type`) sono presenti nell'index → `where` clause è path primary, fallback testuale residuale.

## 3. I sette principi Kimi

P1 Intent-First (V2), P2 Search-First (G1 ✅), P3 Reversibile (G3), P4 Multiple Views (V2), P5 AI Grounding (G2/G2.1 ✅), P6 Keyboard-First (G1+G2+G2.1+G3), P7 Progressive Disclosure (V2). Vedi sezione completa nei riferimenti Kimi `lca_ui_studio_sec05.md`.

## 4. Roadmap GUI

**G1 Command Palette ⌘K** ✅ DONE merged main 2026-05-05 (commit 6815de6, PR #5)
**G2 Ghost Text inventory** ✅ DONE codice 2026-05-05 (commit 692041e su night/G2-ghost-text-inventory)
**G2.1 Qualifier + layout** ✅ DONE atomic same-branch 2026-05-05 (commit adfbb6a stesso branch)
**G3 Optimistic UI** 📝 SPEC scritta 2026-05-05 (~2 settimane stimate)
**V2 full redesign** 🔮 strategic decision post-V1.5

Constraint cross-sprint: niente node-graph V1.5, niente CRDT, niente i18n, niente major version bump, niente undo/redo globale (V2).

## 5. Status sprint

| Sprint | Status | Branch | Commit | Data |
|---|---|---|---|---|
| G1 | ✅ DONE merged | `night/G1-command-palette` | `6815de6` | 2026-05-05 |
| G2 | ✅ DONE codice (PR open) | `night/G2-ghost-text-inventory` | `692041e` | 2026-05-05 |
| G2.1 | ✅ DONE atomic same-branch | stesso G2 | `adfbb6a` | 2026-05-05 |
| G3 | 📝 SPEC | — | — | — |

Backend post-G2.1: pytest 379 + 4 skipped, vitest 31, bundle main 94.36 KB gzip.

### G2.1 done snapshot

- Layout A multi-line (badge + dataset name canonical clamp-2 + metadata strutturati 📍 IT · ⚙ Cutoff · 🔬 market activity · 📏 kWh + hint tastiera)
- Sintassi `:IT :cutoff :market` qualifier (parse_query, ChromaDB where clause con $and wrapper)
- Sticky qualifier per progetto (zustand persist, deriveLocationFromScope helper)
- Performance warmup lifespan FastAPI (cold 12.8s pre-fix → atteso <400ms post-fix)
- 2 nuovi palette commands: act.set-sticky-location, act.clear-sticky-qualifiers (totale registry 19)
- Bundle main +1.02 KB (cap +5)
- 8 nuovi pytest + 11 nuovi vitest

### Carry-over G2.x backlog (consolidato dal REPORT G2.1 §9)

1. Filter chips UI (MEDIA, 3-4 giorni)
2. Inline @-mention syntax (V2 pattern, 5-7 giorni)
3. Highlight matched chars (1 giorno)
4. Statistiche qualifier usage (1-2 giorni)
5. Smart suggestion proattivo (V2 pattern, 2-3 giorni)
6. act.accept-all-high-confidence (carry-over G2)
7. ProcessEditor / Wizard ghost text (1-2 settimane)
8. Matcher M1 threshold ricalibrazione real-time (V1.5 backlog #10, ALTA pending empirical)
9. Backend LRU cache (Stretch S5)

## 6. Decisioni cross-sprint

D-1 stack invariato V1.5
D-2 Tailwind only
D-3 italiano-only
D-4 WCAG 2.1 AA
D-5 bundle cap +15 KB gzip per sprint main
D-6 registerCommand superficie unica AI-native
D-7 context-awareness pathname
D-8 setupTests.ts condiviso
D-9 localStorage solo UX state non sensibile
D-10 REPORT post-sprint obbligatorio
D-11 numerazione ADR cumulativa col MASTER_PLAN (post-G2.1: 31-36)
D-12 UI inventory step pre-flight (lezione G2)
**D-13 — Atomic same-branch cleanup per hot fix sprint correlati**: quando uno sprint G\* lascia bug o limiti che vanno risolti subito, il fix vive sullo stesso branch. PR finale squash cattura entrambi. Pattern applicato G2/G2.1.

## 7. Riferimenti

Repo coordination: https://github.com/mirkobusto/lca-tool-coordination

Workflow operativo:
- Architect-GUI output in /mnt/user-data/outputs/
- Mirko scarica + apply.sh per commit rapidi
- Claude Code Ubuntu legge da repo, scrive REPORT con git nativo
- Drive deprecato per docs di coordinamento

---

**Fine DESIGN_GUI v1.3 — 2026-05-05.**

NOTA: Questa è la versione abbreviata su Drive per backup. La versione completa (~290 righe) vive su /mnt/user-data/outputs/DESIGN_GUI.md e nel repo GitHub https://github.com/mirkobusto/lca-tool-coordination/blob/main/design/DESIGN_GUI.md una volta committata via apply.sh.
