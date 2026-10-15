"""
KOUBE PRODUÇÃO — API (FastAPI)
Roda no mesmo Docker/VM do Pedidos, database koube_producao.

Endpoints principais:
  POST /auth/login                      login (retorna JWT)
  GET  /usuarios          (admin)       lista usuários
  POST /usuarios          (admin)       cria usuário
  GET  /produtos                        lista produtos p/ seleção
  GET  /programacao?data=&setor_id=     itens programados do dia
  GET  /programacao/periodo?de=&ate=    totais por dia num intervalo (dashboards)
  POST /programacao                     adiciona item
  PATCH/programacao/{id}/realizado      preenche o realizado
  GET  /dashboard?periodo=semanal|mensal   consolida programado x realizado
  GET  /manutencao/os                   REG 7005 (lista de OSM)
  POST /manutencao/os                   abre OSM (corretiva)
  GET  /manutencao/preventivas          REG 7002 c/ próxima ação calculada
  POST /manutencao/preventivas/{id}/executar   registra execução (recalcula)
  GET  /auditoria                       log
"""
from datetime import date, datetime
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from sqlalchemy import desc, func

from config import settings
from database import get_db, engine, Base
import models, security, logica, schemas
from auth import usuario_atual, somente_admin, acesso_supervisao, registrar_auditoria
from protecao import (checar_bloqueio, registrar_falha, limpar_tentativas,
                      validar_forca_senha, SecurityHeadersMiddleware)
from fastapi import Request

app = FastAPI(title="Koube Produção API", version="1.0")

# cabeçalhos de segurança em todas as respostas
app.add_middleware(SecurityHeadersMiddleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in settings.cors_origins.split(",")],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "DELETE"],   # sem wildcard
    allow_headers=["Authorization", "Content-Type"],
)


@app.get("/health")
def health():
    return {"ok": True, "sistema": "Koube Produção"}


# ---------------- AUTH ----------------
@app.post("/auth/login")
def login(request: Request, form: OAuth2PasswordRequestForm = Depends(),
          db: Session = Depends(get_db)):
    codigo = form.username.upper()
    # 1) bloqueio por força bruta
    checar_bloqueio(request, codigo)
    # 2) validação de credenciais
    u = db.query(models.Usuario).filter(models.Usuario.codigo == codigo).first()
    if not u or not security.verificar_senha(form.password, u.senha_hash):
        registrar_falha(request, codigo)
        # log de tentativa falha (sem revelar se o usuário existe)
        registrar_auditoria(db, u if u else None, "login_falha", "usuarios",
                            f"Tentativa de login falhou para código {codigo}")
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Código ou senha inválidos")
    if not u.ativo:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Usuário inativo")
    # 3) sucesso: zera tentativas
    limpar_tentativas(request, codigo)
    u.ultimo_acesso = datetime.utcnow()
    db.commit()
    registrar_auditoria(db, u, "login", "usuarios", "Login realizado")
    return {
        "access_token": security.criar_token(u.id, u.nivel),
        "token_type": "bearer",
        "usuario": {"nome": u.nome, "codigo": u.codigo, "nivel": u.nivel,
                    "acesso_producao": u.acesso_producao, "acesso_manutencao": u.acesso_manutencao,
                    "senha_temporaria": u.senha_temporaria},
    }


@app.post("/auth/trocar-senha")
def trocar_senha(dados: schemas.TrocarSenha, db: Session = Depends(get_db),
                 u=Depends(usuario_atual)):
    """Troca a própria senha. Usado no primeiro acesso (senha_temporaria)."""
    if not security.verificar_senha(dados.senha_atual, u.senha_hash):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Senha atual incorreta")
    validar_forca_senha(dados.senha_nova)
    u.senha_hash = security.hash_senha(dados.senha_nova)
    u.senha_temporaria = False
    db.commit()
    registrar_auditoria(db, u, "editar", "usuarios", "Alterou a própria senha", str(u.id))
    return {"ok": True}


# ---------------- USUÁRIOS (só admin cria) ----------------
@app.get("/usuarios")
def listar_usuarios(db: Session = Depends(get_db), _=Depends(usuario_atual)):
    return db.query(models.Usuario).order_by(models.Usuario.nome).all()


@app.post("/usuarios", status_code=201)
def criar_usuario(dados: schemas.NovoUsuario, db: Session = Depends(get_db),
                  admin=Depends(somente_admin)):
    if db.query(models.Usuario).filter(models.Usuario.codigo == dados.codigo.upper()).first():
        raise HTTPException(400, "Código já existe")
    validar_forca_senha(dados.senha)   # senha inicial já precisa ser forte
    u = models.Usuario(
        codigo=dados.codigo.upper(), nome=dados.nome, cargo=dados.cargo,
        senha_hash=security.hash_senha(dados.senha), nivel=dados.nivel,
        senha_temporaria=True,          # obriga troca no primeiro acesso
        acesso_producao=dados.acesso_producao,
        acesso_manutencao=dados.acesso_manutencao,
        criado_por=admin.id,
    )
    db.add(u); db.commit(); db.refresh(u)
    registrar_auditoria(db, admin, "criar", "usuarios",
                        f"Criou usuário {u.nome} ({u.codigo})", str(u.id))
    return u


# ---------------- PRODUTOS ----------------
@app.get("/produtos")
def listar_produtos(db: Session = Depends(get_db), _=Depends(usuario_atual)):
    return db.query(models.Produto).filter(models.Produto.ativo == True)\
        .order_by(models.Produto.descricao).all()


