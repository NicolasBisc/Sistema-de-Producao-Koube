#!/usr/bin/env python3
"""
KOUBE PRODUÇÃO — Manutenção do banco de dados
=============================================
Faz três coisas, na ordem:

  1. BACKUP    do banco (pg_dump comprimido), com retenção configurável
  2. RELATÓRIO mensal consolidado (o histórico fica preservado em resumo)
  3. LIMPEZA   dos registros antigos, para não sobrecarregar a VM

O relatório é gerado ANTES da limpeza — assim nada de importante se perde:
os números do mês ficam guardados na tabela `relatorios_mensais` mesmo depois
que os registros detalhados forem apagados.

Uso na VM (exemplos):
    python3 manutencao_db.py --backup
    python3 manutencao_db.py --relatorio 2026-07
    python3 manutencao_db.py --limpeza
    python3 manutencao_db.py --tudo          # backup + relatório do mês passado + limpeza

Agendar no cron (diário às 2h da manhã, backup; dia 1º de cada mês, tudo):
    0 2 * * *  cd /home/usuario/koube_sistema/scripts && python3 manutencao_db.py --backup
    0 3 1 * *  cd /home/usuario/koube_sistema/scripts && python3 manutencao_db.py --tudo
"""
import argparse
import gzip
import os
import shutil
import subprocess
import sys
from datetime import date, datetime, timedelta

# ------------------------------------------------------------------
#  CONFIGURAÇÃO (ajustar na VM)
# ------------------------------------------------------------------
DB_NAME = os.getenv("KOUBE_DB", "koube_producao")
DB_USER = os.getenv("KOUBE_DB_USER", "postgres")
DB_HOST = os.getenv("KOUBE_DB_HOST", "localhost")
DB_PORT = os.getenv("KOUBE_DB_PORT", "5432")
CONTAINER = os.getenv("KOUBE_PG_CONTAINER", "postgres")  # nome do container do Postgres

BACKUP_DIR = os.getenv("KOUBE_BACKUP_DIR", "/home/usuario/backups/koube_producao")
RETENCAO_DIAS = int(os.getenv("KOUBE_BACKUP_RETENCAO", "30"))   # backups mais antigos são apagados

# Quanto tempo manter os registros detalhados antes de limpar:
MANTER_AUDITORIA_DIAS = int(os.getenv("KOUBE_MANTER_AUDITORIA", "180"))   # 6 meses
MANTER_PROGRAMACAO_DIAS = int(os.getenv("KOUBE_MANTER_PROGRAMACAO", "730"))  # 2 anos
MANTER_OS_CONCLUIDAS_DIAS = int(os.getenv("KOUBE_MANTER_OS", "1095"))     # 3 anos


def psql(sql: str, capturar=True):
    """Executa SQL no banco via docker exec + psql."""
    cmd = ["docker", "exec", "-i", CONTAINER, "psql", "-U", DB_USER, "-d", DB_NAME,
           "-t", "-A", "-F", "|", "-c", sql]
    r = subprocess.run(cmd, capture_output=capturar, text=True)
    if r.returncode != 0:
        raise RuntimeError(f"Erro no psql: {r.stderr}")
    return r.stdout.strip() if capturar else ""


