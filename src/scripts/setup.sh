#!/usr/bin/env bash
# Prepara git, Backlog.md e le cartelle del flusso in un progetto che contiene già i file del blueprint.
# Uso: scripts/setup.sh [nome-progetto] [--installa-backlog]
set -euo pipefail

NOME=""
INSTALLA=0
for arg in "$@"; do
  case "$arg" in
    --installa-backlog) INSTALLA=1 ;;
    -h|--help) echo "Uso: scripts/setup.sh [nome-progetto] [--installa-backlog]"; exit 0 ;;
    *) NOME="$arg" ;;
  esac
done
NOME="${NOME:-$(basename "$PWD")}"

echo "== Setup flusso spec-driven: $NOME =="

# 1. Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "- Repository git non trovato: eseguo git init"
  git init -q
fi

# 2. Backlog.md
if ! command -v backlog >/dev/null 2>&1; then
  if [ "$INSTALLA" -eq 1 ]; then
    command -v npm >/dev/null 2>&1 || { echo "ERRORE: npm non trovato. Installa Node.js e riprova."; exit 1; }
    npm install -g backlog.md
  else
    echo "ERRORE: CLI 'backlog' non trovata."
    echo "Installala con: npm install -g backlog.md   (oppure rilancia con --installa-backlog)"
    exit 1
  fi
fi

if [ ! -f backlog/config.yml ]; then
  echo "- Inizializzo Backlog.md."
  echo "  Se chiede di creare o modificare file di istruzioni per agenti, rispondi NO:"
  echo "  le istruzioni sono già in CLAUDE.md e .claude/."
  backlog init "$NOME"
fi

# 3. Stati della board: aggiunge 'Verify' (verifica del revisore) e 'Change Review' (revisione umana della change)
STATI='statuses: ["To Do", "In Progress", "Verify", "Change Review", "Done"]'
if grep -q '^statuses:' backlog/config.yml; then
  sed -i.bak "s|^statuses:.*|$STATI|" backlog/config.yml && rm -f backlog/config.yml.bak
else
  printf '\n%s\n' "$STATI" >> backlog/config.yml
fi
echo "- Stati della board: To Do, In Progress, Verify, Change Review, Done"

# 4. Cartelle della documentazione
mkdir -p docs/changes docs/adr
touch docs/changes/.gitkeep docs/adr/.gitkeep

echo "== Fatto =="
echo "Prossimo passo: apri Claude Code in questa cartella ed esegui /setup-progetto"
