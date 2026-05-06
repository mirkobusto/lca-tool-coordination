# REPORT A2.1 — Hot fix link contrast su dark theme

| | |
|---|---|
| Sprint | A2.1 (atomic same-branch hot fix di A2, ADR 36 / D-13) |
| Branch codice | `claude/fix-a11y-issues-VxP5V` (stesso A2, **nuovo commit** `b20d24c`) |
| Branch coordination | `claude/fix-a11y-issues-VxP5V` (stesso A2 report branch, nuovo commit) |
| PR codice | https://github.com/mirkobusto/lca-tool/pull/11 (titolo aggiornato `[A2 + A2.1]`) |
| PR coordination | https://github.com/mirkobusto/lca-tool-coordination/pull/5 (description aggiornata) |
| Stima SPEC | 30 min |
| Effettivo | ~25 min |
| Data | 2026-05-06 |

---

## 1. Trigger

Re-run `node scripts/audit-a11y.mjs` lato Mirko, post-merge atteso di PR #11
(A2 baseline) ma in realtà eseguito **prima del merge** sul branch
`claude/fix-a11y-issues-VxP5V` per smoke pre-merge:

- ✅ **0 Critical** (era target A2)
- ❌ **28 Serious** — tutti `color-contrast`, pattern unico:
  `<a class="text-accent">` su panel `#171a21`

Causa: A2.4 ha cambiato accent `#4f8cff` → `#3a6fd8` verificandolo SOLO contro
sfondo bianco (5.16:1, OK per `.btn-primary` + `.bg-accent` + testo bianco).
Ma l'app è dark theme: i link che usano `text-accent` come **color del testo**
finiscono su panel scuro `#171a21`, dove `#3a6fd8` dà contrast **3.69:1**
(sotto AA 4.5:1).

---

## 2. Strategia scelta — Strategia C (patch chirurgico)

Tre opzioni considerate:

| | Strategia | Pro | Contro |
|---|---|---|---|
| A | Cambiare `accent` a un colore valido sia su white che su `#171a21` | 1 sola variabile da gestire | Quasi impossibile: serve >=4.5:1 su entrambi gli estremi → finisce in zona grigia poco distintiva |
| B | Cambiare `accent` a colore chiaro (valido su dark), accettare regressione bottoni | Semplice | Rompe `.btn-primary` che era stato fixato in A2.4 |
| **C** | Mantenere `accent` (per bg/border/btn) + introdurre nuovo token `link` per text su dark | Zero regressione, semantica chiara, future-proof | Una variabile in più da maintainere |

**Scelta: C** — segue l'intento dello SPEC ("accent #3a6fd8 RESTA, introduci
nuovo token link") ed è quella che minimizza il blast radius.

---

## 3. Color choice + WCAG verification

Calcolo contrast ratio (WCAG 2.1 formula) di vari candidati vs `#171a21`:

| Hex | vs `#171a21` (panel) | vs `#ffffff` (white) | Verdetto |
|---|---|---|---|
| `#3a6fd8` (current accent) | **3.69:1** ❌ AA fail | 4.72:1 ✅ AA | tenere SOLO per bg/border/btn |
| `#5e90f2` | 5.59:1 ✅ AA | 3.11:1 ❌ | candidato |
| `#6c98f5` | 6.17:1 ✅ AA | 2.82:1 ❌ | candidato |
| **`#7aa3ff`** ⭐ | **7.06:1 ✅ AA + AAA** | 2.47:1 ❌ | **scelto** (first option SPEC) |
| `#8fb4ff` | 8.41:1 ✅ AAA | 2.07:1 ❌ | margine eccessivo |
| `#a5c4ff` | 9.90:1 ✅ AAA | 1.76:1 ❌ | troppo chiaro, perde "link feel" |

**Scelta finale**: `link: #7aa3ff` — passa **AAA** (>=7) con margine
confortevole (qualunque hover/focus/disabled darken non scende sotto AA).

Aggiunto in `frontend/tailwind.config.js`:
```js
colors: {
  // ...
  accent: "#3a6fd8",
  link:   "#7aa3ff",   // A2.1 — text-link su dark panel (AA + AAA)
}
```

---

## 4. Sweep `text-accent` → `text-link`

Pre-fix grep su `frontend/src/`:

