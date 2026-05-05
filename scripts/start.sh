#!/bin/bash
# start.sh — avvia backend + frontend del tool LCA
# Uso: ./start.sh

set -e

REPO_DIR="$HOME/lca/STEP_A_DB_extraction"
cd "$REPO_DIR"

echo "==> Stop processi vecchi (uvicorn, vite)"
pkill -f "uvicorn backend.main" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
sleep 1

echo "==> Auto-detect venv"
if [ -d ".venv" ]; then
    VENV_PATH=".venv"
elif [ -d "venv" ]; then
    VENV_PATH="venv"
elif [ -d "backend/.venv" ]; then
    VENV_PATH="backend/.venv"
elif [ -d "backend/venv" ]; then
    VENV_PATH="backend/venv"
else
    echo "ERROR: nessun venv trovato. Cerco activate..."
    find . -name "activate" -path "*/bin/*" 2>/dev/null | head -3
    exit 1
fi
echo "    Trovato venv in: $VENV_PATH"

echo "==> Attiva venv"
source "$VENV_PATH/bin/activate"

echo "==> Avvio backend (uvicorn :8000) in background"
mkdir -p .logs
nohup uvicorn backend.main:app --reload --port 8000 > .logs/backend.log 2>&1 &
BACKEND_PID=$!
echo "    Backend PID: $BACKEND_PID  (log: .logs/backend.log)"

echo "==> Aspetto che backend sia ready (max 15s)"
for i in {1..15}; do
    if curl -s http://localhost:8000/api/health > /dev/null 2>&1 || \
       curl -s http://localhost:8000/docs > /dev/null 2>&1; then
        echo "    Backend ready dopo ${i}s"
        break
    fi
    sleep 1
done

echo "==> Avvio frontend (vite :5173) in foreground"
echo "    Premi Ctrl+C per fermare entrambi"
echo ""

# Cleanup quando esci con Ctrl+C
trap "echo ''; echo '==> Stop tutto'; kill $BACKEND_PID 2>/dev/null; pkill -f vite 2>/dev/null; exit 0" INT TERM

cd frontend
rm -rf node_modules/.vite  # cache pulita ogni avvio
npm run dev
