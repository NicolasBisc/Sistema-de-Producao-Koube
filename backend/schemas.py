"""Schemas Pydantic — validam e tipam os dados que entram na API.
Substituem os 'dict' soltos, evitando dados malformados e injeção via payload."""
from datetime import date
from pydantic import BaseModel, Field, field_validator


class LoginIn(BaseModel):
    codigo: str = Field(min_length=2, max_length=10)
    senha: str = Field(min_length=1, max_length=128)


class NovoUsuario(BaseModel):
    codigo: str = Field(min_length=2, max_length=10, pattern=r"^[A-Za-z0-9]+$")
    nome: str = Field(min_length=2, max_length=120)
    senha: str = Field(min_length=8, max_length=128)
    cargo: str | None = Field(default=None, max_length=120)
    nivel: str = Field(default="operador")
    acesso_producao: bool = False
    acesso_manutencao: bool = False

    @field_validator("nivel")
    @classmethod
    def nivel_valido(cls, v):
        if v not in {"admin", "supervisor", "operador", "manutencao"}:
            raise ValueError("nível inválido")
        return v


class TrocarSenha(BaseModel):
    senha_atual: str = Field(min_length=1, max_length=128)
    senha_nova: str = Field(min_length=8, max_length=128)


class ProgramacaoIn(BaseModel):
    data: date
    setor_id: int
    lote: str | None = Field(default=None, max_length=30)
    produto_codigo: str | None = Field(default=None, max_length=20)
    produto_desc: str | None = Field(default=None, max_length=200)
    qtd_programada: int = Field(ge=0, le=10_000_000)


class RealizadoIn(BaseModel):
    qtd_realizada: int = Field(ge=0, le=10_000_000)


class OrdemServicoIn(BaseModel):
    tipo: str = Field(default="Corretiva", max_length=20)
    area: str | None = Field(default=None, max_length=60)
    solicitante: str | None = Field(default=None, max_length=120)
    solicitacao: str | None = None
    data_abertura: date | None = None
    hora_abertura: str | None = Field(default=None, max_length=10)
    tipo_servico: str | None = Field(default=None, max_length=40)
    tecnico: str | None = Field(default=None, max_length=120)
    descricao_servico: str | None = None
    data_conclusao: date | None = None
    hora_conclusao: str | None = Field(default=None, max_length=10)
    status: str = Field(default="Pendente", max_length=20)


class EquipamentoIn(BaseModel):
    nome: str = Field(min_length=2, max_length=120)
    area: str | None = Field(default=None, max_length=60)


class PreventivaIn(BaseModel):
    equipamento_id: int
    sequencia: int | None = None
    atividade: str = Field(min_length=2, max_length=200)
    periodicidade_dias: int = Field(ge=1, le=3650)
    tipo: str | None = Field(default=None, max_length=40)
    ultima_acao: date | None = None


class ExecucaoIn(BaseModel):
    data_realizada: date
    hora: str | None = Field(default=None, max_length=10)
    motivo: str | None = None
    tipo: str = Field(default="Preditiva", max_length=20)
    responsavel: str | None = Field(default=None, max_length=120)
    observacao: str | None = None


class ColaboradorIn(BaseModel):
    nome: str = Field(min_length=2, max_length=120)
    cargo: str | None = Field(default=None, max_length=120)
    setor: str | None = Field(default=None, max_length=60)
    linha_id: int | None = None
    data_admissao: date
    ultimas_ferias: date | None = None
    foto: str | None = None


class LinhaIn(BaseModel):
    nome: str = Field(min_length=1, max_length=60)
    tipo: str = Field(default="linha")

    @field_validator("tipo")
    @classmethod
    def tipo_ok(cls, v):
        if v not in {"linha", "equipe"}:
            raise ValueError("tipo deve ser 'linha' ou 'equipe'")
        return v


class FeriasPeriodoIn(BaseModel):
    data_inicio: date
    data_retorno: date | None = None
    dias: int | None = None
    observacao: str | None = Field(default=None, max_length=200)


class ConfigFeriasIn(BaseModel):
    meses_aquisitivo: int = Field(ge=1, le=60)
    dias_direito: int = Field(ge=1, le=90)
    meses_concessivo: int = Field(ge=1, le=60)
    dias_aviso: int = Field(ge=1, le=365)


class DemissaoIn(BaseModel):
    data_demissao: date
    observacao: str | None = Field(default=None, max_length=200)


class MetaIn(BaseModel):
    ano: int = Field(ge=2020, le=2100)
    mes: int = Field(ge=1, le=12)
    meta_mensal: int = Field(ge=1, le=100_000_000)
    dias_uteis: int = Field(ge=1, le=31)


class TreinamentoIn(BaseModel):
    ano: int = Field(default=2026, ge=2020, le=2100)
    nome: str = Field(min_length=2, max_length=200)
    tipo: str | None = Field(default=None, max_length=60)
    objetivo: str | None = None
    publico: str | None = Field(default=None, max_length=200)
    responsavel: str | None = Field(default=None, max_length=120)
    meses: list[int] = Field(default_factory=list)
    feitos: list[int] = Field(default_factory=list)

    @field_validator("meses", "feitos")
    @classmethod
    def meses_validos(cls, v):
        if any(m < 1 or m > 12 for m in v):
            raise ValueError("mês deve estar entre 1 e 12")
        return sorted(set(v))


class AgendaIn(BaseModel):
    treinamento_id: str | None = None
    data: date
    hora: str | None = Field(default=None, max_length=10)
    instrutor: str | None = Field(default=None, max_length=120)
    participantes: str | None = Field(default=None, max_length=200)
    observacao: str | None = None
