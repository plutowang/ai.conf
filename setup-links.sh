#!/usr/bin/env bash
# setup-links.sh - Symlink AI tool configs from this repo into their config dirs
#
# Tools:
#   copilot  -> ~/.copilot/          (agents/, skills/, + root files)
#               copilot/rules/    -> ~/.copilot/instructions/
#               copilot/commands/ -> ~/Library/Application Support/Code/User/prompts/ (macOS only)
#   cursor   -> ~/.cursor/           (agents rules commands skills + root files)
#   opencode -> ~/.config/opencode/  (agents rules commands skills plugins bin + root files)
#
# Cursor settings.json/extensions.json go to
#   ~/Library/Application Support/Cursor/User/ (macOS only)

set -euo pipefail

# --- Globals ---------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR=""
SOURCE_ROOT=""
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

ACTION="link"
TOOL="all"
TOOL_EXPLICIT=false
DRY_RUN=false
FORCE=false
HELP=false

LINK_COUNT=0
REMOVE_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

# --- Usage -----------------------------------------------------------------
usage() {
    cat <<EOF
Usage:
  ./setup-links.sh [link|unlink] [copilot|cursor|opencode|all] [options]

Actions:
  link     Create symlinks (default)
  unlink   Remove symlinks at managed destinations (never touches real files)

Options:
  --dry-run    Show what would be done without touching anything
  --force|-f   link only: backup existing real files/dirs, then symlink
  --source <p> Override the repo root (default: auto-detect)
  --help|-h    Show this help message
EOF
}

# --- Argument parsing ------------------------------------------------------
parse_args() {
    local positional=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) DRY_RUN=true ;;
            --force|-f) FORCE=true ;;
            --source)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: --source requires a value" >&2
                    usage >&2
                    exit 2
                fi
                SOURCE_DIR="$2"
                shift
                ;;
            --help|-h) HELP=true ;;
            -*)
                echo "Error: unknown option: $1" >&2
                usage >&2
                exit 2
                ;;
            *) positional+=("$1") ;;
        esac
        shift
    done

    if [[ ${#positional[@]} -gt 2 ]]; then
        echo "Error: too many arguments" >&2
        usage >&2
        exit 2
    fi

    if [[ -n "${positional[0]:-}" ]]; then
        ACTION="${positional[0]}"
    fi
    if [[ -n "${positional[1]:-}" ]]; then
        TOOL="${positional[1]}"
        TOOL_EXPLICIT=true
    fi

    case "$ACTION" in
        link|unlink) ;;
        *)
            echo "Error: unknown action '$ACTION' (expected link|unlink)" >&2
            usage >&2
            exit 2
            ;;
    esac
    case "$TOOL" in
        copilot|cursor|opencode|all) ;;
        *)
            echo "Error: unknown tool '$TOOL' (expected copilot|cursor|opencode|all)" >&2
            usage >&2
            exit 2
            ;;
    esac
    if $FORCE && [[ "$ACTION" == "unlink" ]]; then
        echo "Error: --force is only valid with link" >&2
        exit 2
    fi
}

# --- Source detection ------------------------------------------------------
detect_source() {
    if [[ -n "$SOURCE_DIR" ]]; then
        echo "$SOURCE_DIR"
        return 0
    fi
    local candidate tool
    for candidate in "$SCRIPT_DIR" "$SCRIPT_DIR/.." "$HOME/projects/ai.conf" "$HOME/ai.conf"; do
        for tool in copilot cursor opencode; do
            if [[ -d "$candidate/$tool" ]]; then
                echo "$candidate"
                return 0
            fi
        done
    done
    echo "Error: could not detect repo root (expected copilot/|cursor/|opencode/ nearby). Use --source." >&2
    exit 1
}

# --- Mapping tables --------------------------------------------------------
tool_base() {
    case "$1" in
        copilot)  echo "$HOME/.copilot" ;;
        cursor)   echo "$HOME/.cursor" ;;
        opencode) echo "$HOME/.config/opencode" ;;
    esac
}

tool_subdirs() {
    case "$1" in
        copilot)  echo "agents rules skills commands" ;;
        cursor)   echo "agents rules commands skills" ;;
        opencode) echo "agents rules commands skills plugins bin" ;;
    esac
}

