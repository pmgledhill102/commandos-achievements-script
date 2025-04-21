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
    bWereAllEnemiesKilled   = "6257657265416c6c456e656d6965734b696c6c6564"
    bWasNoEnemyKilled       = "625761734e6f456e656d794b696c6c6564"
    bWasGlobalAlarmSetOff   = "62576173476c6f62616c416c61726d5365744f6666"
    CompletionTime          = "436f6d706c6574696f6e54696d65"
    DifficultyHard          = "446966666963756c74792e48617264"
}

# Regex pattern to match a chunk
$pattern = @"
(?:00)*
(?<MapName>((?:(?!00)[0-9a-f]{2})+))
(?:(00|0f)+)
$($hexMap.CompletionTime)
[0-9a-f]+?
(?<HardDifficultyFlag>$($hexMap.DifficultyHard))?
[0-9a-f]{0,10}
$($hexMap.bWereAllEnemiesKilled)[00-9a-f]*?(?<KilledAllVal>00|10)12
[0-9a-f]*?
$($hexMap.bWasNoEnemyKilled)[0-9a-f]*?(?<KilledNoneVal>00|10)18
[0-9a-f]*?
$($hexMap.bWasGlobalAlarmSetOff)[0-9a-f]*?(?<AlarmVal>00|10)15
"@ -replace "`r`n", ""

# Run the regex
$matches = [regex]::Matches($hex, $pattern)

if ($matches.Count -eq 0) {
    Write-Host "No matches found."
    exit
}

foreach ($match in $matches) {
    $mapHex = $match.Groups["MapName"].Value
    $mapName = -join (
        ($mapHex -split '(.{2})' | Where-Object { $_ -match '^[0-9a-f]{2}$' }) |
        ForEach-Object { [char]([Convert]::ToInt32($_, 16)) }
    )

    $difficultyHard = $match.Groups["HardDifficultyFlag"].Success
    $killedAll = if ($match.Groups["KilledAllVal"].Value -eq '10') { $true } else { $false }
    $killedNone = if ($match.Groups["KilledNoneVal"].Value -eq '10') { $true } else { $false }
    $alarmSet = if ($match.Groups["AlarmVal"].Value -eq '10') { $true } else { $false }

    Write-Host "`nMap: $mapName"
    Write-Host "  bWereAllEnemiesKilled:    " -NoNewline
    Write-Host ($killedAll) -ForegroundColor:($(if ($killedAll) { "Green" } else { "Red" }))

    Write-Host "  bWasNoEnemyKilled:        " -NoNewline
    Write-Host ($killedNone) -ForegroundColor:($(if ($killedNone) { "Green" } else { "Red" }))

    Write-Host "  bWasGlobalAlarmSetOff:    " -NoNewline
    Write-Host ($alarmSet) -ForegroundColor:($(if ($alarmSet) { "Red" } else { "Green" }))

    Write-Host "  DifficultyHard:           " -NoNewline
    Write-Host ($difficultyHard) -ForegroundColor:($(if ($difficultyHard) { "Green" } else { "Red" }))

}
