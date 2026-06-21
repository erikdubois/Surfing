# Changelog

## 2026.06.21 — Fix folder-name aliases falling back to foreign themes

### What Changed

On Plasma, the **Downloads** folder rendered in a foreign style (different
colour) instead of the Surfn blue. Cause: Surfn ships alternate folder names
(`folder-downloads`, `folder-text`, `folder-image(s)`, `folder-sound(s)`, …)
only under `scalable/`, so when a desktop requested one at a **fixed pixel size**
it missed and fell through `Inherits=` (Numix first) to a foreign theme. Fixed by
propagating those aliases down to every fixed size in the generator.

### Technical Details

- [rearrange.sh](./rearrange.sh): new `propagate_place_aliases()` step (runs
  after `overlay_breeze_contexts`). For each same-directory alias symlink in
  `places/scalable`, it recreates the alias at every fixed size where the target
  icon exists — so e.g. `folder-downloads.png → folder-download.png` now lives at
  16–128, not just `scalable/`.
- Regenerated: **416** place aliases propagated to fixed sizes; `index.theme`
  unchanged (102 groups — aliases land in already-declared directories).
- `check-icons.sh` clean: no broken symlinks, `gtk-update-icon-cache` builds.

### Files Modified

- `rearrange.sh` (new `propagate_place_aliases` step)
- `usr/share/icons/Surfing/places/**` (regenerated — fixed-size folder aliases)

## 2026.06.21 — Initial Surfing theme + repo

### What Changed

Created the **Surfing** icon theme: the Surfn icon set rearranged from its
non-standard size-first, triple-nested layout into a clean **Breeze-style
context-first** layout, with Breeze's `applets` and `preferences` contexts
overlaid so Surfing carries the full Breeze context set. Stood the repo up with
flow scripts and a package recipe.

### Technical Details

- [rearrange.sh](./rearrange.sh) deterministically rebuilds the theme from a
  read-only Surfn source snapshot (`_src/`, gitignored):
  - `<size>/<context>/` → `<context>/<size>/`; `scalable/<context>/{scalable,symbolic}/`
    → `<context>/{scalable,symbolic}/`; flat scalable → `<context>/scalable/`.
  - Whole-context redirect symlinks dropped (the real `<context>/scalable`
    bucket, declared `Type=Scalable`, serves every size).
  - 33 cross-context `../` aliases rewritten to the new paths; per-context `@2x`
    HiDPI symlinks recreated.
  - Breeze `applets` (259 svg) + `preferences` (413 svg) overlaid; 38 dead Breeze
    cross-context aliases pruned (they fall back through `Inherits=`).
  - `index.theme` regenerated from the tree on disk (102 groups) — zero
    declared-but-missing, zero undeclared.
- Verified: 13,013 → 13,013 real files (no icon loss), 0 broken symlinks,
  `gtk-update-icon-cache` builds, `check-icons.sh` reports all themes clean.
- Flow: [setup.sh](./setup.sh) (git remote), [up.sh](./up.sh) (validate via
  check-icons.sh, then commit/push). Package recipe `surfing-icons-git`
  (PKGBUILD + build.sh) lives in `KIRO-PKG-BUILD-ICONS/surfing/`.

### Files Modified

- `rearrange.sh`, `check-icons.sh`, `setup.sh`, `up.sh` (new)
- `usr/share/icons/Surfing/**` (generated theme)
- `README.md`, `CHANGELOG.md`, `.gitignore` (new)
