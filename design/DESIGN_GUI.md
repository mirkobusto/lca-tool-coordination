# DESIGN_GUI — master document Architect-GUI

> Documento vivente. Sorgente di verità per il workstream GUI (V1.5/V2).
> Mantenuto dalla **chat Architect-GUI** (parallela a Architect main).
> Letto da Claude Code dev all'inizio di ogni sprint G\*.
> Prima versione: **2026-05-05** (post-merge G1 Command Palette).

---

## 1. Purpose

Questo documento è la bussola del redesign GUI del tool LCA. Tiene insieme tre cose: la diagnosi del Kimi research dossier (perché V1 va evoluta), i sette principi di design che guidano le scelte sprint-by-sprint, e lo stato di avanzamento concreto degli sprint G\* (Gn = GUI sprint n) che materializzano quei principi nel codebase.

Si rivolge a tre lettori distinti. **Mirko**: ha qui in pagina lo stato GUI senza dover leggere ~80 pagine di dossier Kimi ogni volta. **Architect-GUI** (questa chat): usa il documento come memoria persistente delle decisioni cross-sprint per non rideciderle ad ogni SPEC. **Claude Code dev**: legge questo documento + la SPEC dello sprint corrente all'inizio del lavoro, e ha tutto il contesto strategico per le decisioni autonome di implementazione.

Il MASTER_PLAN principale (gestito da Architect main) resta autoritativo per architettura tool nel suo insieme, roadmap M\*, ADR cross-modulo. Questo documento è autoritativo solo per il sotto-dominio GUI: principi, pattern, sprint G\*, decisioni di design system. In caso di conflitto fra MASTER_PLAN §12 e questo documento, MASTER_PLAN §12 vince — questo documento si allinea.

## 2. Stack frontend V1 rilevato

Il V1 attuale del tool è uno stack React moderno ma senza primitive AI-native. Il dettaglio rilevato post-G1:

- **React 18.x** + **TypeScript** + **Vite** (build tool)
- **Tailwind CSS** (utility-first, no CSS files custom)
- **TanStack Query** per data fetching e mutations
- **zustand** per stato client (slice per dominio, no slice globale unica)
- **react-router-dom 6.26.2** per routing client-side
- **Vitest 4.1.5** + **@testing-library/react 16.3.2** + **jsdom 29.1.1** per test (introdotto in G1 — assente in baseline)
- **cmdk 1.1.1** per command palette (introdotto in G1)
- **~120 modules** circa nel codebase frontend pre-sprint

Rotte effettive (non assumere altre senza verifica):
- `/` → Home/Project list
- `/projects` → elenco progetti
- `/projects/:pid` → dettaglio progetto (BoM, parametri, scenari)
- `/projects/:pid/match` → matching BoM↔ecoinvent
- `/projects/:pid/wizard` → wizard ISO+ILCD

Niente `/wizard`, `/bom`, `/compliance`, `/modelling-guide` standalone — tutto è scoped sul progetto corrente. Pattern "project-first" coerente con il workflow consulente reale. Carry-over potenziale (V1.5/V2): introdurre pagine global (template/wizard senza progetto attivo) se il volume utenti lo giustifica.

Componenti rilevanti già in produzione che la GUI roadmap deve rispettare e potenziare (no riscrittura):
- Wizard ISO+ILCD (M2.1 + M2.x.2) — situation A/B/C1/C2 filtering
- BomTable nel match page
- ProcessEditor minimale
- ComplianceBanner.tsx (banner UI per rule 5 disclosure)
- Generatore Modelling Guide PDF (M2.3.1)
- Project store JSON-blob, schema_version=6

Backend FastAPI con prefisso `/api/...`. Endpoint rilevanti per GUI (signature da verificare al pre-flight di ogni sprint):
- `POST /api/projects/{pid}/build_zolca` (download .zolca)
- `GET /api/projects/{pid}/data_collection_template.xlsx`
- `GET /api/projects/{pid}/compliance`
- `POST /api/projects/{pid}/modelling_guide`

ChromaDB embedding index del matcher M1 (multilingual-e5-large, 1024-dim, 23k processi ecoinvent indicizzati): presente, motore di retrieval per il ghost text in G2 (vedi SPEC G2 §3).

## 3. I sette principi Kimi

