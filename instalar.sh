#!/usr/bin/env bash
#
# ============================================================
#  KOUBE PRODUÇÃO — Instalador
# ============================================================
#  Roda na VM (SEU_IP). Faz tudo:
#    1. confere o ambiente
#    2. cria o banco koube_producao
#    3. aplica schema + dados iniciais
#    4. gera o .env com SECRET_KEY forte
#    5. sobe o container
#    6. testa se subiu
#
#  Uso:
#      cd ~/koube_sistema
#      chmod +x instalar.sh
#      ./instalar.sh
#
#  Para refazer do zero (APAGA O BANCO):
#      ./instalar.sh --recriar
# ============================================================

set -euo pipefail

# ---------- configuração (ajuste se necessário) ----------
PG_CONTAINER="${KOUBE_PG_CONTAINER:-postgres}"   # nome do container do Postgres
PG_USER="${KOUBE_DB_USER:-postgres}"
DB_NAME="${KOUBE_DB:-koube_producao}"
PORTA="${KOUBE_PORTA:-8010}"
SERVICO="producao-api"

RECRIAR=0
[[ "${1:-}" == "--recriar" ]] && RECRIAR=1

# ---------- cores ----------
V='\033[0;32m'; A='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; N='\033[0m'
ok()   { echo -e "  ${V}✔${N} $1"; }
aviso(){ echo -e "  ${A}!${N} $1"; }
erro() { echo -e "  ${R}✘${N} $1"; }
passo(){ echo -e "\n${C}▸ $1${N}"; }

echo -e "${C}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║        KOUBE PRODUÇÃO — INSTALAÇÃO           ║"
echo "  ║        Koube Química do Brasil               ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${N}"

# ============================================================
passo "1/6 · Conferindo o ambiente"
# ============================================================
command -v docker >/dev/null 2>&1 || { erro "Docker não encontrado nesta máquina."; exit 1; }
ok "Docker instalado"

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  erro "Docker Compose não encontrado."; exit 1
fi
ok "Docker Compose disponível ($COMPOSE)"

if ! docker ps --format '{{.Names}}' | grep -qx "$PG_CONTAINER"; then
  erro "Container do Postgres '$PG_CONTAINER' não está rodando."
  echo "     Containers ativos:"
  docker ps --format '       - {{.Names}}'
  echo "     Ajuste com: KOUBE_PG_CONTAINER=nome ./instalar.sh"
  exit 1
fi
ok "Postgres rodando no container '$PG_CONTAINER'"

for arq in db/schema.sql db/seed.sql db/seed_colaboradores.sql Dockerfile docker-compose.producao.yml; do
  [[ -f "$arq" ]] || { erro "Arquivo não encontrado: $arq (rode de dentro de ~/koube_sistema)"; exit 1; }
done
ok "Arquivos do projeto presentes"

# porta livre?
if ss -ltn 2>/dev/null | grep -q ":$PORTA " ; then
  aviso "A porta $PORTA já está em uso — se for uma instalação anterior, tudo bem."
else
  ok "Porta $PORTA livre"
fi

# ============================================================
passo "2/6 · Banco de dados"
# ============================================================
existe=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -tAc \
  "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" 2>/dev/null || echo "")

if [[ "$existe" == "1" ]]; then
  if [[ $RECRIAR -eq 1 ]]; then
    aviso "Banco '$DB_NAME' existe e será APAGADO (--recriar)."
    read -r -p "     Digite APAGAR para confirmar: " conf
    if [[ "$conf" == "APAGAR" ]]; then
      docker exec "$PG_CONTAINER" psql -U "$PG_USER" -c "DROP DATABASE $DB_NAME;" >/dev/null
      docker exec "$PG_CONTAINER" psql -U "$PG_USER" -c "CREATE DATABASE $DB_NAME;" >/dev/null
      ok "Banco recriado do zero"
      APLICAR_DADOS=1
    else
      erro "Cancelado."; exit 1
    fi
  else
    ok "Banco '$DB_NAME' já existe (mantido)"
    aviso "Os dados iniciais NÃO serão reaplicados. Use --recriar para começar do zero."
    APLICAR_DADOS=0
  fi
else
  docker exec "$PG_CONTAINER" psql -U "$PG_USER" -c "CREATE DATABASE $DB_NAME;" >/dev/null
  ok "Banco '$DB_NAME' criado"
  APLICAR_DADOS=1
fi

# ============================================================
passo "3/6 · Estrutura e dados"
# ============================================================
docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -q < db/schema.sql
tabelas=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -tAc \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';")
ok "Schema aplicado — $tabelas tabelas"

