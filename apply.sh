#!/bin/bash
# apply.sh — applica un file generato da Architect-GUI e committa+pusha
# Uso:
#   ./apply.sh <target> "msg" <source-file>   → da file
#   ./apply.sh <target> "msg" -               → da stdin (heredoc)

set -e

if [ -z "$1" ] || [ -z "$3" ]; then
    cat << 'HELP'
Uso:
  ./apply.sh <target-path> "<commit-msg>" <source-file>
  ./apply.sh <target-path> "<commit-msg>" -    (legge da stdin)

Esempi:
  ./apply.sh specs/SPEC_G3.md "Add SPEC G3" /tmp/spec_g3.md
  cat /tmp/foo.md | ./apply.sh design/DESIGN_GUI.md "v1.3 update" -
  ./apply.sh design/DESIGN_GUI.md "v1.3" - <<'END'
# qui il contenuto
END
HELP
    exit 1
fi

TARGET="$1"
MSG="$2"
SOURCE="$3"

if [ "$SOURCE" = "-" ]; then
    TMPFILE=$(mktemp)
    cat > "$TMPFILE"
    SOURCE="$TMPFILE"
    CLEANUP_SOURCE=true
elif [ ! -f "$SOURCE" ]; then
    echo "ERRORE: source $SOURCE non esiste."
    exit 1
fi

if [ ! -s "$SOURCE" ]; then
    echo "ERRORE: source $SOURCE è vuoto."
    exit 1
fi

cd ~/lca-tool-coordination
mkdir -p "$(dirname "$TARGET")"
cp "$SOURCE" "$TARGET"

[ "$CLEANUP_SOURCE" = "true" ] && rm -f "$SOURCE"

git add "$TARGET"
git commit -m "$MSG"
git push origin main

echo "✓ Committed and pushed: $TARGET"
