# DFG Devices: firmware for little gadgets

A site for sharing firmware for ESP-based devices (ESP32-S3 touch-screen boards such as Waveshare's round
AMOLED and LCD displays). Each project has a page where anyone with a supported board can install the latest
build straight from the browser with [ESP Web Tools](https://esphome.github.io/esp-web-tools/) (Chrome or Edge,
Web Serial): no toolchain, drivers or downloads needed.

Live at https://deepfriedgalliform.github.io/

- `index.html`: the homepage, a card for each project listing the devices it's made for
- `help.html`: connection problems
- `<project>/index.html`: the project's page, an Install button for each board
- `<project>/manifest-<board>.json` and `<project>/firmware/<board>/*.bin`: written by `tools/publish.ps1`

## Publishing a new build

Build the firmware as usual (for MultiTouch: `tools\build.ps1 -Board amoledc` in its repo), then here:

```
.\tools\publish.ps1 -Project multitouch -Board amoledc -Version 0.9n
```

For Brew Buddy (from the BrewBuddy_Release repo), build with board **ESP32S3 Dev Module**, ESP32 core 3.3.x,
LVGL 9.6 and TFT_eSPI 2.5.43 set up as in its `config/README.md`, with **Partition Scheme: Huge APP (3MB No OTA)**
(the app is about 1.6 MB, too big for the default 1.2 MB) and **USB CDC On Boot: Enabled**. Then:

```
.\tools\publish.ps1 -Project brew-buddy -Board lcd -Version "4.1 (<date>, build <commit>)" -Sketch BrewBuddy -Name "Brew Buddy" -BuildDir <build folder>
```

Commit and push. The page shows the new version on its button.

## Adding a project

1. Copy `multitouch/` to a new folder and edit its text and its `BOARDS` list.
2. Publish its builds with `-Project <folder> -Sketch <ino name> -Name "<shown name>" -BuildDir <build folder>`.
3. Turn its homepage card into a link and list its boards in the card's `devices` list.

## Putting it online (GitHub Pages, free for a public repo)

1. Make a public repo named `<your-username>.github.io` and push this folder to it.
2. In the repo: Settings > Pages > Build from a branch: `main`, `/ (root)`.
3. After a minute it's at `https://<your-username>.github.io/`.

Web Serial needs HTTPS, which Pages gives. To try it locally, serve the folder (for example `python -m http.server`)
and open `http://localhost:8000`. Opening the files straight from the disk can't load the manifests.
