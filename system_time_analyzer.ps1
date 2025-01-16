# Konfiguracja
$config = @{
    ShowConsoleOutput = $true  # Ustaw na $false aby wyłączyć wyświetlanie w konsoli, $true - aby łaczyć
    ExportPath = "C:\SystemEvents.csv"
    # Ustaw zakres dat (format: "yyyy-MM-dd")
    StartDate = "2024-12-01"  # Data początkowa
    EndDate = "2025-01-16"    # Data końcowa
}

# Konwersja dat z tekstu na format DateTime
$startDate = [DateTime]::ParseExact($config.StartDate, "yyyy-MM-dd", $null)
$endDate = [DateTime]::ParseExact($config.EndDate, "yyyy-MM-dd", $null).AddDays(1).AddSeconds(-1)

# Pobranie zdarzeń
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ProviderName = @(
        'Microsoft-Windows-Kernel-Boot',
        'Microsoft-Windows-Kernel-General'
    )
    ID = @(30, 13)  # 30 - boot, 13 - shutdown
    StartTime = $startDate
    EndTime = $endDate
} | Select-Object TimeCreated, Id, ProviderName

# Utworzenie hashtable do przechowywania danych według dni
$dailyEvents = @{}

# Najpierw utworzenie wpisów dla wszystkich dni z zakresu
$currentDate = $startDate
while ($currentDate.Date -le $endDate.Date) {
    $dateString = $currentDate.ToString("yyyy-MM-dd")
    $dailyEvents[$dateString] = @{
        FirstBoot = $null
        LastShutdown = $null
        HasData = $false
    }
    $currentDate = $currentDate.AddDays(1)
}

# Grupowanie zdarzeń według dni
foreach ($event in $events) {
    $date = $event.TimeCreated.Date.ToString("yyyy-MM-dd")
    $dailyEvents[$date].HasData = $true
    
    # Zapisywanie pierwszego uruchomienia i ostatniego zamknięcia
    if ($event.Id -eq 30 -and $event.ProviderName -eq 'Microsoft-Windows-Kernel-Boot') {
        if ($null -eq $dailyEvents[$date].FirstBoot -or 
            $event.TimeCreated -lt $dailyEvents[$date].FirstBoot) {
            $dailyEvents[$date].FirstBoot = $event.TimeCreated
        }
    }
    elseif ($event.Id -eq 13 -and $event.ProviderName -eq 'Microsoft-Windows-Kernel-General') {
        if ($null -eq $dailyEvents[$date].LastShutdown -or 
            $event.TimeCreated -gt $dailyEvents[$date].LastShutdown) {
            $dailyEvents[$date].LastShutdown = $event.TimeCreated
        }
    }
}

# Utworzenie pliku CSV
$output = foreach ($date in $dailyEvents.Keys | Sort-Object) {
    $bootTime = $dailyEvents[$date].FirstBoot
    $shutdownTime = $dailyEvents[$date].LastShutdown
    $hasData = $dailyEvents[$date].HasData
    
    # Obliczenie czasu pracy systemu
    $uptime = if ($bootTime -and $shutdownTime -and $shutdownTime -gt $bootTime) {
        $duration = $shutdownTime - $bootTime
        "{0:hh\:mm\:ss}" -f $duration
    } else {
        "Nie można określić"
    }

    # Ustawienie odpowiednich komunikatów w zależności od dostępności danych
    $statusBoot = if (-not $hasData) {
        "---"
    } elseif ($bootTime) {
        $bootTime.ToString("HH:mm:ss")
    } else {
        "Brak danych"
    }

    $statusShutdown = if (-not $hasData) {
        "---"
    } elseif ($shutdownTime) {
        $shutdownTime.ToString("HH:mm:ss")
    } else {
        "Brak danych"
    }

    $statusUptime = if (-not $hasData) {
        "---"
    } else {
        $uptime
    }

    [PSCustomObject]@{
        Data = $date
        Pierwsze_Uruchomienie = $statusBoot
        Ostatnie_Zamkniecie = $statusShutdown
        Czas_Pracy = $statusUptime
    }
}

# Eksport do pliku CSV
$output | Export-Csv -Path $config.ExportPath -NoTypeInformation -Encoding UTF8

# Wyświetl podsumowanie na ekranie (jeśli włączone)
if ($config.ShowConsoleOutput) {
    Write-Host "`nZestawienie czasów uruchomienia i zamknięcia systemu" -ForegroundColor Cyan
    Write-Host "Okres: $($config.StartDate) do $($config.EndDate)" -ForegroundColor Cyan
    Write-Host ""
    $output | Format-Table -AutoSize
    Write-Host "`nDane zostały wyeksportowane do: $($config.ExportPath)" -ForegroundColor Green
}
