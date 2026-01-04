#!/bin/bash

# --- Configuration ---
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- 1. IDEMPOTENCY CHECK (Fixes Vercel Double Install) ---
# If 'av' is already installed, stop here.
if pip show av >/dev/null 2>&1; then
    echo "✅ [CACHE HIT] 'av' is already installed. Skipping build."
    exit 0
fi

# --- 2. Download and Extract ---
if [ ! -d "$DIRNAME" ]; then
    echo "--- Downloading ---"
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

# --- 3. Set Environment Variables (Replaces activate.sh) ---
echo "--- Configuring Environment ---"

# Get the absolute path to the 'pyav' directory
CURRENT_DIR="$(pwd)"
export PYAV_ROOT="$CURRENT_DIR/$DIRNAME"

# Default library version found in your script
PYAV_LIBRARY="ffmpeg-8.0"

# Construct the paths to the embedded vendor libraries
# Based on: $PYAV_ROOT/vendor/build/$PYAV_LIBRARY
PYAV_LIBRARY_PREFIX="$PYAV_ROOT/vendor/build/$PYAV_LIBRARY"

# Export these so 'pip install' can see the custom ffmpeg
export PATH="$PYAV_LIBRARY_PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PYAV_LIBRARY_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$PYAV_LIBRARY_PREFIX/lib:$LD_LIBRARY_PATH"

# --- 4. Install ---
echo "--- Installing ---"
if [ -d "$DIRNAME" ]; then
    cd "$DIRNAME" || exit 1
    
    # Run install
    pip install .
    
    echo "Done."
else
    echo "Error: Directory $DIRNAME not found."
    exit 1
fi
