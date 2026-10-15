#!/bin/bash
# ============================================================
# Koube — backup diário dos bancos (Produção + Pedidos)
# Retenção: 30 dias
# Rodar como: usuario
# ============================================================

set -euo pipefail

CONTAINER="${KOUBE_PG_CONTAINER:-postgres-db}"
DBUSER="${KOUBE_DB_USER:-app_user}"
DESTINO="${KOUBE_BACKUP_DIR:-/home/usuario/backups}"
RETENCAO_DIAS=30
BANCOS=("koube_producao" "app_db")

DATA=$(date +%Y-%m-%d_%H%M)
LOG="$DESTINO/backup.log"

mkdir -p "$DESTINO"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

log "=== início do backup ==="

# o container precisa estar de pé
if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  log "ERRO: container $CONTAINER não está rodando. Backup abortado."
  exit 1
fi

FALHAS=0

for DB in "${BANCOS[@]}"; do
  ARQ="$DESTINO/${DB}_${DATA}.sql.gz"

  if docker exec "$CONTAINER" pg_dump -U "$DBUSER" -d "$DB" 2>>"$LOG" | gzip > "$ARQ"; then
    TAM=$(du -h "$ARQ" | cut -f1)

    # um dump válido nunca é minúsculo — 1 KB indica dump vazio/quebrado
    BYTES=$(stat -c%s "$ARQ")
    if [ "$BYTES" -lt 1024 ]; then
      log "ERRO: $DB gerou arquivo suspeito ($BYTES bytes). Removido."
      rm -f "$ARQ"
      FALHAS=$((FALHAS+1))
    else
      log "OK: $DB -> $(basename "$ARQ") ($TAM)"
    fi
  else
    log "ERRO: falha no pg_dump de $DB"
    rm -f "$ARQ"
    FALHAS=$((FALHAS+1))
  fi
done

# limpeza da retenção
REMOVIDOS=$(find "$DESTINO" -name "*.sql.gz" -mtime +$RETENCAO_DIAS -print -delete | wc -l)
log "retenção: $REMOVIDOS arquivo(s) com mais de $RETENCAO_DIAS dias removido(s)"

TOTAL=$(find "$DESTINO" -name "*.sql.gz" | wc -l)
ESPACO=$(du -sh "$DESTINO" | cut -f1)
log "acervo atual: $TOTAL arquivo(s), $ESPACO"

if [ "$FALHAS" -gt 0 ]; then
  log "=== fim COM $FALHAS FALHA(S) ==="
  exit 1
fi

log "=== fim do backup, tudo certo ==="
