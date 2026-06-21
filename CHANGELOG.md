# Changelog

## 2026.06.21 — Fix Plasma/GTK rendering: folder aliases + broken symbolic SVGs

### What Changed

Two rendering bugs surfaced after installing on real desktops:

1. **Plasma — Downloads folder rendered in a foreign style** (different colour)
   instead of the Surfn blue. Surfn ships alternate folder names
   (`folder-downloads`, `folder-text`, `folder-image(s)`, `folder-sound(s)`, …)
   only under `scalable/`, so a desktop requesting one at a **fixed pixel size**
   missed and fell through `Inherits=` (Numix first) to a foreign theme.
2. **Thunar (GTK) — back/forward toolbar buttons showed a missing-icon "?"**.
   ~29 Surfn symbolic icons (`go-previous`, `go-next`, `pan-*`, `zoom-*`,
   `media-*`, `open-menu`, …) carry a dead `<linearGradient osb:paint="solid">`
   Inkscape swatch but never declare the `osb:` namespace — so librsvg (used by
   GTK) aborts parsing the **whole file** and the icon disappears.

Both fixed in the generator so regeneration stays reproducible.

### Technical Details

- [rearrange.sh](./rearrange.sh) `propagate_place_aliases()` (after
  `overlay_breeze_contexts`): for each same-directory alias symlink in
  `places/scalable`, recreates it at every fixed size where the target exists —
  `folder-downloads.png → folder-download.png` now lives at 16–128, not just
  `scalable/`. **416** aliases propagated.
- [rearrange.sh](./rearrange.sh) `repair_osb_svgs()` (after
  `overlay_breeze_contexts`): injects
  `xmlns:osb="http://www.openswatchbook.org/uri/2009/osb"` into every SVG that
  uses `osb:` without declaring it. **29** SVGs repaired; afterwards all 190
  symbolic action icons parse (`rsvg-convert` clean, 0 failures).
- `index.theme` group count unchanged (aliases/repairs land in already-declared
  directories). `check-icons.sh` clean; `gtk-update-icon-cache` builds.

### Files Modified

- `rearrange.sh` (new `propagate_place_aliases`, `repair_osb_svgs` steps)
- `usr/share/icons/Surfing/**` (regenerated — fixed-size folder aliases, repaired
  symbolic SVGs)

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
