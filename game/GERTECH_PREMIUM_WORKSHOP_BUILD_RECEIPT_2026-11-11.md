# GERTECH Aqua Workshop — Premium Graphics First release candidate
**Owner:** Isekai Ryan · **2026-11-11** · **Status:** ZIP packaged / file CRC checked / static & geometry tests passed; **Godot engine runtime not tested**.

## Actual deliverable
- **Complete candidate Godot project ZIP in the existing PRIVATE Drive Godot handoff folder:** https://drive.google.com/file/d/1bYIhdn3Cvy39TXIXONGhS8sANoYdfsg_/view?usp=drivesdk
- File: `GERTECH_Aqua_Workshop_Premium_Graphics_First_2026-11-11.zip`
- SHA-256 of uploaded candidate source package (computed locally): `cc8c3ed6cb41ecac102715b06256ebb9630aeacb4507b6370822d8ca27124276`
- Bytes: `1,534,914`; entries `82`, ZIP CRC PASS.
- **Private Drive permission is not automatically granted by this link.** Bot must report if unable to access; no bypass/public media repost.
- Local source baseline: `GERTECH_Modular_Crystal_Gold_Foundry_Reset_2026-11-11.zip` SHA-256 `8b8cf035f8d930348bd358730d5eb6f17f0c20d7a3793807c2cbbf1b6c73a09f`.

## Scope of visual work
Only existing `scripts/workshop.gd` and `project.godot` changed. Added `graphics/premium_workshop_pass.gd`, `graphics/aqua_caustics.gdshader`, eight neutral PBR albedo/normal PNGs, three original owner-mesh GLB sample components, and build README. Scene now *constructs* finer pressure-window frames, arch clamps, ceiling gold trusses, deck gasket plates, material service pipes, rim braces around six existing vats/crystal tubes, fixture housings and soft lights. Original auth/identity asset source unchanged. Added opt-in profile setting `gertech_visuals/quality_level=0..3` (default 3). Extra display meshes/trim are not validated gameplay ports or inventory items.

## Verified exclusions
66 original files byte-identical, including `workshop/inventory.gd`, `theme_foundry/forge_foundry.gd`, `worldseed/world_seed.gd`, `scripts/explorer.gd`. No minigame mechanics, new coral systems, swarm AI, interfaces, film route, saved WorldSeed rules, or control semantics added or changed. Geometry suite `tests/check_voxel_tetra.py`: PASS.

## Runtime QC needed
Godot 4.7 project GL Compatibility. No Godot executable in current build environment, so this is **not** a verified runnable release. On Steam Deck: extract as separate project, allow imports, run, inspect console for parse/import errors and FPS. Try profile 2 or 1 for hardware constraints. Keep user's original ZIP and saves intact. If failure, report path/line, actual logs and screenshots; do not declare fixed without new runnable receipt.

**Design authority:** https://github.com/IsekaiSensei/to-world-open-crew/blob/main/game/GERTECH_WORKSHOP_GRAPHICS_FIRST_OWNER_DIRECTION_2026-11-11.md
**Cross-window project source audit:** https://github.com/IsekaiSensei/to-world-open-crew/blob/main/game/GODOT_CROSS_WINDOW_HANDOFF_2026-11-11.md
