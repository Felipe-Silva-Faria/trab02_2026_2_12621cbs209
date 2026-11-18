#!/usr/bin/env bash
# Uso: bash scripts/backup_dados.sh
set -euo pipefail

ID="trab02_2026_2_12621cbs209"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$RAIZ/data"
NOME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --network none \
  -v "${ID}_data:/origem:ro" \
  -v "$RAIZ/data:/destino" \
  --entrypoint tar \
  "${ID}:5.0" czf "/destino/$NOME" -C /origem .

echo "Backup criado: data/$NOME"
