# System Boot and Shutdown Time Analyzer

## Opis
Skrypt PowerShell do analizy czasów uruchomienia i zamknięcia systemu Windows. Generuje raport w formie CSV zawierający informacje o pierwszym uruchomieniu i ostatnim zamknięciu systemu dla każdego dnia w wybranym zakresie dat.

## Funkcjonalności
- Analiza zdarzeń systemowych związanych z uruchomieniem i zamknięciem systemu
- Możliwość określenia zakresu dat do analizy
- Generowanie raportu CSV
- Opcjonalne wyświetlanie wyników w konsoli
- Uwzględnianie dni bez aktywności systemu

## Wymagania
- Windows PowerShell 5.1 lub nowszy
- Uprawnienia administratora (do odczytu dziennika zdarzeń systemowych)

## Instalacja
1. Sklonuj repozytorium lub pobierz plik `system_time_analyzer.ps1`
2. Upewnij się, że masz odpowiednie uprawnienia do uruchamiania skryptów PowerShell

## Konfiguracja
W sekcji konfiguracyjnej skryptu możesz dostosować:
- Zakres dat analizy (`StartDate`, `EndDate`)
- Ścieżkę eksportu pliku CSV (`ExportPath`)
- Wyświetlanie wyników w konsoli (`ShowConsoleOutput`)

```powershell
$config = @{
    ShowConsoleOutput = $true  # true/false - włączenie/wyłączenie wyświetlania w konsoli
    ExportPath = "C:\SystemEvents.csv"
    StartDate = "2024-12-01"  # Data początkowa (format: yyyy-MM-dd)
    EndDate = "2025-01-16"    # Data końcowa (format: yyyy-MM-dd)
}
```

## Użycie
Otwórz PowerShell jako administrator
Przejdź do katalogu ze skryptem
Uruchom skrypt:
.\system_time_analyzer.ps1

## Format wyników
Skrypt generuje plik CSV z następującymi kolumnami:
Data - data w formacie YYYY-MM-DD
Pierwsze_Uruchomienie - czas pierwszego uruchomienia systemu
Ostatnie_Zamkniecie - czas ostatniego zamknięcia systemu
Czas_Pracy - całkowity czas pracy systemu w danym dniu

Wartości specjalne:
--- - dzień bez aktywności systemu
Brak danych - brak informacji o zdarzeniu

