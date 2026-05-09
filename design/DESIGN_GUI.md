# DESIGN_GUI — master document workstream GUI

> Documento vivente. Sorgente di verità per il workstream GUI (V1.5 / V2).
> Mantenuto dalla chat **Architect unificato** (post 2026-05-06).
> Letto da Claude Code dev all'inizio di ogni sprint G\* o A\*.
> Versione: **v1.5** — post-merge A2 + A2.1, V1.5 partial COMPLETE.

---

## 🎉 V1.5 partial COMPLETE — 2026-05-06

Il workstream GUI V1.5 partial è chiuso. Il tool è in stato:

- **AI-native primitives**: Command Palette ⌘K + Ghost Text + Optimistic UI tutti production-grade
- **Search backend pronto**: B1 endpoint `/api/search/global` per future integrazioni palette
- **WCAG 2.1 AA compliant**: 0 Critical / 0 Serious / 0 Moderate / 0 Minor verificato empiricamente axe-core su 6 route

Pronto per pitch istituzionale EU procurement.

---

## 1. Purpose

Documento è la bussola del redesign GUI del tool LCA. Tiene insieme tre cose: la diagnosi del Kimi research dossier (perché V1 va evoluta), i sette principi di design che guidano le scelte sprint-by-sprint, e lo stato di avanzamento concreto degli sprint G\* + A\* (a11y) che materializzano quei principi nel codebase.

## 2. Stack frontend V1.5 partial complete

- **React 18.x** + **TypeScript** + **Vite**
- **Tailwind CSS** (utility-only, no CSS files custom)
- **TanStack Query v5** (mutation pattern G3 con optimistic helper riusabile)
- **zustand** (slice: `useCommandRegistry` G1, `useGhostTextSettings` G2, `useStickyQualifiers` G2.1, `toastStore` G3)
- **react-router-dom 6.26.2**
- **cmdk 1.1.1** (palette G1)
- **Vitest 4.1.5** + **@testing-library/react 16.3.2** + **jsdom 29.1.1**
- ~150 modules totali post-A2.1

Design tokens (Tailwind theme):
- `accent: #3a6fd8` — usato per `bg-accent`, `border-accent`, `.btn-primary` (AA pass su white 4.72:1)
- `link: #7aa3ff` — usato per `text-link` (AAA pass su `#171a21` 7.06:1) — introdotto in A2.1

Backend FastAPI con `/api/...` prefix:
- `/api/projects/{pid}/build_zolca` (M3.1.x)
- `/api/projects/{pid}/data_collection_template.xlsx` (M2.x)
- `/api/projects/{pid}/compliance` (M2.3)
- `/api/projects/{pid}/modelling_guide` (M2.3.1)
- `/api/projects/{pid}/suggest` (G2/G2.1, esteso in G2.2 con `field_kind`)
- `/api/projects/{pid}/search/global` (B1)

ChromaDB matcher M1: 23k processi ecoinvent, multilingual-e5-large 1024-dim, metadata `geography`/`system_model`/`activity_type`.

## 3. I sette principi Kimi — stato implementazione

| # | Principio | Stato V1.5 partial | Sprint che lo materializza |
|---|---|---|---|
| P1 | Intent-First (dashboard "cosa devo fare oggi") | 🔮 V2 | — |
| P2 | Search-First (Command Palette) | ✅ DONE | G1 |
| P3 | Reversibile (optimistic UI + undo) | ✅ DONE per le 4 mutations principali | G3 |
| P4 | Multiple Views (Tree/Canvas/Table/Sankey) | 🔮 V2 | — |
| P5 | AI Grounding (ghost text + agent mode) | ✅ ghost text retrieval-only | G2/G2.1/G2.2 |
| P6 | Keyboard-First (navigation + mnemonic) | ✅ DONE | G1 + G2 + G2.1 + G3 |
| P7 | Progressive Disclosure (Wizard → form → node-graph) | 🔮 V2 (oggi solo Wizard + form) | — |

V1.5 partial materializza P2 + P3 + P5 + P6 parzialmente. V2 full redesign per P1 + P4 + P7 + AI Grounding completo.

## 4. Roadmap GUI

### V1.5 partial — COMPLETE 2026-05-06

