# Import planu do GitHub Projects

Ten katalog zawiera 68 zadań z [planu projektu](https://claude.ai/artifact/FLGsyStgUVFRUvYHAWbyZ4) przygotowanych jako issues dla boardu **learning_tracker**.

- `issues/<ID>.md` to treść issue. Każde ma opis, listę zadań, na które czeka, listę zadań, które odblokowuje, oraz checklistę „Zaliczone, gdy”.
- `import.sh` zakłada etykiety, sprinty jako milestones i issues, dodaje je do boardu i wstawia linki `#numer` między zależnymi zadaniami.

## Co powstanie

| Na GitHubie | Skąd |
|---|---|
| 68 issues z tytułem `S2-K2 · CRUD wpisów` | zadania z planu |
| Milestones `Sprint 1` … `Sprint 5` | sprinty (opis: co macie na koniec) |
| Etykiety `sprint-1…5`, `baza`, `backend`, `frontend`, `zespół`, `twist`, `rozmiar-S/M/L` | sprint, warstwa, rozmiar |
| Assignee | osoba z planu (gdy wpiszecie jej login w skrypcie) |
| Karty w kolumnie **Todo** na boardzie | wszystkie issues |

Issues są zakładane w kolejności wykonania: sprint, potem kolejność w sprincie. Dzięki temu na boardzie leżą mniej więcej w tej kolejności, w jakiej trzeba je brać.

## Uruchomienie

Najlepiej uruchamia Natalia, bo repo i board są na jej koncie.

1. Zainstaluj i zaloguj GitHub CLI, z dostępem do Projects:

   ```bash
   brew install gh
   ```

   ```bash
   gh auth login
   ```

   ```bash
   gh auth refresh -s project
   ```

2. W `import.sh` uzupełnij loginy GitHub: `LOGIN_M`, `LOGIN_K`, `LOGIN_T`, `LOGIN_E`. Pusty login oznacza issue bez przypisanej osoby.

3. Podgląd, który niczego nie tworzy:

   ```bash
   bash docs/github-projects/import.sh --dry-run
   ```

4. Prawdziwy import (trwa około 4 minut):

   ```bash
   bash docs/github-projects/import.sh
   ```

Skrypt można uruchomić ponownie, na przykład po przerwaniu. Zadania, które już mają issue, są wyszukiwane po identyfikatorze w tytule i pomijane.

## Ustawienia boardu po imporcie

- **Widok sprintów:** View → Group by → Milestone.
- **Widok osoby:** New view, w filtrze wpisz `assignee:<login>`.
- **Jeden sprint:** w filtrze wpisz `milestone:"Sprint 1"`.
- **Automatyczne przenoszenie:** Workflows → włącz „Item closed” → Done i „Pull request merged” → Done. W opisie PR wpisz `Closes #numer`, a karta sama przejdzie do Done.

## Issue #2 „Model bazy danych Neon”

To issue już jest na boardzie. Pokrywa się z zadaniami **S1-N3** (projekt schematu) i **S2-N1** (modele i migracja). Po imporcie zamknijcie #2 z komentarzem, że zastępują je te dwa zadania, albo usuńcie je z boardu.
