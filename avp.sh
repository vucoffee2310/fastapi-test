#!/bin/bash

# Configuration
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- 1. PREVENT DOUBLE INSTALL ---
# Check if python package is installed AND the library folder exists
if [ -d "$DIRNAME/lib" ] && pip show av >/dev/null 2>&1; then
    echo "✅ [CACHE HIT] 'av' is installed and libs exist. Skipping build."
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

# --- 3. CONFIGURE, MAKE, & INSTALL ---
if [ -d "$DIRNAME" ]; then
    cd "$DIRNAME" || return
    LOCAL_ROOT="$(pwd)"
    
    echo "--- Setting Local Paths ---"
    # Point compiler and linker to the local 'lib' and 'include' folders
    export PKG_CONFIG_PATH="$LOCAL_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="$LOCAL_ROOT/lib:$LD_LIBRARY_PATH"
    export CFLAGS="-I$LOCAL_ROOT/include"
    export LDFLAGS="-L$LOCAL_ROOT/lib"

    # --- STEP A: MAKE ---
    echo "🔨 Running 'make'..."
    if make; then
        echo "✅ Make successful."
    else
        echo "⚠️ Make failed or no Makefile found. Attempting pip install anyway..."
    fi

    # --- STEP B: PIP INSTALL ---
    echo "🚀 Running 'pip install .'..."
    pip install .
    INSTALL_STATUS=$?

    # Go back to root
    cd ..

    # --- 4. SMART CLEANUP ---
    if [ $INSTALL_STATUS -eq 0 ]; then
        echo "✅ Installation successful."
        
        echo "🧹 Cleaning up sources (keeping libs)..."
        # Remove source code and headers to save space
        rm -rf "$DIRNAME/include"
        rm -rf "$DIRNAME/src"
        rm -rf "$DIRNAME/examples"
        rm -rf "$DIRNAME/tests"
        rm -rf "$DIRNAME/docs"
        # Remove the downloaded archive
        rm -f "$FILENAME"

        # ⚠️ CRITICAL: DO NOT DELETE "$DIRNAME/lib" 
        # The app will crash if you delete this.
        
        echo "✨ Cleanup complete."
    else
        echo "❌ Installation failed."
        exit 1
    fi

else
    echo "Error: Folder '$DIRNAME' not found."
    exit 1
fi
