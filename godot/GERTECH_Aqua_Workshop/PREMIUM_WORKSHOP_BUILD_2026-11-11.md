# GERTECH — Aqua Workshop + Forge Loft
## Graphics-first build · November 11, 2026

**Starting point:** `GERTECH_Modular_Crystal_Gold_Foundry_Reset_2026-11-11.zip` supplied in this conversation (SHA-256 `8b8cf035f8d930348bd358730d5eb6f17f0c20d7a3793807c2cbbf1b6c73a09f`). The original is not overwritten.

### What changed in this build

- Added a separate `graphics/premium_workshop_pass.gd` for the walkable, persistent 3D workshop. This produces detailed machined pressure-window frames, gold stays and clamps, illuminated ceiling trusses, multi-tiered forge/vat retention hardware, overhead material-feed pipes, hall navigation inlays, service plates, batched fasteners, and compact tooling housings. The 3D geometry is actual mesh geometry, not images pasted over scenery.
- Material pass: higher-contrast ivory ceramic, clear blue/violet crystal, satin gold/bronze alloy, and improved metallic/roughness values. Added **eight generated, neutral high-frequency PBR albedo and normal maps** for brushed alloy, white ceramic, carbon-fiber texture, and floor decks. The procedural images are created for this game, not copied from or inferred from owner character art.
- Added animated visual-only underwater caustic highlights (`aqua_caustics.gdshader`) and cool/warm practical lights. A procedural sky provides reflecting environment color to metal surfaces. No new water/physics gameplay.
- Added three **actual source GLB components** from the owner's original `GERTECH_CUBE_MESHES_AND_ART_ONLY_2026-11-02.zip` for the presentation gallery: `cube_half.glb`, `manifold.glb`, `conduit_U.glb`. Reused existing bundled source parts; these are non-interactive display models, **not** newly approved WorldSeed port geometry.
- Added `gertech_visuals/quality_level` profile in `project.godot`: `0` original/no extra props, `1` lighter detailing, `2` high detailing, `3` ultra/full presentation. Default `3`; change to `1` or `2` if your Steam Deck drops frames. This does not alter controls, UI, physics or saved worlds.

### Explicitly untouched / deferred

- Foundry/Tetris gameplay, incoming stock and output recipes, stock upgrade pricing, player controls, WorldSeed vertex/edge/assembly/tetra APIs, save/load path, F9 reset, the one active minigame, and the existing display of incomplete minigame docks.
- No coral growth economy, extra arcade minigames, self-replicating network, worker automation AI, or adult-character variations have been implemented here. Those are later design stages.
- Do not confuse decorative joints, end-caps, samples, vat stays, or floor inlays with validated functional ports. Their names indicate they are visual-only.
- No source JPEG/concept art was modified, and private images were not published to GitHub.

### How to run

1. Extract the **complete** ZIP as one project folder. Don't copy a patch into a prior project unless you deliberately want to merge changes.
2. Open `GERTECH_Aqua_Workshop/project.godot` using the same Godot 4.x editor that opened your previous project (the user project's baseline is Godot 4.7 GL Compatibility).
3. Allow new GLB meshes and PBR PNG textures to import, then run the scene.
4. If the rendering is too heavy for Steam Deck, in `project.godot` set `[gertech_visuals] quality_level=2` or `1`, reopen and test.
5. Retain a backup of your previous installed game and saved WorldSeed JSON before changing builds; visual upgrades are not a substitute for an upgrade migration test.

### Tests performed here

- Original ZIP and new ZIP archive CRC verification.
- Python voxel/tetra geometry test: six nondegenerate tetrahedra per occupied voxel, shared-face conformity, and no nonmanifold shared triangles — PASS.
- Static comparison to the source tree to verify that no gameplay scripts were changed; only `scripts/workshop.gd` and `project.godot` were modified plus new visual scripts/textures/GLBs/docs.

**Engine limitation:** This environment does not have a Godot executable and cannot retrieve one over its blocked network, so this build has **not** been verified with a Godot import, headless parse, actual 3D render, FPS test, or Steam Deck runtime. Treat it as a deliverable release candidate, not a completed runtime QC pass. Report the first Godot parser/import error with file and line if one occurs.