# ------------------------------------------------------------------
#  1. BACKUP
# ------------------------------------------------------------------
def fazer_backup() -> str:
    os.makedirs(BACKUP_DIR, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M")
    destino = os.path.join(BACKUP_DIR, f"{DB_NAME}_{stamp}.sql.gz")

    print(f"[backup] gerando {destino} ...")
    dump = subprocess.run(
        ["docker", "exec", CONTAINER, "pg_dump", "-U", DB_USER, DB_NAME],
        capture_output=True, text=True,
    )
    if dump.returncode != 0:
        raise RuntimeError(f"pg_dump falhou: {dump.stderr}")

    with gzip.open(destino, "wt", encoding="utf-8") as f:
        f.write(dump.stdout)

    tamanho = os.path.getsize(destino) / 1024 / 1024
    print(f"[backup] concluído — {tamanho:.1f} MB")

    # retenção
    limite = datetime.now() - timedelta(days=RETENCAO_DIAS)
    removidos = 0
    for arq in os.listdir(BACKUP_DIR):
        caminho = os.path.join(BACKUP_DIR, arq)
        if os.path.isfile(caminho) and datetime.fromtimestamp(os.path.getmtime(caminho)) < limite:
            os.remove(caminho)
            removidos += 1
    if removidos:
        print(f"[backup] {removidos} backup(s) com mais de {RETENCAO_DIAS} dias removido(s)")
    return destino


# ------------------------------------------------------------------
#  2. RELATÓRIO MENSAL (preserva o histórico em resumo)
# ------------------------------------------------------------------
SQL_TABELA_RELATORIOS = """
CREATE TABLE IF NOT EXISTS relatorios_mensais (
    id              SERIAL PRIMARY KEY,
    ano             INT NOT NULL,
    mes             INT NOT NULL,
    -- produção
    total_programado    BIGINT DEFAULT 0,
    total_realizado     BIGINT DEFAULT 0,
    pct_atingido        NUMERIC(6,2) DEFAULT 0,
    -- manutenção
    os_abertas          INT DEFAULT 0,
    os_concluidas       INT DEFAULT 0,
    os_corretivas       INT DEFAULT 0,
    os_preventivas      INT DEFAULT 0,
    preventivas_executadas INT DEFAULT 0,
    -- pessoas
    colaboradores_ativos   INT DEFAULT 0,
    gerado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (ano, mes)
);
"""


def gerar_relatorio(ano: int, mes: int):
    print(f"[relatório] consolidando {mes:02d}/{ano} ...")
    psql(SQL_TABELA_RELATORIOS, capturar=False)

    ini = date(ano, mes, 1)
    fim = date(ano + (mes // 12), (mes % 12) + 1, 1)  # 1º dia do mês seguinte

    sql = f"""
    WITH prod AS (
      SELECT COALESCE(SUM(qtd_programada),0) prog,
             COALESCE(SUM(qtd_realizada),0)  real
      FROM programacao WHERE data >= '{ini}' AND data < '{fim}'
    ), os AS (
      SELECT COUNT(*) FILTER (WHERE criado_em >= '{ini}' AND criado_em < '{fim}') abertas,
             COUNT(*) FILTER (WHERE status='Concluído' AND data_conclusao >= '{ini}' AND data_conclusao < '{fim}') concluidas,
             COUNT(*) FILTER (WHERE tipo='Corretiva' AND criado_em >= '{ini}' AND criado_em < '{fim}') corretivas,
             COUNT(*) FILTER (WHERE tipo<>'Corretiva' AND criado_em >= '{ini}' AND criado_em < '{fim}') preventivas
      FROM ordens_servico
    ), exec AS (
      SELECT COUNT(*) n FROM preventivas_execucao
      WHERE data_realizada >= '{ini}' AND data_realizada < '{fim}'
    ), pess AS (
      SELECT COUNT(*) n FROM colaboradores WHERE ativo = TRUE
    )
    INSERT INTO relatorios_mensais
      (ano, mes, total_programado, total_realizado, pct_atingido,
       os_abertas, os_concluidas, os_corretivas, os_preventivas,
       preventivas_executadas, colaboradores_ativos)
    SELECT {ano}, {mes}, prod.prog, prod.real,
           CASE WHEN prod.prog > 0 THEN ROUND(prod.real::numeric / prod.prog * 100, 2) ELSE 0 END,
           os.abertas, os.concluidas, os.corretivas, os.preventivas, exec.n, pess.n
    FROM prod, os, exec, pess
    ON CONFLICT (ano, mes) DO UPDATE SET
      total_programado = EXCLUDED.total_programado,
      total_realizado  = EXCLUDED.total_realizado,
      pct_atingido     = EXCLUDED.pct_atingido,
      os_abertas       = EXCLUDED.os_abertas,
      os_concluidas    = EXCLUDED.os_concluidas,
      os_corretivas    = EXCLUDED.os_corretivas,
      os_preventivas   = EXCLUDED.os_preventivas,
      preventivas_executadas = EXCLUDED.preventivas_executadas,
      colaboradores_ativos   = EXCLUDED.colaboradores_ativos,
      gerado_em = now();
    """
    psql(sql, capturar=False)

    resumo = psql(f"""SELECT total_programado, total_realizado, pct_atingido,
                             os_abertas, os_concluidas, preventivas_executadas
                      FROM relatorios_mensais WHERE ano={ano} AND mes={mes};""")
    if resumo:
        p, r, pct, oa, oc, pe = resumo.split("|")
        print(f"[relatório] {mes:02d}/{ano}: programado {p} · realizado {r} ({pct}%)")
        print(f"[relatório] OS abertas {oa} · concluídas {oc} · preventivas executadas {pe}")
    print("[relatório] salvo em relatorios_mensais (histórico preservado)")


# ------------------------------------------------------------------
#  3. LIMPEZA (só depois do relatório!)
# ------------------------------------------------------------------
def limpar_antigos():
    print("[limpeza] removendo registros antigos ...")
    alvos = [
        ("auditoria",
         f"DELETE FROM auditoria WHERE criado_em < now() - interval '{MANTER_AUDITORIA_DIAS} days';",
         f"{MANTER_AUDITORIA_DIAS} dias"),
        ("programação",
         f"DELETE FROM programacao WHERE data < current_date - interval '{MANTER_PROGRAMACAO_DIAS} days';",
         f"{MANTER_PROGRAMACAO_DIAS} dias"),
        ("ordens de serviço concluídas",
         f"""DELETE FROM ordens_servico
             WHERE status = 'Concluído'
               AND data_conclusao < current_date - interval '{MANTER_OS_CONCLUIDAS_DIAS} days';""",
         f"{MANTER_OS_CONCLUIDAS_DIAS} dias"),
    ]
    for nome, sql, prazo in alvos:
        antes = psql(f"SELECT count(*) FROM {sql.split('FROM')[1].split('WHERE')[0].strip()};")
        psql(sql, capturar=False)
        depois = psql(f"SELECT count(*) FROM {sql.split('FROM')[1].split('WHERE')[0].strip()};")
        print(f"[limpeza] {nome}: {antes} -> {depois} (mantendo últimos {prazo})")

    print("[limpeza] compactando espaço (VACUUM) ...")
    psql("VACUUM ANALYZE;", capturar=False)
    tamanho = psql(f"SELECT pg_size_pretty(pg_database_size('{DB_NAME}'));")
    print(f"[limpeza] tamanho atual do banco: {tamanho}")


# ------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description="Manutenção do banco Koube Produção")
    ap.add_argument("--backup", action="store_true", help="gera backup comprimido")
    ap.add_argument("--relatorio", metavar="AAAA-MM", help="consolida o mês informado")
    ap.add_argument("--limpeza", action="store_true", help="remove registros antigos")
    ap.add_argument("--tudo", action="store_true",
                    help="backup + relatório do mês anterior + limpeza")
    args = ap.parse_args()

    if not any([args.backup, args.relatorio, args.limpeza, args.tudo]):
        ap.print_help()
        return

    try:
        if args.backup or args.tudo:
            fazer_backup()

        if args.relatorio:
            ano, mes = map(int, args.relatorio.split("-"))
            gerar_relatorio(ano, mes)
        elif args.tudo:
            primeiro_deste_mes = date.today().replace(day=1)
            mes_passado = primeiro_deste_mes - timedelta(days=1)
            gerar_relatorio(mes_passado.year, mes_passado.month)

        if args.limpeza or args.tudo:
            limpar_antigos()

        print("\n✔ Manutenção concluída.")
    except Exception as e:
        print(f"\n✘ Falha: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
