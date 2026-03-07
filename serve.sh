#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# Offline Knowledge Base - Serve Script
# Starts kiwix-serve for all ZIM files in the target directory
# Usage: ./serve.sh [/path/to/content-dir] [--port PORT]
# ---------------------------------------------------------------

# If called from the SSD itself, use the script's directory as default
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$SCRIPT_DIR}"
PORT=8888

# Parse optional --port flag
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port) PORT="$2"; shift 2 ;;
        *) TARGET="$1"; shift ;;
    esac
done

ZIM_DIR="$TARGET/zim"

if [ ! -d "$ZIM_DIR" ]; then
    echo "Error: ZIM directory not found at $ZIM_DIR"
    echo "Usage: $0 [/path/to/content-dir] [--port PORT]"
    exit 1
fi

# Collect all .zim files
ZIM_FILES=("$ZIM_DIR"/*.zim)

if [ ${#ZIM_FILES[@]} -eq 0 ] || [ ! -f "${ZIM_FILES[0]}" ]; then
    echo "No .zim files found in $ZIM_DIR"
    echo "Run setup.sh first to download content."
    exit 1
fi

if ! command -v kiwix-serve &>/dev/null; then
    echo "Error: kiwix-serve not found."
    echo "Install kiwix-tools:"
    echo "  Arch:   pacman -S kiwix-tools"
    echo "  Debian: apt install kiwix-tools"
    echo "  macOS:  brew install kiwix-tools"
    exit 1
fi

echo "Starting offline knowledge base..."
echo "  Content: $ZIM_DIR (${#ZIM_FILES[@]} ZIM files)"
echo "  URL:     http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop."
echo ""

exec kiwix-serve --port "$PORT" "${ZIM_FILES[@]}"
