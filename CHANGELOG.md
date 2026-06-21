# Changelog

## 2026.06.21 — Match up/down arrow weight to back/forward

### What Changed

After flattening the nav icons, the up arrow looked too thick next to
back/forward — Surfn's symbolic `go-up`/`go-down` are a heavier design than
`go-previous`/`go-next`. Now the vertical arrows are derived by rotating the
thin `go-previous` arrow, so the whole nav family shares one weight.

### Technical Details

- [rearrange.sh](./rearrange.sh) `derive_vertical_arrows()` (after
  `flatten_nav_actions`): builds `go-up` (`rotate(90 8 8)`) and `go-down`
  (`rotate(-90 8 8)`) from the flat `go-previous` across
  `actions/{16,22,24,32,scalable}` (**10** files); `go-up` removed from
  `NAV_FLAT_ICONS` so it's no longer flattened from its heavier symbolic art.
- Rendered + recolor-checked; `check-icons.sh` clean.

## 2026.06.21 — Hamburger menu icon for Dolphin's open-menu button

### What Changed

Dolphin's hamburger (⋮/≡) menu button rendered blank: it requests
`application-menu`, but Surfn ships only a *gear* (`open-menu` and the
`*-symbolic` variants) with no colored `application-menu`, so KDE fell back to
nothing usable. Shipped a proper flat ≡ hamburger so the button keeps its
expected look.

### Technical Details

- [rearrange.sh](./rearrange.sh) `make_hamburger_menu()` (after
  `flatten_nav_actions`): writes a clean three-bar ≡ SVG (fill `currentColor` +
  `.ColorScheme-Text` stylesheet, so KDE recolours it light-on-dark /
  dark-on-light) as `application-menu` **and** `open-menu` across
  `actions/{16,22,24,32,scalable}` (**10** files), replacing the Surfn gear.
- Rendered + recolor-checked with `rsvg-convert`; `check-icons.sh` clean.

## 2026.06.21 — Flat navigation icons in Dolphin (match Thunar)

### What Changed

Plasma/Dolphin's toolbar showed the colored blue-circle navigation icons while
XFCE/Thunar showed flat monochrome arrows — same theme, but the apps pull
different files (GTK uses `actions/symbolic/<n>-symbolic`, KDE the colored
`actions/<size>/<n>`). Made Dolphin match Thunar's flat arrows for the
navigation set (back/forward/up/home/reload), auto-recolored to the toolbar
text colour.

### Technical Details

- [rearrange.sh](./rearrange.sh) `flatten_nav_actions()` (after `repair_osb_svgs`):
  builds each colored nav action icon from the symbolic artwork, converting the
  fill to `currentColor` + a `.ColorScheme-Text` stylesheet so KDE recolours it
  (light on dark, dark on light). Writes to `actions/{16,22,24,32,scalable}`,
  replacing the blue-circle versions. GTK keeps using the untouched symbolic
  icons. Set: `go-previous/next/up/home`, `view-refresh`, `go-previous/next-rtl`
  (**35** files).
- Verified with `rsvg-convert`: flat render in default grey and (simulated)
  light recolor; `check-icons.sh` clean.

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
3. **Plasma sidebar — Network was a plain folder, Recent Files a foreign icon**.
   Dolphin's "Network" uses `folder-network` (Surfn maps it to a plain folder);
   pointed it at the `network-workgroup` globe instead — the same icon XFCE's
   "Browse Network" shows. "Recent Files" uses `document-open-recent` (Surfn
   ships it only as a scalable SVG → fell back at fixed sizes); aliased to
   `folder-recent`, matching "Recent Locations".

All fixed in the generator so regeneration stays reproducible.

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
- [rearrange.sh](./rearrange.sh) `preferred_place_aliases()` (after
  `propagate_place_aliases`): forces specific names to the expected Surfn icon,
  overriding the generic propagation — `folder-network → network-workgroup`
  (globe), `document-open-recent → folder-recent`. **18** aliases applied.
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
