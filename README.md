<h1 align="center">
  <img src="kiro.jpg" alt="Kiro" width="220" />
  <br />
  Surfing
</h1>

![Last-Commit](https://img.shields.io/github/last-commit/erikdubois/Surfing?style=for-the-badge)

<img alt="GitHub followers" src="https://img.shields.io/github/followers/erikdubois?style=flat">&nbsp;&nbsp;<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/erikdubois/Surfing">&nbsp;&nbsp;<img alt="GitHub forks" src="https://img.shields.io/github/forks/erikdubois/Surfing">

<img alt="YouTube Channel Subscribers" src="https://img.shields.io/youtube/channel/subscribers/UCJdmdUp5BrsWsYVQUylCMLg">&nbsp;&nbsp;<img alt="YouTube Channel Views" src="https://img.shields.io/youtube/channel/views/UCJdmdUp5BrsWsYVQUylCMLg">

---

**Surfing** is the [Surfn](https://github.com/erikdubois/surfn) icon set rearranged into a
clean, **Breeze-style context-first** layout. The name is no accident — *Surfn* is pronounced
*surfing*, so this is the same icons spelled out, organised the standard freedesktop way
(`apps/22/`, `places/scalable/`, …) instead of Surfn's size-first tree.

On top of the rearrange it overlays Breeze's `applets` and `preferences` contexts, so Surfing
carries the **full Breeze context set** while keeping every Surfn icon.

## Installation (Arch / Kiro — nemesis_repo)

```
sudo pacman -S surfing-icons-git
```

## Manual

Copy `usr/share/icons/Surfing` into `~/.icons` (or `~/.local/share/icons` on Plasma),
then select **Surfing** in your appearance settings.

## How it is managed

Surfing is **generated**, not hand-edited. [rearrange.sh](./rearrange.sh) rebuilds the whole
theme from a read-only Surfn source snapshot: it inverts the size-first layout to context-first,
collapses the triple-nested scalable tree, overlays the Breeze `applets`/`preferences` contexts,
prunes dead symlinks, and regenerates `index.theme` from the tree on disk. [check-icons.sh](./check-icons.sh)
validates the result — no missing index entries, no broken symlinks, cache builds clean — and is
run by [up.sh](./up.sh) before every push. Regenerating from the source keeps the layout consistent
and the index always in sync with what is actually shipped.

## Credits

- **Surfn** — Erik Dubois (base icon set)
- **Breeze** (`applets`, `preferences` contexts) — the KDE Visual Design Group

## License

[LICENSE](./LICENSE) — Attribution-NonCommercial-ShareAlike 4.0 International (Surfn icons).
The bundled Breeze `applets`/`preferences` icons are LGPL-3.0 (KDE).
