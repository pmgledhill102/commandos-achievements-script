# commandos-achievements-script

Hacky script to show progress towards Commandos: Origins global achievements

## Background

When playing `Commandos: Origins` there are 3 global achievements that are difficult to
track using the UI. There's a great Steam community guide on how to find our progress
based on a `.sav` file contents, using a Hex Editor.

I decided to try and codify it, to make it easier.

## Code

I wrote it in PowerShell so it should run on any Windows machine, just run:

```
.\CheckAchievements.ps1
```

## Output

It should find any completed maps, and show progress against the achievements:

```
Map: BritishCompound
  bWereAllEnemiesKilled:    False
  bWasNoEnemyKilled:        False
  bWasGlobalAlarmSetOff:    False
  DifficultyHard:           False

Map: Weatherstation
  bWereAllEnemiesKilled:    True
  bWasNoEnemyKilled:        False
  bWasGlobalAlarmSetOff:    False
  DifficultyHard:           False

Map: FortCapuzzo1
  bWereAllEnemiesKilled:    True
  bWasNoEnemyKilled:        False
  bWasGlobalAlarmSetOff:    False
  DifficultyHard:           True

Map: TrainBridge
  bWereAllEnemiesKilled:    True
  bWasNoEnemyKilled:        False
  bWasGlobalAlarmSetOff:    False
  DifficultyHard:           True
```

## Disclaimer

The way it's written - it's really likely they'll "break" the script with a future update.

Be warned.
