# Round Devices: the install site

A static site that installs the projects' firmware from the browser with
[ESP Web Tools](https://esphome.github.io/esp-web-tools/) (Chrome or Edge, Web Serial).

- `index.html`: the homepage, a card for each project
- `help.html`: connection problems
- `<project>/index.html`: the project's page, an Install button for each board
- `<project>/manifest-<board>.json` and `<project>/firmware/<board>/*.bin`: written by `tools/publish.ps1`

## Publishing a new build

Build the firmware as usual (for MultiTouch: `tools\build.ps1 -Board amoledc` in its repo), then here:

```
.\tools\publish.ps1 -Project multitouch -Board amoledc -Version 0.9n
```

Commit and push. The page shows the new version on its button.

## Adding a project

1. Copy `multitouch/` to a new folder and edit its text and its `BOARDS` list.
2. Publish its builds with `-Project <folder> -Sketch <ino name> -Name "<shown name>" -BuildDir <build folder>`.
3. Turn its homepage card into a link.

## Putting it online (GitHub Pages, free for a public repo)

1. Make a public repo named `<your-username>.github.io` and push this folder to it.
2. In the repo: Settings > Pages > Build from a branch: `main`, `/ (root)`.
3. After a minute it's at `https://<your-username>.github.io/`.

Web Serial needs HTTPS, which Pages gives. To try it locally, serve the folder (for example `python -m http.server`)
and open `http://localhost:8000`. Opening the files straight from the disk can't load the manifests.
