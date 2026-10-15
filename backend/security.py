"""Segurança: hash de senha (bcrypt) e tokens JWT."""
from datetime import datetime, timedelta, timezone
import bcrypt
from jose import jwt, JWTError
from config import settings


def hash_senha(senha: str) -> str:
    return bcrypt.hashpw(senha.encode("utf-8")[:72], bcrypt.gensalt()).decode("utf-8")


def verificar_senha(senha: str, senha_hash: str) -> bool:
    try:
        return bcrypt.checkpw(senha.encode("utf-8")[:72], senha_hash.encode("utf-8"))
    except ValueError:
        return False


def criar_token(usuario_id: str, nivel: str) -> str:
    expira = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    payload = {"sub": str(usuario_id), "nivel": nivel, "exp": expira}
    return jwt.encode(payload, settings.secret_key, algorithm="HS256")


def decodificar_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.secret_key, algorithms=["HS256"])
    except JWTError:
        return None
