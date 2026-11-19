# Contributing Guide
 
## Nazwy gałęzi
 
Format: `<typ>/<ID-zadania>-<krotki-opis>`
 
- `feature/PROJ-123-logowanie-uzytkownika`
- `fix/PROJ-456-blad-walidacji-formularza`
- `chore/PROJ-789-aktualizacja-zaleznosci`
Typy: `feature`, `fix`, `chore`, `docs`, `refactor`, `test`.
Opis pisz małymi literami, bez polskich znaków, słowa łącz myślnikami.
 
## Pull Request
 
- Tytuł PR musi zaczynać się od identyfikatora zadania, np. `PROJ-123: Dodaj logowanie użytkownika`.
- Uzupełnij szablon PR (zadanie, co zmienia, jak sprawdzić, checklista „Zaliczone, gdy”).
- PR powinien być mały i dotyczyć jednego zadania.
## Review i merge
 
- Wymagany jest **minimum 1 review od innej osoby** niż autor PR.
- Wszystkie uwagi muszą być rozwiązane, a testy i lint przechodzą w CI.
- PR scalamy wyłącznie przez **squash merge**. Tytuł commita po squashu = tytuł PR (z ID zadania).
- Po scaleniu usuń gałąź.
## Uruchamianie testów i lintu
 
### Backend (Python)
 
```bash
# instalacja zależności (w tym grupy dev: pytest, httpx, ruff)
uv sync
 
# testy
uv run pytest
 
# lint i formatowanie (ruff, konfiguracja w pyproject.toml)
uv run ruff check .              # lint
uv run ruff check . --fix        # lint z automatycznymi poprawkami
uv run ruff format .             # formatowanie
uv run ruff format . --check     # sprawdzenie formatowania bez zmian (jak w CI)
```
 
Konfiguracja ruff: długość linii 100, reguły `E`, `F`, `I`, `UP`, `B`.
 
### Frontend
 
```bash
cd frontend
npm ci
 
# testy
npm test
 
# lint
npm run lint
```
 
> Uwaga: ścieżki i nazwy skryptów dostosuj do faktycznej struktury repozytorium.
 
## Przed otwarciem PR
 
1. `uv run ruff check . && uv run ruff format . --check`
2. `uv run pytest`
3. `cd frontend && npm run lint && npm test`