# ---------------- PROGRAMAÇÃO ----------------
@app.get("/programacao")
def listar_programacao(data: date, setor_id: int,
                       db: Session = Depends(get_db), _=Depends(usuario_atual)):
    return db.query(models.Programacao).filter(
        models.Programacao.data == data,
        models.Programacao.setor_id == setor_id).all()


@app.get("/programacao/periodo")
def programacao_periodo(de: date, ate: date, setor_id: int | None = None,
                        db: Session = Depends(get_db), _=Depends(usuario_atual)):
    """Totais de programado x realizado por dia, num intervalo.

    Usado pelos dashboards semanal e mensal. Devolve um dia por linha,
    já somado, para o frontend não precisar puxar item a item.
    """
    if ate < de:
        raise HTTPException(400, "A data final deve ser igual ou posterior à inicial.")
    if (ate - de).days > 400:
        raise HTTPException(400, "Intervalo muito grande (máximo de 400 dias).")

    q = db.query(
        models.Programacao.data.label("data"),
        func.coalesce(func.sum(models.Programacao.qtd_programada), 0).label("programado"),
        func.coalesce(func.sum(models.Programacao.qtd_realizada), 0).label("realizado"),
    ).filter(
        models.Programacao.data >= de,
        models.Programacao.data <= ate,
    )
    if setor_id is not None:
        q = q.filter(models.Programacao.setor_id == setor_id)

    linhas = q.group_by(models.Programacao.data).order_by(models.Programacao.data).all()
    return [{"data": r.data.isoformat(),
             "programado": int(r.programado or 0),
             "realizado": int(r.realizado or 0)} for r in linhas]


