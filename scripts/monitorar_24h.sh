#!/usr/bin/env bash
# Uso: bash scripts/monitorar_24h.sh            (24 h, 1 amostra a cada 30 min)
#      AMOSTRAS=1 bash scripts/monitorar_24h.sh (foto unica)
set -euo pipefail

ID="trab02_2026_2_12621cbs209"
PORTA="${PORTA:-2209}"
INTERVALO="${INTERVALO:-1800}"
AMOSTRAS="${AMOSTRAS:-49}"

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$RAIZ/evidencias"
ARQ="$RAIZ/evidencias/monitor_$(date +%Y%m%d_%H%M%S)_a${AMOSTRAS}_$$.log"

echo "# $ID | host=$(hostname 2>/dev/null || uname -n) | inicio=$(date -Is) | amostras=$AMOSTRAS | intervalo=${INTERVALO}s" | tee -a "$ARQ"

for i in $(seq 1 "$AMOSTRAS"); do
  estado="$(docker inspect -f 'status={{.State.Status}} iniciado={{.State.StartedAt}} reinicios={{.RestartCount}} saude={{if .State.Health}}{{.State.Health.Status}}{{else}}n/a{{end}}' "$ID" 2>&1 || true)"
  http="$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://localhost:$PORTA/health" || true)"
  echo "$(date -Is) amostra=$i/$AMOSTRAS $estado http=${http:-000}" | tee -a "$ARQ"
  if [ "$i" -lt "$AMOSTRAS" ]; then
    sleep "$INTERVALO"
  fi
done

echo "# fim=$(date -Is)" | tee -a "$ARQ"