```
ManualEntry.tsx:120         "text-xs text-accent hover:underline" (button "+ row")
ProjectWizard.tsx:521       "text-xs text-accent hover:underline"
ProjectDetailPage.tsx:80    "text-accent" (Link "Add BOM →")
MatchPage.tsx:167           "text-xs text-accent hover:underline"
MatchPage.tsx:180           condizionale "text-accent" : "text-muted hover:text-ink" (mode tab)
MatchPage.tsx:395           "text-xs font-semibold text-accent" (td colSpan)
ProjectsPage.tsx:99         "text-accent hover:underline" (Link project card)
```

Totale: **7 occorrenze in 5 file**.

Sweep eseguito con:
```bash
grep -rl "text-accent" frontend/src/ | xargs sed -i 's/\btext-accent\b/text-link/g'
```

Post-sweep grep: **0 residui** di `text-accent` in `frontend/src/`.

**NON toccato** (verificato a parte, restano accent-based):
- `bg-accent` — usato in `.btn-primary` CSS, PreWizard "active state", MatchPage progress bar
- `border-accent` — usato in PreWizard radio/checkbox selected, ParametersModal card border, ProjectsPage card hover, MatchPage row top border
- `focus:border-accent` — in `.input` CSS

Tutti su sfondi appropriati per `#3a6fd8`, nessuna regressione.

---

## 5. Tests

File nuovo: `frontend/src/__tests__/a11y_link_contrast.test.tsx` (4 test).

| # | Test | Cosa verifica |
|---|---|---|
| 1 | `token \`link\` esiste in tailwind.config.js` | `colors.link` è hex 6-char |
| 2 | `token \`link\` >= 4.5:1 contrast vs panel` | Calcolo WCAG live, fallisce se qualcuno cambia il token sotto AA |
| 3 | `token \`accent\` invariato a #3a6fd8` | Guard contro regressioni A2.4 (es. qualcuno "fixa" il contrast cambiando accent) |
| 4 | sweep: nessun `text-accent` residuo | Scan via `import.meta.glob` di tutti i `.ts/.tsx/.css/.html` in `src/`, regex `\btext-accent\b`, fallisce se ricomparirebbe in futuro |

**Pattern import.meta.glob** scelto invece di `node:fs` per evitare dipendenze
da `@types/node` (non presente in `tsconfig.json`) e mantenere build clean.

---

## 6. Bundle + tests delta

| Metrica | A2 baseline | A2.1 dopo |
|---|---|---|
| Vitest | 66 pass | **70 pass** (+4) |
| Pytest | invariato | invariato |
| Bundle main gzip | 96.11 KB | **96.11 KB** (+0) |
| Bundle CSS gzip | 4.97 KB | 4.97 KB (+0) |
| TypeScript build | clean | clean |
| Cap rispettato | n/a | sub-cap +0.5 KB ✅ (delta reale 0) |

Bundle delta zero perché abbiamo solo:
- aggiunto 1 entry nel theme.extend.colors (Tailwind purge tiene solo classi
  effettivamente usate → `text-link` sostituisce 1:1 `text-accent`, gli
  utility CSS atom stessa size)
- rinominato 7 occorrenze di classe (markup invariato in lunghezza,
  `text-accent` e `text-link` sono entrambi 11 char)

---

## 7. Acceptance criteria — verifica puntuale SPEC

- [x] vitest +>=2 nuovi pass → **+4** ✅
- [x] vitest totale: 66 + >=2 = >=68 → **70** ✅
- [x] Bundle main delta <= +0.5 KB gzip → **+0 KB** ✅
- [x] pytest invariato → ✅
- [x] TypeScript build clean → ✅
- [x] Token `link` aggiunto in tailwind.config.js con contrast verificato AA su `#171a21` → **7.06:1 (AAA)** ✅
- [x] Zero usi di `.text-accent` residui (sweep grep) → **0** ✅

Tutti i 7 criteri passati.

---

## 8. PR strategy applicata

Da SPEC §4 (atomic same-branch, ADR 36):

- **NON** aperta PR separata sul repo codice ✅
- Nuovo commit `b20d24c` su branch esistente `claude/fix-a11y-issues-VxP5V` ✅
- Titolo PR #11 aggiornato: `[A2 + A2.1] Fix a11y Critical + Serious + link contrast — V1.5 unblock` ✅
- Description PR #11 aggiornata con sezione A2.1 + nuove metriche ✅

