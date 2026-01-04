#!/bin/bash

# Configuration
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- 1. CHECK: Is it already installed? (Saves time on Vercel) ---
if pip show av >/dev/null 2>&1; then
    echo "✅ [CACHE HIT] 'av' is already installed. Skipping everything."
    exit 0
fi

# --- 2. DOWNLOAD & EXTRACT ---
if [ ! -d "$DIRNAME" ]; then
    echo "--- Downloading custom PyAV archive ---"
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
    echo "--- Extracting ---"
    chmod 755 "$FILENAME"
    tar -xf "$FILENAME"
fi

# --- 3. CONFIGURE PATHS DIRECTLY ---
# We calculate the absolute path to the extracted folder
PYAV_ROOT="$(pwd)/$DIRNAME"

# Based on your previous script, the included files are here:
FFMPEG_LOCAL="$PYAV_ROOT/vendor/build/ffmpeg-8.0"

echo "--- Pointing to local 'lib' and 'include' ---"
echo "Root: $FFMPEG_LOCAL"

# This is the MAGIC part. 
# By setting PKG_CONFIG_PATH to your local folder, 
# PyAV will find the 'include' and 'lib' folders there and WON'T download FFmpeg.
export PKG_CONFIG_PATH="$FFMPEG_LOCAL/lib/pkgconfig:$PKG_CONFIG_PATH"

# Also set library paths so the compiler finds them
export LD_LIBRARY_PATH="$FFMPEG_LOCAL/lib:$LD_LIBRARY_PATH"
export CFLAGS="-I$FFMPEG_LOCAL/include"
export LDFLAGS="-L$FFMPEG_LOCAL/lib"

# --- 4. INSTALL ---
if [ -d "$DIRNAME" ]; then
    cd "$DIRNAME" || return
    echo "🚀 Compiling PyAV using local files..."
    
    # Install directly. It will use the env vars exported above.
    pip install .
