from app.config import DEFAULT_JWT_SECRET, Settings


def test_defaults_work_without_env(monkeypatch):
    for name in ("DATABASE_URL", "JWT_SECRET", "CORS_ORIGINS"):
        monkeypatch.delenv(name, raising=False)

    settings = Settings(_env_file=None)

    assert settings.database_url
    assert settings.jwt_secret
    assert settings.cors_origins_list == [
        "http://localhost:5173",
        "https://nataliakrawczyk03.github.io",
    ]


def test_reads_env_and_splits_cors_origins(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", "s3cret")
    monkeypatch.setenv(
        "CORS_ORIGINS", "http://localhost:5173, https://nataliakrawczyk03.github.io"
    )

    settings = Settings(_env_file=None)

    assert settings.jwt_secret == "s3cret"
    assert settings.cors_origins_list == [
        "http://localhost:5173",
        "https://nataliakrawczyk03.github.io",
    ]


def test_empty_env_values_fall_back_to_defaults(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", "")

    settings = Settings(_env_file=None)

    assert settings.jwt_secret == DEFAULT_JWT_SECRET
