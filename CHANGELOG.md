# Changelog

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
