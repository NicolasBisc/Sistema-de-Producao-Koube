-- ============================================================
--  KOUBE PRODUÇÃO — Schema do banco de dados (PostgreSQL)
--  Database sugerido: koube_producao (separado do app_db,
--  mesmo servidor Postgres na VM SEU_IP)
--
--  Criar o banco (rodar uma vez, como superusuário):
--    CREATE DATABASE koube_producao;
--  Depois conectar nele e rodar este arquivo:
--    \c koube_producao
--    \i schema.sql
-- ============================================================

-- ---------- extensões ----------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";  -- gen_random_uuid()

-- ============================================================
--  1. USUÁRIOS E ACESSO
--  Login só é criado por admin (sem autocadastro).
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo          VARCHAR(10)  NOT NULL UNIQUE,          -- ex.: NBI, SPV
    nome            VARCHAR(120) NOT NULL,
    cargo           VARCHAR(120),
    senha_hash      VARCHAR(255) NOT NULL,                 -- bcrypt
    nivel           VARCHAR(20)  NOT NULL DEFAULT 'operador',  -- admin | supervisor | operador | manutencao
    senha_temporaria BOOLEAN NOT NULL DEFAULT TRUE,  -- força troca no primeiro acesso
    acesso_producao   BOOLEAN NOT NULL DEFAULT FALSE,
    acesso_manutencao BOOLEAN NOT NULL DEFAULT FALSE,
    acesso_supervisao BOOLEAN NOT NULL DEFAULT FALSE,  -- colaboradores/férias/linhas (só gestão)
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acesso   TIMESTAMPTZ,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por      UUID REFERENCES usuarios(id)
);
COMMENT ON TABLE usuarios IS 'Usuários do sistema. Só admin cria/exclui.';

-- ============================================================
--  2. PRODUTOS
--  Cadastro de produtos (código + descrição + embalagem).
--  Fonte inicial: tabela de preços (DOC 10005). Pode ser
--  sincronizado do app_db futuramente.
-- ============================================================
CREATE TABLE IF NOT EXISTS produtos (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo      VARCHAR(20)  NOT NULL UNIQUE,
    descricao   VARCHAR(200) NOT NULL,
    embalagem   VARCHAR(40),
    ativo       BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON produtos(codigo);

-- ============================================================
--  3. SUPERVISÃO DE PRODUÇÃO
-- ============================================================

-- setores de produção (envase, manipulação, rotulagem)
CREATE TABLE IF NOT EXISTS setores (
    id      SERIAL PRIMARY KEY,
    nome    VARCHAR(60) NOT NULL UNIQUE,
    ativo   BOOLEAN NOT NULL DEFAULT TRUE
);

-- metas mensais (por mês/ano), com dias úteis -> meta diária derivada
CREATE TABLE IF NOT EXISTS metas_mensais (
    id             SERIAL PRIMARY KEY,
    ano            INT NOT NULL,
    mes            INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    meta_mensal    INT NOT NULL,
    dias_uteis     INT NOT NULL,
    -- meta_diaria calculada na aplicação: meta_mensal / dias_uteis
    criado_em      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (ano, mes)
);

-- feriados / dias não produtivos (editáveis)
CREATE TABLE IF NOT EXISTS feriados (
    id        SERIAL PRIMARY KEY,
    data      DATE NOT NULL,
    descricao VARCHAR(120) NOT NULL,
    UNIQUE (data)
);

-- programação de produção: uma linha por item programado num dia/setor
-- É a origem do "programado" e do "realizado" que alimentam o dashboard.
CREATE TABLE IF NOT EXISTS programacao (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data            DATE NOT NULL,
    setor_id        INT  NOT NULL REFERENCES setores(id),
    lote            VARCHAR(30),
    produto_id      UUID REFERENCES produtos(id),
    produto_codigo  VARCHAR(20),          -- redundância p/ histórico mesmo se produto mudar
    produto_desc    VARCHAR(200),
    qtd_programada  INT NOT NULL DEFAULT 0,
    qtd_realizada   INT,                  -- NULL = ainda não preenchido
    observacao      VARCHAR(200),
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por      UUID REFERENCES usuarios(id)
);
CREATE INDEX IF NOT EXISTS idx_prog_data_setor ON programacao(data, setor_id);

-- ============================================================
--  3b. COLABORADORES DA PRODUÇÃO (RH — férias e cargos)
--  Acesso restrito à gestão (acesso_supervisao).
-- ============================================================
CREATE TABLE IF NOT EXISTS colaboradores (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome            VARCHAR(120) NOT NULL,
    cargo           VARCHAR(120),
    setor           VARCHAR(60),                 -- Envase | Manipulação | Rotulagem
    linha_id        INT,                         -- linha/equipe onde atua
    data_admissao   DATE NOT NULL,
    ultimas_ferias  DATE,                        -- (legado) último retorno de férias
    foto            TEXT,                        -- foto (base64 data URL ou caminho)
    -- regra de férias própria (NULL = usa a configuração geral)
    meses_aquisitivo INT,                        -- tempo de espera até ter direito
    dias_direito     INT,                        -- dias de férias a que tem direito
    -- situação
    status          VARCHAR(20) NOT NULL DEFAULT 'ativo',  -- ativo | demitido | afastado
    data_demissao   DATE,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por      UUID REFERENCES usuarios(id)
);
CREATE INDEX IF NOT EXISTS idx_colab_ativo ON colaboradores(ativo);

-- períodos de férias concedidos (histórico completo, editável)
-- A contagem reinicia a partir da DATA DE RETORNO.
CREATE TABLE IF NOT EXISTS ferias_periodos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    colaborador_id  UUID NOT NULL REFERENCES colaboradores(id) ON DELETE CASCADE,
    data_inicio     DATE NOT NULL,
    data_retorno    DATE,                  -- NULL = ainda de férias
    dias            INT,                   -- dias usados (calculado ou informado)
    observacao      VARCHAR(200),
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por      UUID REFERENCES usuarios(id)
);
CREATE INDEX IF NOT EXISTS idx_ferias_colab ON ferias_periodos(colaborador_id, data_inicio DESC);

