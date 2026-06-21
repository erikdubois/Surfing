#!/bin/bash
set -uo pipefail
#####################################################################
# Author    : Erik Dubois
# Website   : https://erikdubois.be
#####################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
# Purpose:
#   Rebuild the Surfing icon theme from the read-only source snapshot
#   (_src/Surfn) into a clean, Breeze-style CONTEXT-FIRST layout while
#   keeping scalable buckets:
#       <size>/<context>/            -> <context>/<size>/
#       scalable/<context>/scalable/ -> <context>/scalable/
#       scalable/<context>/symbolic/ -> <context>/symbolic/
#       scalable/<context>/*.svg     -> <context>/scalable/   (flat, e.g. animations)
#   Whole-context redirect symlinks (<size>/<context> -> ../scalable/...)
#   are dropped; the real <context>/scalable bucket (declared Scalable in
#   index.theme) serves every size the freedesktop way. index.theme is
#   regenerated from the resulting tree so it is exactly consistent.
#
# Why:
#   surfn's size-first, triple-nested layout left ~13k scalable SVGs
#   undeclared/unindexed. This produces a maintainable standard layout.
#   The original surfn repo is never touched; this only writes under
#   this sandbox.
#####################################################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SCRIPT_DIR}/_src/Surfn"
OUT="${SCRIPT_DIR}/usr/share/icons/Surfing"

#####################################################################
# Colors
#####################################################################
if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
    RED="$(tput setaf 1)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"; CYAN="$(tput setaf 6)"; RESET="$(tput sgr0)"
else
    RED="" GREEN="" YELLOW="" BLUE="" CYAN="" RESET=""
fi

#####################################################################
# Logging
#####################################################################
log_section() { echo; echo "${GREEN}############################################################################${RESET}"; echo "$1"; echo "${GREEN}############################################################################${RESET}"; echo; }
log_info()    { echo; echo "${BLUE}############################################################################${RESET}"; echo "$1"; echo "${BLUE}############################################################################${RESET}"; echo; }
log_warn()    { echo; echo "${YELLOW}############################################################################${RESET}"; echo "$1"; echo "${YELLOW}############################################################################${RESET}"; echo; }
log_error()   { echo; echo "${RED}############################################################################${RESET}"; echo "$1"; echo "${RED}############################################################################${RESET}"; echo; }
log_success() { echo; echo "${GREEN}############################################################################${RESET}"; echo "$1"; echo "${GREEN}############################################################################${RESET}"; echo; }

#####################################################################
# Error handling
#####################################################################
on_error() { local lineno="$1" cmd="$2"; echo; echo "${RED}ERROR on line ${lineno}: ${cmd}${RESET}"; echo; sleep 10; }
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

#####################################################################
# Helpers
#####################################################################
SIZES_RE='^(8|12|16|22|24|32|48|64|96|128|256)$'

# Map a context directory name to its freedesktop Context= value.
context_value() {
    case "$1" in
        apps)          echo "Applications" ;;
        places)        echo "Places" ;;
        mimetypes)     echo "MimeTypes" ;;
        actions)       echo "Actions" ;;
        devices)       echo "Devices" ;;
        categories)    echo "Categories" ;;
        emblems)       echo "Emblems" ;;
        emotes)        echo "Emotes" ;;
        status)        echo "Status" ;;
        animations)    echo "Animations" ;;
        panel)         echo "Panel" ;;
        notifications) echo "Notifications" ;;
        applets)       echo "Status" ;;
        preferences)   echo "Applications" ;;
        *)             echo "Applications" ;;
    esac
}

# Transform a source-relative path to its new context-first path.
transform_path() {
    local p="$1"
    if [[ "$p" == scalable/* ]]; then
        local rest="${p#scalable/}"          # <ctx>/...
        local ctx="${rest%%/*}"
        local tail="${rest#*/}"
        if [[ "$rest" == "$ctx" ]]; then
            echo "$p"; return                # bare 'scalable/<ctx>' dir, no tail
        fi
        case "$tail" in
            scalable/*) echo "${ctx}/scalable/${tail#scalable/}" ;;
            symbolic/*) echo "${ctx}/symbolic/${tail#symbolic/}" ;;
            scalable)   echo "${ctx}/scalable" ;;
            symbolic)   echo "${ctx}/symbolic" ;;
            *)          echo "${ctx}/scalable/${tail}" ;;   # flat files under scalable/<ctx>/
        esac
    else
        local size="${p%%/*}"          # <size>
        local rest="${p#*/}"           # <ctx> or <ctx>/<more>
        local ctx="${rest%%/*}"
        if [[ "${rest}" == "${ctx}" ]]; then
            echo "${ctx}/${size}"      # exactly <size>/<ctx>
        else
            echo "${ctx}/${size}/${rest#*/}"   # <size>/<ctx>/<more>
        fi
    fi
}

