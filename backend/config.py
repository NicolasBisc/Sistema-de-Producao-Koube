"""Configuração central — lê variáveis de ambiente (arquivo .env)."""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Banco: mesmo Postgres da VM, database separado koube_producao
    database_url: str = "postgresql://koube:senha@localhost:5432/koube_producao"

    # JWT
    secret_key: str = "troque-esta-chave-em-producao"
    access_token_expire_minutes: int = 60 * 8  # 8h de jornada

    # CORS (frontend do Produção)
    cors_origins: str = "http://localhost:5500,https://producao.koube.com.br"


settings = Settings()
