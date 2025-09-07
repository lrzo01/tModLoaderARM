#!/usr/bin/env bash
arch=arm64

for arg in "$@"; do
    if [[ "$arg" == --arch=* ]]; then
        arch="${arg#--arch=}"
        break
    fi
done

if [[ "$(uname -m)" != "$arch" ]]; then
    exec arch -$arch /bin/bash "$0" "$@"
fi

cd "$(dirname "$0")" ||
{ read -n 1 -s -r -p "Can't cd to script directory. Press any button to exit..." && exit 1; }

export SteamClientLaunch=1
chmod a+x ./start-tModLoader.sh
./start-tModLoader.sh