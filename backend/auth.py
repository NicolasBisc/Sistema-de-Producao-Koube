"""Autenticação (dependências FastAPI) e registro de auditoria."""
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from database import get_db
from security import decodificar_token
import models

oauth2 = OAuth2PasswordBearer(tokenUrl="/auth/login")


def usuario_atual(token: str = Depends(oauth2), db: Session = Depends(get_db)) -> models.Usuario:
    payload = decodificar_token(token)
    if not payload:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token inválido ou expirado")
    usuario = db.query(models.Usuario).filter(models.Usuario.id == payload["sub"]).first()
    if not usuario or not usuario.ativo:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Usuário inativo")
    return usuario


def somente_admin(usuario: models.Usuario = Depends(usuario_atual)) -> models.Usuario:
    if usuario.nivel != "admin":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Ação restrita a administradores")
    return usuario


def acesso_supervisao(usuario: models.Usuario = Depends(usuario_atual)) -> models.Usuario:
    """Colaboradores, férias e linhas: só gestão (admin ou acesso_supervisao)."""
    if usuario.nivel != "admin" and not usuario.acesso_supervisao:
        raise HTTPException(status.HTTP_403_FORBIDDEN,
                            "Ação restrita à gestão de produção")
    return usuario


def registrar_auditoria(db: Session, usuario: models.Usuario, acao: str,
                        entidade: str, descricao: str,
                        entidade_id: str = None, valor_antigo=None, valor_novo=None):
    """Grava uma entrada no log de auditoria."""
    log = models.Auditoria(
        usuario_id=usuario.id if usuario else None,
        usuario_nome=usuario.nome if usuario else "sistema",
        acao=acao, entidade=entidade, entidade_id=entidade_id,
        descricao=descricao, valor_antigo=valor_antigo, valor_novo=valor_novo,
    )
    db.add(log)
    db.commit()
