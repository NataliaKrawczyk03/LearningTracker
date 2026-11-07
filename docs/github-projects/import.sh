#!/usr/bin/env bash
# Zakłada 68 zadań planu LearningTracker jako issues i dodaje je do boardu GitHub Projects.
#
# Uruchomienie (najlepiej przez Natalię, bo repo i board są na jej koncie):
#   brew install gh
#   gh auth login
#   gh auth refresh -s project        # dostęp do GitHub Projects
#   bash docs/github-projects/import.sh --dry-run   # najpierw podgląd, nic nie tworzy
#   bash docs/github-projects/import.sh
#
# Skrypt można uruchomić drugi raz: zadania, które już mają issue (szuka po ID w tytule), pomija.
set -euo pipefail

# ---------- KONFIGURACJA: uzupełnijcie loginy GitHub ----------
REPO="NataliaKrawczyk03/LearningTracker"
OWNER="NataliaKrawczyk03"
PROJECT_TITLE="learning_tracker"
LOGIN_N="NataliaKrawczyk03"   # Natalia
LOGIN_M=""                    # Martyna, np. martynacios
LOGIN_K=""                    # Kuba
LOGIN_T=""                    # Tomek
LOGIN_E=""                    # Eryk
# Pusty login = issue bez osoby przypisanej (można przypisać potem na boardzie).
# --------------------------------------------------------------

DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1
DIR="$(cd "$(dirname "$0")" && pwd)"
MAP="$(mktemp)"
trap 'rm -f "$MAP" "$MAP".*' EXIT

run() { if [[ $DRY == 1 ]]; then printf '[dry-run] %s\n' "$*" >&2; else "$@"; fi; }

login_for() {
  case "$1" in
    N) echo "$LOGIN_N" ;; M) echo "$LOGIN_M" ;; K) echo "$LOGIN_K" ;;
    T) echo "$LOGIN_T" ;; E) echo "$LOGIN_E" ;; *) echo "" ;;
  esac
}

if [[ $DRY == 0 ]]; then
  command -v gh >/dev/null || { echo "Brak gh. Zainstaluj: brew install gh"; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "Zaloguj się: gh auth login"; exit 1; }
  PROJECT_NUMBER="$(gh project list --owner "$OWNER" --format json --jq ".projects[] | select(.title==\"$PROJECT_TITLE\") | .number")"
  [[ -n "$PROJECT_NUMBER" ]] || { echo "Nie znalazłem boardu \"$PROJECT_TITLE\". Uruchom: gh auth refresh -s project"; exit 1; }
  echo "Board: $PROJECT_TITLE (nr $PROJECT_NUMBER)"
else
  PROJECT_NUMBER="<nr>"
fi

echo "== Etykiety"
lbl() { run gh label create "$1" -R "$REPO" --color "$2" --description "$3" --force >/dev/null; }
lbl sprint-1 0E8A16 "Sprint 1: Start"
lbl sprint-2 1D76DB "Sprint 2: CI i dane"
lbl sprint-3 5319E7 "Sprint 3: CD i integracja"
lbl sprint-4 D93F0B "Sprint 4: Funkcje i twist"
lbl sprint-5 B60205 "Sprint 5: Demo i obrona"
lbl baza B4760C "Baza danych (Natalia)"
lbl backend 2D7A57 "Backend Python (Martyna, Kuba)"
lbl frontend 2F63B0 "Frontend TypeScript (Tomek, Eryk)"
lbl "zespół" 16211B "Zadanie całego zespołu"
lbl twist F2D43A "Część twistu, do doprecyzowania po losowaniu"
lbl rozmiar-S C2E0C6 "2–3 h"
lbl rozmiar-M FEF2C0 "4–6 h"
lbl rozmiar-L F9D0C4 "8–12 h"

echo "== Kamienie milowe (sprinty)"
ms() {
  if [[ $DRY == 1 ]]; then echo "[dry-run] milestone $1"; return; fi
  if ! gh api "repos/$REPO/milestones?state=all&per_page=100" --jq '.[].title' | grep -qx "$1"; then
    gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null
  fi
}
ms "Sprint 1" "Na koniec: hello world na produkcji, oba adresy działają"
ms "Sprint 2" "Na koniec: zielony check wymagany do merge"
ms "Sprint 3" "Na koniec: merge do main = nowa wersja online"
ms "Sprint 4" "Na koniec: demo postępów, 5 minut na zespół"
ms "Sprint 5" "Na koniec: prezentacja, zmiana na żywo, ocena końcowa"