# stdout: destination for a root-level file, or empty if not applicable
dest_for_file() {
    local tool="$1" name="$2"
    if [[ "$tool" == "cursor" && ( "$name" == "settings.json" || "$name" == "extensions.json" ) ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            echo "$CURSOR_USER_DIR/$name"
        fi
    else
        echo "$(tool_base "$tool")/$name"
    fi
}

# stdout: destination for a tool subdir, or empty if not applicable
# (handles subdirs whose destination name differs from the source name)
subdir_dest() {
    local tool="$1" sub="$2"
    case "$tool:$sub" in
        copilot:rules)
            echo "$(tool_base copilot)/instructions"
            ;;
        copilot:commands)
            if [[ "$(uname)" == "Darwin" ]]; then
                echo "$HOME/Library/Application Support/Code/User/prompts"
            fi
            ;;
        *)
            echo "$(tool_base "$tool")/$sub"
            ;;
    esac
}

selected_tools() {
    if [[ "$TOOL" == "all" ]]; then
        echo "copilot cursor opencode"
    else
        echo "$TOOL"
    fi
}

# --- Link primitives -------------------------------------------------------
link_entry() {
    local src="$1" dest="$2"
    if [[ -L "$dest" ]]; then
        if [[ "$(readlink "$dest")" == "$src" ]]; then
            echo "  [OK] Already linked: $dest -> $src"
            SKIP_COUNT=$((SKIP_COUNT + 1))
        else
            if $DRY_RUN; then
                echo "  [~] Would relink: $dest -> $src"
            else
                rm "$dest"
                mkdir -p "$(dirname "$dest")"
                ln -sfn "$src" "$dest"
                echo "  [~] Updated: $dest -> $src"
            fi
            LINK_COUNT=$((LINK_COUNT + 1))
        fi
    elif [[ -e "$dest" ]]; then
        if $FORCE; then
            if $DRY_RUN; then
                echo "  [*] Would backup and link: $dest -> $src"
            else
                local bak="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$dest" "$bak"
                echo "  [*] Backed up: $dest -> $bak"
                mkdir -p "$(dirname "$dest")"
                ln -sfn "$src" "$dest"
                echo "  [*] Created: $dest -> $src"
            fi
            LINK_COUNT=$((LINK_COUNT + 1))
        else
            echo "  [-] Exists (use --force to replace): $dest"
            SKIP_COUNT=$((SKIP_COUNT + 1))
        fi
    else
        if $DRY_RUN; then
            echo "  [dry-run] Would link: $dest -> $src"
        else
            mkdir -p "$(dirname "$dest")"
            ln -sfn "$src" "$dest"
            echo "  [+] Created: $dest -> $src"
        fi
        LINK_COUNT=$((LINK_COUNT + 1))
    fi
}

# --- Unlink primitives -----------------------------------------------------
unlink_entry() {
    local dest="$1"
    if [[ -L "$dest" ]]; then
        if $DRY_RUN; then
            echo "  [dry-run] Would remove: $dest"
        else
            rm "$dest"
            echo "  [-] Removed: $dest"
        fi
        REMOVE_COUNT=$((REMOVE_COUNT + 1))
    elif [[ -e "$dest" ]]; then
        echo "  [skip] Not a symlink, leaving alone: $dest"
        SKIP_COUNT=$((SKIP_COUNT + 1))
    fi
}

