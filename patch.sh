
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


STEAM_API_ARM_DIR="$TML_PATH/Libraries/Native/OSX-arm64"
STEAM_API_DIR="$TML_PATH/Libraries/Native/OSX"
mkdir -p "$STEAM_API_ARM_DIR"
if [ -f "$STEAM_API_DIR/libsteam_api64.dylib" ]; then
    printf "\033[1;36m[ACTION]\033[0m Copying old Steam API dylib from %s to %s...\n" "$STEAM_API_DIR" "$STEAM_API_ARM_DIR"
    cp "$STEAM_API_DIR/libsteam_api64.dylib" "$STEAM_API_ARM_DIR/libsteam_api64.dylib"
fi

printf "\033[1;36m[ACTION]\033[0m Patching tModLoader...\n"
cp -a "$REPO_TML_DIR/." "$TML_PATH/"

printf "\033[1;36m[ACTION]\033[0m Removing quarantine attributes from dylib files...\n"
find "$TML_PATH" -name "*.dylib" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null

SDL_DIR="$TML_PATH/Libraries/Native/OSX-arm64"
mkdir -p "$SDL_DIR"
if [ -f "$SDL_DIR/libsdl2-2.0.0.dylib" ]; then
    printf "\033[1;36m[ACTION]\033[0m Creating symlink libSDL2.dylib -> libsdl2-2.0.0.dylib in %s\n" "$SDL_DIR"
    ln -sf "libsdl2-2.0.0.dylib" "$SDL_DIR/libSDL2.dylib"
fi

printf "\033[1;32m[SUCCESS]\033[0m Patch complete.\n"
printf "\033[1;32m[SUCCESS]\033[0m Ensure that you remove GLDevice from your steam launch options for TML.\n"