echo "== Issues (krok 1/2: zakładanie)"
create_task() {
  local id="$1" title="$2" labels="$3" milestone="$4" who="$5"
  local body="$DIR/issues/$id.md" url="" login
  login="$(login_for "$who")"
  if [[ $DRY == 0 ]]; then
    url="$(gh issue list -R "$REPO" --state all --search "\"$id\" in:title" --json url,title \
      --jq "map(select(.title | startswith(\"$id \"))) | .[0].url // empty")"
  fi
  if [[ -n "$url" ]]; then
    echo "  $id już istnieje: $url"
  else
    # w pierwszym przebiegu znaczniki {{ID}} znikają, bo numery issues jeszcze nie istnieją
    sed -E 's/\{\{[A-Z0-9-]+\}\} //g' "$body" > "$MAP.body"
    local args=(gh issue create -R "$REPO" --title "$title" --body-file "$MAP.body" --label "$labels" --milestone "$milestone")
    [[ -n "$login" ]] && args+=(--assignee "$login")
    if [[ $DRY == 1 ]]; then
      run "${args[@]}"; url="https://github.com/$REPO/issues/0"
    else
      url="$("${args[@]}")"
      echo "  $id → $url"
      sleep 1
    fi
  fi
  echo "$id ${url##*/} $url" >> "$MAP"
}

