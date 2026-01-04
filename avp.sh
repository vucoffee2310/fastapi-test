#!/bin/bash

# Configuration
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- 1. PREVENT DOUBLE INSTALL ---
if pip show av >/dev/null 2>&1; then
    echo "✅ [CACHE HIT] 'av' is already installed. Skipping."
    exit 0
fi

# --- 2. DOWNLOAD & EXTRACT ---
# Only proceed if the directory doesn't exist yet
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

# --- 3. CONFIGURE & INSTALL ---
if [ -d "$DIRNAME" ]; then
    cd "$DIRNAME" || return
    
    # Get absolute path of the extracted folder
    LOCAL_ROOT="$(pwd)"
    
    echo "--- Setting Local Paths ---"
    echo "Root: $LOCAL_ROOT"
    
    # Point directly to the 'lib' and 'include' folders at the root of the extracted archive
    export PKG_CONFIG_PATH="$LOCAL_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="$LOCAL_ROOT/lib:$LD_LIBRARY_PATH"
    export CFLAGS="-I$LOCAL_ROOT/include"
    export LDFLAGS="-L$LOCAL_ROOT/lib"

    echo "🚀 Compiling PyAV..."
    # Install the package
    pip install .
    
    # Capture the result of the installation
    INSTALL_STATUS=$?

    # Move back to the parent directory so we can delete the folder
    cd ..

    # --- 4. CLEANUP ---
    if [ $INSTALL_STATUS -eq 0 ]; then
        echo "✅ Installation successful."
        echo "🧹 Cleaning up source files and archive..."
        rm -rf "$DIRNAME"
        rm -f "$FILENAME"
        echo "✨ Cleanup complete."
    else
        echo "❌ Installation failed. Files preserved for debugging."
        exit 1
    fi

else
    echo "Error: Folder '$DIRNAME' not found."
    exit 1
fi
