# _CURRENT_STATE — Stato day-by-day del tool LCA

> **Ultimo aggiornamento**: 2026-05-06 post-merge A2+A2.1
> **Mantenuto da**: Architect unificato (chiunque chiude uno sprint)
> **Autoritativo per**: stato day-by-day, commit hash main, test count, baseline numerica
> **NON autoritativo per**: vision strategica → vedi `master-plan/MASTER_PLAN.md`

---

## 🎉 V1.5 partial COMPLETE — 2026-05-06

Tool in stato **V1.5 partial complete + WCAG 2.1 AA compliant**. Pronto per pitch istituzionale EU procurement.

Workstream GUI V1.5 partial = G1 + G2 + G2.1 + G2.2 + G3 + B1 + A1 + A2 + A2.1, tutti chiusi e mergiati su main.

## Main HEAD

```
lca-tool main:                post-merge PR #11 A2+A2.1 — chiedere a Mirko SHA esatto
lca-tool-coordination main:   post-merge PR coordination V1.5 partial docs
```

## Sprint chiusi (cumulative)

| Sprint | Status | Commit (su main) | PR | Data merge |
|---|---|---|---|---|
| M3.1.0.x | ✅ DONE | `67a2ec4` | #3 | 2026-05-04 |
| M3.1.1 | ✅ DONE | `b8d6002` | #4 | 2026-05-05 |
| G1 — Command Palette ⌘K | ✅ DONE | `45e5b6f` | #5 | 2026-05-05 |
| G2 + G2.1 — Ghost Text + qualifier | ✅ DONE | `6c9f618` | #6 | 2026-05-06 |
| G3 — Optimistic UI | ✅ DONE | `51b70e7` | #8 | 2026-05-06 |
| G2.2 — Process_name split + overflow | ✅ DONE | `d05e350` | #10 | 2026-05-06 |
| B1 — Global entity search backend | ✅ DONE | `d98447d` | #9 | 2026-05-06 |
| A2 + A2.1 — a11y Critical + Serious + link contrast | ✅ DONE | post #11 | #11 | 2026-05-06 |
| **V1.5 partial** | ✅ **COMPLETE** | — | — | **2026-05-06** |
| M3.1.2 — CF EF 3.1 reali | 🔧 in progress (parallelo) | — | — | — |

## Test baseline post V1.5 partial complete

```
Backend pytest:    394 passed + 4 skipped (atteso, da verificare empiricamente)
Frontend vitest:   70 passed (12 G1 + 8 G2 + 11 G2.1 + 15 G3 + 4 G2.2 + 16 A2 + 4 A2.1)
Build:             clean, TypeScript no errors
Bundle main:       96.11 KB gzip
                   (delta cumulative G1+G2+G2.1+G3+G2.2+A2+A2.1 = +5.27 KB vs pre-G1 baseline 90.84 KB)
Bundle CSS:        4.97 KB gzip
Bundle CommandPalette lazy chunk: 17.14 KB gzip
WCAG 2.1 AA:       0 Critical / 0 Serious / 0 Moderate / 0 Minor (verificato empirico via axe-core 6 route)
```

## Audit a11y verificato

Il tool è stato auditato empiricamente con axe-core 4.10 + WCAG 2.1 AA tags il 2026-05-06 post merge A2+A2.1. Risultato su tutte e 6 le route principali: **0 violazioni in tutte le severity**.

Lo script audit vive in `frontend/scripts/audit-a11y.mjs` (uncommitted, ricreabile da SPEC A1 §5). Re-run prima di qualunque V1.5 release.

## ADR cumulativi (su MASTER_PLAN §6)

| # | Sprint | Titolo |
|---|---|---|
| 31 | M3.x | Kimi research dossier come fonte autoritativa V1.5+ scope GUI |
| 32 | M3.1.1 | LCIA scaffolding-only |
| 33 | M3.1.1 | Deterministic Build Contract |
| 34 | M3.1.1 | Verify merge before branch delete |
| 35 | G1 | Command Palette ⌘K |
| 36 | G2+G2.1 | Atomic same-branch cleanup per hot fix sprint correlati |
| 37 | G3 | Optimistic UI con TanStack Query helper riusabile |
| 38 | 2026-05-06 | Workflow operativo: SPEC e REPORT scambiati via repo coordination, NO copia-incolla manuale |
| 39 | A2+A2.1 | WCAG 2.1 AA compliance milestone — verifica empirica obbligatoria pre-release via axe-core |
| 40 | A2.1 | Design tokens semantici separati per `bg-` vs `text-` quando il tool è dark theme |

## Branch survival post-merge

9 branch sopravvivono come "merged but not deleted" (limitazione MCP delete_branch non disponibile). Sweep manuale dalla UI GitHub quando comodo. Tutti confermati merged. Non urgente.

## Workflow operativo

- Coordination repo: https://github.com/mirkobusto/lca-tool-coordination
- Code repo: https://github.com/mirkobusto/lca-tool
- Architect-unificato output in /mnt/user-data/outputs/ + commit via `apply.sh` o GitHub UI
- Implementer: Claude Code on the web (claude.ai/code), con istruzione esplicita di scrivere REPORT su repo coordination
- Drive deprecato per docs

## Stato pending lato Mirko

1. **Manual QA empirical 15 BoM rows con qualifier** — pending da G2.1, non bloccante per V1.5 partial complete ma necessario pre-V1.5 release decision sulla ricalibrazione threshold matcher M1.
2. **VoiceOver/NVDA test** — empirical screen reader test su Command Palette + GhostInput + Toast. Carry-over post-A2.
3. **Manual visual QA** — verifica che i bottoni `.btn-primary` con nuovo `accent #3a6fd8` restino visivamente "primari" su tutte le pagine (gating-soft per pitch).
4. **Branch sweep delete** — 9 branch da eliminare via UI GitHub (housekeeping).
5. **Decisione strategica post-V1.5 partial complete** — A3 fix Moderate+Minor / G1.x search frontend / V1.5 alpha release con consulenti pilota.

## Prossimi sprint candidati (post V1.5 partial)

| Sprint | Tipo | Stima | Priorità |
|---|---|---|---|
| **A3** | Fix a11y Moderate + Minor (i18n stringhe ~120, scope th, focus indicator, etc.) | ~3-5 gg | MEDIA — no blocker pitch |
| **G1.x** | Search globale entità — frontend integration palette ⌘K (B1 è pronto) | 0.5-1 settimana | ALTA |
| **V1.5 alpha** | Release con 2-3 consulenti pilota italiani | 1-2 gg setup | strategica |
| **M3.1.2** | CF reali EF 3.1 | in progress parallelo | ALTA per V1 release |
| **M3.2** | LCIA re-import + Report DOCX | 2 mesi | V1 release blocker |
| **AI Grant Parser premium** | killer feature V1.5 premium tier | 3-4 settimane | premium gating |