Il Kimi research dossier (~80 pagine, folder Drive `Substitute HiQ cortex/Kimi_Agent_gui/`) ha mappato 27 software LCA, 60+ tool da altri domini, 80+ paper accademici, e ha condensato i sette principi che reggono il redesign.

**P1 — Intent-First, non Graph-First**. La schermata iniziale risponde all'intento implicito "cosa devo fare oggi?", non a "cosa vuoi fare?". Sostituisce il canvas vuoto / albero gerarchico con dashboard composta da Quick Actions + Active Projects con progresso visibile + AI Suggestions contestuali + Recent Activity + Compliance at a Glance. Risolve la learning curve 90% citata in sec04.

**P2 — Search-First, non Navigation-First**. Command palette ⌘K universale come entry point per tutte le azioni. Pattern Linear/Raycast. Sostituisce gerarchie di menu con fuzzy search globale. **Materializzato in G1** (sprint corrente, merged main 2026-05-05).

**P3 — Reversibile**. Undo/redo nativo, optimistic UI con rollback, niente `.save()` esplicito. Ogni modifica è atomica e rollback-safe. Materializzato parzialmente in G1 (palette ESC, registry idempotente). Materializzazione piena in G3 (TanStack Query optimistic mutations).

**P4 — Multiple Views**. Lo stesso modello LCA visualizzato come Tree / Canvas / Table / Sankey / Treemap, switch istantaneo via `⌘1..5`. Pattern Houdini/Blender/Notion. Pattern V2 (full redesign), non in V1.5 partial.

**P5 — AI Grounding**. Suggerimenti AI con confidence score esplicito, fonte citata (database + version + ID), sourcing trasparente. Mitigation hallucination 37-40% su dati ambientali. **G2 (Ghost Text)** materializza la versione retrieval-only (no LLM in loop, lookup vettoriale puro su ChromaDB matcher index — più sicuro). V2 introduce Agent Mode con LLM in loop.

**P6 — Keyboard-First, Mouse-Optional**. Navigation `j/k`, `⌘Enter` calcolo, mnemonic mapping `g`+lettera Linear-style, shortcut numerici per view switch. Materializzato in G1 (palette + 8 mnemonic shortcut). Espanso in G2/G3 con shortcut accept ghost text (Tab) e undo (`⌘Z`).

**P7 — Progressive Disclosure**. Wizard guidato (~1h primo modello) → form parametri → node-graph esperto. Tre layer di profondità sempre disponibili, default sul layer più basso adatto al task. Pattern V2 (full redesign).

I principi si rinforzano a vicenda. Adottarne solo alcuni produce frizione nei punti di contatto: una palette ⌘K (P2) senza optimistic UI (P3) lascia l'utente in attesa dopo ogni invio, vanificando il keyboard-first (P6); un ghost text (P5) senza palette (P2) è scoperto solo da chi lo trova per caso. La sequenza V1.5 partial G1→G2→G3 è scelta per copertura accumulativa: ogni sprint chiude un gap visibile.

## 4. Roadmap GUI

### V1.5 partial — 3 sprint sequenziali (~7 settimane totali)

**G1 — Command Palette ⌘K** (~3 settimane). Materializza P2 + P6. Status: ✅ **DONE 2026-05-05**, merged main, commit `6815de6`. Bundle delta +3.04 KB gzip su main + lazy chunk 17 KB. 14 comandi (5 nav + 9 act). 12/12 vitest pass. Backend invariato. Vedi SPEC_G1, REPORT_G1.

**G2 — Ghost Text inventory** (~2 settimane). Materializza P5 (versione retrieval-only) + estende P2/P6. Status: 📝 **SPEC scritta 2026-05-05** (`SPEC_G2_ghost_text.md`), pronta per Claude Code. Aggancio: BomTable cells dentro `/projects/:pid/match`. Backend: nuovo endpoint `/api/projects/{pid}/suggest` che leva ChromaDB matcher index esistente. Frontend: input wrapper component con ghost text inline, Tab accetta, Esc dismisses.

**G3 — Optimistic UI** (~2 settimane). Materializza P3 + estende P5 (rollback su rifiuto AI). Status: 📋 **backlog**, SPEC da scrivere post-G2 merge. Aggancio: TanStack Query mutations su BomRow quantity, parametri, scenari. Pattern: `onMutate` aggiorna cache locale immediatamente, `onError` rollback con toast.

