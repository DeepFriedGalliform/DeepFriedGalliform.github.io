# Copy a project's latest build into the site and write its manifest for ESP Web Tools.
#   .\tools\publish.ps1 -Project multitouch -Board amoledc -Version 0.9n
#   .\tools\publish.ps1 -Project multitouch -Board lcd -Version 0.9n -BuildDir C:\some\build\folder
# The build folder is the one arduino-cli wrote (MultiTouch's tools\build.ps1 uses %TEMP%\mt_build_<board>). It must
# hold <Sketch>.ino.bin, .bootloader.bin and .partitions.bin, and boot_app0.bin.
# Only the four parts are published, never a file-system image. The installer asks whether to erase the board first (unticked: settings and files kept).
param(
  [Parameter(Mandatory)] [string]$Project,       # the site folder: multitouch, brew-buddy, ...
  [Parameter(Mandatory)] [string]$Board,         # the board's id on the project page: lcd, amoled, amoledc
  [Parameter(Mandatory)] [string]$Version,
  [string]$BuildDir = '',
  [string]$Sketch = 'MultiTouch',                # the .ino's name, as the build files are named
  [string]$Name = ''                             # the name the installer shows (default: the sketch's)
)
$ErrorActionPreference = 'Stop'
$site = Split-Path $PSScriptRoot -Parent
if (-not $BuildDir) { $BuildDir = Join-Path $env:TEMP "mt_build_$Board" }
if (-not (Test-Path $BuildDir)) { throw "No build folder at ${BuildDir}: build the firmware first" }
if (-not $Name) { $Name = $Sketch }

# the parts and where they go in the flash (ESP32-S3, Arduino core 3)
$parts = @(
  @{ src = "$Sketch.ino.bootloader.bin"; dst = 'bootloader.bin'; offset = 0x0 },
  @{ src = "$Sketch.ino.partitions.bin"; dst = 'partitions.bin'; offset = 0x8000 },
  @{ src = 'boot_app0.bin';              dst = 'boot_app0.bin';  offset = 0xE000 },
  @{ src = "$Sketch.ino.bin";            dst = 'app.bin';        offset = 0x10000 }
)
foreach ($p in $parts) { if (-not (Test-Path (Join-Path $BuildDir $p.src))) { throw "Missing $($p.src) in $BuildDir" } }

$projDir = Join-Path $site $Project
$fwDir = Join-Path $projDir "firmware\$Board"
New-Item -ItemType Directory -Force $fwDir | Out-Null
foreach ($p in $parts) { Copy-Item (Join-Path $BuildDir $p.src) (Join-Path $fwDir $p.dst) -Force }

$manifest = [ordered]@{
  name = $Name
  version = $Version
  new_install_prompt_erase = $true               # (the installer asks: an "Erase device" box, unticked, so an update keeps the board's data; ticked, it starts clean. False would ERASE EVERY TIME: the firmware isn't recognised, so each install counts as new)
  builds = @(@{
    chipFamily = 'ESP32-S3'
    parts = @($parts | ForEach-Object { [ordered]@{ path = "firmware/$Board/$($_.dst)"; offset = $_.offset } })
  })
}
$json = $manifest | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText((Join-Path $projDir "manifest-$Board.json"), $json)   # (UTF-8, no BOM)
$app = (Get-Item (Join-Path $fwDir 'app.bin')).Length
Write-Host ("Published {0} {1} for {2}: app {3:N0} bytes, built {4}" -f $Name, $Version, $Board, $app, (Get-Item (Join-Path $BuildDir "$Sketch.ino.bin")).LastWriteTime)
