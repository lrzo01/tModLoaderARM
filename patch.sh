
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    printf "\033[1;31m[ERROR]\033[0m This script must be run as root. Please use: sudo $0\n"
    exit 1
fi

REPO_TML_DIR="$(cd "$(dirname "$0")" && pwd)/tModLoader"
DEFAULT_TML="$HOME/Library/Application Support/Steam/steamapps/common/tModLoader"

if [ -d "$DEFAULT_TML" ]; then
    TML_PATH="$DEFAULT_TML"
    printf "\033[1;32m[INFO]\033[0m Found tModLoader at: \033[1;34m%s\033[0m\n" "$TML_PATH"
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
printf "\033[1;36m[BACKUP]\033[0m Creating backup at: \033[1;34m%s\033[0m\n" "$BACKUP_PATH"
cp -a "$TML_PATH" "$BACKUP_PATH"


printf "\033[1;36m[ACTION]\033[0m Removing 'dotnet' folder if it exists...\n"
rm -rf "$TML_PATH/dotnet"

printf "\033[1;36m[ACTION]\033[0m Setting up Steam API libraries...\n"
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
    printf "\033[1;36m[ACTION]\033[0m Copying Steam API dylib...\n"
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

printf "\033[1;36m[ACTION]\033[0m Removing quarantine attributes from dylib files...\n"
find "$TML_PATH" -name "*.dylib" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null

printf "\033[1;36m[ACTION]\033[0m Setting up SDL library directories...\n"
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
        printf "\033[1;36m[ACTION]\033[0m Creating symlink libSDL2.dylib -> libSDL2-2.0.0.dylib in %s\n" "$SDL_DIR"
        ln -sf "libSDL2-2.0.0.dylib" "$SDL_DIR/libSDL2.dylib"
    fi
done

SDL_DIR="$TML_PATH/Libraries/Native/OSX-arm64"
if [ -f "$SDL_DIR/libSDL2-2.0.0.dylib" ]; then
    printf "\033[1;36m[ACTION]\033[0m Creating legacy symlink libSDL2.dylib -> libSDL2-2.0.0.dylib in %s\n" "$SDL_DIR"
    ln -sf "libSDL2-2.0.0.dylib" "$SDL_DIR/libSDL2.dylib"
fi

printf "\033[1;36m[ACTION]\033[0m Verifying SDL library setup...\n"
for SDL_DIR in "$SDL_ARM64_SDL2_DIR" "$SDL_ARM64_SDL3_DIR" "$SDL_X86_SDL2_DIR" "$SDL_X86_SDL3_DIR"; do
    if [ -f "$SDL_DIR/libSDL2-2.0.0.dylib" ]; then
        ARCH=$(file "$SDL_DIR/libSDL2-2.0.0.dylib" | grep -oE "arm64|x86_64" | head -1)
        SDL_TYPE=$(basename "$SDL_DIR")
        if [[ "$SDL_DIR" == *"arm64"* ]]; then
            DIR_ARCH="arm64"
        else
            DIR_ARCH="x86_64"
        fi
        printf "\033[1;32m[OK]\033[0m Found SDL2 library (%s) in %s/%s\n" "$ARCH" "$DIR_ARCH" "$SDL_TYPE"
    else
        SDL_TYPE=$(basename "$SDL_DIR")
        if [[ "$SDL_DIR" == *"arm64"* ]]; then
            DIR_ARCH="arm64"
        else
            DIR_ARCH="x86_64"
        fi
        printf "\033[1;31m[WARNING]\033[0m Missing SDL2 library in %s/%s\n" "$DIR_ARCH" "$SDL_TYPE"
    fi
done

for SDL3_DIR in "$SDL_ARM64_SDL3_DIR" "$SDL_X86_SDL3_DIR"; do
    if [ -f "$SDL3_DIR/libSDL3.dylib" ]; then
        ARCH=$(file "$SDL3_DIR/libSDL3.dylib" | grep -oE "arm64|x86_64" | head -1)
        if [[ "$SDL3_DIR" == *"arm64"* ]]; then
            DIR_ARCH="arm64"
        else
            DIR_ARCH="x86_64"
        fi
        printf "\033[1;32m[OK]\033[0m Found SDL3 library (%s) in %s/sdl3\n" "$ARCH" "$DIR_ARCH"
    else
        if [[ "$SDL3_DIR" == *"arm64"* ]]; then
            DIR_ARCH="arm64"
        else
            DIR_ARCH="x86_64"
        fi
        printf "\033[1;31m[WARNING]\033[0m Missing SDL3 library in %s/sdl3\n" "$DIR_ARCH"
    fi
done

printf "\033[1;32m[SUCCESS]\033[0m Patch complete.\n"