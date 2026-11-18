import os

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

DEFAULT_JWT_SECRET = "dev-secret-change-me-local-development-only"


class Settings(BaseSettings):
    """Read from env vars (and backend/.env locally). Defaults are for local development."""

    model_config = SettingsConfigDict(
        env_file=".env", env_ignore_empty=True, extra="ignore"
    )

    database_url: str = "sqlite:///./dev.db"
    jwt_secret: str = DEFAULT_JWT_SECRET
    # Comma-separated. Production should allow only the GitHub Pages origin.
    cors_origins: str = "http://localhost:5173,https://nataliakrawczyk03.github.io"

    @property
    def cors_origins_list(self) -> list[str]:
        return [
            origin.strip() for origin in self.cors_origins.split(",") if origin.strip()
        ]

    @property
    def sqlalchemy_url(self) -> str:
        # Neon gives postgres:// or postgresql://, but we use the psycopg 3 driver.
        url = self.database_url
        for prefix in ("postgres://", "postgresql://"):
            if url.startswith(prefix):
                return "postgresql+psycopg://" + url.removeprefix(prefix)
        return url

    @model_validator(mode="after")
    def _no_default_secret_on_vercel(self) -> "Settings":
        if os.getenv("VERCEL") and self.jwt_secret == DEFAULT_JWT_SECRET:
            raise ValueError("JWT_SECRET must be set on Vercel (not the default).")
        return self


settings = Settings()
