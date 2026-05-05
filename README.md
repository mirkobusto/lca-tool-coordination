# lca-tool-coordination

Architect docs e coordination per il tool LCA (vedi repo separato `lca-tool` per il codice).

## Struttura

- `master-plan/` — MASTER_PLAN attuale (Vision, architettura, ADR cumulativi, roadmap strategica)
- `current-state/` — `_CURRENT_STATE.md` snapshot day-by-day (commit hash main, test count, sprint chiuso)
- `design/` — `DESIGN_GUI.md` master document Architect-GUI (workstream GUI V1.5/V2)
- `specs/` — SPEC sprint G* (Command Palette G1, Ghost Text G2/G2.1, Optimistic UI G3, ...)
- `reports/` — REPORT post-merge per ogni sprint
- `kimi-research/` — sintesi Kimi research dossier (7 principi, 5 mockup, 30 pattern)
- `scripts/` — utility scripts (es. start.sh per avviare dev environment)
- `_GUI_BOOTSTRAP_20260505.md` — bootstrap chat Architect-GUI (riferimento storico)

## Workflow

- **Architect-GUI** (chat Claude.ai parallela) scrive SPEC e DESIGN in questo repo
- **Architect main** (chat Claude.ai per backend/architettura) scrive MASTER_PLAN e CURRENT_STATE
- **Claude Code Ubuntu** (chat dev) clona questo repo accanto al codice del tool, legge SPEC, scrive REPORT post-sprint
- Sincronia via git pull/push, niente Google Drive

## Convenzioni

- Solo file markdown, niente binari
- 1 commit = 1 modifica logica con messaggio descrittivo
- File aggiornati: modifica in-place + commit, no duplicati v1, v2, v3
- `_CURRENT_STATE.md` è autoritativo per stato day-by-day
- `master-plan/MASTER_PLAN.md` è autoritativo per vision strategica
- In caso di conflitto fra MASTER_PLAN e CURRENT_STATE, lo STATE vince

## Repository correlati

- `lca-tool` (privato): codice del tool LCA — backend FastAPI + frontend React + ChromaDB matcher