```
[x] G1     Command Palette ⌘K          ✅ DONE  3 settimane    PR #5
[x] G2     Ghost Text inventory        ✅ DONE  2 settimane    PR #6
[x] G2.1   Qualifier + layout          ✅ DONE  ~5 ore atomic  (in PR #6)
[x] G2.2   Process split + overflow    ✅ DONE  3 ore           PR #10
[x] G3     Optimistic UI                ✅ DONE  2 settimane    PR #8
[x] B1     Global search backend       ✅ DONE  2 ore           PR #9
[x] A1     Audit a11y baseline          ✅ DONE  audit          PR coord #1
[x] A2     a11y Critical + Serious      ✅ DONE  ~1 settimana   PR #11
[x] A2.1   Link contrast hot fix        ✅ DONE  ~25 min atomic (in PR #11)
```

### V1.5 backlog parking (priorità per dopo)

| # | Sprint | Stima | Priorità |
|---|---|---|---|
| 1 | **A3** Fix a11y Moderate + Minor | ~3-5 gg | MEDIA (no blocker pitch) |
| 2 | **G1.x** Search globale entità — frontend integration palette | 0.5-1 settimana | ALTA |
| 3 | **G2.x** Filter chips UI qualifier (alternativa scopribile a `:tag`) | 3-4 gg | MEDIA |
| 4 | **G2.x** Match-replace popup di RowItem con ghost search | 3-5 gg | MEDIA |
| 5 | **G2.x** ProcessEditor / Wizard ghost text (GhostTextarea multiline) | 1-2 settimane | MEDIA |
| 6 | **Matcher M1 threshold ricalibrazione** | 0.5-1 settimana | ALTA pending Mirko 15 BoM rows |

### V2 strategic backlog (~8-12 settimane post-V1.5 release)

Materializza P1 + P4 + P7 + AI Grounding completo. Possibile pivot stack: TanStack-router + radix-ui + Tldraw o ReactFlow per node-graph canvas.

## 5. Status sprint

| Sprint | Status | Branch | Commit | Data |
|---|---|---|---|---|
| G1 | ✅ DONE merged | `night/G1-command-palette` | `45e5b6f` | 2026-05-05 |
| G2 + G2.1 | ✅ DONE merged | `night/G2-ghost-text-inventory` | `6c9f618` | 2026-05-06 |
| G3 | ✅ DONE merged | `night/G3-optimistic-ui` | `51b70e7` | 2026-05-06 |
| G2.2 | ✅ DONE merged | `night/G2.2-process-split-and-overflow` | `d05e350` | 2026-05-06 |
| B1 | ✅ DONE merged | `night/B1-global-entity-search` | `d98447d` | 2026-05-06 |
| A1 | ✅ DONE merged | `night/A1-a11y-audit` (coord) | report-only | 2026-05-06 |
| A2 + A2.1 | ✅ DONE merged | `claude/fix-a11y-issues-VxP5V` | post #11 | 2026-05-06 |

Baseline post V1.5 partial complete:
- backend pytest **394** + 4 skipped
- frontend vitest **70**
- bundle main **96.11 KB** gzip
- WCAG 2.1 AA: **0/0/0/0** verificato empirico

## 6. Decisioni cross-sprint

| ID | Decisione |
|---|---|
| D-1 | Stack invariato V1.5 (no major version bump) |
| D-2 | Tailwind only, no CSS files custom |
| D-3 | Italiano-only labels |
| D-4 | Accessibility WCAG 2.1 AA non-negotiable — **VERIFIED 2026-05-06** |
| D-5 | Bundle cap +15 KB gzip per sprint, +5 KB hot fix, +1 KB micro-fix |
| D-6 | `registerCommand` superficie unica AI-native |
| D-7 | Context-awareness via pathname |
| D-8 | Test setup condiviso (`setupTests.ts` con polyfill) |
| D-9 | localStorage solo UX state non sensibile |
| D-10 | REPORT post-sprint obbligatorio |
| D-11 | Numerazione ADR cumulativa col MASTER_PLAN |
| D-12 | UI inventory step pre-flight ogni sprint G\* |
| D-13 | Atomic same-branch cleanup per hot fix sprint correlati |
| D-14 | Design tokens semantici separati per `bg-` vs `text-` quando il tool è dark theme (lezione A2.4 → A2.1) |
| D-15 | WCAG verification deve coprire SIA fg-su-bg-chiari SIA fg-su-bg-scuri (lezione A2.1) |
| D-16 | axe-core re-run è gating per merge sprint a11y (lezione A2 → A2.1) |

## 7. Riferimenti

Repo coordination: https://github.com/mirkobusto/lca-tool-coordination

Audit a11y procedure:
1. Tool running (`./scripts/sync-and-start.sh`)
2. `cd frontend && node scripts/audit-a11y.mjs`
3. Verificare 0 Critical / 0 Serious prima di merge sprint a11y

---

**Fine DESIGN_GUI v1.5 — 2026-05-06.**
