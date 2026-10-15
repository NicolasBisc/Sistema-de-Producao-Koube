"""Runner LOCAL de teste — sobe a API com SQLite (sem precisar de Postgres).
Em produção usa-se o Postgres via DATABASE_URL. Isto é só para validar aqui."""
import os, sys, uuid
sys.path.insert(0, os.path.dirname(__file__))

os.environ["DATABASE_URL"] = "sqlite:////tmp/koube_local.db"
if os.path.exists("/tmp/koube_local.db"):
    os.remove("/tmp/koube_local.db")

import sqlalchemy
from sqlalchemy import String, JSON
import sqlalchemy.dialects.postgresql as pg
pg.UUID = lambda **k: String(36)
pg.JSONB = JSON

import database
database.engine = sqlalchemy.create_engine("sqlite:////tmp/koube_local.db", connect_args={"check_same_thread": False})
database.SessionLocal = sqlalchemy.orm.sessionmaker(bind=database.engine)

import models, security

# senha dos usuários de teste locais; defina SENHA_LOCAL para usar outra
SENHA_LOCAL = os.environ.get("SENHA_LOCAL", "senha-local-teste")
from datetime import date, timedelta
# ids string no SQLite (no Postgres é gen_random_uuid())
for _t in [models.Usuario, models.Produto, models.Programacao, models.Treinamento,
           models.OrdemServico, models.Preventiva, models.PreventivaExecucao]:
    _t.__table__.c.id.default = sqlalchemy.ColumnDefault(lambda: str(uuid.uuid4()))
models.OrdemServico.__table__.c.numero.default = sqlalchemy.ColumnDefault(
    lambda: __import__('random').randint(776, 999999))
# datas string -> date
import sqlalchemy.types as _t2
from datetime import datetime as _dt
class _SD(_t2.TypeDecorator):
    impl = _t2.Date; cache_ok = True
    def process_bind_param(self, v, d):
        return _dt.strptime(v[:10], "%Y-%m-%d").date() if isinstance(v, str) else v
for _m in models.Base.registry.mappers:
    for _c in _m.local_table.columns:
        if isinstance(_c.type, _t2.Date) and not isinstance(_c.type, _SD):
            _c.type = _SD()

models.Base.metadata.create_all(database.engine)

# seed mínimo de demonstração
db = database.SessionLocal()
hoje = date.today()
db.add(models.Setor(id=1, nome="Envase"))
db.add(models.Setor(id=2, nome="Manipulação"))
db.add(models.Setor(id=3, nome="Rotulagem"))
db.add(models.Usuario(id=str(uuid.uuid4()), codigo="NBI", nome="Bianca", cargo="Aprendiz",
    senha_hash=security.hash_senha(SENHA_LOCAL), nivel="admin",
    acesso_producao=True, acesso_manutencao=True, ativo=True, senha_temporaria=False))
db.add(models.Usuario(id=str(uuid.uuid4()), codigo="SPV", nome="Simone", cargo="Supervisor de Produção",
    senha_hash=security.hash_senha(SENHA_LOCAL), nivel="supervisor",
    acesso_producao=True, acesso_manutencao=True, ativo=True, senha_temporaria=False))
db.add(models.Equipamento(id=1, nome="MÁQUINA DE ENVASE 1"))
db.add(models.Equipamento(id=2, nome="COMPRESSOR PARAFUSO TB 30"))
db.commit()
db.add(models.Preventiva(id=str(uuid.uuid4()), equipamento_id=1, sequencia=1,
    atividade="Trocar anéis e vedações dos bicos", periodicidade_dias=15,
    ultima_acao=(hoje - timedelta(days=19)).isoformat()))   # atrasada
db.add(models.Preventiva(id=str(uuid.uuid4()), equipamento_id=1, sequencia=2,
    atividade="Verificação da esteira e lubrificação", periodicidade_dias=30,
    ultima_acao=(hoje - timedelta(days=27)).isoformat()))   # vence em breve
db.add(models.Preventiva(id=str(uuid.uuid4()), equipamento_id=2, sequencia=1,
    atividade="Verificar nível de óleo", periodicidade_dias=90,
    ultima_acao=(hoje - timedelta(days=10)).isoformat()))   # em dia
db.add(models.OrdemServico(id=str(uuid.uuid4()), numero=773, tipo="Corretiva", area="Rotulagem",
    solicitante="Patrícia", solicitacao="Problema na tomada da rotuladora", tecnico="Murilo",
    descricao_servico="Análise do circuito, troca da tomada e teste de carga.",
    data_abertura="2026-07-05", hora_abertura="08:30", data_conclusao="2026-07-05",
    hora_conclusao="13:30", tempo_execucao="5:00", status="Concluído"))
db.commit(); db.close()

# servir o frontend
from fastapi.staticfiles import StaticFiles
import main
_front = os.path.join(os.path.dirname(__file__), "..", "frontend")
# (main.py já monta se a pasta existir; garantir aqui também)
print(f"Seed pronto. Usuário: NBI / senha: {SENHA_LOCAL}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(main.app, host="127.0.0.1", port=8010, log_level="warning")