# Remove leftover symlinks in a tool's base/override dirs that point into the
# source dir (covers sources deleted from the repo after linking).
sweep_stale_links() {
    local tool="$1" scan_dir f target
    for scan_dir in "$(tool_base "$tool")" "$CURSOR_USER_DIR"; do
        if [[ "$tool" != "cursor" && "$scan_dir" == "$CURSOR_USER_DIR" ]]; then
            continue
        fi
        [[ -d "$scan_dir" ]] || continue
        for f in "$scan_dir"/*; do
            [[ -L "$f" ]] || continue
            target="$(readlink "$f")"
            case "$target" in
                "$SOURCE_ROOT/$tool"/*)
                    if $DRY_RUN; then
                        echo "  [dry-run] Would remove stale link: $f"
                    else
                        rm "$f"
                        echo "  [-] Removed stale link: $f"
                    fi
                    REMOVE_COUNT=$((REMOVE_COUNT + 1))
                    ;;
            esac
        done
    done
}

# --- Per-tool link/unlink --------------------------------------------------
link_subdirs() {
    local tool="$1" sub src dest
    for sub in $(tool_subdirs "$tool"); do
        src="$SOURCE_ROOT/$tool/$sub"
        if [[ ! -d "$src" ]]; then
            echo "  [-] Skipping $sub: source not found"
            SKIP_COUNT=$((SKIP_COUNT + 1))
            continue
        fi
        dest="$(subdir_dest "$tool" "$sub")"
        if [[ -z "$dest" ]]; then
            echo "  [-] Skipping $sub (macOS only)"
            SKIP_COUNT=$((SKIP_COUNT + 1))
            continue
        fi
        link_entry "$src" "$dest"
    done
}

link_root_files() {
    local tool="$1" f name dest
    for f in "$SOURCE_ROOT/$tool"/*; do
        if [[ -L "$f" ]]; then continue; fi
        if [[ ! -f "$f" ]]; then continue; fi
        name="$(basename "$f")"
        if [[ "$name" == .* ]]; then continue; fi
        dest="$(dest_for_file "$tool" "$name")"
        if [[ -z "$dest" ]]; then
            echo "  [-] Skipping $name (macOS only)"
            SKIP_COUNT=$((SKIP_COUNT + 1))
            continue
        fi
        link_entry "$f" "$dest"
    done
}

unlink_subdirs() {
    local tool="$1" sub dest
    for sub in $(tool_subdirs "$tool"); do
        dest="$(subdir_dest "$tool" "$sub")"
        if [[ -n "$dest" ]]; then
            unlink_entry "$dest"
        fi
    done
}

unlink_root_files() {
    local tool="$1" f name dest
    if [[ -d "$SOURCE_ROOT/$tool" ]]; then
        for f in "$SOURCE_ROOT/$tool"/*; do
            if [[ -L "$f" ]]; then continue; fi
            if [[ ! -f "$f" ]]; then continue; fi
            name="$(basename "$f")"
            if [[ "$name" == .* ]]; then continue; fi
            dest="$(dest_for_file "$tool" "$name")"
            if [[ -n "$dest" ]]; then
                unlink_entry "$dest"
            fi
        done
    elif [[ "$tool" == "cursor" && "$(uname)" == "Darwin" ]]; then
        # Source dir gone: still remove override destinations by name
        unlink_entry "$CURSOR_USER_DIR/settings.json"
        unlink_entry "$CURSOR_USER_DIR/extensions.json"
    fi
    sweep_stale_links "$tool"
}

# --- Main ------------------------------------------------------------------
main() {
    parse_args "$@"

    if $HELP; then
        usage
        exit 0
    fi

    SOURCE_ROOT="$(detect_source)"
    if [[ ! -d "$SOURCE_ROOT" ]]; then
        echo "ERROR: source root not found: $SOURCE_ROOT" >&2
        exit 1
    fi
    SOURCE_ROOT="$(cd "$SOURCE_ROOT" && pwd)"

    echo "=========================================="
    echo "ai.conf - Setup Symlinks ($ACTION)"
    echo "=========================================="
    echo "Source:  $SOURCE_ROOT"
    echo "Tool(s): $TOOL"
    echo "Mode:    $(if $DRY_RUN; then echo "DRY-RUN"; else echo "NORMAL"; fi)$(if $FORCE && [[ "$ACTION" == "link" ]]; then echo " (force)"; fi)"
    echo ""

    local tool src_dir
    for tool in $(selected_tools); do
        src_dir="$SOURCE_ROOT/$tool"

        if [[ "$ACTION" == "link" && ! -d "$src_dir" ]]; then
            if $TOOL_EXPLICIT; then
                echo "ERROR: source dir not found: $src_dir" >&2
                exit 1
            fi
            echo "[$tool]"
            echo "  [!] Source dir missing, skipping: $src_dir"
            SKIP_COUNT=$((SKIP_COUNT + 1))
            continue
        fi

        echo "[$tool] -> $(tool_base "$tool")"
        if [[ "$ACTION" == "unlink" ]]; then
            if [[ ! -d "$src_dir" ]]; then
                echo "  [!] Source dir missing; removing by destination names only"
            fi
            unlink_subdirs "$tool"
            unlink_root_files "$tool"
        else
            link_subdirs "$tool"
            link_root_files "$tool"
        fi
        echo ""
    done

    echo "=========================================="
    echo "Summary ($ACTION)"
    echo "=========================================="
    if [[ "$ACTION" == "unlink" ]]; then
        echo "Removed: $REMOVE_COUNT"
    else
        echo "Created: $LINK_COUNT"
    fi
    echo "Skipped: $SKIP_COUNT"
    echo "Errors:  $ERROR_COUNT"
    echo ""
    if $DRY_RUN; then
        echo "This was a dry-run. Run without --dry-run to apply changes."
    elif [[ $ERROR_COUNT -eq 0 ]]; then
        echo "[OK] Done."
    fi
}

main "$@"
