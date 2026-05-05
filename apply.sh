#!/bin/bash
set -e
if [ -z "$1" ]; then
    echo "Uso: ./apply.sh <path-relativo> [commit-msg]"
    exit 1
fi
TARGET="$1"
MSG="${2:-Update $1}"
PASTE_FILE="$HOME/.claude-paste"
if [ ! -f "$PASTE_FILE" ]; then
    echo "ERRORE: $PASTE_FILE non esiste. Lancia 'paste-spec' prima."
    exit 1
fi
cd ~/lca-tool-coordination
mkdir -p "$(dirname "$TARGET")"
mv "$PASTE_FILE" "$TARGET"
git add "$TARGET"
git commit -m "$MSG"
git push origin main
echo "✓ Committed and pushed: $TARGET"
