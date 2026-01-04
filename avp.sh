#!/bin/bash

# Configuration
URL="https://github.com/vucoffee2310/youtubedownloader/releases/download/pyav-custom/pyav-custom.tar.gz"
FILENAME="pyav-custom.tar.gz"
DIRNAME="pyav"

# --- 0. INSTALL BUILD DEPENDENCIES ---
# PyAV requires Cython to build from source
echo "📦 Installing build dependencies..."
pip install cython wheel setuptools

# --- 1. PREVENT DOUBLE INSTALL ---
if [ -d "$DIRNAME/lib" ] && pip show av >/dev/null 2>&1; then
    echo "✅ [CACHE HIT] 'av' is installed and libs exist. Skipping build."
    exit 0
fi

# --- 2. DOWNLOAD & EXTRACT ---
if [ ! -d "$DIRNAME" ]; then
    echo "⬇️ Downloading custom PyAV archive..."
    if [ ! -f "$FILENAME" ]; then
        curl -L -o "$FILENAME" "$URL"
    fi
    echo "📦 Extracting..."
    tar -xf "$FILENAME"
fi

# --- 3. CONFIGURE, MAKE, & INSTALL ---
if [ -d "$DIRNAME" ]; then
    cd "$DIRNAME" || exit 1
    LOCAL_ROOT="$(pwd)"
    
    echo "⚙️ Setting Build Paths..."
    export PKG_CONFIG_PATH="$LOCAL_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="$LOCAL_ROOT/lib:$LD_LIBRARY_PATH"
    export CFLAGS="-I$LOCAL_ROOT/include"
    
    # CRITICAL: Add rpath so the binary remembers where to find libs relative to itself
    # \$ORIGIN is a special linker token.
    export LDFLAGS="-L$LOCAL_ROOT/lib -Wl,-rpath,'$LOCAL_ROOT/lib'"

    echo "🔨 Running 'make' (if Makefile exists)..."
    make || echo "⚠️ Make skipped or failed (proceeding to pip)..."

    echo "🚀 Running 'pip install .'..."
    # -v gives verbose output so you can see compilation errors in Vercel logs
    pip install . -v 
    INSTALL_STATUS=$?

    cd ..

    # --- 4. CLEANUP ---
    if [ $INSTALL_STATUS -eq 0 ]; then
        echo "✅ Installation successful."
        # Clean up heavy folders, BUT KEEP 'lib'
        rm -rf "$DIRNAME/include" "$DIRNAME/src" "$DIRNAME/examples" "$DIRNAME/docs" "$FILENAME"
    else
        echo "❌ Installation failed."
        exit 1
    fi

else
    echo "❌ Error: Folder '$DIRNAME' not found."
    exit 1
fi
