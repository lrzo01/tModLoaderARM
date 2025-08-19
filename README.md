
# tModLoader for Apple Silicon

A very botched implementation that allows tModLoader to run natively on Apple Silicon macs. Additionally, uses Metal instead of OpenGL for improved performance!
## Acknowledgements

 - [TerrariaArmMac](https://github.com/Candygoblen123/TerrariaArmMac)
 - [tModLoader](https://github.com/tModLoader/tModLoader)


## Vulkan support
As mentioned, this project allows tModLoader and Terraria to use `SDL3` through `SDL2-compat`. 

The newest versions of FNA3D and SDL3 skip the middleman (Vulkan) and use Metal. The launch script will automatically sort this for you, and therefore you do not need to adjust your steam launch options.

## Installation

1. Download this project
2. Open a terminal in the project folder
3. Run the patch script:

	```sh
	./patch.sh
	```

	- The script will auto-detect your tModLoader install (or ask for the path if not found)
	- It will automatically back up your current tModLoader folder before patching
	- All files in the repo's `tModLoader` folder will be copied into your install, overwriting as needed

That's it! Launch tModLoader as usual from Steam.

## Uninstalling
In Steam, verify tModLoader's files and it should revert back to using Rosetta. 

## Technical details

This implementation was fairly simple to sort. This is a list of what I had to do
- Compile `MonoMod` from source and build arm64 binaries
- Compile `Steamworks.NET.dll` from source and build arm64 binaries
- Replace the `SDL2` lib with `SDL2-compat`
- Upgrade all other native libs to use `ARM64` 
- Updated all launch scripts to force arm64 execution, use arm64 libs and set `FNA3D_FORCE_DRIVER=METAL`
