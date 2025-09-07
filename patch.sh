
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    printf "\033[1;31m[ERROR]\033[0m This script must be run as root. Please use: sudo $0\n"
    exit 1
fi

REPO_TML_DIR="$(cd "$(dirname "$0")" && pwd)/tModLoader"
DEFAULT_TML="$HOME/Library/Application Support/Steam/steamapps/common/tModLoader"

if [ -d "$DEFAULT_TML" ]; then
    TML_PATH="$DEFAULT_TML"
else
    read -e -p $'\033[1;33m[INPUT]\033[0m Enter the path to your tModLoader installation: ' TML_PATH
    if [ ! -d "$TML_PATH" ]; then
    printf "\033[1;31m[ERROR]\033[0m tModLoader path not found: %s\n" "$TML_PATH"
        exit 1
    fi
fi

BACKUP_DIR="$TML_PATH/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/tModLoader_backup_$TIMESTAMP"
printf "\033[1;36m[BACKUP]\033[0m Creating backup...\n"
cp -a "$TML_PATH" "$BACKUP_PATH"


printf "\033[1;36m[ACTION]\033[0m Removing 'dotnet' folder...\n"
rm -rf "$TML_PATH/dotnet"

printf "\033[1;36m[ACTION]\033[0m Setting up libraries...\n"
STEAM_API_ARM_SDL2_DIR="$TML_PATH/Libraries/Native/OSX-arm64/sdl2"
STEAM_API_ARM_SDL3_DIR="$TML_PATH/Libraries/Native/OSX-arm64/sdl3"
STEAM_API_X86_SDL2_DIR="$TML_PATH/Libraries/Native/OSX/sdl2"
STEAM_API_X86_SDL3_DIR="$TML_PATH/Libraries/Native/OSX/sdl3"
STEAM_API_ARM_DIR="$TML_PATH/Libraries/Native/OSX-arm64"
STEAM_API_DIR="$TML_PATH/Libraries/Native/OSX"

mkdir -p "$STEAM_API_ARM_SDL2_DIR"
mkdir -p "$STEAM_API_ARM_SDL3_DIR"
mkdir -p "$STEAM_API_X86_SDL2_DIR"
mkdir -p "$STEAM_API_X86_SDL3_DIR"
mkdir -p "$STEAM_API_ARM_DIR"

if [ -f "$STEAM_API_DIR/libsteam_api64.dylib" ]; then
    cp "$STEAM_API_DIR/libsteam_api64.dylib" "$STEAM_API_ARM_DIR/libsteam_api64.dylib" 2>/dev/null || true
    cp "$STEAM_API_DIR/libsteam_api64.dylib" "$STEAM_API_ARM_SDL2_DIR/libsteam_api64.dylib" 2>/dev/null || true
    cp "$STEAM_API_DIR/libsteam_api64.dylib" "$STEAM_API_ARM_SDL3_DIR/libsteam_api64.dylib" 2>/dev/null || true
    cp "$STEAM_API_DIR/libsteam_api64.dylib" "$STEAM_API_X86_SDL2_DIR/libsteam_api64.dylib" 2>/dev/null || true
    cp "$STEAM_API_DIR/libsteam_api64.dylib" "$STEAM_API_X86_SDL3_DIR/libsteam_api64.dylib" 2>/dev/null || true
else
    printf "\033[1;33m[WARNING]\033[0m Steam API library not found, skipping Steam API setup\n"
fi

printf "\033[1;36m[ACTION]\033[0m Patching tModLoader...\n"
cp -a "$REPO_TML_DIR/." "$TML_PATH/"

find "$TML_PATH" -name "*.dylib" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null
SDL_ARM64_SDL2_DIR="$TML_PATH/Libraries/Native/OSX-arm64/sdl2"
SDL_ARM64_SDL3_DIR="$TML_PATH/Libraries/Native/OSX-arm64/sdl3"
SDL_X86_SDL2_DIR="$TML_PATH/Libraries/Native/OSX/sdl2"
SDL_X86_SDL3_DIR="$TML_PATH/Libraries/Native/OSX/sdl3"

mkdir -p "$SDL_ARM64_SDL2_DIR"
mkdir -p "$SDL_ARM64_SDL3_DIR"
mkdir -p "$SDL_X86_SDL2_DIR"
mkdir -p "$SDL_X86_SDL3_DIR"

for SDL_DIR in "$SDL_ARM64_SDL2_DIR" "$SDL_ARM64_SDL3_DIR" "$SDL_X86_SDL2_DIR" "$SDL_X86_SDL3_DIR"; do
    if [ -f "$SDL_DIR/libSDL2-2.0.0.dylib" ]; then
        ln -sf "libSDL2-2.0.0.dylib" "$SDL_DIR/libSDL2.dylib"
    fi
done

SDL_DIR="$TML_PATH/Libraries/Native/OSX-arm64"
if [ -f "$SDL_DIR/libSDL2-2.0.0.dylib" ]; then
    ln -sf "libSDL2-2.0.0.dylib" "$SDL_DIR/libSDL2.dylib"
fi

printf "\033[1;36m[ACTION]\033[0m Verifying libraries...\n"
MISSING_LIBS=0
for SDL_DIR in "$SDL_ARM64_SDL2_DIR" "$SDL_ARM64_SDL3_DIR" "$SDL_X86_SDL2_DIR" "$SDL_X86_SDL3_DIR"; do
    if [ ! -f "$SDL_DIR/libSDL2-2.0.0.dylib" ]; then
        SDL_TYPE=$(basename "$SDL_DIR")
        if [[ "$SDL_DIR" == *"arm64"* ]]; then
            DIR_ARCH="arm64"
        else
            DIR_ARCH="x86_64"
        fi
        printf "\033[1;31m[WARNING]\033[0m Missing SDL2 library in %s/%s\n" "$DIR_ARCH" "$SDL_TYPE"
        MISSING_LIBS=1
    fi
done

for SDL3_DIR in "$SDL_ARM64_SDL3_DIR" "$SDL_X86_SDL3_DIR"; do
    if [ ! -f "$SDL3_DIR/libSDL3.dylib" ]; then
        if [[ "$SDL3_DIR" == *"arm64"* ]]; then
            DIR_ARCH="arm64"
        else
            DIR_ARCH="x86_64"
        fi
        printf "\033[1;31m[WARNING]\033[0m Missing SDL3 library in %s/sdl3\n" "$DIR_ARCH"
        MISSING_LIBS=1
    fi
done

printf "\033[1;32m[SUCCESS]\033[0m Patch complete.\n"