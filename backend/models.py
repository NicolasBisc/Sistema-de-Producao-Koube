"""Models SQLAlchemy — espelham as tabelas de db/schema.sql."""
import uuid
from datetime import datetime, date
from sqlalchemy import (
    Column, String, Integer, Boolean, Date, DateTime, Text, ForeignKey, Sequence
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from database import Base


def _uuid():
    return uuid.uuid4()


class Usuario(Base):
    __tablename__ = "usuarios"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    codigo = Column(String(10), unique=True, nullable=False)
    nome = Column(String(120), nullable=False)
    cargo = Column(String(120))
    senha_hash = Column(String(255), nullable=False)
    nivel = Column(String(20), nullable=False, default="operador")
    senha_temporaria = Column(Boolean, default=True)
    acesso_producao = Column(Boolean, default=False)
    acesso_manutencao = Column(Boolean, default=False)
    acesso_supervisao = Column(Boolean, default=False)
    ativo = Column(Boolean, default=True)
    ultimo_acesso = Column(DateTime(timezone=True))
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class Produto(Base):
    __tablename__ = "produtos"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    codigo = Column(String(20), unique=True, nullable=False)
    descricao = Column(String(200), nullable=False)
    embalagem = Column(String(40))
    ativo = Column(Boolean, default=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())


class Setor(Base):
    __tablename__ = "setores"
    id = Column(Integer, primary_key=True)
    nome = Column(String(60), unique=True, nullable=False)
    ativo = Column(Boolean, default=True)


class MetaMensal(Base):
    __tablename__ = "metas_mensais"
    id = Column(Integer, primary_key=True)
    ano = Column(Integer, nullable=False)
    mes = Column(Integer, nullable=False)
    meta_mensal = Column(Integer, nullable=False)
    dias_uteis = Column(Integer, nullable=False)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())


class Feriado(Base):
    __tablename__ = "feriados"
    id = Column(Integer, primary_key=True)
    data = Column(Date, nullable=False, unique=True)
    descricao = Column(String(120), nullable=False)


