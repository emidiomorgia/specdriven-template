#!/usr/bin/env bash
# Copia il blueprint in una cartella di progetto, senza sovrascrivere nulla di esistente.
# Uso: scripts/installa-blueprint.sh <cartella-progetto>
set -euo pipefail

DEST="${1:-}"
[ -n "$DEST" ] || { echo "Uso: $0 <cartella-progetto>"; exit 1; }

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$DEST"
DEST="$(cd "$DEST" && pwd)"

copia() { # <sorgente> <destinazione>
  if [ -e "$2" ]; then
    echo "- esiste già, non sovrascrivo: ${2#"$DEST"/}"
    return
  fi
  mkdir -p "$(dirname "$2")"
  cp "$1" "$2"
  echo "+ ${2#"$DEST"/}"
}

copia_albero() { # <cartella sorgente> <cartella destinazione>
  (cd "$1" && find . -type f | sed 's|^\./||') | while read -r f; do
    copia "$1/$f" "$2/$f"
  done
}

# CLAUDE.md: se esiste già, non lo tocca
if [ -e "$DEST/CLAUDE.md" ]; then
  if cmp -s "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"; then
    echo "- CLAUDE.md già presente e identico al blueprint"
  else
    cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.blueprint.md"
    echo "! CLAUDE.md esiste già: copiato come CLAUDE.blueprint.md (da unire a mano)"
  fi
else
  copia "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
fi

copia "$SRC/.claude/workflow.yml" "$DEST/.claude/workflow.yml"
copia_albero "$SRC/.claude/skills" "$DEST/.claude/skills"
copia_albero "$SRC/.claude/agents" "$DEST/.claude/agents"
copia_albero "$SRC/docs/_templates" "$DEST/docs/_templates"
copia "$SRC/scripts/setup.sh" "$DEST/scripts/setup.sh"
copia "$SRC/scripts/setup.bat" "$DEST/scripts/setup.bat"
copia "$SRC/README.md" "$DEST/docs/MANUALE-WORKFLOW.md"
chmod +x "$DEST/scripts/setup.sh" 2>/dev/null || true

echo
echo "Blueprint installato in: $DEST"
echo "Passi successivi:"
echo "  1. cd \"$DEST\" && scripts/setup.sh \"nome-progetto\" [--installa-backlog]"
echo "  2. Apri Claude Code nella cartella ed esegui /setup-progetto"
echo "  Manuale: docs/MANUALE-WORKFLOW.md"
