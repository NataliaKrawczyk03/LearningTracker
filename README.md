# LearningTracker

Backend: Python (FastAPI, zarządzany przez uv) w `backend/`. Frontend: JavaScript (Vite) w `frontend/`.

## Uruchomienie lokalne

Backend (wymaga zainstalowanego [uv](https://docs.astral.sh/uv/)):

```
cd backend
uv sync
uv run uvicorn main:app --reload
```

Frontend:

```
cd frontend
npm install
npm run dev
```

## Testy i lint

```
cd backend && uv run pytest && uv run ruff check .
cd frontend && npm run lint && npm test
```
