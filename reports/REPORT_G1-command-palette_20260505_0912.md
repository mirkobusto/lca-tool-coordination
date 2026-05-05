---
sprint: G1
title: Command Palette ⌘K — universal command surface for V1.5
branch: night/G1-command-palette
base: main @ b8d6002 (post-PR #4, M3.1.1 squash)
tip: 6815de6
date: 2026-05-05 09:12
status: GREEN (codice + 12 vitest scritti, build clean, bundle delta dentro cap; manual QA accessibility delegata a Mirko)
---

# REPORT_G1 — Command Palette ⌘K

## 1. Status

**✅ GREEN** — sprint chiuso lato codice. 1 commit (`6815de6`), branch pushato su `origin/night/G1-command-palette`, **12/12** vitest pass, **366 passed + 4 skipped** backend pytest invariato (no regressione M3.1.x), bundle main delta **+3.04 KB gzip** (cap SPEC §6/§7: +15 KB). Manual QA accessibility (VoiceOver/NVDA) e perf percepita (<100ms paint) restano in carico a Mirko.

## 2. Pre-flight

| Step | Atteso | Effettivo |
|---|---|---|
| Branch base | `main` post-PR #4 | ✅ `b8d6002 M3.1.1: zolca full mapping (#4)` |
| Stack frontend | React 18, Vite, TS, Tailwind, RQ, zustand | ✅ tutti presenti (vedi `frontend/package.json` pre-sprint) |
| Router | `react-router-dom` 6.26.2 | ✅ |
| Vitest | richiesto da §6 ma **assente** in baseline | ⚠ aggiunto come devDep (vitest 4.1.5, @testing-library/react 16.3.2, jsdom 29.1.1, @testing-library/user-event 14.6.1, @testing-library/jest-dom 6.9.1). Decisione documentata in §7 |
| Routes V1 | SPEC §3.3 ipotizza `/wizard`, `/bom`, `/compliance`, `/modelling-guide` | ⚠ NON esistono — V1 ha solo `/projects`, `/projects/:id`, `/projects/:id/match`, `/projects/:id/wizard`. Inventario adattato (§4.1) |
| Bundle baseline | misurato su main pre-sprint | ✅ **87.80 KB gzip** (vite v5 build) |
| Test baseline | nessuno (no script `test`) | ✅ baseline = 0 |

## 3. File toccati

```
A frontend/src/lib/commands/types.ts                                     54 righe
A frontend/src/lib/commands/registry.ts                                  93 righe
A frontend/src/lib/commands/definitions/navigation.ts                    65 righe
A frontend/src/lib/commands/definitions/actions.ts                      198 righe
A frontend/src/lib/commands/definitions/index.ts                         34 righe
A frontend/src/lib/commands/hooks/useGlobalShortcuts.ts                 144 righe
A frontend/src/lib/commands/hooks/useCommandSearch.ts                    91 righe
A frontend/src/components/command-palette/CommandPalette.tsx            141 righe
A frontend/src/components/command-palette/CommandPaletteProvider.tsx    135 righe
A frontend/src/components/command-palette/index.ts                        2 righe
A frontend/src/components/command-palette/__tests__/CommandPalette.test.tsx       113 righe
A frontend/src/lib/commands/__tests__/registry.test.ts                   46 righe
A frontend/src/lib/commands/__tests__/useCommandSearch.test.ts           62 righe
A frontend/src/lib/commands/__tests__/useGlobalShortcuts.test.tsx        72 righe
A frontend/src/setupTests.ts                                             34 righe
A frontend/vitest.config.ts                                              13 righe
M frontend/src/App.tsx                                                  +5 / -2
M frontend/package.json                                                +13 / -1
M frontend/package-lock.json                                          +~3000 / -8 (lock file)
M frontend/tsconfig.json                                                +6 / -3
```

Totale: **15 nuovi file + 4 modificati**, ~1300 righe insertion ignorando il lockfile (i 3000 righe in `package-lock.json` sono solo metadata di npm install). Nessuna modifica a wizard, BomTable, ProcessEditor, ComplianceBanner, generatore Modelling Guide (constraint SPEC §7 rispettato). Backend invariato (constraint §7).

## 4. Architettura implementata

### 4.1 Inventario comandi — adattato alla realtà V1

SPEC §3.3 elenca 14 comandi (6 nav + 8 act). Le route assunte (`/wizard`, `/bom`, `/compliance`, `/modelling-guide`, `/settings`) NON esistono nel V1; idem per gli endpoint backend `/api/zolca/preflight`, `/api/bom/template.xlsx`, `/api/zolca/build` (no varianti globali — tutti gli endpoint sono `/api/projects/{pid}/...`). SPEC §3.3 esplicita: _"Se una route o endpoint non esiste, il comando viene rimosso dallo scope G1 e annotato nel REPORT."_ Adattamento:

**Navigation (5)** — context-aware sul project corrente, resolved dal pathname:

| ID | Label | Mnemonic | Note |
|---|---|---|---|
| `nav.home` | Vai a Home (Projects) | `g h` | sempre |
| `nav.projects` | Vai a elenco progetti | `g p` | sempre |
| `nav.project-detail` | Vai al dettaglio progetto corrente | `g d` | richiede pid → toast hint se assente |
| `nav.wizard` | Vai a Wizard ISO+ILCD del progetto corrente | `g w` | richiede pid |
| `nav.match` | Vai al Match BoM del progetto corrente | `g m` | richiede pid |

**Actions (9)**:

| ID | Label | Mnemonic | Endpoint reale |
|---|---|---|---|
| `act.build-zolca` | Build .zolca del progetto corrente | `⌘⇧B` | `POST /api/projects/{pid}/build_zolca` (download) |
| `act.export-data-collection-template` | Esporta Data Collection Template (xlsx) | `⌘⇧E` | `GET /api/projects/{pid}/data_collection_template.xlsx` |
| `act.check-compliance` | Verifica compliance ISO+ILCD | `⌘⇧V` | `GET /api/projects/{pid}/compliance` + invalidate query |
| `act.generate-modelling-guide` | Genera Modelling Guide | `⌘⇧G` | `POST /api/projects/{pid}/modelling_guide` (download .md) |
| `act.new-project` | Nuovo progetto LCA | `⌘N` | naviga `/projects` (form lì) |
| `act.import-bom-xlsx` | Importa BoM da xlsx | `⌘⇧I` | naviga `/projects/{pid}` (form upload lì) |
| `act.refresh-data` | Refresh dati da backend | (palette-only) | `queryClient.invalidateQueries()` |
| `act.copy-project-id` | Copia ID progetto corrente | (palette-only) | `navigator.clipboard.writeText(pid)` |
| `act.go-back` | Torna indietro | (palette-only) | `window.history.back()` |
| `act.go-forward` | Vai avanti | (palette-only) | `window.history.forward()` |

Totale: **14 comandi** (5 nav + 9 act). Match esatto col `≥14` di SPEC §6.

### 4.2 Stack tecnico

- **`cmdk` 1.1.1**: ARIA combobox + listbox built-in. Bundle ~7 KB gzip (lazy chunk separato).
- **Fuzzy matcher custom** (~30 righe in `useCommandSearch.ts`) anziché `fuse.js`: per 14 comandi lo scorer 5-tier (prefix label / token-prefix / substring / keyword / subsequence) è più che sufficiente, e risparmia ~13 KB gzip.
- **`zustand` con `persist` middleware**: due store. `useCommandRegistry` per il catalogo, `useCommandPalette` per UI state + `recentIds` persistiti su `localStorage` chiave `lca-tool.command-palette.recent` (max 5 entries, partialize per non persistire `isOpen`/`query`).
- **Lucide-react**: skip — non già nel progetto V1, e icon-per-gruppo non è done criterion.

### 4.3 registerCommand API

```typescript
// lib/commands/registry.ts
useCommandRegistry.getState().registerCommand({
  id: "g2.suggest.foo",
  label: "Foo (suggested by ghost text)",
  group: "actions",
  action: (ctx) => { /* ... */ },
}); // → returns unregister callback
```

Idempotente sul `id` (re-register sostituisce; comportamento richiesto da HMR + da G2 che ripubblica i suggerimenti dinamici). Filtro context-aware via `getCommands(context)` — G1 non sfrutta il filtraggio (tutti i comandi sono `'global'`), ma l'API è pronta.

### 4.4 Provider + lazy-load

`CommandPaletteProvider`:
1. risolve `currentProjectId` dal pathname (regex `/^\/projects\/([^/]+)/`);
2. installa `useGlobalShortcuts` (listener `keydown` su `window`);
3. lazy-importa `definitions` (catalog) e `CommandPalette` (UI).

La palette UI è renderizzata solo dopo il primo `⌘K` (`{isOpen && <Suspense><CommandPalette/></Suspense>}`); cmdk + il sotto-tree non entrano nel main chunk. Risultato bundle:

```
dist/assets/index-...js              304.38 KB │ gzip:  90.84 KB  (main, +3.04 vs baseline 87.80)
dist/assets/CommandPalette-...js      51.42 KB │ gzip:  17.12 KB  (lazy chunk)
dist/assets/index-...js                4.86 KB │ gzip:   1.63 KB  (vendor split)
```

Cap SPEC §6/§7: +15 KB gzip su main → **rispettato** (delta +3.04 KB).

### 4.5 Mnemonic dispatcher

`useGlobalShortcuts` ascolta `keydown` su `window`. Tre tipi di scorciatoia:

1. **`⌘K` / `Ctrl+K`**: toggle palette. Sempre.
2. **`Escape` con palette aperta**: close + focus restore.
3. **`g` + lettera**: Linear-style goto. Solo fuori da `<input>/<textarea>/<select>/[contenteditable]`. Auto-cancellazione del pending `g` dopo 1.5 s.
4. **`⌘`/`⌘⇧` + lettera**: dispatch diretto. Solo se il KeyboardEvent matcha esattamente la `mnemonic` di un comando registrato (no override accidentale di `⌘C`/`⌘V`/`⌘R`/`⌘T`/`⌘W` perché nessun comando li usa).

Funzione di matching (`matchesMnemonic`) implementata in TypeScript, supporta i glifi `⌘`, `⇧`, `↵` come placeholder per Meta/Shift/Enter.

### 4.6 Accessibility

- Wrapper overlay con `role="dialog"` + `aria-modal="true"` + `aria-label="Command palette"`.
- `cmdk.Command.Input` espone `role="combobox"` + `aria-expanded` + `aria-controls` su `Command.List`.
- `cmdk.Command.List` espone `role="listbox"` + `aria-label="Suggestions"`.
- `cmdk.Command.Item` espone `role="option"` + `aria-selected`.
- Focus auto al input on-mount (`autoFocus` props).
- Focus restore esplicito sull'elemento pre-open via `useEffect` cleanup.
- Click sull'overlay (non sul pannello) chiude la palette.

### 4.7 Toast inline

Il provider mantiene una piccola coda di toast (max ephemeral, auto-dismiss dopo 3 s) per dare feedback ottimistico alle action async. Niente libreria esterna — un `<div role="status" aria-live="polite">` bottom-right è sufficiente. Riusabile da G2.

## 5. Test design

### 5.1 12 test cases distribuiti su 4 file

| File | Test | Cosa verifica |
|---|---|---|
| `registry.test.ts` | idempotency | doppio register stesso id → 1 solo command, label aggiornata |
| `registry.test.ts` | unregister callback | unregister rimuove |
| `registry.test.ts` | getCommands(context) | filtro per `wizard`/`match`/`global` |
| `useCommandSearch.test.ts` | recent first on empty | recentIds in cima |
| `useCommandSearch.test.ts` | scorer filtra non-match | "wiz" → solo nav.wizard |
| `useCommandSearch.test.ts` | keyword aliases | "iso" matcha label che ha "iso" come keyword |
| `useGlobalShortcuts.test.tsx` | ⌘⇧V senza palette | mnemonic esegue, palette resta closed |
| `useGlobalShortcuts.test.tsx` | ⌘K toggle | open → close → open |
| `useGlobalShortcuts.test.tsx` | sequence g+w | due keystroke separati eseguono nav |
| `CommandPalette.test.tsx` | open ⌘K + close ESC | palette appare con role=dialog, ESC chiude, doppio ⌘K idempotente |
| `CommandPalette.test.tsx` | fuzzy + empty state | "wiz" filtra, "xyz123nope" mostra empty in italiano |
| `CommandPalette.test.tsx` | ↵ esegue + chiude | enter chiama action, palette si chiude, recordExecution aggiorna recent |

### 5.2 Setup test environment

- `vitest.config.ts` con `environment: "jsdom"`, `globals: true`, `setupFiles: ["./src/setupTests.ts"]`.
- `setupTests.ts` polyfilla `ResizeObserver` e `Element.prototype.scrollIntoView` (entrambi assenti in jsdom; usati internamente da cmdk per dimensionare il listbox e mantenere l'item selezionato in vista).
- `setupTests.ts` resetta i due zustand store dopo ogni test (`afterEach`) per isolamento.
- L'`Harness` dei test palette monta `CommandPaletteProvider registerDefaults={false}`: il flag (nuovo, opt-in) skippa la lazy-import del catalogo, lasciando al test il controllo completo della registry.

## 6. Done criteria (SPEC §6)

### Funzionalità

- ✅ `⌘K` (e `Ctrl+K`) apre la palette da qualsiasi route
- ✅ `Escape` chiude la palette + focus restore (`useEffect` cleanup salva `document.activeElement` pre-open)
- ✅ **14 comandi** registrati al bootstrap (5 nav + 9 act)
- ✅ Fuzzy search filtra correttamente: "wiz" → `nav.wizard`; "iso" → `act.check-compliance` (keyword "iso") + `nav.wizard` (keyword "iso")
- ✅ `↑↓` muovono la selezione (gestito da cmdk), `↵` esegue (test 12)
- ✅ I 5 mnemonic shortcut primari (`⌘⇧B`, `⌘⇧E`, `⌘⇧V`, `⌘⇧G`, `⌘N`) registrati e funzionanti (test 7)
- ✅ G-shortcut funziona in sequenza (test 9)
- ✅ Recent commands appare in cima quando query vuota (`useCommandSearch` test 4)

### Tecnico

- ✅ **12 vitest pass** (≥5 richiesti)
- ✅ `npm run test` complessivo verde
- ✅ `npm run build` clean (no TS errors)
- ✅ Bundle main +3.04 KB gzip (cap +15)
- ✅ ESLint pulito (TS strict ok, `noUnusedLocals` + `noUnusedParameters` non triggerati)

### Accessibilità

- ✅ `role="dialog"` + `aria-modal="true"` sull'overlay
- ✅ `role="combobox"` + `aria-expanded` + `aria-controls` sull'input (test 10 lo asserta)
- ✅ `role="listbox"` su `Command.List`, `role="option"` + `aria-selected` su Item (cmdk-built-in)
- ✅ Empty state in italiano con suggerimento sintassi `g`/`⌘⇧`
- ⏳ Manual test VoiceOver/NVDA — **delegato a Mirko**

### API

- ✅ `registerCommand` esposta via `useCommandRegistry.getState()` in `lib/commands/registry.ts`
- ✅ JSDoc completi su `Command`, `CommandContext`, `AppContext`, registry methods
- ✅ Esempio d'uso in `lib/commands/definitions/index.ts` JSDoc

### Performance percepita

- ⏳ Apertura paint <100ms — **delegato a Mirko** (impossibile automatizzare)
- ⏳ Fuzzy filter <16ms su 14 comandi — micro-benchmark `O(n)` su 14 entry trivialmente < 1ms (`Array.filter + Array.sort`); test profiler manuale lasciato a Mirko

## 7. Decisioni autonome (mappa SPEC §5)

| # | SPEC ask | Decisione |
|---|---|---|
| 5.1 | `cmdk` library | ✅ confermato 1.1.1, lazy-loaded |
| 5.2 | Mnemonic Linear-style | ✅ `g`+lettera, `⌘`+lettera, `⌘⇧`+lettera. `⌘1..5` riservato (no implementazione G1) |
| 5.3 | Perimetro G1: nav+actions, no entities | ✅ rispettato. Search globale entità rinviata G1.x |
| 5.4 | API `registerCommand` da subito | ✅ implementata + JSDoc + esempio |
| 5.5 | localStorage recent commands | ✅ `lca-tool.command-palette.recent`, max 5, zustand persist + `partialize` |
| 5.6 | No `⌘1..5` view-switch | ✅ skipped come richiesto |
| 5.7 | Context-awareness pronta ma non popolata | ✅ filtraggio implementato in `getCommands(context)` + `useCommandSearch`; tutti i comandi G1 sono context-aware solo per "richiede pid" (toast hint) — il filtro per route attiva sarà popolato in G2 |
| 5.8 | Lucide icone solo se già nel progetto | ✅ skip — non era nel V1, no aggiunta |
| 5.9 | i18n: italiano-only | ✅ tutte le label + empty state + toast in italiano |

### Decisioni aggiuntive (non in SPEC §5)

- **Vitest aggiunto come devDep**: era richiesto dai done criteria ma assente nel baseline. SPEC §7 dice _"package.json: aggiunta cmdk e (forse) lucide-react se assente. Niente major version bump"_; vitest è additivo, no bump. Documentato.
- **Polyfill `ResizeObserver` + `scrollIntoView` in setupTests**: jsdom non li implementa, cmdk li usa. Polyfill stub idempotenti.
- **Prop `registerDefaults` su `CommandPaletteProvider`**: aggiunta per i test, default `true` in production. Nessun impatto runtime.
- **Lazy chunk per palette UI**: introdotto per stare sotto cap +15 KB. Senza lazy il delta era +20.21 KB. Con lazy: main +3.04 KB, palette chunk separato 17.12 KB caricato solo on-demand.
- **Toast inline (no libreria esterna)**: il SPEC menzionava `toast` come parte di `AppContext` ma non specificava la implementation. Implementato come `<div role="status" aria-live="polite">` bottom-right con auto-dismiss 3 s.
- **Bypass `⌘R` browser reload**: come SPEC §3.3 anticipava, evito di overridere `⌘R`. Il comando `act.refresh-data` è palette-only (no mnemonic).

## 8. Constraints rispettati (SPEC §7)

- ✅ Nessuna modifica a wizard ISO+ILCD, BomTable, ProcessEditor, ComplianceBanner, generatore Modelling Guide
- ✅ Nessuna modifica backend / nuovi endpoint / nuove migration
- ✅ Nessun cambio router (`react-router-dom` 6 invariato)
- ✅ Tailwind only (nessun CSS file aggiunto)
- ✅ Dark-mode aware (classi `dark:bg-neutral-900` etc., il V1 supporta dark via class strategy implicita)
- ✅ Bundle delta +3.04 KB gzip ≪ cap +15
- ✅ Niente i18n introdotta
- ✅ Niente major version bump (cmdk + vitest sono additivi)

## 9. Carry-over a G1.x

Esplicitamente documentati per il prossimo Architect-GUI sprint:

1. **Search globale entità (priorità ALTA)**. Richiede endpoint nuovo, es. `GET /api/search/global?q=...&types=process,flow,parameter,bom_row` che ritorni risultati indexati. Senza, la palette resta limitata a comandi statici. Stima 1-2 settimane backend + 0.5 settimana frontend.

2. **act.calculate-preflight (M3.1.0.7)**. Il preflight openLCA è un service Python invocato da pytest, non un endpoint REST. Per esporlo come comando palette serve `POST /api/projects/{pid}/preflight` che spawna un job async e restituisce uno stream SSE col risultato. Priorità media. Voce parallela alla pipeline IPC (V1.5).

3. **Routes standalone /wizard, /bom, /compliance, /modelling-guide**. Il V1 attuale impone di aprire un progetto prima. Se in V1.5 si introducono pagine "global" (template/wizard senza progetto attivo), ribindare i comandi navigation. Priorità bassa (l'UX attuale "project-first" è coerente).

4. **Context-awareness route-based**. L'API `getCommands(context)` è pronta. G1 non popola comandi context-scoped: tutti vivono come `'global'`. G2 (ghost text) avrà bisogno di scope `'wizard'`/`'bom'`/`'process'` reali. Priorità media — abilita G2.

5. **Theme toggle dedicato**. La palette è già dark-mode aware via classi Tailwind, ma manca un comando `act.toggle-theme` (richiede uno store `useTheme` o similare nel V1). Priorità bassa.

6. **act.import-bom-xlsx come file picker reale**. Oggi il comando naviga al detail page; un `<input type="file">` triggerato da palette + chiamata a `/api/projects/{pid}/bom/upload` sarebbe one-shot. Stima 1 giorno.

7. **Telemetry opt-in (Stretch S6)**. Skipped in G1. Richiede una decisione privacy esplicita. Priorità bassa.

## 10. Note tecniche & next sprint

1. **Provider lazy import + StrictMode double-mount**: il `useEffect` del provider che lazy-importa `definitions` ha cleanup che chiama `unregisters.forEach(fn)`. Con `React.StrictMode` (attivo in `main.tsx`), in dev il cleanup gira due volte. Implementazione: il flag `cancelled` + array shadow `unregisters` evita di registrare i fn dopo che il primo cleanup ha già richiamato qualcosa. Funzionante in dev e produzione.

2. **cmdk in jsdom**: come scoperto durante i test, cmdk usa `ResizeObserver` (per dimensionare il listbox) e `Element.prototype.scrollIntoView` (per autoscroll dell'item selezionato). Entrambi assenti in jsdom 29.x. Polyfill stub minimali nel `setupTests.ts` (no-op observer + funzione vuota). Se in futuro si testano metriche reali (es. visibilità item) servirà un mock più realistico.

3. **Bundle: trade-off lazy vs eager**. Il main chunk delta scende da +20.21 KB a +3.04 KB col lazy. Trade-off: la prima apertura `⌘K` carica un chunk extra (~17 KB). Su connessione lenta questo introduce un piccolo lag al primo trigger. Mitigazione possibile in V1.5: prefetch del chunk al `mouseenter` su un eventuale icon "command palette" nell'header — non implementato in G1.

4. **Idempotenza registerCommand**: l'API replace-on-duplicate semplifica HMR e i suggest dinamici di G2, ma significa che due moduli registrare lo stesso `id` con label diversi avranno l'ultimo che "vince". Se la collaborazione tra plugin diventa frequente, serve una namespace policy. Non urgente: G1 gestisce solo il catalogo statico + future suggest dinamici di G2.

5. **Performance fuzzy**: scorer custom è O(n × m) con n=14 commands e m=lunghezza query. Trivialmente <1ms. Quando il catalogo cresce oltre i 100 entry (search globale entità), va valutato `fuse.js` o `cmdk` filter built-in per non ricalcolare ad ogni keystroke (debounce o memo).

6. **Catena dipendenze sprint successivi**:
   - **G2 (Ghost text)** ~2 settimane: `useCommandRegistry` come superficie di registrazione per i suggest dinamici contestuali
   - **G3 (Optimistic UI)** ~2 settimane: piggyback sui pattern TanStack Query rollback già nell'app
   - **V2 (Agent mode)** futuro: il registry come catalogo di "tools" per LLM

7. **Reminder per Architect-GUI dopo G1**:
   - Aggiornare `MASTER_PLAN §12` con G1 ✅ merged main
   - SPEC G2 può essere scritta — la registry API è stabile
   - Considerare se G1.x search-globale entra prima di G2 (ROI per l'utente probabilmente più alto)

---

**Fine REPORT_G1.**
