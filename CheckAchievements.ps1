# Enable strict behavior
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Path to .sav file (from same dir as script)
$savFilePath = "$env:LOCALAPPDATA\Commandos\Saved\SaveGames\StatTrackingGlobal.sav"

# Read file as hex string
$bytes = [System.IO.File]::ReadAllBytes($savFilePath)
$hex = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ""

# Define key fields as hex
$hexMap = @{
    CompletionTime          = "436f6d706c6574696f6e54696d65"
    bWereAllEnemiesKilled   = "6257657265416c6c456e656d6965734b696c6c6564000d000000426f6f6c50726f7065727479"
    bWasNoEnemyKilled       = "625761734e6f456e656d794b696c6c6564000d000000426f6f6c50726f7065727479"
    bWasGlobalAlarmSetOff   = "62576173476c6f62616c416c61726d5365744f6666000d000000426f6f6c50726f7065727479"
}

# Define regex options
$regexOptions = [System.Text.RegularExpressions.RegexOptions]::CultureInvariant

# Define the regex pattern - map names
$pattern = @"
(?<MapName>((?:(?!00)[0-9a-f]{2}){1,18}))
(?:(00|0f)+)
$($hexMap.CompletionTime)
"@ -replace "`r`n", ""  # Remove newlines to make the pattern one continuous string

# Test the regex pattern
$matchesMap = [regex]::Matches($hex, $pattern, $regexOptions)
Write-Host "Map matches found: $($matchesMap.Count)"

# Define the regex pattern - kill all
$pattern = @"
$($hexMap.bWereAllEnemiesKilled)
(?:00){9}
(?<KilledAllVal>00|10)
12
"@ -replace "[\`r\`n]", ""  # Remove newlines to make the pattern one continuous string

# Test the regex pattern
$matchesKillAll = [regex]::Matches($hex, $pattern, $regexOptions)
Write-Host "Kill All matches found: $($matchesKillAll.Count)"

# Define the regex pattern - kill none
$pattern = @"
$($hexMap.bWasNoEnemyKilled)
(?:00){9}
(?<KilledNoneVal>00|10)
18
"@ -replace "`r`n", ""  # Remove newlines to make the pattern one continuous string

# Test the regex pattern
$matchesKillNone = [regex]::Matches($hex, $pattern, $regexOptions)
Write-Host "Kill None matches found: $($matchesKillNone.Count)"

# Define the regex pattern - alarm
$pattern = @"
$($hexMap.bWasGlobalAlarmSetOff)
(?:00){9}
(?<AlarmVal>00|10)
15
"@ -replace "`r`n", ""  # Remove newlines to make the pattern one continuous string

# Test the regex pattern
$matchesAlarm = [regex]::Matches($hex, $pattern, $regexOptions)
Write-Host "Alarm matches found: $($matchesAlarm.Count)"

# Output the result
for ($i = 0; $i -lt $matchesMap.Count; $i++) {
    $mapHex = $matchesMap[$i].Groups["MapName"].Value
    $mapName = -join (
        ($mapHex -split '(.{2})' | Where-Object { $_ -match '^[0-9a-f]{2}$' }) |
        ForEach-Object { [char]([Convert]::ToInt32($_, 16)) }
    )
    $killedAll = if ($matchesKillAll[$i].Groups["KilledAllVal"].Value -eq '10') { $true } else { $false }
    $killedNone = if ($matchesKillNone[$i].Groups["KilledNoneVal"].Value -eq '10') { $true } else { $false }
    $alarmSet = if ($matchesAlarm[$i].Groups["AlarmVal"].Value -eq '10') { $true } else { $false }

    Write-Host "`nMap: $mapName"
    Write-Host "  bWereAllEnemiesKilled:    " -NoNewline
    Write-Host ($killedAll) -ForegroundColor:($(if ($killedAll) { "Green" } else { "Red" }))

    Write-Host "  bWasNoEnemyKilled:        " -NoNewline
    Write-Host ($killedNone) -ForegroundColor:($(if ($killedNone) { "Green" } else { "Red" }))

    Write-Host "  bWasGlobalAlarmSetOff:    " -NoNewline
    Write-Host ($alarmSet) -ForegroundColor:($(if ($alarmSet) { "Green" } else { "Red" }))

}
