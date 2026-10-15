#!/bin/bash
# ============================================================
# Koube — restaurar um backup
# Uso: ./restaurar_backup.sh /caminho/koube_producao_2026-08-10_0300.sql.gz
# ============================================================
# ATENÇÃO: sobrescreve o banco inteiro. Use com calma.
# ============================================================

set -euo pipefail

ARQ="${1:-}"
CONTAINER="${KOUBE_PG_CONTAINER:-postgres-db}"
DBUSER="${KOUBE_DB_USER:-app_user}"

if [ -z "$ARQ" ] || [ ! -f "$ARQ" ]; then
  echo "Uso: $0 <arquivo.sql.gz>"
  echo ""
  echo "Backups disponíveis:"
  ls -lht /home/usuario/backups/*.sql.gz 2>/dev/null | head -20 || echo "  (nenhum encontrado)"
  exit 1
fi

# descobre o banco pelo nome do arquivo
DB=$(basename "$ARQ" | sed 's/_[0-9]\{4\}-.*//')

echo "============================================"
echo " Arquivo : $(basename "$ARQ")"
echo " Banco   : $DB"
echo " Container: $CONTAINER"
echo "============================================"
echo ""
echo "Isto vai APAGAR os dados atuais de '$DB' e substituir pelo backup."
read -rp "Digite RESTAURAR para confirmar: " CONF

if [ "$CONF" != "RESTAURAR" ]; then
  echo "Cancelado."
  exit 0
fi

echo "Restaurando..."
gunzip -c "$ARQ" | docker exec -i "$CONTAINER" psql -U "$DBUSER" -d "$DB"

echo ""
echo "Pronto. Reinicie a API:  docker restart producao-api"
