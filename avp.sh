#!/bin/bash

# Configuration
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- THE FIX: Stop if already installed ---
if pip show av >/dev/null 2>&1; then
    echo "✅ 'av' is already installed. Skipping installation."
    exit 0
fi
# ------------------------------------------

echo "--- 1. Downloading ---"
if [ ! -d "$DIRNAME" ]; then
    if [ ! -f "$FILENAME" ]; then
        if command -v curl >/dev/null 2>&1; then
            curl -L -o "$FILENAME" "$URL"
        elif command -v wget >/dev/null 2>&1; then
            wget -O "$FILENAME" "$URL"
        else
            echo "Error: Need curl or wget."
            exit 1
        fi
    fi

    echo "--- 2. Extracting ---"
    chmod 755 "$FILENAME"
    tar -xf "$FILENAME"
fi

echo "--- 3. Setup and Install ---"
if [ -d "$DIRNAME" ]; then
    cd "$DIRNAME" || return
    
    # Source the environment variables
    if [ -f "scripts/activate.sh" ]; then
        source scripts/activate.sh
    fi

    echo "🚀 Compiling and Installing (This takes ~2 mins)..."
    pip install .
else
    echo "Error: Folder '$DIRNAME' not found."
    exit 1
fi
