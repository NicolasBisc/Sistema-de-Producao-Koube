"""Regras de negócio que o sistema calcula sozinho."""
from datetime import date, timedelta

DIAS_AVISO_ANTECEDENCIA = 5  # avisar quando faltar 5 dias ou menos


def calcular_proxima_acao(ultima_acao: date, periodicidade_dias: int) -> date:
    """Próxima ação = última ação + periodicidade (em dias)."""
    return ultima_acao + timedelta(days=periodicidade_dias)


def status_preventiva(ultima_acao: date | None, periodicidade_dias: int,
                      hoje: date | None = None) -> dict:
    """Retorna próxima ação, status e dias restantes/atrasados.

    Estados:
      - 'Sem histórico' : nunca foi executada
      - 'Em dia'        : falta mais que DIAS_AVISO_ANTECEDENCIA
      - 'Vence em breve': faltam DIAS_AVISO_ANTECEDENCIA dias ou menos (>=0)
      - 'Atrasado'      : já passou do prazo (acumula dias)
    """
    hoje = hoje or date.today()
    if ultima_acao is None:
        return {"proxima_acao": None, "status": "Sem histórico",
                "dias_restantes": None, "dias_atraso": None, "aviso": None}

    proxima = calcular_proxima_acao(ultima_acao, periodicidade_dias)
    delta = (proxima - hoje).days  # >0 falta; <0 atrasado; 0 vence hoje

    if delta < 0:
        return {"proxima_acao": proxima, "status": "Atrasado",
                "dias_restantes": 0, "dias_atraso": abs(delta),
                "aviso": f"Atrasada há {abs(delta)} dia(s)"}
    elif delta <= DIAS_AVISO_ANTECEDENCIA:
        txt = "Vence hoje" if delta == 0 else f"Vence em {delta} dia(s)"
        return {"proxima_acao": proxima, "status": "Vence em breve",
                "dias_restantes": delta, "dias_atraso": 0, "aviso": txt}
    else:
        return {"proxima_acao": proxima, "status": "Em dia",
                "dias_restantes": delta, "dias_atraso": 0, "aviso": None}


def meta_diaria(meta_mensal: int, dias_uteis: int) -> int:
    """Meta diária derivada da meta mensal e dos dias úteis."""
    if not dias_uteis:
        return 0
    return round(meta_mensal / dias_uteis)


def meta_semanal(meta_diaria_valor: int, dias_uteis_semana: int = 5) -> int:
    """Meta semanal = meta diária x dias úteis da semana."""
    return meta_diaria_valor * dias_uteis_semana


def resumo_producao(itens: list[dict]) -> dict:
    """Consolida programado x realizado. Alimenta o dashboard."""
    programado = sum(i.get("qtd_programada") or 0 for i in itens)
    realizado = sum(i.get("qtd_realizada") or 0 for i in itens)
    diferenca = realizado - programado
    pct = round((realizado / programado) * 100, 1) if programado else 0.0
    return {"programado": programado, "realizado": realizado,
            "diferenca": diferenca, "pct_atingido": pct}


def resumo_manutencao(preventivas_calc: list[dict], ordens: list[dict]) -> dict:
    """Dashboard interno da manutenção: contagens por estado e por tipo."""
    em_dia = sum(1 for p in preventivas_calc if p["status"] == "Em dia")
    vence_breve = sum(1 for p in preventivas_calc if p["status"] == "Vence em breve")
    atrasadas = sum(1 for p in preventivas_calc if p["status"] == "Atrasado")
    corretivas = sum(1 for o in ordens if (o.get("tipo") or "").lower() == "corretiva")
    preditivas = sum(1 for o in ordens if (o.get("tipo") or "").lower() in ("preventiva", "preditiva"))
    return {
        "preventivas_em_dia": em_dia,
        "preventivas_vence_breve": vence_breve,
        "preventivas_atrasadas": atrasadas,
        "total_preventivas": len(preventivas_calc),
        "os_corretivas": corretivas,
        "os_preditivas": preditivas,
        "total_os": len(ordens),
    }


# ============================================================
#  FÉRIAS (regra CLT — período aquisitivo de 12 meses)
#  Ajustável quando a planilha de RH chegar.
# ============================================================
DIAS_AVISO_FERIAS = 60  # avisar quando faltar <= 60 dias para vencer o concessivo


def _add_meses(d: date, meses: int) -> date:
    m = d.month - 1 + meses
    ano = d.year + m // 12
    mes = m % 12 + 1
    import calendar
    dia = min(d.day, calendar.monthrange(ano, mes)[1])
    return date(ano, mes, dia)


