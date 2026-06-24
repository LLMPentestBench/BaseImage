#!/bin/bash
# /usr/local/bin/docker-preload.sh
set -e

PRELOAD_DIR="/preload/images"

for tar in "$PRELOAD_DIR"/*.tar; do
    # Guard against empty directory (glob doesn't match)
    [ -f "$tar" ] || continue

    echo "Loading $tar..."
    docker load -i "$tar"
    rm -f "$tar"
    echo "Loaded and removed $tar."
done

echo "Preload complete."