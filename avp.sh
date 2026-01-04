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
    
    # Get the absolute path of the current extracted folder
    LOCAL_ROOT="$(pwd)"
    
    echo "--- Setting Local Paths ---"
    echo "Using libs from: $LOCAL_ROOT"
    
    # Based on your tree output:
    # 1. 'lib/pkgconfig' is where the .pc files are
    export PKG_CONFIG_PATH="$LOCAL_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH"
    
    # 2. 'lib' contains the compiled .so files
    export LD_LIBRARY_PATH="$LOCAL_ROOT/lib:$LD_LIBRARY_PATH"
    
    # 3. Explicitly tell C compiler where to find headers and libraries
    export CFLAGS="-I$LOCAL_ROOT/include"
    export LDFLAGS="-L$LOCAL_ROOT/lib"

    echo "🚀 Compiling PyAV..."
    # Install using the local files defined above
    pip install .
    
    echo "✅ Done."
else
    echo "Error: Folder '$DIRNAME' not found."
    exit 1
fi
