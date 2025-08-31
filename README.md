# tModLoader for Apple Silicon (arm64)

 A native patch for tModLoader on Apple Silicon (M1/M2/M3/M4) Macs. This patch enables direct Metal graphics support via SDL2-compat, removing the need for MoltenVK or OpenGL, and bundles all required ARM64 native libraries and binaries.

---

## Acknowledgements

- [TerrariaArmMac](https://github.com/Candygoblen123/TerrariaArmMac)
- [tModLoader](https://github.com/tModLoader/tModLoader)

---

## Known Issues & Workarounds

- **Accent Selector pops up when moving:**
  - *Issue:* The macOS accent selector may appear when holding movement keys.
  - *Solution:* Run the following command in your terminal, then log out and back in:
    ```sh
    defaults write -g ApplePressAndHoldEnabled -bool false
    ```

- **Magic Storage slope movement bug:**
  - *Issue:* Movement on slopes may require jumping instead of walking when using the Magic Storage mod.
  - *Status:* No known fix. Likely requires forking and modifying the tModLoader source. Remove the mod if it bothers you.

---

## Installation

1. Download this repository or use the latest release
2. Open a terminal in the project folder
3. Run the patch script:
   ```sh
   sudo ./patch.sh