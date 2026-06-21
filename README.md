# Surfing icon theme

A **Breeze-style, context-first** icon theme built from the Surfn icon set,
rearranged into the standard freedesktop layout and topped up with Breeze's
`applets` and `preferences` contexts.

## Layout

Context-first, the way Breeze and Papirus organise icons:

```
usr/share/icons/Surfing/
  apps/16/  apps/22/ ... apps/scalable/  apps/symbolic/
  places/16/ ... places/scalable/  places/symbolic/
  actions/ animations/ applets/ categories/ devices/ emblems/
  emotes/ mimetypes/ notifications/ panel/ preferences/ status/
  index.theme
```

Each context holds fixed-size buckets (`16/`, `22/`, …) with per-size `@2x`
HiDPI symlinks, plus `scalable/` and `symbolic/` SVG buckets. `index.theme`
is generated from the tree on disk, so every directory is declared and nothing
is left unindexed.

## Installation

### From the repo (pacman)

```bash
sudo pacman -S surfing-icons-git
```

### Manual

Copy `usr/share/icons/Surfing` to `~/.icons` (or `~/.local/share/icons` on
Plasma), then select **Surfing** in your desktop's appearance settings.

## Building the theme

The theme is generated from a read-only Surfn source snapshot by
[rearrange.sh](./rearrange.sh) — it inverts the old size-first layout to
context-first, collapses the triple-nested scalable tree, overlays the Breeze
`applets`/`preferences` contexts, prunes dead symlinks, and regenerates
`index.theme`. [check-icons.sh](./check-icons.sh) validates the result (run by
[up.sh](./up.sh) before every push).

## Credits

- **Surfn** icons — Erik Dubois (Surfn icon theme)
- **Breeze** icons (applets, preferences contexts) — the KDE Visual Design Group

See `usr/share/icons/Surfing/CREDITS` and `LICENSE.txt` for the upstream
licensing of the bundled icon sets.

## Websites

Information : https://erikdubois.be

## Social Media

Youtube : https://www.youtube.com/erikdubois
