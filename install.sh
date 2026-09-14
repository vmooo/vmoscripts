#!/usr/bin/env bash
#
# install_bin.sh — expose all Bash and Python scripts from ./bin
# (recursively) as commands callable by name.
#
# Namespacing: subdirectories are joined with "-".
#   bin/learning/trainer.py  -> learning-trainer
#   bin/misc.py              -> misc
#
set -euo pipefail

SRC_DIR="bin"
DEST_DIR="${HOME}/.local/bin"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ ! -d "$SRC_DIR" ]]; then
    echo -e "${RED}Error: directory '$SRC_DIR' not found.${NC}" >&2
    exit 1
fi

mkdir -p "$DEST_DIR"

SRC_ABS="$(cd "$SRC_DIR" && pwd)"

shopt -s nullglob

installed=0
skipped=0
declare -A seen_names=()

# Recurse into all files under bin/.
while IFS= read -r -d '' file; do
    [[ -f "$file" ]] || continue

    # Path relative to bin/ (e.g. "learning/trainer.py").
    rel="${file#"$SRC_ABS"/}"

    name="$(basename "$rel")"
    dir="$(dirname "$rel")"

    # Decide whether the file is a script we care about.
    is_script=0
    base=""

    case "$name" in
        *.sh|*.bash)
            is_script=1
            base="${name%.*}"
            ;;
        *.py)
            is_script=1
            base="${name%.*}"
            ;;
        *)
            if head -n1 "$file" 2>/dev/null | grep -qE '^#!.*(bash|sh|python)'; then
                is_script=1
                base="$name"
            fi
            ;;
    esac

    if (( is_script == 0 )); then
        skipped=$((skipped + 1))
        continue
    fi

    # Build the command name: replace "/" with "-".
    if [[ "$dir" == "." ]]; then
        cmd_name="$base"
    else
        cmd_name="${dir//\//-}-${base}"
    fi

    # Detect collisions (same command name from two different sources).
    if [[ -n "${seen_names[$cmd_name]:-}" && "${seen_names[$cmd_name]}" != "$file" ]]; then
        echo -e "${YELLOW}collision${NC}  '$cmd_name' already linked to '${seen_names[$cmd_name]}'; skipping '$file'" >&2
        skipped=$((skipped + 1))
        continue
    fi
    seen_names["$cmd_name"]="$file"

    chmod +x "$file"

    link="$DEST_DIR/$cmd_name"
    if [[ -e "$link" || -L "$link" ]]; then
        rm -f "$link"
    fi

    ln -s "$file" "$link"
    echo -e "${GREEN}linked${NC}  ${CYAN}${cmd_name}${NC} -> $rel"
    installed=$((installed + 1))

done < <(find "$SRC_ABS" -type f -print0)

echo
echo -e "${GREEN}Installed:${NC} $installed   ${YELLOW}Skipped:${NC} $skipped"
echo "Symlinks location: $DEST_DIR"

if ! echo ":$PATH:" | grep -q ":$DEST_DIR:"; then
    echo
    echo -e "${YELLOW}Warning:${NC} $DEST_DIR is not in your PATH."
    echo "Add this line to your ~/.bashrc (or ~/.zshrc):"
    echo
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi