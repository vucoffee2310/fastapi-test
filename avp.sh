#!/bin/bash

# Configuration
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- 1. PREVENT DOUBLE INSTALL (Saves 2 mins) ---
if pip show av >/dev/null 2>&1; then
    echo "✅ [CACHE HIT] 'av' is already installed. Skipping build."
    exit 0
fi

# --- 2. DOWNLOAD & EXTRACT ---
echo "--- Downloading & Extracting ---"
# Only download if not already extracted
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
    chmod 755 "$FILENAME"
    tar -xf "$FILENAME"
else
    echo "Folder '$DIRNAME' already exists."
fi

# --- 3. SET VARIABLES DIRECTLY (No 'source' needed) ---
# We calculate absolute path to the extracted folder
REPO_DIR="$(pwd)/$DIRNAME"
FFMPEG_DIR="$REPO_DIR/vendor/build/ffmpeg-8.0"

echo "--- Setting Environment Variables ---"
echo "Target FFMPEG: $FFMPEG_DIR"

# These are the exact values 'activate.sh' would have set
export PYAV_ROOT="$REPO_DIR"
export PYAV_LIBRARY="ffmpeg-8.0"
export PYAV_LIBRARY_PREFIX="$FFMPEG_DIR"

# Crucial paths for the c
