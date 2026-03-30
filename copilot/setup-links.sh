#!/usr/bin/env bash
# setup-links.sh - Symlink VSCode Copilot configuration
#
# - agents/, instructions/, skills/ → ~/.copilot/
# - prompts/ → ~/Library/Application Support/Code/User/prompts/ (macOS only)
#
# Usage:
#   ./setup-links.sh [--dry-run] [--force] [--source <path>]
#
# Options:
#   --dry-run    Show what would be created without making changes
#   --force      Backup existing files/folders and create symlinks
#   --source     Override the source path (default: auto-detect)
#   --help       Show this help message

set -euo pipefail

# Configuration
SOURCE_DIR=""  # Will be set dynamically
TARGET_BASE="$HOME/.copilot"
SUBDIRS=("agents" "instructions" "prompts" "skills")
PROMPTS_SUBDIR="prompts"
# Special file that goes directly in TARGET_BASE
GLOBAL_INSTRUCTIONS="copilot-instructions.md"

# Script directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
DRY_RUN=false
FORCE=false
HELP=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            HELP=true
            shift
            ;;
    esac
done

# Show help and exit
if $HELP; then
    sed -n '4,11p' "$0" | sed -e 's/^# //' -e '/^#$/d'
    exit 0
fi

# Detect source directory
detect_source() {
    if [[ -n "$SOURCE_DIR" ]]; then
        echo "$SOURCE_DIR"
        return 0
    fi

    # Try to find ai.conf repo (flat structure under copilot/)
    local candidates=(
        "$SCRIPT_DIR"                        # Relative to script (flat structure)
        "$SCRIPT_DIR/.."                     # Parent directory
        "$HOME/projects/ai.conf/copilot"     # Standard location
        "$HOME/ai.conf/copilot"             # Alternative location
    )

    for candidate in "${candidates[@]}"; do
        if [[ -d "$candidate/agents" ]] || [[ -d "$candidate/instructions" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    # Fallback: use script location
    if [[ -d "$SCRIPT_DIR/agents" ]]; then
        echo "$SCRIPT_DIR"
        return 0
    fi

    echo "ERROR: Could not detect source directory. Use --source to specify." >&2
    exit 1
}

# Detect VS Code profile prompts directory (macOS only)
detect_vscode_profile() {
    local vscode_prompts_dir="$HOME/Library/Application Support/Code/User/prompts"

    if [[ "$(uname)" != "Darwin" ]]; then
        echo ""
        echo "[WARNING] Prompts linking is only supported on macOS." >&2
        echo "          On other platforms, use VSCode Profile import instead." >&2
        return 1
    fi

    if [[ ! -d "$HOME/Library/Application Support/Code/User" ]]; then
        echo ""
        echo "[WARNING] VS Code profile directory not found." >&2
        echo "          On other platforms, use VSCode Profile import instead." >&2
        return 1
    fi

    echo "$vscode_prompts_dir"
    return 0
}

# Check if path is a symlink
is_symlink() {
    [[ -L "$1" ]]
}

# Check if path exists (file or directory)
exists() {
    [[ -e "$1" ]]
}

# Create backup of existing file/directory
backup() {
    local path="$1"
    local backup_path="${path}.backup.$(date +%Y%m%d_%H%M%S)"
    if $DRY_RUN; then
        echo "  [dry-run] Would backup: $path → $backup_path"
    else
        mv "$path" "$backup_path"
        echo "  Backed up: $path -> $backup_path"
    fi
}

# Create symlink
create_link() {
    local source="$1"
    local target="$2"
    local target_dir
    target_dir="$(dirname "$target")"

    if $DRY_RUN; then
        echo "  [dry-run] Would create: $target → $source"
    else
        mkdir -p "$target_dir"
        ln -sfn "$source" "$target"
        echo "  Created: $target -> $source"
    fi
}

# Main execution
main() {
    local source_base
    source_base="$(detect_source)"

    echo "=========================================="
    echo "VSCode Copilot - Setup Symlinks"
    echo "=========================================="
    echo ""
    echo "Source:  $source_base"
    echo "Target:  $TARGET_BASE"
    echo "Mode:    $(if $DRY_RUN; then echo "DRY-RUN"; else echo "NORMAL"; fi)$(if $FORCE; then echo " (force)"; fi)"
    echo ""

    # Validate source exists
    if [[ ! -d "$source_base" ]]; then
        echo "ERROR: Source directory not found: $source_base" >&2
        exit 1
    fi

    # Check each subdirectory
    local link_count=0
    local skip_count=0
    local error_count=0

    for subdir in "${SUBDIRS[@]}"; do
        # Skip prompts - handled separately for VSCode profile
        if [[ "$subdir" == "$PROMPTS_SUBDIR" ]]; then
            continue
        fi

        local source_path="$source_base/$subdir"
        local target_path="$TARGET_BASE/$subdir"

        if [[ ! -d "$source_path" ]]; then
            echo "[-] Skipping $subdir: source not found"
            continue
        fi

        echo "[$subdir]"

        # Remove existing symlink if present
        if is_symlink "$target_path"; then
            local current_target
            current_target="$(readlink "$target_path")"
            if [[ "$current_target" != "$source_path" ]]; then
                echo "  [~] Updating existing link..."
                rm "$target_path"
                create_link "$source_path" "$target_path"
                ((link_count++))
            else
                echo "  [OK] Already linked correctly: $target_path -> $source_path"
                ((skip_count++))
            fi
        elif exists "$target_path"; then
            if $FORCE; then
                # Force: backup and replace
                echo "  [*] Exists as real directory, backing up..."
                backup "$target_path"
                create_link "$source_path" "$target_path"
                ((link_count++))
            else
                # No force: skip
                echo "  [-] Exists as real directory (use --force to replace)"
                ((skip_count++))
            fi
        else
            # Target doesn't exist, create link
            create_link "$source_path" "$target_path"
            ((link_count++))
        fi
    done

    # Handle prompts separately (VSCode profile on macOS only)
    local source_prompts="$source_base/$PROMPTS_SUBDIR"
    if [[ -d "$source_prompts" ]]; then
        local vscode_prompts_dir
        if vscode_prompts_dir="$(detect_vscode_profile)"; then
            echo "[$PROMPTS_SUBDIR] (VSCode profile)"

            if is_symlink "$vscode_prompts_dir"; then
                local current_target
                current_target="$(readlink "$vscode_prompts_dir")"
                if [[ "$current_target" != "$source_prompts" ]]; then
                    echo "  [~] Updating existing link..."
                    rm "$vscode_prompts_dir"
                    create_link "$source_prompts" "$vscode_prompts_dir"
                    ((link_count++))
                else
                    echo "  [OK] Already linked correctly: $vscode_prompts_dir -> $source_prompts"
                    ((skip_count++))
                fi
            elif exists "$vscode_prompts_dir"; then
                if $FORCE; then
                    echo "  [*] Exists as real directory, backing up..."
                    backup "$vscode_prompts_dir"
                    create_link "$source_prompts" "$vscode_prompts_dir"
                    ((link_count++))
                else
                    echo "  [-] Exists as real directory (use --force to replace)"
                    ((skip_count++))
                fi
            else
                create_link "$source_prompts" "$vscode_prompts_dir"
                ((link_count++))
            fi
        else
            # Non-macOS or VSCode not found - skip prompts
            echo "[$PROMPTS_SUBDIR]"
            echo "  [-] Skipped (macOS/VSCode profile required)"
            ((skip_count++))
        fi
    fi

    # Handle global instructions file (copilot-instructions.md)
    local source_instructions="$source_base/$GLOBAL_INSTRUCTIONS"
    local target_instructions="$TARGET_BASE/$GLOBAL_INSTRUCTIONS"

    if [[ -f "$source_instructions" ]]; then
        echo "[$GLOBAL_INSTRUCTIONS]"

        if is_symlink "$target_instructions"; then
            # Symlink exists - check if it points to correct source
            local current_target
            current_target="$(readlink "$target_instructions")"
            # Normalize both paths for comparison
            local current_real
            current_real="$(cd "$(dirname "$target_instructions")" && cd -P . && pwd)/$(basename "$current_target")"
            local source_real
            source_real="$(cd "$source_base" && pwd)/$GLOBAL_INSTRUCTIONS"
            
            if [[ "$current_real" != "$source_real" ]]; then
                echo "  [~] Updating existing link..."
                rm "$target_instructions"
                create_link "$source_instructions" "$target_instructions"
                ((link_count++))
            else
                echo "  [OK] Already linked correctly"
                ((skip_count++))
            fi
        elif exists "$target_instructions"; then
            if $FORCE; then
                # Force: backup and replace
                echo "  [*] Exists as real file, backing up..."
                backup "$target_instructions"
                create_link "$source_instructions" "$target_instructions"
                ((link_count++))
            else
                # No force: skip
                echo "  [-] Exists as real file (use --force to replace)"
                ((skip_count++))
            fi
        else
            # Target doesn't exist
            create_link "$source_instructions" "$target_instructions"
            ((link_count++))
        fi
    fi

    echo ""
    echo "=========================================="
    echo "Summary"
    echo "=========================================="
    echo "Created: $link_count"
    echo "Skipped: $skip_count"
    echo "Errors:  $error_count"
    echo ""

    if $DRY_RUN; then
        echo "This was a dry-run. Run without --dry-run to apply changes."
    elif [[ $error_count -eq 0 ]]; then
        echo "[OK] Setup complete! Restart VSCode to apply changes."
    else
        echo "[!!] Setup completed with errors."
        exit 1
    fi
}

main
