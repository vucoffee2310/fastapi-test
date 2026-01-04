from fastapi import FastAPI
from fastapi.responses import JSONResponse
import sys
import os
import ctypes
import glob

# --- 1. PRE-LOAD SHARED LIBRARIES ---
# Vercel Runtime Hack: Manually load FFmpeg libs from the local folder
# because LD_LIBRARY_PATH from build step is lost.
def load_custom_libraries():
    # Helper to find the absolute path
    cwd = os.getcwd()
    lib_path = os.path.join(cwd, "pyav", "lib")
    
    print(f"Checking for libs in: {lib_path}") # Logs to Vercel dashboard

    if os.path.exists(lib_path):
        # Order matters! avutil usually needs to be first.
        # We try to load all .so files in the directory.
        libs = sorted(glob.glob(os.path.join(lib_path, "*.so*")))
        
        # Specific order helps dependency resolution
        priority_libs = ['avutil', 'swresample', 'avcodec', 'avformat', 'avdevice', 'avfilter']
        
        sorted_libs = []
        # Add priority libs first
        for name in priority_libs:
            for lib in libs:
                if name in os.path.basename(lib):
                    sorted_libs.append(lib)
        
        # Add the rest
        for lib in libs:
            if lib not in sorted_libs:
                sorted_libs.append(lib)

        for lib in sorted_libs:
            try:
                # RTLD_GLOBAL allows subsequent libraries (and 'av') to see symbols
                ctypes.CDLL(lib, mode=ctypes.RTLD_GLOBAL)
                print(f"Loaded: {os.path.basename(lib)}")
            except OSError as e:
                print(f"Failed to load {os.path.basename(lib)}: {e}")

# Execute load before App starts
load_custom_libraries()

app = FastAPI()

@app.get("/")
async def root():
    """Check if PyAV is installed"""
    try:
        # Import inside function to prevent app crash if import fails
        import av
        pyav_version = av.__version__
        return JSONResponse(
            content={
                "status": "success",
                "pyav_installed": True,
                "pyav_version": pyav_version,
                "message": "PyAV is successfully installed!",
                "ffmpeg_dir": os.path.join(os.getcwd(), "pyav", "lib")
            },
            status_code=200
        )
    except ImportError as e:
        return JSONResponse(
            content={
                "status": "error",
                "pyav_installed": False,
                "error": str(e),
                "message": "PyAV is NOT installed. Check logs for library loading errors.",
                "python_version": sys.version
            },
            status_code=200
        )

@app.get("/health")
async def health():
    return {"status": "healthy"}