create_task "S1-N1" "S1-N1 · Ochrona main i dostęp do repozytorium" "sprint-1,baza,rozmiar-S" "Sprint 1" "N"
create_task "S1-N3" "S1-N3 · Projekt schematu bazy w docs/database.md" "sprint-1,baza,rozmiar-M" "Sprint 1" "N"
create_task "S1-M1" "S1-M1 · Struktura backendu i konfiguracja" "sprint-1,backend,rozmiar-M" "Sprint 1" "M"
create_task "S1-K2" "S1-K2 · Ruff, CONTRIBUTING i szablon PR" "sprint-1,backend,rozmiar-S" "Sprint 1" "K"
create_task "S1-T1" "S1-T1 · Przejście frontendu na TypeScript" "sprint-1,frontend,rozmiar-M" "Sprint 1" "T"
create_task "S1-N2" "S1-N2 · Konto Vercel i baza Neon" "sprint-1,baza,rozmiar-M" "Sprint 1" "N"
create_task "S1-K1" "S1-K1 · Kontrakt API v1 w docs/api.md" "sprint-1,backend,rozmiar-M" "Sprint 1" "K"
create_task "S1-E1" "S1-E1 · Style i układ aplikacji z makiety" "sprint-1,frontend,rozmiar-M" "Sprint 1" "E"
create_task "S1-E2" "S1-E2 · Funkcje dat i pierwsze testy frontendu" "sprint-1,frontend,rozmiar-S" "Sprint 1" "E"
create_task "S1-M2" "S1-M2 · Backend na Vercel i CORS" "sprint-1,backend,rozmiar-S" "Sprint 1" "M"
create_task "S1-T2" "S1-T2 · Frontend na GitHub Pages" "sprint-1,frontend,rozmiar-S" "Sprint 1" "T"
create_task "S2-N1" "S2-N1 · Modele i pierwsza migracja" "sprint-2,baza,rozmiar-L" "Sprint 2" "N"
create_task "S2-K1" "S2-K1 · Job backend w ci.yml" "sprint-2,backend,rozmiar-S" "Sprint 2" "K"
create_task "S2-T1" "S2-T1 · Job frontend w ci.yml" "sprint-2,frontend,rozmiar-S" "Sprint 2" "T"
create_task "S2-T2" "S2-T2 · Router i strażnik logowania" "sprint-2,frontend,rozmiar-M" "Sprint 2" "T"
create_task "S2-T3" "S2-T3 · Klient API i typy" "sprint-2,frontend,rozmiar-M" "Sprint 2" "T"
create_task "S2-E1" "S2-E1 · Komponenty interfejsu" "sprint-2,frontend,rozmiar-M" "Sprint 2" "E"
create_task "S2-N2" "S2-N2 · Sesja bazy i fixture do testów" "sprint-2,baza,rozmiar-M" "Sprint 2" "N"
create_task "S2-N3" "S2-N3 · Zielony check wymagany do merge" "sprint-2,baza,rozmiar-S" "Sprint 2" "N"
create_task "S2-E2" "S2-E2 · Pulpit na danych testowych" "sprint-2,frontend,rozmiar-M" "Sprint 2" "E"
create_task "S2-E3" "S2-E3 · Siatka kalendarza" "sprint-2,frontend,rozmiar-M" "Sprint 2" "E"
create_task "S2-M1" "S2-M1 · Rejestracja, logowanie i /me" "sprint-2,backend,rozmiar-L" "Sprint 2" "M"
create_task "S2-K3" "S2-K3 · /health ze sprawdzeniem bazy" "sprint-2,backend,rozmiar-S" "Sprint 2" "K"
create_task "S2-M2" "S2-M2 · CRUD celów" "sprint-2,backend,rozmiar-L" "Sprint 2" "M"
create_task "S2-K2" "S2-K2 · CRUD wpisów" "sprint-2,backend,rozmiar-L" "Sprint 2" "K"
create_task "S3-N1" "S3-N1 · Zapytania statystyk" "sprint-3,baza,rozmiar-L" "Sprint 3" "N"
create_task "S3-N2" "S3-N2 · Sekrety, zmienne i migracje przy deployu" "sprint-3,baza,rozmiar-M" "Sprint 3" "N"
create_task "S3-N3" "S3-N3 · Dane demo" "sprint-3,baza,rozmiar-M" "Sprint 3" "N"
create_task "S3-M3" "S3-M3 · CORS na produkcji" "sprint-3,backend,rozmiar-S" "Sprint 3" "M"
create_task "S3-K3" "S3-K3 · Testy backendu także na Postgresie w CI" "sprint-3,backend,rozmiar-M" "Sprint 3" "K"
create_task "S3-T1" "S3-T1 · Ekrany logowania i rejestracji" "sprint-3,frontend,rozmiar-M" "Sprint 3" "T"
create_task "S3-T2" "S3-T2 · Ekran Cele" "sprint-3,frontend,rozmiar-L" "Sprint 3" "T"
create_task "S3-T3" "S3-T3 · Ekran Nowy wpis" "sprint-3,frontend,rozmiar-M" "Sprint 3" "T"
create_task "S3-E2" "S3-E2 · Kalendarz na prawdziwym API" "sprint-3,frontend,rozmiar-L" "Sprint 3" "E"
create_task "S3-M1" "S3-M1 · deploy-backend.yml ze smoke testem" "sprint-3,backend,rozmiar-L" "Sprint 3" "M"
create_task "S3-K1" "S3-K1 · Endpointy statystyk" "sprint-3,backend,rozmiar-M" "Sprint 3" "K"
create_task "S3-T4" "S3-T4 · deploy-frontend.yml w wersji docelowej" "sprint-3,frontend,rozmiar-S" "Sprint 3" "T"
create_task "S3-M2" "S3-M2 · Testy izolacji użytkowników" "sprint-3,backend,rozmiar-M" "Sprint 3" "M"
create_task "S3-K2" "S3-K2 · OpenAPI i generowanie typów TypeScript" "sprint-3,backend,rozmiar-S" "Sprint 3" "K"
create_task "S3-E1" "S3-E1 · Pulpit na prawdziwym API" "sprint-3,frontend,rozmiar-M" "Sprint 3" "E"
create_task "S4-N2" "S4-N2 · Dependabot i badge w README" "sprint-4,baza,rozmiar-S" "Sprint 4" "N"
create_task "S4-N3" "S4-N3 · Kopia bazy i odtwarzanie" "sprint-4,baza,rozmiar-S" "Sprint 4" "N"
create_task "S4-M2" "S4-M2 · Smoke test z logowaniem" "sprint-4,backend,rozmiar-S" "Sprint 4" "M"
create_task "S4-M3" "S4-M3 · Przegląd bezpieczeństwa" "sprint-4,backend,rozmiar-S" "Sprint 4" "M"
create_task "S4-K2" "S4-K2 · Cache i matrix dwóch wersji Pythona" "sprint-4,backend,rozmiar-S" "Sprint 4" "K"
create_task "S4-K3" "S4-K3 · Testy brzegowe i strefa czasu" "sprint-4,backend,rozmiar-M" "Sprint 4" "K"
create_task "S4-T2" "S4-T2 · Stany ładowania, błędów i pustki" "sprint-4,frontend,rozmiar-M" "Sprint 4" "T"
create_task "S4-T3" "S4-T3 · Testy widoków" "sprint-4,frontend,rozmiar-S" "Sprint 4" "T"
create_task "S4-E1" "S4-E1 · Ekran Tydzień z wykresem" "sprint-4,frontend,rozmiar-L" "Sprint 4" "E"
create_task "S4-A1" "S4-A1 · Rozpisanie twistu na zadania" "sprint-4,zespół,rozmiar-S,twist" "Sprint 4" "A"
create_task "S4-N1" "S4-N1 · Twist: zmiany w bazie" "sprint-4,baza,rozmiar-M,twist" "Sprint 4" "N"
create_task "S4-E2" "S4-E2 · Wersja na telefon i ciemny motyw" "sprint-4,frontend,rozmiar-M" "Sprint 4" "E"
create_task "S4-M1" "S4-M1 · Twist: backend, część 1" "sprint-4,backend,rozmiar-M,twist" "Sprint 4" "M"
create_task "S4-K1" "S4-K1 · Twist: backend, część 2" "sprint-4,backend,rozmiar-M,twist" "Sprint 4" "K"
create_task "S4-T1" "S4-T1 · Twist: frontend, część 1" "sprint-4,frontend,rozmiar-M,twist" "Sprint 4" "T"
create_task "S4-E3" "S4-E3 · Twist: frontend, część 2" "sprint-4,frontend,rozmiar-M,twist" "Sprint 4" "E"
create_task "S4-A2" "S4-A2 · Demo postępów w 5 minut" "sprint-4,zespół,rozmiar-S" "Sprint 4" "A"
create_task "S5-N1" "S5-N1 · README" "sprint-5,baza,rozmiar-M" "Sprint 5" "N"
create_task "S5-N2" "S5-N2 · Trening zmiany na żywo: frontend" "sprint-5,baza,rozmiar-S" "Sprint 5" "N"
create_task "S5-M1" "S5-M1 · AI.md" "sprint-5,backend,rozmiar-S" "Sprint 5" "M"
create_task "S5-M2" "S5-M2 · Trening zmiany na żywo: frontend" "sprint-5,backend,rozmiar-S" "Sprint 5" "M"
create_task "S5-K1" "S5-K1 · Testy akceptacyjne na produkcji" "sprint-5,backend,rozmiar-M" "Sprint 5" "K"
create_task "S5-K2" "S5-K2 · Trening zmiany na żywo: frontend" "sprint-5,backend,rozmiar-S" "Sprint 5" "K"
create_task "S5-T1" "S5-T1 · Zgodność z makietą" "sprint-5,frontend,rozmiar-M" "Sprint 5" "T"
create_task "S5-T2" "S5-T2 · Trening zmiany na żywo: backend" "sprint-5,frontend,rozmiar-S" "Sprint 5" "T"
create_task "S5-E1" "S5-E1 · Dostępność i dopracowanie" "sprint-5,frontend,rozmiar-M" "Sprint 5" "E"
create_task "S5-E2" "S5-E2 · Trening zmiany na żywo: backend" "sprint-5,frontend,rozmiar-S" "Sprint 5" "E"
create_task "S5-A1" "S5-A1 · Prezentacja i próba obrony" "sprint-5,zespół,rozmiar-M" "Sprint 5" "A"

echo "== Dodawanie do boardu"
while read -r id num url; do
  if [[ $DRY == 1 ]]; then echo "[dry-run] gh project item-add $PROJECT_NUMBER --owner $OWNER --url $url"; continue; fi
  gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$url" >/dev/null 2>&1 \
    && echo "  $id na boardzie" || echo "  $id: już był na boardzie albo błąd dodawania"
  sleep 0.5
done < "$MAP"

echo "== Issues (krok 2/2: linki do zależności)"
# zamienia {{S1-N3}} na #numer, więc w issue widać stan zadań, na które czeka
: > "$MAP.sed"
while read -r id num url; do echo "s/\\{\\{$id\\}\\}/#$num/g" >> "$MAP.sed"; done < "$MAP"
while read -r id num url; do
  sed -E -f "$MAP.sed" "$DIR/issues/$id.md" > "$MAP.body"
  run gh issue edit "$num" -R "$REPO" --body-file "$MAP.body" >/dev/null
  [[ $DRY == 0 ]] && { echo "  $id zaktualizowane"; sleep 1; }
done < "$MAP"

echo
echo "Gotowe. Na boardzie: View → Group by: Milestone (sprinty) albo filtr label:sprint-1 / assignee:<login>."
