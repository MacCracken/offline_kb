#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="/data"
ZIM_DIR="$DATA_DIR/zim"
PDF_DIR="$DATA_DIR/pdfs"
KIWIX_PORT="${KIWIX_PORT:-8888}"
PORTAL_PORT="${PORTAL_PORT:-8080}"

mkdir -p "$ZIM_DIR" "$PDF_DIR" "$DATA_DIR/other"

# Copy landing page and nginx config into place
cp /app/index.html "$DATA_DIR/index.html" 2>/dev/null || true
sed -i "s|KIWIX_PORT_PLACEHOLDER|$KIWIX_PORT|g" "$DATA_DIR/index.html"

# Start nginx for the portal landing page
sed -i "s|PORTAL_PORT|$PORTAL_PORT|g" /etc/nginx/nginx.conf
sed -i "s|DATA_DIR|$DATA_DIR|g" /etc/nginx/nginx.conf
nginx

# Check for ZIM files
ZIM_FILES=("$ZIM_DIR"/*.zim 2>/dev/null) || true

if [ ${#ZIM_FILES[@]} -eq 0 ] || [ ! -f "${ZIM_FILES[0]}" ]; then
    echo "============================================="
    echo "  No ZIM files found in $ZIM_DIR"
    echo ""
    echo "  To download content, run:"
    echo "    docker exec -it offline-kb /app/setup.sh /data"
    echo ""
    echo "  Or download ZIM files manually from:"
    echo "    https://library.kiwix.org"
    echo "  and place them in the ./data/zim/ directory."
    echo ""
    echo "  Portal is running at http://localhost:$PORTAL_PORT"
    echo "  Waiting for ZIM files..."
    echo "============================================="

    # Wait for ZIM files to appear, then start kiwix-serve
    while true; do
        ZIM_FILES=("$ZIM_DIR"/*.zim 2>/dev/null) || true
        if [ ${#ZIM_FILES[@]} -gt 0 ] && [ -f "${ZIM_FILES[0]}" ]; then
            echo "ZIM files detected, starting kiwix-serve..."
            break
        fi
        sleep 5
    done
fi

echo "Starting kiwix-serve on port $KIWIX_PORT..."
echo "  Portal:  http://localhost:$PORTAL_PORT"
echo "  Kiwix:   http://localhost:$KIWIX_PORT"

exec kiwix-serve --port "$KIWIX_PORT" "$ZIM_DIR"/*.zim