Su coordination:

- Branch coordination = stesso `claude/fix-a11y-issues-VxP5V` (pratico,
  evita PR separata) ✅
- File NUOVO `reports/REPORT_A2.1_20260506_0942.md` (questo) — più
  navigabile rispetto a sezione "12." dentro REPORT_A2 ✅
- Description PR coordination #5 aggiornata ✅

---

## 9. Decisioni autonome documentate

1. **Color #7aa3ff (first option SPEC)**: scelto perché passa AA + AAA con
   margine. Le altre alternative (`#8fb4ff`, `#a5c4ff`) erano più chiare
   ma rischiavano di non sembrare più "link" — preferito il minimo
   sopra-AAA.

2. **Test sweep via `import.meta.glob`**: preferito a `node:fs` perché
   `tsconfig.json` non include `@types/node` e aggiungerlo era out of
   scope per un hot fix da 30 minuti. Pattern Vite-native, già supportato
   nel toolchain.

3. **Self-exclusion del test file dal sweep**: il file di test contiene
   la stringa `text-accent` nei commenti (necessaria per spiegare il fix).
   Aggiunta `if (path.includes("a11y_link_contrast.test")) continue;`
   nello sweep per evitare false-positive su sé stesso.

4. **Branch coordination = stesso A2** (non nuovo `claude/a2.1-report-XXX`):
   atomic same-branch è coerente con la strategia codice; un branch
   coordination separato avrebbe richiesto seconda PR coordination
   complicando il merge.

5. **Triple-slash `<reference types="vite/client" />`** nel test invece
   di creare `vite-env.d.ts` global: meno invasivo, scope locale al
   test file che ne ha effettivamente bisogno.

---

## 10. Re-run axe atteso (lato Mirko)

Pre-A2.1: 0 Critical / 28 Serious (color-contrast).

Atteso post-A2.1: **0 Critical / 0 Serious**.

Tutti i 28 Serious erano riconducibili al pattern `text-accent` su panel
scuro. Avendo migrato tutti i 7 use site (alcuni rendono più di un'istanza
DOM, da cui i 28 hit axe) al nuovo `text-link` AAA, l'aspettativa è
recupero pulito.

Mirko esegue:
```bash
git fetch origin && git checkout claude/fix-a11y-issues-VxP5V && git pull
cd frontend && rm -rf node_modules/.vite && npm run dev
# in altro terminale:
node scripts/audit-a11y.mjs
```

Se 🟢 **0/0** → mergia PR #11 e PR coordination #5.
Se ❌ residui → riapri task con axe report aggiornato.

---

## 11. Carry-over A3

Nessuno emerso da A2.1. Resta valido il backlog A3 documentato in REPORT_A2 §11
e in `AUDIT_a11y_20260506.md` §5:

- i18n cleanup (~120 stringhe)
- `ConfidenceBadge` "confidence" → "confidenza"
- `<th scope>` sitewide
- `text-muted` contrast review
- focus indicator `.btn` / `.input`
- `window.confirm()` → dialog
- route-change live region + skip-link
- font-size minimo `text-[10px]`

A2.1 NON sblocca né blocca nessuno di questi.

---

## 12. Lessons learned

1. **WCAG verification deve coprire SIA fg-su-bg-chiari SIA fg-su-bg-scuri**.
   A2.4 ha verificato `accent` solo contro bianco. Per dark theme servono
   sempre 2 verifiche minime: vs bg principale chiaro (white) e vs panel
   scuro (`#171a21`).

2. **Distinguere semantica `bg-` vs `text-` dei design token**. Un singolo
   color token che fa sia background-color (con testo bianco sopra) sia
   text-color (su sfondo scuro) ha vincoli di contrast incompatibili
   nella maggior parte dei casi. Preferire 2 token separati (`accent` per
   bg, `link` per text) — che è esattamente la fix di A2.1.

3. **Atomic same-branch funziona bene** per hot fix sotto le 30 minuti
   senza dover aprire seconda PR — coerente con ADR 36 / D-13. Da
   replicare per futuri hot fix che derivano da audit re-run.

---

_Generato da [Claude Code](https://claude.ai/code/session_01YXZL4eFWEUF8HrUSy2XNaV) il 2026-05-06._