@app.post("/programacao", status_code=201)
def add_programacao(dados: schemas.ProgramacaoIn, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    item = models.Programacao(
        data=dados.data, setor_id=dados.setor_id, lote=dados.lote,
        produto_codigo=dados.produto_codigo, produto_desc=dados.produto_desc,
        qtd_programada=dados.qtd_programada, criado_por=u.id,
    )
    db.add(item); db.commit(); db.refresh(item)
    registrar_auditoria(db, u, "criar", "programacao",
                        f"Programou {item.qtd_programada} un. de {item.produto_desc}", str(item.id))
    return item


@app.patch("/programacao/{item_id}/realizado")
def preencher_realizado(item_id: str, dados: schemas.RealizadoIn,
                        db: Session = Depends(get_db), u=Depends(usuario_atual)):
    item = db.query(models.Programacao).filter(models.Programacao.id == item_id).first()
    if not item:
        raise HTTPException(404, "Item não encontrado")
    antigo = item.qtd_realizada
    item.qtd_realizada = dados.qtd_realizada
    db.commit()
    registrar_auditoria(db, u, "editar", "programacao",
                        f"Preencheu realizado de {item.produto_desc}: {dados.qtd_realizada} un.",
                        str(item.id), {"qtd_realizada": antigo}, {"qtd_realizada": item.qtd_realizada})
    return item


# ---------------- DASHBOARD ----------------
@app.get("/dashboard")
def dashboard(inicio: date, fim: date, db: Session = Depends(get_db), _=Depends(usuario_atual)):
    itens = db.query(models.Programacao).filter(
        models.Programacao.data >= inicio, models.Programacao.data <= fim).all()
    resumo = logica.resumo_producao([
        {"qtd_programada": i.qtd_programada, "qtd_realizada": i.qtd_realizada} for i in itens
    ])
    return {"inicio": inicio, "fim": fim, **resumo}


# ---------------- MANUTENÇÃO: CORRETIVA (REG 7005 / 7001) ----------------
@app.get("/manutencao/os")
def listar_os(tipo: str | None = None, status: str | None = None,
              limite: int = 1000, db: Session = Depends(get_db), _=Depends(usuario_atual)):
    """Ordens de serviço, da mais recente para a mais antiga.

    O limite anterior de 200 escondia as corretivas, que são mais antigas
    que a rotina de preventivas de 2025/2026.
    """
    limite = max(1, min(limite, 5000))
    q = db.query(models.OrdemServico)
    if tipo:
        q = q.filter(models.OrdemServico.tipo == tipo)
    if status:
        q = q.filter(models.OrdemServico.status == status)
    return q.order_by(desc(models.OrdemServico.numero)).limit(limite).all()


@app.post("/manutencao/os", status_code=201)
def abrir_os(dados: schemas.OrdemServicoIn, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    os_ = models.OrdemServico(
        tipo=dados.tipo, area=dados.area,
        solicitante=dados.solicitante, solicitacao=dados.solicitacao,
        data_abertura=dados.data_abertura, hora_abertura=dados.hora_abertura,
        tipo_servico=dados.tipo_servico, tecnico=dados.tecnico,
        descricao_servico=dados.descricao_servico,
        data_conclusao=dados.data_conclusao, hora_conclusao=dados.hora_conclusao,
        status=dados.status, criado_por=u.id,
    )
    db.add(os_); db.commit(); db.refresh(os_)
    registrar_auditoria(db, u, "criar", "ordens_servico",
                        f"Abriu OSM {os_.numero} ({os_.tipo}) — {os_.area}", str(os_.id))
    return {"id": str(os_.id), "numero": os_.numero, "tipo": os_.tipo,
            "area": os_.area, "status": os_.status}


# ---------------- MANUTENÇÃO: EQUIPAMENTOS (incluir / excluir) ----------------
@app.get("/manutencao/equipamentos")
def listar_equipamentos(db: Session = Depends(get_db), _=Depends(usuario_atual)):
    return db.query(models.Equipamento).filter(models.Equipamento.ativo == True)\
        .order_by(models.Equipamento.nome).all()


@app.post("/manutencao/equipamentos", status_code=201)
def criar_equipamento(dados: schemas.EquipamentoIn, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    eq = models.Equipamento(nome=dados.nome, area=dados.area)
    db.add(eq); db.commit(); db.refresh(eq)
    registrar_auditoria(db, u, "criar", "equipamentos",
                        f"Cadastrou equipamento: {eq.nome}", str(eq.id))
    return eq


@app.delete("/manutencao/equipamentos/{eq_id}")
def excluir_equipamento(eq_id: int, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    """Exclusão lógica (marca inativo) — preserva histórico de máquinas descartadas."""
    eq = db.query(models.Equipamento).filter(models.Equipamento.id == eq_id).first()
    if not eq:
        raise HTTPException(404, "Equipamento não encontrado")
    eq.ativo = False
    # desativa também as atividades preventivas do equipamento
    db.query(models.Preventiva).filter(models.Preventiva.equipamento_id == eq_id)\
        .update({"ativo": False})
    db.commit()
    registrar_auditoria(db, u, "excluir", "equipamentos",
                        f"Descartou equipamento: {eq.nome}", str(eq.id))
    return {"ok": True}


# ---------------- MANUTENÇÃO: ATIVIDADES PREVENTIVAS (ficha do equipamento) ----------------
@app.post("/manutencao/preventivas", status_code=201)
def criar_preventiva(dados: schemas.PreventivaIn, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    """Adiciona uma parte/atividade com periodicidade à ficha do equipamento."""
    p = models.Preventiva(
        equipamento_id=dados.equipamento_id, sequencia=dados.sequencia,
        atividade=dados.atividade, periodicidade_dias=dados.periodicidade_dias,
        tipo=dados.tipo, ultima_acao=dados.ultima_acao,
    )
    db.add(p); db.commit(); db.refresh(p)
    registrar_auditoria(db, u, "criar", "preventivas",
                        f"Nova atividade preventiva ({p.periodicidade_dias}d): {p.atividade}", str(p.id))
    return p


@app.delete("/manutencao/preventivas/{prev_id}")
def excluir_preventiva(prev_id: str, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    p = db.query(models.Preventiva).filter(models.Preventiva.id == prev_id).first()
    if not p:
        raise HTTPException(404, "Atividade não encontrada")
    p.ativo = False; db.commit()
    registrar_auditoria(db, u, "excluir", "preventivas",
                        f"Removeu atividade: {p.atividade}", str(p.id))
    return {"ok": True}


# ---------------- MANUTENÇÃO: PREVENTIVA (REG 7002 / 7003) ----------------
@app.get("/manutencao/preventivas")
def listar_preventivas(db: Session = Depends(get_db), _=Depends(usuario_atual)):
    """Cada atividade com próxima ação, status e aviso CALCULADOS.
    Estados: Em dia | Vence em breve (faltam <=5d) | Atrasado (acumula dias)."""
    prevs = db.query(models.Preventiva).filter(models.Preventiva.ativo == True).all()
    equipamentos = {e.id: e.nome for e in db.query(models.Equipamento).all()}
    hoje = date.today()
    resultado = []
    for p in prevs:
        calc = logica.status_preventiva(p.ultima_acao, p.periodicidade_dias, hoje)
        resultado.append({
            "id": str(p.id), "equipamento": equipamentos.get(p.equipamento_id),
            "sequencia": p.sequencia, "atividade": p.atividade,
            "periodicidade_dias": p.periodicidade_dias, "ultima_acao": p.ultima_acao,
            "tipo": p.tipo, "numero_os": p.numero_os,
            "proxima_acao": calc["proxima_acao"], "status": calc["status"],
            "dias_restantes": calc["dias_restantes"], "dias_atraso": calc["dias_atraso"],
            "aviso": calc["aviso"],
        })
    # ordena: atrasadas primeiro, depois vence em breve, depois em dia
    ordem = {"Atrasado": 0, "Vence em breve": 1, "Em dia": 2, "Sem histórico": 3}
    resultado.sort(key=lambda r: (ordem.get(r["status"], 9), -(r["dias_atraso"] or 0)))
    return resultado


@app.post("/manutencao/preventivas/{prev_id}/executar")
def executar_preventiva(prev_id: str, dados: schemas.ExecucaoIn,
                        db: Session = Depends(get_db), u=Depends(usuario_atual)):
    """Registra execução (código sequencial automático) -> atualiza última ação
    -> próxima ação recalculada sozinha."""
    p = db.query(models.Preventiva).filter(models.Preventiva.id == prev_id).first()
    if not p:
        raise HTTPException(404, "Preventiva não encontrada")
    exec_ = models.PreventivaExecucao(
        preventiva_id=p.id, data_realizada=dados.data_realizada,
        hora=dados.hora, motivo=dados.motivo, tipo=dados.tipo,
        responsavel=dados.responsavel, observacao=dados.observacao,
        criado_por=u.id,
    )
    antigo = p.ultima_acao
    p.ultima_acao = dados.data_realizada
    db.add(exec_); db.commit(); db.refresh(exec_)
    registrar_auditoria(db, u, "editar", "preventivas",
                        f"Executou preventiva (cód. {exec_.codigo}): {p.atividade}", str(p.id),
                        {"ultima_acao": str(antigo)}, {"ultima_acao": str(p.ultima_acao)})
    nova = logica.status_preventiva(p.ultima_acao, p.periodicidade_dias)
    return {"ok": True, "codigo": exec_.codigo,
            "proxima_acao": nova["proxima_acao"], "status": nova["status"]}


# ---------------- DASHBOARD DE MANUTENÇÃO (interno) ----------------
@app.get("/manutencao/dashboard")
def dashboard_manutencao(db: Session = Depends(get_db), _=Depends(usuario_atual)):
    """Painel interno do setor de manutenção (não exposto no dashboard principal)."""
    prevs = db.query(models.Preventiva).filter(models.Preventiva.ativo == True).all()
    hoje = date.today()
    prev_calc = [logica.status_preventiva(p.ultima_acao, p.periodicidade_dias, hoje) for p in prevs]
    for pc, p in zip(prev_calc, prevs):
        pc["status"] = pc["status"]
    ordens = db.query(models.OrdemServico).all()
    resumo = logica.resumo_manutencao(prev_calc, [{"tipo": o.tipo} for o in ordens])
    return resumo


# ---------------- AUDITORIA ----------------
@app.get("/auditoria")
def listar_auditoria(limite: int = 100, db: Session = Depends(get_db), _=Depends(usuario_atual)):
    return db.query(models.Auditoria).order_by(desc(models.Auditoria.criado_em)).limit(limite).all()


# ---------------- COLABORADORES (RH — férias, cargos) ----------------
def _cfg_ferias(db):
    c = db.query(models.ConfigFerias).filter(models.ConfigFerias.id == 1).first()
    if not c:
        c = models.ConfigFerias(id=1, meses_aquisitivo=12, dias_direito=30,
                                meses_concessivo=12, dias_aviso=60)
        db.add(c); db.commit()
    return c


def _situacao_ferias(db, c, cfg, hoje):
    """Monta a situação de férias do colaborador considerando o histórico."""
    periodos = db.query(models.FeriasPeriodo)\
        .filter(models.FeriasPeriodo.colaborador_id == c.id)\
        .order_by(desc(models.FeriasPeriodo.data_inicio)).all()
    de_ferias_desde = None
    ultimo_retorno = None
    for p in periodos:
        if p.data_retorno is None:
            de_ferias_desde = p.data_inicio      # período aberto = está de férias
            break
        ultimo_retorno = p.data_retorno          # o mais recente já fechado
        break
    if ultimo_retorno is None and not de_ferias_desde:
        ultimo_retorno = c.ultimas_ferias        # compatibilidade com dado antigo
    return logica.status_ferias(
        c.data_admissao, ultimo_retorno, hoje,
        meses_aquisitivo=c.meses_aquisitivo or cfg.meses_aquisitivo,
        dias_direito=c.dias_direito or cfg.dias_direito,
        meses_concessivo=cfg.meses_concessivo,
        dias_aviso=cfg.dias_aviso,
        de_ferias_desde=de_ferias_desde,
    ), periodos


@app.get("/config-ferias")
def obter_config_ferias(db: Session = Depends(get_db), _=Depends(acesso_supervisao)):
    c = _cfg_ferias(db)
    return {"meses_aquisitivo": c.meses_aquisitivo, "dias_direito": c.dias_direito,
            "meses_concessivo": c.meses_concessivo, "dias_aviso": c.dias_aviso}


@app.patch("/config-ferias")
def salvar_config_ferias(dados: schemas.ConfigFeriasIn, db: Session = Depends(get_db),
                         u=Depends(acesso_supervisao)):
    c = _cfg_ferias(db)
    antes = {"meses_aquisitivo": c.meses_aquisitivo, "dias_direito": c.dias_direito,
             "meses_concessivo": c.meses_concessivo, "dias_aviso": c.dias_aviso}
    c.meses_aquisitivo = dados.meses_aquisitivo
    c.dias_direito = dados.dias_direito
    c.meses_concessivo = dados.meses_concessivo
    c.dias_aviso = dados.dias_aviso
    db.commit()
    registrar_auditoria(db, u, "editar", "config_ferias",
                        f"Alterou regra de férias: {dados.meses_aquisitivo} meses de espera, "
                        f"{dados.dias_direito} dias de direito", "1", antes, dados.model_dump())
    return {"ok": True}


@app.get("/colaboradores")
def listar_colaboradores(incluir_inativos: bool = False,
                         db: Session = Depends(get_db), _=Depends(acesso_supervisao)):
    """Lista colaboradores com a situação de férias e experiência CALCULADAS."""
    q = db.query(models.Colaborador)
    if not incluir_inativos:
        q = q.filter(models.Colaborador.ativo == True)
    colabs = q.order_by(models.Colaborador.nome).all()
    linhas = {l.id: l.nome for l in db.query(models.LinhaProducao).all()}
    cfg = _cfg_ferias(db)
    hoje = date.today()
    out = []
    for c in colabs:
        fer, periodos = _situacao_ferias(db, c, cfg, hoje)
        exp = logica.status_experiencia(c.data_admissao, hoje)
        out.append({
            "id": str(c.id), "nome": c.nome, "cargo": c.cargo, "setor": c.setor,
            "linha": linhas.get(c.linha_id), "linha_id": c.linha_id,
            "data_admissao": c.data_admissao, "foto": c.foto,
            "status": c.status, "data_demissao": c.data_demissao, "ativo": c.ativo,
            "meses_aquisitivo": c.meses_aquisitivo, "dias_direito": c.dias_direito,
            "meses_casa": fer["meses_casa"], "ferias_status": fer["status"],
            "ferias_aviso": fer["aviso"], "tem_direito": fer["tem_direito"],
            "ferias_dias_direito": fer["dias_direito"],
            "ferias_proximo_direito": fer.get("proximo_direito"),
            "ferias_vence_em": fer.get("vence_em"),
            "exp_status": exp["status"], "exp_aviso": exp["aviso"],
            "em_experiencia": exp["em_experiencia"],
            "ferias_historico": [
                {"id": str(p.id), "inicio": p.data_inicio, "retorno": p.data_retorno,
                 "dias": p.dias, "obs": p.observacao} for p in periodos
            ],
        })
    return out


@app.post("/colaboradores", status_code=201)
def criar_colaborador(dados: schemas.ColaboradorIn, db: Session = Depends(get_db),
                      u=Depends(acesso_supervisao)):
    c = models.Colaborador(
        nome=dados.nome, cargo=dados.cargo, setor=dados.setor, linha_id=dados.linha_id,
        data_admissao=dados.data_admissao, ultimas_ferias=dados.ultimas_ferias,
        foto=dados.foto, meses_aquisitivo=dados.meses_aquisitivo,
        dias_direito=dados.dias_direito, criado_por=u.id,
    )
    db.add(c); db.commit(); db.refresh(c)
    registrar_auditoria(db, u, "criar", "colaboradores",
                        f"Cadastrou colaborador {c.nome} ({c.cargo or '—'})", str(c.id))
    return {"id": str(c.id), "nome": c.nome, "cargo": c.cargo, "setor": c.setor,
            "linha_id": c.linha_id, "data_admissao": c.data_admissao}


@app.patch("/colaboradores/{colab_id}")
def editar_colaborador(colab_id: str, dados: dict, db: Session = Depends(get_db),
                       u=Depends(acesso_supervisao)):
    c = db.query(models.Colaborador).filter(models.Colaborador.id == colab_id).first()
    if not c:
        raise HTTPException(404, "Colaborador não encontrado")
    linha_antiga = c.linha_id
    antes = {"nome": c.nome, "cargo": c.cargo, "setor": c.setor, "linha_id": c.linha_id}
    for campo in ("nome", "cargo", "setor", "linha_id", "data_admissao", "ultimas_ferias",
                  "foto", "meses_aquisitivo", "dias_direito", "status", "data_demissao"):
        if campo in dados:
            setattr(c, campo, dados[campo])
    db.commit()
    # descrição específica quando houve transferência de linha
    if "linha_id" in dados and dados["linha_id"] != linha_antiga:
        nomes = {l.id: l.nome for l in db.query(models.LinhaProducao).all()}
        desc = (f"Transferiu {c.nome}: {nomes.get(linha_antiga, '—')} "
                f"→ {nomes.get(c.linha_id, '—')}")
    else:
        desc = f"Atualizou colaborador {c.nome}"
    registrar_auditoria(db, u, "editar", "colaboradores", desc, str(c.id),
                        antes, {"nome": c.nome, "cargo": c.cargo, "setor": c.setor,
                                "linha_id": c.linha_id})
    return {"ok": True}


@app.delete("/colaboradores/{colab_id}")
def excluir_colaborador(colab_id: str, db: Session = Depends(get_db),
                        u=Depends(acesso_supervisao)):
    c = db.query(models.Colaborador).filter(models.Colaborador.id == colab_id).first()
    if not c:
        raise HTTPException(404, "Colaborador não encontrado")
    c.ativo = False; db.commit()
    registrar_auditoria(db, u, "excluir", "colaboradores",
                        f"Removeu colaborador {c.nome}", str(c.id))
    return {"ok": True}


# ---------------- LINHAS DE PRODUÇÃO (editáveis pela gestão) ----------------
@app.get("/linhas")
def listar_linhas(db: Session = Depends(get_db), _=Depends(usuario_atual)):
    return db.query(models.LinhaProducao).filter(models.LinhaProducao.ativo == True)\
        .order_by(models.LinhaProducao.id).all()


@app.post("/linhas", status_code=201)
def criar_linha(dados: schemas.LinhaIn, db: Session = Depends(get_db),
                u=Depends(acesso_supervisao)):
    l = models.LinhaProducao(nome=dados.nome, tipo=dados.tipo)
    db.add(l); db.commit(); db.refresh(l)
    registrar_auditoria(db, u, "criar", "linhas_producao",
                        f"Criou {dados.tipo}: {l.nome}", str(l.id))
    return {"id": l.id, "nome": l.nome, "tipo": l.tipo}


@app.patch("/linhas/{linha_id}")
def editar_linha(linha_id: int, dados: dict, db: Session = Depends(get_db),
                 u=Depends(acesso_supervisao)):
    l = db.query(models.LinhaProducao).filter(models.LinhaProducao.id == linha_id).first()
    if not l:
        raise HTTPException(404, "Linha não encontrada")
    if "nome" in dados: l.nome = dados["nome"]
    if "tipo" in dados: l.tipo = dados["tipo"]
    db.commit()
    registrar_auditoria(db, u, "editar", "linhas_producao", f"Renomeou linha para {l.nome}", str(l.id))
    return {"ok": True}


@app.delete("/linhas/{linha_id}")
def excluir_linha(linha_id: int, db: Session = Depends(get_db), u=Depends(acesso_supervisao)):
    l = db.query(models.LinhaProducao).filter(models.LinhaProducao.id == linha_id).first()
    if not l:
        raise HTTPException(404, "Linha não encontrada")
    l.ativo = False; db.commit()
    registrar_auditoria(db, u, "excluir", "linhas_producao", f"Removeu {l.tipo}: {l.nome}", str(l.id))
    return {"ok": True}




# ---------------- CENTRAL DE ALERTAS (dashboard) ----------------
@app.get("/alertas")
def central_alertas(db: Session = Depends(get_db), u=Depends(usuario_atual)):
    """Junta o que precisa de atenção agora: manutenção preventiva,
    férias, período de experiência e ordens de serviço pendentes.
    Respeita o acesso do usuário (RH só para a gestão)."""
    hoje = date.today()
    itens = []

    # --- manutenção preventiva ---
    if u.acesso_manutencao or u.nivel == "admin":
        equip = {e.id: e.nome for e in db.query(models.Equipamento).all()}
        for p in db.query(models.Preventiva).filter(models.Preventiva.ativo == True).all():
            calc = logica.status_preventiva(p.ultima_acao, p.periodicidade_dias, hoje)
            if calc["status"] == "Atrasado":
                itens.append({"tipo": "preventiva", "gravidade": "alta",
                              "titulo": f"{equip.get(p.equipamento_id, '—')}: {p.atividade}",
                              "detalhe": calc["aviso"], "modulo": "Manutenção"})
            elif calc["status"] == "Vence em breve":
                itens.append({"tipo": "preventiva", "gravidade": "media",
                              "titulo": f"{equip.get(p.equipamento_id, '—')}: {p.atividade}",
                              "detalhe": calc["aviso"], "modulo": "Manutenção"})
        pendentes = db.query(models.OrdemServico).filter(
            models.OrdemServico.status != "Concluído").count()
        if pendentes:
            itens.append({"tipo": "os", "gravidade": "media",
                          "titulo": f"{pendentes} ordem(ns) de serviço em aberto",
                          "detalhe": "Corretivas pendentes ou em andamento",
                          "modulo": "Manutenção"})

    # --- RH: férias e experiência (só gestão) ---
    if u.nivel == "admin" or u.acesso_supervisao:
        for c in db.query(models.Colaborador).filter(models.Colaborador.ativo == True).all():
            fer = logica.status_ferias(c.data_admissao, c.ultimas_ferias, hoje)
            if fer["status"] == "Férias vencidas":
                itens.append({"tipo": "ferias", "gravidade": "alta",
                              "titulo": f"{c.nome} — férias vencidas",
                              "detalhe": fer["aviso"], "modulo": "Supervisão"})
            elif fer["status"] == "Conceder logo":
                itens.append({"tipo": "ferias", "gravidade": "media",
                              "titulo": f"{c.nome} — programar férias",
                              "detalhe": fer["aviso"], "modulo": "Supervisão"})
            exp = logica.status_experiencia(c.data_admissao, hoje)
            if exp["status"] == "Marco vencendo":
                itens.append({"tipo": "experiencia", "gravidade": "alta",
                              "titulo": f"{c.nome} — período de experiência",
                              "detalhe": exp["aviso"], "modulo": "Supervisão"})

    ordem = {"alta": 0, "media": 1, "baixa": 2}
    itens.sort(key=lambda i: ordem.get(i["gravidade"], 9))
    return {"total": len(itens),
            "altas": sum(1 for i in itens if i["gravidade"] == "alta"),
            "medias": sum(1 for i in itens if i["gravidade"] == "media"),
            "itens": itens[:40]}




# ---------------- FÉRIAS: períodos (registrar, editar, apagar) ----------------
@app.post("/colaboradores/{colab_id}/ferias", status_code=201)
def registrar_ferias(colab_id: str, dados: schemas.FeriasPeriodoIn,
                     db: Session = Depends(get_db), u=Depends(acesso_supervisao)):
    """Registra um período de férias. Sem data_retorno = está de férias agora.
    Quando o retorno é informado, a contagem reinicia a partir dele."""
    c = db.query(models.Colaborador).filter(models.Colaborador.id == colab_id).first()
    if not c:
        raise HTTPException(404, "Colaborador não encontrado")
    dias = dados.dias
    if dias is None and dados.data_retorno:
        dias = (dados.data_retorno - dados.data_inicio).days   # Pydantic já entrega date
    p = models.FeriasPeriodo(
        colaborador_id=c.id, data_inicio=dados.data_inicio,
        data_retorno=dados.data_retorno, dias=dias,
        observacao=dados.observacao, criado_por=u.id,
    )
    db.add(p)
    if dados.data_retorno:
        c.ultimas_ferias = dados.data_retorno      # mantém o campo legado coerente
    db.commit(); db.refresh(p)
    desc = (f"Registrou férias de {c.nome}: {dados.data_inicio}"
            + (f" a {dados.data_retorno} ({dias} dias)" if dados.data_retorno else " (em andamento)"))
    registrar_auditoria(db, u, "criar", "ferias_periodos", desc, str(p.id))
    return {"id": str(p.id), "data_inicio": p.data_inicio,
            "data_retorno": p.data_retorno, "dias": p.dias}


@app.patch("/ferias/{periodo_id}")
def editar_ferias(periodo_id: str, dados: dict, db: Session = Depends(get_db),
                  u=Depends(acesso_supervisao)):
    """Edita um período — usado para lançar o RETORNO e reiniciar a contagem."""
    p = db.query(models.FeriasPeriodo).filter(models.FeriasPeriodo.id == periodo_id).first()
    if not p:
        raise HTTPException(404, "Período não encontrado")
    antes = {"data_inicio": str(p.data_inicio), "data_retorno": str(p.data_retorno)}
    for campo in ("data_inicio", "data_retorno", "dias", "observacao"):
        if campo in dados:
            setattr(p, campo, dados[campo])
    if p.data_retorno and p.data_inicio and not dados.get("dias"):
        ini, ret = p.data_inicio, p.data_retorno
        if isinstance(ini, str):
            ini = datetime.strptime(ini[:10], "%Y-%m-%d").date()
        if isinstance(ret, str):
            ret = datetime.strptime(ret[:10], "%Y-%m-%d").date()
        p.dias = (ret - ini).days
    c = db.query(models.Colaborador).filter(models.Colaborador.id == p.colaborador_id).first()
    if c and p.data_retorno:
        c.ultimas_ferias = p.data_retorno
    db.commit()
    registrar_auditoria(db, u, "editar", "ferias_periodos",
                        f"Atualizou férias de {c.nome if c else '—'} (retorno: {p.data_retorno})",
                        str(p.id), antes, {"data_retorno": str(p.data_retorno)})
    return {"ok": True, "dias": p.dias}


@app.delete("/ferias/{periodo_id}")
def apagar_ferias(periodo_id: str, db: Session = Depends(get_db),
                  u=Depends(acesso_supervisao)):
    p = db.query(models.FeriasPeriodo).filter(models.FeriasPeriodo.id == periodo_id).first()
    if not p:
        raise HTTPException(404, "Período não encontrado")
    db.delete(p); db.commit()
    registrar_auditoria(db, u, "excluir", "ferias_periodos",
                        f"Removeu período de férias iniciado em {p.data_inicio}", periodo_id)
    return {"ok": True}


# ---------------- COLABORADOR: demissão / reativação ----------------
@app.post("/colaboradores/{colab_id}/demitir")
def demitir_colaborador(colab_id: str, dados: schemas.DemissaoIn,
                        db: Session = Depends(get_db), u=Depends(acesso_supervisao)):
    """Marca como demitido preservando todo o histórico (não apaga nada)."""
    c = db.query(models.Colaborador).filter(models.Colaborador.id == colab_id).first()
    if not c:
        raise HTTPException(404, "Colaborador não encontrado")
    c.status = "demitido"
    c.data_demissao = dados.data_demissao
    c.ativo = False
    db.commit()
    registrar_auditoria(db, u, "editar", "colaboradores",
                        f"Registrou demissão de {c.nome} em {dados.data_demissao}", str(c.id))
    return {"ok": True}


@app.post("/colaboradores/{colab_id}/reativar")
def reativar_colaborador(colab_id: str, db: Session = Depends(get_db),
                         u=Depends(acesso_supervisao)):
    c = db.query(models.Colaborador).filter(models.Colaborador.id == colab_id).first()
    if not c:
        raise HTTPException(404, "Colaborador não encontrado")
    c.status = "ativo"; c.data_demissao = None; c.ativo = True
    db.commit()
    registrar_auditoria(db, u, "editar", "colaboradores", f"Reativou {c.nome}", str(c.id))
    return {"ok": True}




# ---------------- METAS MENSAIS ----------------
@app.get("/metas")
def obter_meta(ano: int, mes: int, db: Session = Depends(get_db), _=Depends(usuario_atual)):
    mt = db.query(models.MetaMensal).filter(models.MetaMensal.ano == ano,
                                            models.MetaMensal.mes == mes).first()
    if not mt:
        return {"definida": False, "meta_mensal": None, "dias_uteis": None}
    return {"definida": True, "ano": mt.ano, "mes": mt.mes,
            "meta_mensal": mt.meta_mensal, "dias_uteis": mt.dias_uteis,
            "meta_diaria": logica.meta_diaria(mt.meta_mensal, mt.dias_uteis),
            "meta_semanal": logica.meta_semanal(logica.meta_diaria(mt.meta_mensal, mt.dias_uteis))}


@app.post("/metas", status_code=201)
def salvar_meta(dados: schemas.MetaIn, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    """Define/atualiza a meta do mês. A meta diária e a semanal são derivadas."""
    mt = db.query(models.MetaMensal).filter(models.MetaMensal.ano == dados.ano,
                                            models.MetaMensal.mes == dados.mes).first()
    antes = {"meta_mensal": mt.meta_mensal, "dias_uteis": mt.dias_uteis} if mt else None
    if mt:
        mt.meta_mensal = dados.meta_mensal
        mt.dias_uteis = dados.dias_uteis
    else:
        mt = models.MetaMensal(ano=dados.ano, mes=dados.mes,
                               meta_mensal=dados.meta_mensal, dias_uteis=dados.dias_uteis)
        db.add(mt)
    db.commit()
    diaria = logica.meta_diaria(dados.meta_mensal, dados.dias_uteis)
    registrar_auditoria(db, u, "editar" if antes else "criar", "metas_mensais",
                        f"Definiu meta de {dados.mes:02d}/{dados.ano}: {dados.meta_mensal} un. "
                        f"em {dados.dias_uteis} dias úteis (diária {diaria})",
                        str(mt.id), antes, {"meta_mensal": dados.meta_mensal, "dias_uteis": dados.dias_uteis})
    return {"ok": True, "meta_diaria": diaria, "meta_semanal": logica.meta_semanal(diaria)}




# ---------------- TREINAMENTOS (cronograma anual + agenda) ----------------
@app.get("/treinamentos")
def listar_treinamentos(ano: int | None = None, db: Session = Depends(get_db),
                        _=Depends(usuario_atual)):
    ano = ano or date.today().year
    ts = db.query(models.Treinamento).filter(models.Treinamento.ano == ano,
                                             models.Treinamento.ativo == True)\
        .order_by(models.Treinamento.nome).all()
    return [{"id": str(t.id), "ano": t.ano, "nome": t.nome, "tipo": t.tipo,
             "objetivo": t.objetivo, "publico": t.publico, "responsavel": t.responsavel,
             "meses": t.meses or [], "feitos": t.feitos or []} for t in ts]


@app.post("/treinamentos", status_code=201)
def criar_treinamento(dados: schemas.TreinamentoIn, db: Session = Depends(get_db),
                      u=Depends(usuario_atual)):
    t = models.Treinamento(ano=dados.ano, nome=dados.nome, tipo=dados.tipo,
                           objetivo=dados.objetivo, publico=dados.publico,
                           responsavel=dados.responsavel, meses=dados.meses,
                           feitos=dados.feitos, criado_por=u.id)
    db.add(t); db.commit(); db.refresh(t)
    registrar_auditoria(db, u, "criar", "treinamentos",
                        f"Cadastrou treinamento: {t.nome} ({len(t.meses or [])} mês/meses)", str(t.id))
    return {"id": str(t.id), "nome": t.nome}


@app.patch("/treinamentos/{trein_id}")
def editar_treinamento(trein_id: str, dados: dict, db: Session = Depends(get_db),
                       u=Depends(usuario_atual)):
    t = db.query(models.Treinamento).filter(models.Treinamento.id == trein_id).first()
    if not t:
        raise HTTPException(404, "Treinamento não encontrado")
    antes = {"meses": t.meses, "feitos": t.feitos}
    for campo in ("nome", "tipo", "objetivo", "publico", "responsavel", "meses", "feitos"):
        if campo in dados:
            valor = dados[campo]
            if campo in ("meses", "feitos"):
                valor = sorted({int(x) for x in (valor or []) if 1 <= int(x) <= 12})
            setattr(t, campo, valor)
    db.commit()
    # descrição amigável quando marcaram como realizado
    novos = set(t.feitos or []) - set(antes["feitos"] or [])
    if novos:
        meses_txt = ", ".join(f"{m:02d}" for m in sorted(novos))
        desc = f"Marcou como realizado: {t.nome} (mês {meses_txt})"
    else:
        desc = f"Atualizou treinamento: {t.nome}"
    registrar_auditoria(db, u, "editar", "treinamentos", desc, str(t.id),
                        antes, {"meses": t.meses, "feitos": t.feitos})
    return {"ok": True}


@app.delete("/treinamentos/{trein_id}")
def excluir_treinamento(trein_id: str, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    t = db.query(models.Treinamento).filter(models.Treinamento.id == trein_id).first()
    if not t:
        raise HTTPException(404, "Treinamento não encontrado")
    t.ativo = False; db.commit()
    registrar_auditoria(db, u, "excluir", "treinamentos", f"Removeu treinamento: {t.nome}", str(t.id))
    return {"ok": True}


@app.get("/treinamentos/agenda")
def listar_agenda(inicio: date, fim: date, db: Session = Depends(get_db), _=Depends(usuario_atual)):
    ags = db.query(models.TreinamentoAgenda).filter(
        models.TreinamentoAgenda.data >= inicio,
        models.TreinamentoAgenda.data <= fim).order_by(models.TreinamentoAgenda.data).all()
    nomes = {str(t.id): t.nome for t in db.query(models.Treinamento).all()}
    tipos = {str(t.id): t.tipo for t in db.query(models.Treinamento).all()}
    return [{"id": str(a.id), "treinamento_id": str(a.treinamento_id) if a.treinamento_id else None,
             "nome": nomes.get(str(a.treinamento_id), "—"), "tipo": tipos.get(str(a.treinamento_id)),
             "data": a.data, "hora": a.hora, "instrutor": a.instrutor,
             "participantes": a.participantes, "realizado": a.realizado} for a in ags]


@app.post("/treinamentos/agenda", status_code=201)
def agendar_treinamento(dados: schemas.AgendaIn, db: Session = Depends(get_db),
                        u=Depends(usuario_atual)):
    a = models.TreinamentoAgenda(
        treinamento_id=dados.treinamento_id, data=dados.data, hora=dados.hora,
        instrutor=dados.instrutor, participantes=dados.participantes,
        observacao=dados.observacao, criado_por=u.id)
    db.add(a); db.commit(); db.refresh(a)
    t = db.query(models.Treinamento).filter(models.Treinamento.id == dados.treinamento_id).first()
    registrar_auditoria(db, u, "criar", "treinamentos_agenda",
                        f"Agendou '{t.nome if t else '—'}' para {dados.data}"
                        + (f" às {dados.hora}" if dados.hora else ""), str(a.id))
    return {"id": str(a.id)}


@app.delete("/treinamentos/agenda/{ag_id}")
def remover_agenda(ag_id: str, db: Session = Depends(get_db), u=Depends(usuario_atual)):
    a = db.query(models.TreinamentoAgenda).filter(models.TreinamentoAgenda.id == ag_id).first()
    if not a:
        raise HTTPException(404, "Agendamento não encontrado")
    db.delete(a); db.commit()
    registrar_auditoria(db, u, "excluir", "treinamentos_agenda",
                        f"Removeu agendamento de {a.data}", ag_id)
    return {"ok": True}


# ---------------- FRONTEND (servir o sistema) ----------------
# O backend serve o próprio frontend (single deployable).
from fastapi.staticfiles import StaticFiles
import os as _os
_FRONT = _os.path.join(_os.path.dirname(__file__), "..", "frontend")
if _os.path.isdir(_FRONT):
    app.mount("/", StaticFiles(directory=_FRONT, html=True), name="frontend")
