# GERTECH Forge Foundry — visual-only revision (November 11, 2026)

**Base:** owner-supplied `gertech_-_aqua_workshop_+_forge_loft_2026-11-11_09-54-53.zip`.

This is a deliberately narrow **Tetris/Forge Foundry graphics pass**. The other docks and unfinished mini-games remain drafts. We do not represent them as playable.

### What changed
- `theme_foundry/forge_foundry.gd`: replaces the CanvasItem `_draw`, `_caption`, and preview appearance; adds two graphics preloads. All methods before `_caption` (gameplay, stock accounting, gravity, key bindings, output receipts and save behavior) are byte-for-byte unchanged except the two preload lines.
- `graphics/foundry_cell_skin.gd`: shape-coded crystal, metal and gold-framed blocks, active highlights and placement ghost.
- `graphics/foundry_console_skin.gd`: fully procedural cast-metal industrial console, material hopper gauges, outlined output receipts, machine-chamber rails and status panels. No PNG required.
- `FOUNDRY_VISUAL_UPGRADE_README.md`: this note.

**No new gameplay, inventory IDs, item links, fabrication recipes, scene nodes, WorldSeed connections or rules.** Decorative gold fittings do not imply validated ports.

### Compatibility and verification
- Design coordinates are 1280 × 800; the scene scales uniformly with its Control size.
- All rendering is Godot 4 CanvasItem drawing; no 3D mesh changes or third-party art added.
- This revision was checked by source diff and archive integrity; **Godot 4 runtime and Steam Deck visual tests are not claimed**. Keep original ZIP and run in a separate folder to inspect screen size and ensure controls still respond.
- If using the earlier *whole-workshop* graphics experiment, the targeted ZIP can be applied as an overlay to the Foundry, but test it before combining with any other changes.

### Quick inspection
1. Unzip this project into a NEW directory.
2. Open its `project.godot` in Godot 4.
3. Enter the existing Forge Foundry through the workshop, or open `theme_foundry/forge_foundry.tscn` in the editor for visual inspection (the minigame requires a start config to be playable).
4. Verify gravity, hold, rotate, drop, completed rows, material use, output receipts and return to workshop. Compare resource counts with the unmodified ZIP.