def status_ferias(data_admissao: date,
                  ultimo_retorno: date | None = None,
                  hoje: date | None = None,
                  meses_aquisitivo: int = 12,
                  dias_direito: int = 30,
                  meses_concessivo: int = 12,
                  dias_aviso: int = DIAS_AVISO_FERIAS,
                  de_ferias_desde: date | None = None) -> dict:
    """Situação de férias de um colaborador — tudo configurável.

    A contagem parte do ÚLTIMO RETORNO de férias; se nunca tirou, da admissão.

    Estados:
      - 'De férias'       : está de férias agora (informado de_ferias_desde)
      - 'Aguardando'      : ainda não completou o período aquisitivo
      - 'Tem direito'     : pode tirar
      - 'Conceder logo'   : dentro do prazo, perto de vencer
      - 'Férias vencidas' : passou do prazo de concessão
    """
    hoje = hoje or date.today()

    if de_ferias_desde:
        dias_fora = (hoje - de_ferias_desde).days
        return {"status": "De férias", "tem_direito": False,
                "base": de_ferias_desde, "dias_direito": dias_direito,
                "proximo_direito": None, "vence_em": None,
                "meses_casa": (hoje.year - data_admissao.year) * 12 + (hoje.month - data_admissao.month),
                "aviso": f"De férias há {dias_fora} dia(s)"}

    base = ultimo_retorno or data_admissao
    aquisitivo_fim = _add_meses(base, meses_aquisitivo)
    concessivo_fim = _add_meses(aquisitivo_fim, meses_concessivo)
    meses_casa = (hoje.year - data_admissao.year) * 12 + (hoje.month - data_admissao.month)

    comum = {"base": base, "dias_direito": dias_direito,
             "proximo_direito": aquisitivo_fim, "vence_em": concessivo_fim,
             "meses_casa": meses_casa}

    if hoje < aquisitivo_fim:
        faltam = (aquisitivo_fim - hoje).days
        return {**comum, "status": "Aguardando", "tem_direito": False,
                "dias_para_direito": faltam,
                "aviso": f"Adquire direito em {faltam} dia(s)"}

    if hoje > concessivo_fim:
        atraso = (hoje - concessivo_fim).days
        return {**comum, "status": "Férias vencidas", "tem_direito": True,
                "dias_vencida": atraso,
                "aviso": f"VENCIDA há {atraso} dia(s) — conceder com urgência"}

    dias_para_vencer = (concessivo_fim - hoje).days
    if dias_para_vencer <= dias_aviso:
        return {**comum, "status": "Conceder logo", "tem_direito": True,
                "dias_para_vencer": dias_para_vencer,
                "aviso": f"Vence em {dias_para_vencer} dia(s) — programar {dias_direito} dias"}

    return {**comum, "status": "Tem direito", "tem_direito": True,
            "dias_para_vencer": dias_para_vencer,
            "aviso": f"Pode tirar {dias_direito} dias"}


# ============================================================
#  PERÍODO DE EXPERIÊNCIA (30 / 60 / 90 dias)
#  Marcos a partir da admissão. Passar do 90º dia sem decisão
#  significa efetivação automática — por isso o alerta.
# ============================================================
DIAS_AVISO_EXPERIENCIA = 7   # avisar quando faltar <= 7 dias para um marco


def status_experiencia(data_admissao: date, hoje: date | None = None) -> dict:
    """Situação do período de experiência.

    Estados:
      - 'Efetivado'        : passou dos 90 dias
      - 'Marco vencendo'   : faltam <= 7 dias para 30/60/90
      - 'Em experiência'   : dentro do período, sem marco próximo
    """
    hoje = hoje or date.today()
    dias = (hoje - data_admissao).days
    marcos = {30: data_admissao + timedelta(days=30),
              60: data_admissao + timedelta(days=60),
              90: data_admissao + timedelta(days=90)}

    if dias > 90:
        return {"status": "Efetivado", "dias_casa": dias, "em_experiencia": False,
                "proximo_marco": None, "dias_para_marco": None, "aviso": None,
                "marcos": marcos}

    # próximo marco ainda não alcançado
    proximo, data_prox = None, None
    for m in (30, 60, 90):
        if dias <= m:
            proximo, data_prox = m, marcos[m]
            break
    faltam = (data_prox - hoje).days
    if faltam <= DIAS_AVISO_EXPERIENCIA:
        txt = ("vence hoje" if faltam == 0 else
               (f"vencido há {abs(faltam)} dia(s)" if faltam < 0 else f"em {faltam} dia(s)"))
        return {"status": "Marco vencendo", "dias_casa": dias, "em_experiencia": True,
                "proximo_marco": proximo, "dias_para_marco": faltam,
                "aviso": f"Avaliação de {proximo} dias {txt}", "marcos": marcos}
    return {"status": "Em experiência", "dias_casa": dias, "em_experiencia": True,
            "proximo_marco": proximo, "dias_para_marco": faltam,
            "aviso": f"{proximo} dias em {faltam} dia(s)", "marcos": marcos}
