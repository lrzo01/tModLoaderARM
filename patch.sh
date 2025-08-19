#!/bin/bash

REPO_TML_DIR="$(cd "$(dirname "$0")" && pwd)/tModLoader"
BACKUP_DIR="$HOME/tModLoader_backups"
DEFAULT_TML="$HOME/Library/Application Support/Steam/steamapps/common/tModLoader"

if [ -d "$DEFAULT_TML" ]; then
    TML_PATH="$DEFAULT_TML"
    echo "Found tModLoader at: $TML_PATH"
else
    read -e -p "Enter the path to your tModLoader installation: " TML_PATH
    if [ ! -d "$TML_PATH" ]; then
        echo "tModLoader path not found: $TML_PATH"
        exit 1
    fi
fi

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/tModLoader_backup_$TIMESTAMP"
echo "Creating backup at: $BACKUP_PATH"
cp -a "$TML_PATH" "$BACKUP_PATH"

echo "Removing 'dotnet' folder if it exists..."
rm -rf "$TML_PATH/dotnet"
echo "Patching tModLoader..."
cp -a "$REPO_TML_DIR/." "$TML_PATH/"
echo "Patch complete."