### V2 — full redesign (~8-12 settimane, post-V1.5)

Materializza P1 (Intent-First dashboard) + P4 (Multiple Views) + P7 (Progressive Disclosure layer 3 node-graph) + AI Grounding completo (Agent Mode con plan visibile). Possibile pivot stack: TanStack-router + radix-ui + Tldraw o ReactFlow per node-graph canvas. Decisione di pivot rimandata a fine V1.5 — lo stack attuale potrebbe reggere V2 senza riscrittura major.

V2 è scope decisione strategica: dipende da feedback V1 release + interesse mercato premium (V1.5 tier 399-599 EUR/mo) + capacity team. Non plannato in dettaglio in questa versione di DESIGN_GUI.md — sarà aggiornato post-V1 release.

### Cosa non facciamo (constraint cross-sprint)

- ❌ **Niente node-graph canvas** in V1.5 (P4 layer 3) — V2 only
- ❌ **Niente CRDT real-time multiplayer** — V2/V3, target consulente medio è asincrono
- ❌ **Niente Git-like branch/merge sui modelli** — V2/V3
- ❌ **Niente full WebGL Sigma.js per 1K+ nodi** — il target di consulente medio fa modelli 50-200 processi
- ❌ **Niente i18n** in V1.5 — italiano-only labels (target consulente LCA italiano)
- ❌ **Niente major version bump** delle librerie esistenti senza approvazione esplicita

## 5. Status sprint

| Sprint | Status | Branch | PR | Commit | Data merge |
|---|---|---|---|---|---|
| G1 — Command Palette ⌘K | ✅ DONE | `night/G1-command-palette` | merged | `6815de6` | 2026-05-05 |
| G2 — Ghost Text inventory | 📝 SPEC scritta | — | — | — | — |
| G3 — Optimistic UI | 📋 backlog | — | — | — | — |
| V2 — full redesign | 🔮 strategic | — | — | — | — |

