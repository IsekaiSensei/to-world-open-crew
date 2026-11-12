# GERTECH Aqua Workshop — PUBLIC SOURCE / PRIVATE ASSET MANIFEST

> **CURRENT OWNER PACKAGE (Nov 11, later than the archive listed below):** [GERTECH_Aqua_Workshop_FULL_RESTORED_Dig_Dog_UI_2026-11-11.zip](https://drive.google.com/file/d/1oESoWFwdAPD_9NT0c-66YyTGZXPJGv3c/view?usp=drivesdk) — **82 entries**, 1,535,536 bytes, SHA-256 `771b63f2314586319a0fb6af5edb78e20babc49863856309a7011603439b05ff`. This is the **latest package identified in the current handoff**. Relative to the original graphics-first package, the final source corrected **DIG DOG** UI labels and documentation; older 82-file Premium Graphics First (SHA `cc8c3ed6...`, below) remains the historical source/provenance record, not the package to install over the current game. Preserve private GLBs/textures; do not use the incomplete 54-file FIXED ZIP. Prior zip/static tests do **not** establish a Godot runtime PASS. [Current game handoff](https://github.com/IsekaiSensei/to-world-open-crew/blob/main/game/GODOT_CURRENT_BUILD_HANDOFF.md).

**Source:** Owner's 2026-11-11 premium graphics-first package. Public repository contains real source files and owner-safe generated neutral textures, not a reconstructed game.
**Verified source archive:** `GERTECH_Aqua_Workshop_Premium_Graphics_First_2026-11-11.zip`
**SHA-256:** `cc8c3ed6cb41ecac102715b06256ebb9630aeacb4507b6370822d8ca27124276`
**Private complete project:** https://drive.google.com/file/d/1bYIhdn3Cvy39TXIXONGhS8sANoYdfsg_/view
**Original cube mesh source (private):** https://drive.google.com/file/d/1yyVmg9JbjS2zQ4bcBsjzucsayn_T5l0-/view
**Godot:** 4.7, GL Compatibility. Main: `res://scenes/workshop.tscn`.

## Contents and limits
- The original relative source paths for all GDScripts, scenes, project configuration, shaders, generic demo silhouette, SVG icon, and 8 newly generated neutral PBR textures are included in this GitHub source tree.
- All original source GLB files, source-associated owner media, and `.import` cache sidecars were deliberately **omitted from PUBLIC GitHub**. They remain in the private complete ZIP/Drive. Rebuild from GitHub by restoring the omitted owner media at the exact relative paths from the private owner ZIP; Godot regenerates imports.
- This public tree alone is **not self-contained** for full original 3D appearance: missing original GLBs are private by design. Do not publish or substitute other people's artwork.
- **Godot runtime launch not performed by this handoff.** GitHub source presence does not imply an executable/tested build.

### Intentionally omitted paths
- `assets/gertech_cube/parts/conduit_U.glb`
- `assets/gertech_cube/parts/corner_bracket.glb`
- `assets/gertech_cube/parts/cube_1m.glb`
- `assets/gertech_cube/parts/cube_1m_0.png`
- `assets/gertech_cube/parts/cube_bare_1m.glb`
- `assets/gertech_cube/parts/cube_half.glb`
- `assets/gertech_cube/parts/face_connector.glb`
- `assets/gertech_cube/parts/gold_rail.glb`
- `assets/gertech_cube/parts/manifold.glb`
- `assets/gertech_cube/parts/reactor.glb`

### Required integration constraints
Preserve Tetris Foundry, shared inventory, WorldSeed persisted data and reset/load, player controls, and all existing scenes. No new gameplay, name/canon or film routing added by this publication.
Source back-reference: https://github.com/IsekaiSensei/to-world-open-crew/blob/main/game/GERTECH_PREMIUM_WORKSHOP_BUILD_RECEIPT_2026-11-11.md