-- configuração geral de férias (editável pela gestão)
CREATE TABLE IF NOT EXISTS config_ferias (
    id                SERIAL PRIMARY KEY,
    meses_aquisitivo  INT NOT NULL DEFAULT 12,   -- tempo de espera para ter direito
    dias_direito      INT NOT NULL DEFAULT 30,   -- dias de férias por período
    meses_concessivo  INT NOT NULL DEFAULT 12,   -- prazo para conceder após o direito
    dias_aviso        INT NOT NULL DEFAULT 60,   -- avisar X dias antes de vencer
    atualizado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO config_ferias (id, meses_aquisitivo, dias_direito, meses_concessivo, dias_aviso)
    VALUES (1, 12, 30, 12, 60) ON CONFLICT (id) DO NOTHING;

-- linhas de produção / equipes (editáveis pela gestão)
CREATE TABLE IF NOT EXISTS linhas_producao (
    id      SERIAL PRIMARY KEY,
    nome    VARCHAR(60) NOT NULL,
    tipo    VARCHAR(20) NOT NULL DEFAULT 'linha',  -- linha | equipe
    ativo   BOOLEAN NOT NULL DEFAULT TRUE
);

-- ============================================================
--  4. TREINAMENTOS (dentro de Supervisão)
-- ============================================================
CREATE TABLE IF NOT EXISTS treinamentos (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ano           INT NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    nome          VARCHAR(200) NOT NULL,
    tipo          VARCHAR(60),                 -- Interno | Externo | Interno (Manutenção)...
    objetivo      TEXT,
    publico       VARCHAR(200),
    responsavel   VARCHAR(120),
    meses         JSONB NOT NULL DEFAULT '[]', -- meses programados: [1,4,8]
    feitos        JSONB NOT NULL DEFAULT '[]', -- meses já realizados
    ativo         BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em     TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por    UUID REFERENCES usuarios(id)
);
CREATE INDEX IF NOT EXISTS idx_trein_ano ON treinamentos(ano);

-- agendamento de um treinamento num dia específico (dentro do mês programado)
CREATE TABLE IF NOT EXISTS treinamentos_agenda (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treinamento_id  UUID REFERENCES treinamentos(id) ON DELETE CASCADE,
    data            DATE NOT NULL,
    hora            VARCHAR(10),
    instrutor       VARCHAR(120),
    participantes   VARCHAR(200),
    observacao      TEXT,
    realizado       BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por      UUID REFERENCES usuarios(id)
);
CREATE INDEX IF NOT EXISTS idx_trein_agenda_data ON treinamentos_agenda(data);

-- ============================================================
--  5. MANUTENÇÃO
-- ============================================================

-- equipamentos (usados nas preventivas e nas corretivas)
CREATE TABLE IF NOT EXISTS equipamentos (
    id      SERIAL PRIMARY KEY,
    nome    VARCHAR(120) NOT NULL UNIQUE,
    area    VARCHAR(60),
    ativo   BOOLEAN NOT NULL DEFAULT TRUE
);

-- contador único de nº de OS (corretiva e preventiva compartilham).
-- Hoje vocês já estão em 775+. Ajustar o start conforme o real.
CREATE SEQUENCE IF NOT EXISTS seq_osm START WITH 776;

-- contador de código de manutenção (registro de execução)
CREATE SEQUENCE IF NOT EXISTS seq_cod_manut START WITH 1;

-- --------- CORRETIVA: REG 7005 (registro) + REG 7001 (relatório) ---------
-- Uma linha aqui = uma linha no REG 7005 = uma folha REG 7001.
CREATE TABLE IF NOT EXISTS ordens_servico (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero              INT NOT NULL UNIQUE DEFAULT nextval('seq_osm'),
    tipo                VARCHAR(20) NOT NULL DEFAULT 'Corretiva',  -- Corretiva | Preventiva | Outros
    area                VARCHAR(60),
    solicitante         VARCHAR(120),
    solicitacao         TEXT,               -- "Solicitação ou Problema"
    data_abertura       DATE,
    hora_abertura       VARCHAR(10),
    tipo_servico        VARCHAR(40),
    tecnico             VARCHAR(120),
    descricao_servico   TEXT,               -- "Descrição do Serviço Realizado"
    data_conclusao      DATE,
    hora_conclusao      VARCHAR(10),
    tempo_execucao      VARCHAR(20),        -- pode ser calculado (abertura->conclusão)
    custos              TEXT,
    pendencias          TEXT,
    status              VARCHAR(20) NOT NULL DEFAULT 'Pendente', -- Pendente|Em andamento|Concluído
    equipamento_id      INT REFERENCES equipamentos(id),
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por          UUID REFERENCES usuarios(id)
);
CREATE INDEX IF NOT EXISTS idx_os_numero ON ordens_servico(numero);
CREATE INDEX IF NOT EXISTS idx_os_status ON ordens_servico(status);

-- --------- PREVENTIVA: REG 7002 (plano-mestre) ---------
-- Cada linha = uma atividade recorrente de um equipamento.
-- proxima_acao e status (Em dia/Atrasado) são CALCULADOS:
--   proxima_acao = ultima_acao + periodicidade_dias
--   status = 'Atrasado' se proxima_acao < hoje, senão 'Em dia'
CREATE TABLE IF NOT EXISTS preventivas (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipamento_id      INT NOT NULL REFERENCES equipamentos(id),
    sequencia           INT,
    atividade           VARCHAR(200) NOT NULL,
    periodicidade_dias  INT NOT NULL,
    tipo                VARCHAR(40),
    ultima_acao         DATE,
    numero_os           INT,               -- referência ao nº de OS que executou
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_prev_equip ON preventivas(equipamento_id);

-- histórico de execução das preventivas (REG 7003 concluído)
-- Ao registrar aqui, a aplicação atualiza preventivas.ultima_acao.
CREATE TABLE IF NOT EXISTS preventivas_execucao (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo          INT NOT NULL DEFAULT nextval('seq_cod_manut'),  -- código sequencial automático
    preventiva_id   UUID NOT NULL REFERENCES preventivas(id),
    data_realizada  DATE NOT NULL,
    hora            VARCHAR(10),
    motivo          TEXT,
    tipo            VARCHAR(20) DEFAULT 'Preditiva',  -- Corretiva | Preditiva
    numero_os       INT,
    responsavel     VARCHAR(120),
    observacao      TEXT,
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_por      UUID REFERENCES usuarios(id)
);

-- ============================================================
--  6. AUDITORIA (log de tudo: quem, quando, o quê)
--  Mantém a última versão preservada (valor_antigo -> valor_novo).
-- ============================================================
CREATE TABLE IF NOT EXISTS auditoria (
    id            BIGSERIAL PRIMARY KEY,
    usuario_id    UUID REFERENCES usuarios(id),
    usuario_nome  VARCHAR(120),        -- desnormalizado p/ manter mesmo se usuário sumir
    acao          VARCHAR(40) NOT NULL, -- criar | editar | excluir | login | gerar_doc
    entidade      VARCHAR(60),          -- tabela/módulo afetado
    entidade_id   VARCHAR(60),
    descricao     TEXT NOT NULL,
    valor_antigo  JSONB,
    valor_novo    JSONB,
    criado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_audit_data ON auditoria(criado_em DESC);
CREATE INDEX IF NOT EXISTS idx_audit_usuario ON auditoria(usuario_id);

-- ============================================================
--  SEEDS BÁSICOS
-- ============================================================
INSERT INTO setores (nome) VALUES ('Envase'), ('Manipulação'), ('Rotulagem'), ('Manutenção')
    ON CONFLICT (nome) DO NOTHING;

-- linhas de produção iniciais (3 linhas + 1 equipe) — editáveis pela gestão
INSERT INTO linhas_producao (nome, tipo) VALUES
    ('Linha 1', 'linha'), ('Linha 2', 'linha'), ('Linha 3', 'linha'),
    ('Equipe A', 'equipe'), ('Equipe Manutenção', 'equipe')
    ON CONFLICT DO NOTHING;
