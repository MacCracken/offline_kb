#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# Offline Knowledge Base - Setup Script
# Downloads content defined in content.yaml to a target directory
# Usage: ./setup.sh /path/to/ssd
# ---------------------------------------------------------------

TARGET="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTENT_FILE="$SCRIPT_DIR/content.yaml"
KIWIX_DOWNLOAD_BASE="https://download.kiwix.org/zim"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 /path/to/ssd"
    echo ""
    echo "  Downloads offline content to the specified directory."
    echo "  Edit content.yaml to choose what to include."
    exit 1
fi

# -- helpers -----------------------------------------------------

info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

check_deps() {
    local missing=()
    for cmd in curl python3; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing dependencies: ${missing[*]}. Install them and retry."
    fi
}

install_kiwix_tools() {
    if command -v kiwix-serve &>/dev/null; then
        info "kiwix-tools already installed."
        return
    fi

    info "Installing kiwix-tools..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm kiwix-tools
    elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y kiwix-tools
    elif command -v brew &>/dev/null; then
        brew install kiwix-tools
    else
        warn "Could not auto-install kiwix-tools. Install manually:"
        warn "  https://kiwix.org/en/downloads/kiwix-tools/"
        warn "Continuing without kiwix-tools (ZIM files will still download)."
    fi
}

# Parse content.yaml with a small Python helper (avoids yq/jq dependency)
parse_content() {
    python3 "$SCRIPT_DIR/parse_content.py" "$CONTENT_FILE"
}

download_zim() {
    local name="$1" zim_prefix="$2" base_url="$3" dest_dir="$4"

    mkdir -p "$dest_dir"

    info "Looking up latest ZIM for: $name ($zim_prefix)"

    # Get the directory listing and find the latest matching file
    local listing
    listing=$(curl -sL "$base_url") || { warn "Failed to fetch listing for $name"; return 1; }

    # Extract the latest matching .zim filename
    local zim_file
    zim_file=$(echo "$listing" \
        | grep -oP "href=\"\K${zim_prefix}[^\"]*\.zim(?=\")" \
        | sort -V \
        | tail -1)

    if [ -z "$zim_file" ]; then
        warn "No ZIM file found matching '$zim_prefix' at $base_url"
        return 1
    fi

    local full_url="${base_url}${zim_file}"
    local dest_path="${dest_dir}/${zim_file}"

    if [ -f "$dest_path" ]; then
        info "Already downloaded: $zim_file (skipping)"
        return 0
    fi

    info "Downloading: $zim_file (~this may take a while)"
    curl -L -C - --progress-bar -o "$dest_path.part" "$full_url"
    mv "$dest_path.part" "$dest_path"
    info "Saved: $dest_path"
}

# -- main --------------------------------------------------------

check_deps
install_kiwix_tools

mkdir -p "$TARGET"/{zim,pdfs,other}

info "Target directory: $TARGET"
info "Parsing content manifest..."

# Read enabled ZIM entries and download them
parse_content | while IFS='|' read -r name type zim_prefix url; do
    case "$type" in
        zim)
            download_zim "$name" "$zim_prefix" "$url" "$TARGET/zim"
            ;;
        pdf)
            info "[MANUAL] $name — download from: $url"
            info "         Save to: $TARGET/pdfs/"
            ;;
        osm)
            info "[MANUAL] $name — download regional extracts from: $url"
            info "         Save to: $TARGET/other/"
            ;;
        *)
            info "[SKIP]   $name (type: $type) — manual setup required"
            ;;
    esac
done

# Copy the serve script to the SSD so it's self-contained
cp "$SCRIPT_DIR/serve.sh" "$TARGET/serve.sh"
chmod +x "$TARGET/serve.sh"

echo ""
info "========================================="
info "  Setup complete!"
info "========================================="
info ""
info "  Content saved to: $TARGET"
info ""
info "  To browse offline:"
info "    $TARGET/serve.sh"
info "    Then open http://localhost:8888"
info ""
info "  Some items require manual download (marked [MANUAL] above)."
info "========================================="