#####################################################################
# Functions
#####################################################################
reset_output() {
    log_section "Resetting output tree"
    [[ -d "${SRC}" ]] || { log_error "Source snapshot missing: ${SRC}"; exit 1; }
    rm -rf "${OUT}"
    mkdir -p "${OUT}"
    cp -a "${SRC}/LICENSE.txt" "${SRC}/CREDITS" "${SRC}/changelog" "${OUT}/" 2>/dev/null || true
    log_success "Output reset"
}

# Copy the real leaf directories into their context-first location. cp -a
# preserves same-dir (and ./-prefixed) alias symlinks verbatim.
copy_leaf_dirs() {
    log_section "Copying leaf directories (context-first)"
    local d ctx size n=0

    # Fixed sizes: <size>/<context>  ->  <context>/<size>
    for d in "${SRC}"/*/; do
        size="$(basename "${d}")"
        [[ "${size}" =~ ${SIZES_RE} ]] || continue
        for ctxd in "${d}"*/; do
            [[ -d "${ctxd}" && ! -L "${ctxd%/}" ]] || continue   # skip context-redirect symlinks
            ctx="$(basename "${ctxd}")"
            mkdir -p "${OUT}/${ctx}/${size}"
            cp -a "${ctxd}." "${OUT}/${ctx}/${size}/"
            n=$((n+1))
        done
    done

    # Scalable tree: scalable/<context>/{scalable,symbolic}/ and flat files
    for ctxd in "${SRC}"/scalable/*/; do
        [[ -d "${ctxd}" && ! -L "${ctxd%/}" ]] || continue
        ctx="$(basename "${ctxd}")"
        if [[ -d "${ctxd}scalable" && ! -L "${ctxd}scalable" ]]; then
            mkdir -p "${OUT}/${ctx}/scalable"; cp -a "${ctxd}scalable/." "${OUT}/${ctx}/scalable/"; n=$((n+1))
        fi
        if [[ -d "${ctxd}symbolic" && ! -L "${ctxd}symbolic" ]]; then
            mkdir -p "${OUT}/${ctx}/symbolic"; cp -a "${ctxd}symbolic/." "${OUT}/${ctx}/symbolic/"; n=$((n+1))
        fi
        # flat svgs directly under scalable/<ctx>/ (e.g. animations)
        if compgen -G "${ctxd}*.svg" >/dev/null 2>&1 || compgen -G "${ctxd}*.png" >/dev/null 2>&1; then
            mkdir -p "${OUT}/${ctx}/scalable"
            find "${ctxd}" -maxdepth 1 -type f \( -name '*.svg' -o -name '*.png' \) -exec cp -a {} "${OUT}/${ctx}/scalable/" \;
            find "${ctxd}" -maxdepth 1 -type l -exec cp -a {} "${OUT}/${ctx}/scalable/" \;
            n=$((n+1))
        fi
    done
    log_success "Copied ${n} leaf directories"
}

# Rewrite the cross-context ../ alias symlinks (which a verbatim copy breaks)
# by resolving each in the source and re-pointing to the mapped new location.
fix_cross_aliases() {
    log_section "Fixing cross-directory alias symlinks"
    local l raw rel newlink finalabs finalrel newtarget reldir n=0 skipped=0
    local srcabs; srcabs="$(realpath "${SRC}")"
    while IFS= read -r l; do
        raw="$(readlink "${l}")"
        [[ "${raw}" == */* ]] || continue          # same-dir: untouched
        [[ "${raw}" == ./* ]] && continue           # ./name : same-dir, already valid
        [[ -d "${l}" ]] && continue                 # dir target = context redirect: dropped (not copied)
        rel="${l#${SRC}/}"
        newlink="${OUT}/$(transform_path "${rel}")"
        [[ -e "${newlink}" || -L "${newlink}" ]] || continue
        finalabs="$(realpath -e "${l}" 2>/dev/null)" || { skipped=$((skipped+1)); continue; }
        case "${finalabs}" in
            "${srcabs}/"*) finalrel="${finalabs#${srcabs}/}" ;;
            *) skipped=$((skipped+1)); continue ;;
        esac
        newtarget="${OUT}/$(transform_path "${finalrel}")"
        [[ -e "${newtarget}" ]] || { skipped=$((skipped+1)); continue; }
        reldir="$(dirname "${newlink}")"
        ln -sfn "$(realpath -m --relative-to="${reldir}" "${newtarget}")" "${newlink}"
        n=$((n+1))
    done < <(find "${SRC}" -type l)
    log_success "Rewrote ${n} cross-dir aliases (${skipped} skipped/unresolved)"
}

# Overlay the Breeze contexts that Surfn never had (applets, preferences) by
# copying Breeze's real size dirs in. Only numeric size dirs are copied; Breeze's
# own @2x/@3x symlinks are skipped so make_hidpi can add @2x uniformly, keeping
# Surfing internally consistent. (Icons are Breeze-sourced — credit accordingly.)
BREEZE="/usr/share/icons/breeze"
overlay_breeze_contexts() {
    log_section "Overlaying missing Breeze contexts (applets, preferences)"
    local ctx size d n=0
    if [[ ! -d "${BREEZE}" ]]; then
        log_warn "Breeze not found at ${BREEZE} — skipping overlay"
        return
    fi
    for ctx in applets preferences; do
        [[ -d "${BREEZE}/${ctx}" ]] || { log_warn "Breeze has no ${ctx} — skipping"; continue; }
        for d in "${BREEZE}/${ctx}"/*/; do
            size="$(basename "${d}")"
            [[ "${size}" =~ ${SIZES_RE} ]] || continue   # skip @2x/@3x symlinks
            [[ -L "${d%/}" ]] && continue
            mkdir -p "${OUT}/${ctx}/${size}"
            cp -a "${d}." "${OUT}/${ctx}/${size}/"
            n=$((n+1))
        done
    done
    log_success "Overlaid ${n} Breeze size dirs"
}

# Recreate HiDPI @2x dirs as symlinks per context (source used uniform @2x).
make_hidpi() {
    log_section "Creating per-context @2x HiDPI symlinks"
    local d ctx size n=0
    for d in "${OUT}"/*/*/; do
        size="$(basename "${d}")"
        [[ "${size}" =~ ${SIZES_RE} ]] || continue
        ctx="$(basename "$(dirname "${d}")")"
        ln -sfn "${size}" "${OUT}/${ctx}/${size}@2x"
        n=$((n+1))
    done
    log_success "Created ${n} @2x symlinks"
}

# Remove any dead symlinks left in the tree (e.g. Breeze cross-context aliases
# whose targets live in contexts Surfing doesn't provide). The alias names fall
# back through Inherits= at runtime, so dropping the dead link loses nothing and
# ships a clean theme.
prune_dangling() {
    log_section "Pruning dead symlinks"
    local l n=0
    while IFS= read -r l; do
        rm -f "${l}"; n=$((n+1))
    done < <(find "${OUT}" -type l ! -exec test -e {} \; -print)
    log_success "Pruned ${n} dead symlinks"
}

# Regenerate index.theme from what is actually on disk in OUT.
generate_index_theme() {
    log_section "Generating index.theme"
    local idx="${OUT}/index.theme" dirs=() scaled=() d rel ctx size ctxval
    local groups=""

    while IFS= read -r d; do
        rel="${d#${OUT}/}"
        ctx="${rel%%/*}"; size="${rel#*/}"
        ctxval="$(context_value "${ctx}")"
        if [[ "${size}" == *@2x ]]; then
            scaled+=("${rel}")
            groups+=$'\n'"[${rel}]"$'\n'"Size=${size%@2x}"$'\n'"Scale=2"$'\n'"Context=${ctxval}"$'\n'"Type=Fixed"$'\n'
        elif [[ "${size}" == "scalable" ]]; then
            dirs+=("${rel}")
            groups+=$'\n'"[${rel}]"$'\n'"Size=48"$'\n'"Context=${ctxval}"$'\n'"MinSize=8"$'\n'"MaxSize=512"$'\n'"Type=Scalable"$'\n'
        elif [[ "${size}" == "symbolic" ]]; then
            dirs+=("${rel}")
            groups+=$'\n'"[${rel}]"$'\n'"Size=16"$'\n'"Context=${ctxval}"$'\n'"MinSize=8"$'\n'"MaxSize=512"$'\n'"Type=Scalable"$'\n'
        elif [[ "${size}" =~ ${SIZES_RE} ]]; then
            dirs+=("${rel}")
            groups+=$'\n'"[${rel}]"$'\n'"Size=${size}"$'\n'"Context=${ctxval}"$'\n'"Type=Fixed"$'\n'
        fi
    done < <(find "${OUT}" -mindepth 2 -maxdepth 2 \( -type d -o -type l \) | sort)

    local all_dirs; all_dirs="$(IFS=,; echo "${dirs[*]}")"
    local all_scaled; all_scaled="$(IFS=,; echo "${scaled[*]}")"

    {
        echo "[Icon Theme]"
        echo "Name=Surfing"
        echo "Comment=Surfing icon theme (Breeze-style context-first layout)"
        grep -E '^Inherits=' "${SRC}/index.theme" 2>/dev/null || echo "Inherits=breeze,hicolor"
        echo "DisplayDepth=32"
        echo "Example=folder"
        echo "FollowsColorScheme=true"
        echo
        echo "DesktopDefault=48"
        echo "DesktopSizes=16,22,32,48,64,128,256"
        echo "ToolbarDefault=22"
        echo "ToolbarSizes=16,22,32,48"
        echo "SmallDefault=16"
        echo "SmallSizes=16,22,32,48"
        echo "DialogDefault=32"
        echo
        echo "Directories=${all_dirs}"
        echo "ScaledDirectories=${all_scaled}"
        echo "${groups}"
    } > "${idx}"
    log_success "index.theme written ($(grep -c '^\[' "${idx}") groups)"
}

#####################################################################
# Main
#####################################################################
main() {
    reset_output
    copy_leaf_dirs
    fix_cross_aliases
    overlay_breeze_contexts
    make_hidpi
    prune_dangling
    generate_index_theme
    log_success "$(basename "$0") done"
}

main "$@"