if [[ $APLICAR_DADOS -eq 1 ]]; then
  docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -q < db/seed.sql
  ok "Dados iniciais (produtos, equipamentos, preventivas, usuários)"
  docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -q < db/seed_colaboradores.sql
  ok "Colaboradores da produção (com fotos)"

  prod=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -tAc "SELECT count(*) FROM produtos;")
  equip=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -tAc "SELECT count(*) FROM equipamentos;")
  prev=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -tAc "SELECT count(*) FROM preventivas;")
  colab=$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$DB_NAME" -tAc "SELECT count(*) FROM colaboradores;")
  echo "       produtos: $prod · equipamentos: $equip · preventivas: $prev · colaboradores: $colab"
else
  ok "Estrutura conferida (dados preservados)"
fi

# ============================================================
passo "4/6 · Configuração (.env)"
# ============================================================
if [[ -f backend/.env ]]; then
  ok ".env já existe (mantido)"
  aviso "Confira se DATABASE_URL e SECRET_KEY estão corretos: nano backend/.env"
else
  SECRET=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | xxd -p -c 64)
  echo ""
  echo "     Precisamos da senha do usuário '$PG_USER' do Postgres."
  read -r -s -p "     Senha do Postgres: " PGPASS; echo ""

  # host do banco: se o Postgres está em container, tentamos o nome dele na rede docker
  PGHOST="$PG_CONTAINER"

  cat > backend/.env <<EOF
# Gerado pelo instalador em $(date '+%d/%m/%Y %H:%M')
DATABASE_URL=postgresql://$PG_USER:$PGPASS@$PGHOST:5432/$DB_NAME
SECRET_KEY=$SECRET
ACCESS_TOKEN_EXPIRE_MINUTES=480
CORS_ORIGINS=https://producao.koube.com.br,http://SEU_IP:$PORTA
EOF
  chmod 600 backend/.env
  ok ".env criado com SECRET_KEY forte (permissão 600)"
fi

# ============================================================
passo "5/6 · Subindo o sistema"
# ============================================================
echo "     Construindo a imagem (pode demorar alguns minutos na primeira vez)..."
if $COMPOSE -f docker-compose.producao.yml up -d --build "$SERVICO" >/tmp/koube_build.log 2>&1; then
  ok "Container '$SERVICO' no ar"
else
  erro "Falha ao subir. Últimas linhas do log:"
  tail -20 /tmp/koube_build.log
  exit 1
fi

# rede: se o Postgres estiver noutra rede, conectar
rede_pg=$(docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$PG_CONTAINER" | awk '{print $1}')
rede_api=$(docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$SERVICO" 2>/dev/null | awk '{print $1}')
if [[ -n "$rede_pg" && "$rede_pg" != "$rede_api" ]]; then
  docker network connect "$rede_pg" "$SERVICO" 2>/dev/null && \
    ok "Container conectado à rede do Postgres ($rede_pg)" || true
  docker restart "$SERVICO" >/dev/null
fi

# ============================================================
passo "6/6 · Testando"
# ============================================================
echo -n "     Aguardando a API responder"
sucesso=0
for i in $(seq 1 30); do
  if curl -sf "http://localhost:$PORTA/health" >/dev/null 2>&1; then sucesso=1; break; fi
  echo -n "."; sleep 2
done
echo ""

if [[ $sucesso -eq 1 ]]; then
  ok "API respondendo: $(curl -s http://localhost:$PORTA/health)"
  if curl -s "http://localhost:$PORTA/" | grep -q "DOCTYPE"; then
    ok "Sistema (tela de login) sendo servido"
  fi
  echo -e "\n${V}  ╔══════════════════════════════════════════════╗"
  echo "  ║              TUDO NO AR! 🎉                  ║"
  echo -e "  ╚══════════════════════════════════════════════╝${N}"
  echo ""
  echo -e "  Acesse:  ${C}http://SEU_IP:$PORTA${N}"
  echo -e "  API:     ${C}http://SEU_IP:$PORTA/docs${N}"
  echo ""
  echo "  Entrar com:"
  echo "     código NBI  (Bianca)   senha inicial: koube123"
  echo "     código SPV  (Simone)  senha inicial: koube123"
  echo -e "  ${A}Troque as senhas no primeiro acesso.${N}"
  echo ""
  echo "  Próximos passos:"
  echo "     1. Nginx apontando producao.koube.com.br → porta $PORTA"
  echo "     2. HTTPS:  certbot --nginx -d producao.koube.com.br"
  echo "     3. Backup: crontab -e  (linhas no DEPLOY.md)"
  echo ""
else
  erro "A API não respondeu em 60s. Veja o log:"
  echo "     docker logs $SERVICO --tail 40"
  exit 1
fi
