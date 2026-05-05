# _CURRENT_STATE — Stato day-by-day del tool LCA

> **Ultimo aggiornamento**: 2026-05-06 post-merge G2+G2.1
> **Mantenuto da**: Architect-GUI + Architect main + Claude Code dev (chiunque chiude uno sprint)
> **Autoritativo per**: stato day-by-day, commit hash main, test count, baseline numerica
> **NON autoritativo per**: vision strategica → vedi `master-plan/MASTER_PLAN.md`

---

## Main HEAD

```
Commit:  6c9f618 (squash merge G2+G2.1, PR #6)
Branch:  main
Date:    2026-05-06
Title:   [G2+G2.1] Ghost Text inventory + qualifier + layout
```

## Sprint chiusi (cumulative)

| Sprint | Status | Commit (su main) | PR | Data merge |
|---|---|---|---|---|
| M3.1.0.x | ✅ DONE | `67a2ec4` | #3 | 2026-05-04 |
| M3.1.1 | ✅ DONE | `b8d6002` | #4 | 2026-05-05 |
| G1 — Command Palette ⌘K | ✅ DONE | `45e5b6f` (squash da `6815de6`) | #5 | 2026-05-05 |
| G2 + G2.1 — Ghost Text inventory + qualifier + layout | ✅ DONE | `6c9f618` (squash da `692041e` + `adfbb6a`) | #6 | 2026-05-06 |
| G3 — Optimistic UI | 📝 SPEC scritta | — | — | — |
| M3.1.2 — CF EF 3.1 reali | 🔧 in progress (Architect main) | — | — | — |

## Test baseline post-merge G2+G2.1

```
Backend pytest: 379 passed + 4 skipped (non-uvicorn preflight) = 383 collected
Frontend vitest: 31 passed (12 G1 + 8 G2 + 11 G2.1)
Build:    clean
Bundle:   main 94.36 KB gzip + CommandPalette lazy 17.12 KB
          (delta cumulative G1+G2+G2.1: +3.52 KB main vs pre-G1 baseline 90.84 KB)
```

## ADR cumulativi (su MASTER_PLAN §6)

| # | Sprint | Titolo |
|---|---|---|
| 31 | M3.x | Kimi research dossier come fonte autoritativa V1.5+ scope GUI |
| 32 | M3.1.1 | LCIA scaffolding-only |
| 33 | M3.1.1 | Deterministic Build Contract |
| 34 | M3.1.1 | Verify merge before branch delete |
| 35 | G1 | Command Palette ⌘K |
| **36** | **G2+G2.1** | **Atomic same-branch cleanup per hot fix sprint correlati** |
| 37 | G3 | atteso: Optimistic UI con TanStack Query helper riusabile |

## Workflow operativo

- Coordination repo: https://github.com/mirkobusto/lca-tool-coordination
- Code repo: https://github.com/mirkobusto/lca-tool
- Architect-GUI scrive output su /mnt/user-data/outputs/
- Da G3 in poi: implementer è Claude Code on the web (claude.ai/code)
- Drive deprecato per docs

NOTA: Versione abbreviata su Drive per backup. Versione completa nel repo coordination una volta committata.