class Programacao(Base):
    __tablename__ = "programacao"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    data = Column(Date, nullable=False)
    setor_id = Column(Integer, ForeignKey("setores.id"), nullable=False)
    lote = Column(String(30))
    produto_id = Column(UUID(as_uuid=True), ForeignKey("produtos.id"))
    produto_codigo = Column(String(20))
    produto_desc = Column(String(200))
    qtd_programada = Column(Integer, default=0)
    qtd_realizada = Column(Integer)  # NULL = não preenchido
    observacao = Column(String(200))
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class Treinamento(Base):
    __tablename__ = "treinamentos"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    ano = Column(Integer, nullable=False)
    nome = Column(String(200), nullable=False)
    tipo = Column(String(60))
    objetivo = Column(Text)
    publico = Column(String(200))
    responsavel = Column(String(120))
    meses = Column(JSONB, default=list)      # [1,4,8]
    feitos = Column(JSONB, default=list)     # meses já realizados
    ativo = Column(Boolean, default=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class TreinamentoAgenda(Base):
    __tablename__ = "treinamentos_agenda"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    treinamento_id = Column(UUID(as_uuid=True), ForeignKey("treinamentos.id"))
    data = Column(Date, nullable=False)
    hora = Column(String(10))
    instrutor = Column(String(120))
    participantes = Column(String(200))
    observacao = Column(Text)
    realizado = Column(Boolean, default=False)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class Equipamento(Base):
    __tablename__ = "equipamentos"
    id = Column(Integer, primary_key=True)
    nome = Column(String(120), unique=True, nullable=False)
    area = Column(String(60))
    ativo = Column(Boolean, default=True)


class OrdemServico(Base):
    __tablename__ = "ordens_servico"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    numero = Column(Integer, Sequence("seq_osm"), unique=True, nullable=False)
    tipo = Column(String(20), default="Corretiva")
    area = Column(String(60))
    solicitante = Column(String(120))
    solicitacao = Column(Text)
    data_abertura = Column(Date)
    hora_abertura = Column(String(10))
    tipo_servico = Column(String(40))
    tecnico = Column(String(120))
    descricao_servico = Column(Text)
    data_conclusao = Column(Date)
    hora_conclusao = Column(String(10))
    tempo_execucao = Column(String(20))
    custos = Column(Text)
    pendencias = Column(Text)
    status = Column(String(20), default="Pendente")
    equipamento_id = Column(Integer, ForeignKey("equipamentos.id"))
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class Preventiva(Base):
    __tablename__ = "preventivas"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    equipamento_id = Column(Integer, ForeignKey("equipamentos.id"), nullable=False)
    sequencia = Column(Integer)
    atividade = Column(String(200), nullable=False)
    periodicidade_dias = Column(Integer, nullable=False)
    tipo = Column(String(40))
    ultima_acao = Column(Date)
    numero_os = Column(Integer)
    ativo = Column(Boolean, default=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())


class PreventivaExecucao(Base):
    __tablename__ = "preventivas_execucao"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    codigo = Column(Integer, Sequence("seq_cod_manut"))  # código sequencial automático
    preventiva_id = Column(UUID(as_uuid=True), ForeignKey("preventivas.id"), nullable=False)
    data_realizada = Column(Date, nullable=False)
    hora = Column(String(10))
    motivo = Column(Text)
    tipo = Column(String(20), default="Preditiva")  # Corretiva | Preditiva
    numero_os = Column(Integer)
    responsavel = Column(String(120))
    observacao = Column(Text)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class Auditoria(Base):
    __tablename__ = "auditoria"
    id = Column(Integer, primary_key=True)
    usuario_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))
    usuario_nome = Column(String(120))
    acao = Column(String(40), nullable=False)
    entidade = Column(String(60))
    entidade_id = Column(String(60))
    descricao = Column(Text, nullable=False)
    valor_antigo = Column(JSONB)
    valor_novo = Column(JSONB)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())


class Colaborador(Base):
    __tablename__ = "colaboradores"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    nome = Column(String(120), nullable=False)
    cargo = Column(String(120))
    setor = Column(String(60))
    linha_id = Column(Integer)
    data_admissao = Column(Date, nullable=False)
    ultimas_ferias = Column(Date)          # (legado) último retorno
    foto = Column(Text)                    # base64 data URL ou caminho
    meses_aquisitivo = Column(Integer)     # NULL = usa config geral
    dias_direito = Column(Integer)         # NULL = usa config geral
    status = Column(String(20), default="ativo")   # ativo | demitido | afastado
    data_demissao = Column(Date)
    ativo = Column(Boolean, default=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class LinhaProducao(Base):
    __tablename__ = "linhas_producao"
    id = Column(Integer, primary_key=True)
    nome = Column(String(60), nullable=False)
    tipo = Column(String(20), default="linha")   # linha | equipe
    ativo = Column(Boolean, default=True)


class FeriasPeriodo(Base):
    __tablename__ = "ferias_periodos"
    id = Column(UUID(as_uuid=True), primary_key=True, default=_uuid)
    colaborador_id = Column(UUID(as_uuid=True), ForeignKey("colaboradores.id"), nullable=False)
    data_inicio = Column(Date, nullable=False)
    data_retorno = Column(Date)             # NULL = ainda de férias
    dias = Column(Integer)
    observacao = Column(String(200))
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    criado_por = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"))


class ConfigFerias(Base):
    __tablename__ = "config_ferias"
    id = Column(Integer, primary_key=True)
    meses_aquisitivo = Column(Integer, default=12)
    dias_direito = Column(Integer, default=30)
    meses_concessivo = Column(Integer, default=12)
    dias_aviso = Column(Integer, default=60)
    atualizado_em = Column(DateTime(timezone=True), server_default=func.now())