**Contesto backend al merge G1**: catena M3.1.0.x + M3.1.1 chiusa lato backend (PR #4 squash, commit `b8d6002`, 2026-05-05 ~01:00). 366 default + 4 preflight pytest skip senza env var = 370 totali. Lo sprint G1 era una delle tre opzioni next sprint (M3.1.2 CF reali / M3.2 LCIA re-import / G1 Command Palette) elencate nello `_CURRENT_STATE_20260505_0100.md` — Mirko ha scelto G1 e l'ha aperto in chat parallela Architect-GUI, mantenendo libero il workstream backend (Architect main resta su decisione M3.1.2 vs M3.2).

### G1 done snapshot

**Cosa abbiamo ottenuto** (REPORT_G1 §6, file id `1cv1bbREFuCk7eLNGKVIRhRs8Wi_U-kQs`):
- Palette ⌘K / Ctrl+K apre da qualsiasi route, ESC chiude con focus restore
- 14 comandi registrati al bootstrap (5 nav `g`+lettera Linear-style + 9 act `⌘`/`⌘⇧`+lettera)
- Mnemonic shortcut funzionano senza aprire palette (es. `⌘⇧V` → validate compliance)
- Recent commands persistiti in localStorage (`lca-tool.command-palette.recent`, max 5)
- API `useCommandRegistry.registerCommand()` esposta come superficie estensione G2/V2 (idempotente sull'id, supporta unregister, context-aware via `getCommands(context)`)
- Accessibility ARIA combobox + listbox + option + dialog modale, focus trap + restore
- Bundle main +3.04 KB gzip, palette UI in lazy chunk 17 KB caricato solo al primo ⌘K
- 12 vitest pass distribuiti su 4 file (registry, useCommandSearch, useGlobalShortcuts, CommandPalette)

**Carry-over G1 → G1.x backlog** (per Architect-GUI sprint futuro):
1. **Search globale entità** (priorità ALTA) — richiede endpoint backend nuovo `/api/search/global?q=...&types=process,flow,parameter,bom_row`. Stima 1-2 settimane backend + 0.5 frontend. Sblocca palette per cercare entità del modello, non solo comandi.
2. **act.calculate-preflight come REST** (priorità MEDIA) — oggi M3.1.0.7 preflight openLCA è solo pytest opt-in; per esporlo come comando palette serve `POST /api/projects/{pid}/preflight` async + SSE stream. Coordinato con M3.1.x backend.
3. **Routes standalone** (priorità BASSA) — `/wizard`, `/bom`, `/compliance` global non scoped a progetto. Coerente con possibile evoluzione UX V1.5+.
4. **Theme toggle dedicato** (priorità BASSA) — palette ha `act.toggle-theme`? Richiede store `useTheme` nel V1, non esiste. Se V1.5 introduce dark mode esplicito, comando si aggancia.
5. **act.import-bom-xlsx come file picker reale** (priorità BASSA) — oggi naviga al detail page; un `<input type="file">` triggerato da palette + chiamata diretta a backend = one-shot. Stima 1 giorno.
6. **Telemetry opt-in** (priorità BASSA) — track quali comandi sono usati di più. Privacy concern, default disabilitato.

## 6. Decisioni cross-sprint (design system + tech)

Decisioni che valgono per tutti gli sprint G\*, prese una volta in G1 e non più rimesse in discussione salvo escalation esplicita.

**D-1 — Stack invariato fino a fine V1.5**. React 18 + Vite + TS + Tailwind + TanStack Query + zustand + react-router-dom 6 + cmdk + Vitest. Niente major version bump. Niente nuovo router. Niente nuovo state manager. Eventuali pivot a TanStack-router / radix-ui / Tldraw rimandati a V2 strategic decision.

**D-2 — Tailwind only, no CSS file custom**. Tutto styling via utility classes. Eventuale necessità di colore non in `tailwind.config.js` → escalation Mirko prima dell'aggiunta. Dark mode aware via class strategy (`dark:bg-neutral-900` etc.) — anche se V1 non ha toggle esplicito.

**D-3 — Italiano-only labels**. Niente i18n introdotta in V1.5 partial. Target utente: consulente LCA italiano. ARIA attributes generati da cmdk e altre librerie restano in inglese (OK, screen reader li gestisce).

**D-4 — Accessibility WCAG 2.1 AA non-negotiable**. Sblocco mercato istituzionale (committenti EU lo richiedono). Ogni componente UI nuovo: role ARIA appropriato, keyboard navigation completa, focus visible, screen reader compatibile. Test manuale VoiceOver/NVDA delegato a Mirko per ogni sprint (non automatizzabile a livello che cattura tutti i casi).

**D-5 — Bundle cap +15 KB gzip per sprint sul main chunk**. Cap volutamente stretto per disciplinare. Sforare → escalation Mirko prima del merge. Lazy chunk OK senza cap (si caricano on-demand). Alternativa al cap: sub-target +5 KB per ogni feature minore, +15 KB per feature principale.

**D-6 — registerCommand è la superficie unica AI-native**. Tutti gli sprint G\* che vogliono contribuire azioni accessibili da palette o da shortcut le registrano via `useCommandRegistry.registerCommand`. Niente parallel registry, niente bypass. G2 ghost text registra suggest dinamici (con cleanup unregister obbligatorio). G3 optimistic UI può registrare azioni di rollback. V2 Agent Mode userà la stessa superficie per i plan steps.

**D-7 — Context-awareness via pathname**. La palette risolve `currentProjectId` da regex sul pathname (`/^\/projects\/([^/]+)/`). Pattern già implementato in G1. G2/G3 lo riusano per scoping comandi/suggest a un progetto/route specifico.

**D-8 — Test setup condiviso**. `setupTests.ts` con polyfill `ResizeObserver` + `Element.prototype.scrollIntoView` (jsdom non li supporta), reset zustand store dopo ogni test. G2/G3 estendono lo stesso file invece di crearne nuovi. Vitest config in `vitest.config.ts` resta quello introdotto in G1.

**D-9 — Persistence localStorage solo per UX state non sensibile**. Recent commands, preferenze UI, pin di palette favorites: OK. Mai dati di progetto, mai PII, mai credentials. Chiave naming: `lca-tool.<feature>.<scope>` (es. `lca-tool.command-palette.recent`).

**D-10 — REPORT post-sprint obbligatorio**. Ogni sprint G\* termina con `REPORT_G<n>-<topic>_YYYYMMDD_HHMM.md` su Drive folder Substitute HiQ cortex, formato 10 sezioni (status, pre-flight, file toccati, architettura, test design, done criteria, decisioni autonome, constraints, carry-over, note). Pattern già rispettato in G1 — vedi REPORT_G1.

**D-11 — Numerazione ADR cumulativa col MASTER_PLAN**. Gli ADR generati dagli sprint G\* si numerano in continuità con la running list del MASTER_PLAN §6, non in serie separata. Stato ADR cumulativo al merge G1 (post-M3.1.1 + post-G1): l'ultimo ADR ufficialmente registrato nel MASTER_PLAN attivo è 31 (Kimi dossier); lo `_CURRENT_STATE_20260505_0100.md` aggiunge cumulativamente 32 (M3.1.1 LCIA scaffolding-only), 33 (Deterministic Build Contract 4 pattern), 34 (verify merge before branch delete). Il primo ADR per G1 è quindi **35**, da aggiungere al MASTER_PLAN §6 con copy del MASTER_PLAN o via Architect main. Ogni sprint G\* successivo incrementa.

## 7. Riferimenti

**Kimi research dossier** (folder Drive `Substitute HiQ cortex/Kimi_Agent_gui/`, id `1pT-t-kUc4oLLWUjxW1EQLzTkqlVPBJTm`):
- `lca_ui_studio_sec05.md` — 7 principi (riferimento per ogni SPEC G\*)
- `lca_ui_studio_sec06.md` — 5 mockup + 3 user journey + MoSCoW + stack tech + rischi
- `lca_ui_studio_sec08.md` — glossario 30 pattern UI con confidenza trasferibilità

**Documenti Architect-GUI** (folder Drive `Substitute HiQ cortex/`):
- `_GUI_BOOTSTRAP_20260505.md` — bootstrap della chat Architect-GUI
- `SPEC_G1_command_palette.md` — sprint G1
- `REPORT_G1-command-palette_20260505_0912.md` — sprint G1 chiusura
- `SPEC_G2_ghost_text.md` — sprint G2 (questa versione)
- `DESIGN_GUI.md` — questo documento

**MASTER_PLAN principale** (id `1G5eDWO4AJgFoAoU74d_zDGhxWiNC-c68`, file `MASTER_PLAN_20260505.md`): autoritativo per **Vision + architettura + ADR + roadmap strategica**. Sezioni rilevanti per Architect-GUI:
- §1 Vision
- §2 Roadmap (M\* milestone backend/modeling)
- §3.6 Premium tier V1.5
- §6 ADR running list (cumulative, vedi D-11 sopra: ADR 35+ per sprint G\*)
- §9 Backlog parking lot V1.5/V2
- §12 GUI Redesign — Kimi research dossier (autoritativo per scope GUI)

**\_CURRENT\_STATE_*.md** (ultima versione canonical: `_CURRENT_STATE_20260505_0100.md` id `1gQElJe5RG2cgseM6l67khadkJ4_X7S9T`): autoritativo per **stato day-by-day** — quale sprint è chiuso oggi, commit hash main, test count backend, file `.zolca` attivo, dev box state, ADR cumulativi non ancora consolidati nel MASTER_PLAN. Update frequenza: a ogni merge importante (es. `_0030` → `_0100` post-merge M3.1.1). Architect-GUI lo legge al pre-flight di ogni sprint per verificare baseline numerica reale (test count, bundle size baseline, branch protection, etc.). In caso di conflitto fra MASTER_PLAN §2 Roadmap "in code" e STATE "merged main", lo STATE vince — il MASTER_PLAN viene aggiornato nelle finestre di sintesi. Lo STATE precedente (`_0030`) è già storia, non riferimento.

**Esterno**:
- cmdk docs: <https://cmdk.paco.me/>
- Linear keyboard shortcuts: <https://linear.app/docs/keyboard-shortcuts>
- Cursor ghost text patterns: <https://cursor.sh/features>
- WCAG 2.1 AA: <https://www.w3.org/WAI/WCAG21/quickref/>

---

**Fine DESIGN_GUI v1.1 — 2026-05-05.**

*Changelog: v1.0 → v1.1: aggiunta D-11 (numerazione ADR cumulativa col MASTER_PLAN, ADR 35+ per G\*). §5 contestualizza G1 come 1 di 3 opzioni next sprint scelta da Mirko post-M3.1.1. §7 riorganizza riferimenti distinguendo MASTER\_PLAN (strategia) da \_CURRENT\_STATE (stato day-by-day, autoritativo per baseline numerica al pre-flight di ogni sprint).*
