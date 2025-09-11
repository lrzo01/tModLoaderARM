# tModLoader for Apple Silicon (arm64)

A native patch for tModLoader on Apple Silicon (M1/M2/M3/M4) Macs. This patch enables direct Metal graphics support via SDL2-compat, removing the need for MoltenVK or OpenGL, and bundles all required ARM64 native libraries and binaries.

## Launch Options

Extra launch flags allow you change runtime architecture and SDL version selection through steam launch options:

### Architecture Selection
- `--arch=arm64` - Run natively on Apple Silicon
- `--arch=x86_64` - Run under Rosetta translation (compatibility mode)

### SDL Version Selection
- `--sdl2` - Uses SDL2 (poorer performance, more stable) - only running **only** with OpenGL on ARM64, with MoltenVK an option under x86_64
- `--sdl3` - **Default:** Uses SDL3 (improved performance, less stable) - allows running directly with Metal

---

## Acknowledgements

- [TerrariaArmMac](https://github.com/Candygoblen123/TerrariaArmMac)
- [tModLoader](https://github.com/tModLoader/tModLoader)

---

## Known Issues & Workarounds

- **Vulkan launch option unavailable on ARM64 SDL2:**
  - *Issue:* Vulkan cannot be used as a launch option when using ARM64 and SDL2
  - *Solution:* Remove the launch option from Steam to use OpenGL, or use SDL3 instead

- **Accent Selector pops up when moving:**
  - *Issue:* The macOS accent selector may appear when holding movement keys.
  - *Solution:* Run the following command in your terminal, then log out and back in:
    ```sh
    defaults write -g ApplePressAndHoldEnabled -bool false
    ```

- **Magic Storage slope movement bug (ARM64 SDL3 only):**
  - *Issue:* Movement on slopes may require jumping instead of walking when using the Magic Storage mod. This issue only occurs when running with `--arch=arm64 --sdl3`.
  - *Workaround:* Use `--arch=arm64 --sdl2` instead for optimal compatibility.
  - *Status:* No known fix for SDL3. Remove the mod if it bothers you or switch to SDL2.

---

## Installation

1. Download this repository or use the latest release
2. Open a terminal in the project folder
3. Run the patch script:
   ```sh
   sudo ./patch.sh
