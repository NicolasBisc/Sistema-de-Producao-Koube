"""
Camada de proteção do Koube Produção.
- Rate limiting no login (anti-força-bruta)
- Bloqueio temporário após N tentativas falhas
- Política de força de senha
- Cabeçalhos HTTP de segurança
"""
import re
import time
from collections import defaultdict
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware

# ------------------------------------------------------------------
# Rate limiting + lockout (em memória; para 1 instância já protege bem.
# Se um dia rodar em vários workers, migrar este estado para Redis.)
# ------------------------------------------------------------------
_TENTATIVAS = defaultdict(list)      # chave -> [timestamps de falha]
_BLOQUEIO = {}                       # chave -> timestamp de fim do bloqueio

MAX_TENTATIVAS = 5                   # falhas antes de bloquear
JANELA_SEGUNDOS = 300                # 5 min: janela de contagem
BLOQUEIO_SEGUNDOS = 900              # 15 min de bloqueio


def _chave(request: Request, usuario: str) -> str:
    ip = request.client.host if request.client else "?"
    return f"{ip}:{usuario.upper()}"


def checar_bloqueio(request: Request, usuario: str):
    """Levanta 429 se a combinação IP+usuário estiver bloqueada."""
    chave = _chave(request, usuario)
    fim = _BLOQUEIO.get(chave)
    if fim and time.time() < fim:
        restante = int(fim - time.time())
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            f"Muitas tentativas. Tente novamente em {restante // 60 + 1} min.",
        )


def registrar_falha(request: Request, usuario: str):
    """Conta uma falha de login; bloqueia se passar do limite."""
    chave = _chave(request, usuario)
    agora = time.time()
    tent = [t for t in _TENTATIVAS[chave] if agora - t < JANELA_SEGUNDOS]
    tent.append(agora)
    _TENTATIVAS[chave] = tent
    if len(tent) >= MAX_TENTATIVAS:
        _BLOQUEIO[chave] = agora + BLOQUEIO_SEGUNDOS
        _TENTATIVAS[chave] = []


def limpar_tentativas(request: Request, usuario: str):
    """Zera o contador após um login bem-sucedido."""
    chave = _chave(request, usuario)
    _TENTATIVAS.pop(chave, None)
    _BLOQUEIO.pop(chave, None)


# ------------------------------------------------------------------
# Política de força de senha
# ------------------------------------------------------------------
def validar_forca_senha(senha: str) -> None:
    """Levanta 400 se a senha for fraca."""
    erros = []
    if len(senha) < 8:
        erros.append("mínimo de 8 caracteres")
    if not re.search(r"[A-Z]", senha):
        erros.append("uma letra maiúscula")
    if not re.search(r"[a-z]", senha):
        erros.append("uma letra minúscula")
    if not re.search(r"\d", senha):
        erros.append("um número")
    fracas = {"koube123", "12345678", "senha123", "password"}
    if senha.lower() in fracas:
        erros.append("não pode ser uma senha comum")
    if erros:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "Senha fraca. Requer: " + ", ".join(erros) + ".",
        )


# ------------------------------------------------------------------
# Cabeçalhos HTTP de segurança
# ------------------------------------------------------------------
class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        resp = await call_next(request)
        resp.headers["X-Content-Type-Options"] = "nosniff"
        resp.headers["X-Frame-Options"] = "DENY"
        resp.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        resp.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
        # HSTS: forçar HTTPS por 1 ano (só faz efeito atrás de HTTPS/Nginx)
        resp.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        return resp
