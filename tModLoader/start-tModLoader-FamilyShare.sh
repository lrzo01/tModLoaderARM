#!/usr/bin/env bash
if [[ "$(uname -m)" != "arm64" ]]; then
    exec arch -arm64 /bin/bash "$0" "$@"
fi

cd "$(dirname "$0")" ||
{ read -n 1 -s -r -p "Can't cd to script directory. Press any button to exit..." && exit 1; }

export SteamClientLaunch=1
chmod a+x ./start-tModLoader.sh
./start-tModLoader.sh