# GERTECH Aqua Workshop — private asset and texture source manifest
**Scope:** Public repository contains the source/config/scenes/test text for the current game. Original artwork and GLB binary assets remain outside this **public** repo as instructed by the owner. This manifest prevents missing assets from being silently replaced by guesses or different-looking stock parts.

## Full exact binary archive
Latest graphics-first complete **Godot project** ZIP, including binary assets:
- Private Google Drive handoff: https://drive.google.com/file/d/1bYIhdn3Cvy39TXIXONGhS8sANoYdfsg_/view?usp=drivesdk
- ZIP filename: `GERTECH_Aqua_Workshop_Premium_Graphics_First_2026-11-11.zip`
- ZIP SHA-256: `cc8c3ed6cb41ecac102715b06256ebb9630aeacb4507b6370822d8ca27124276`
- Original 19-GLB collection: https://drive.google.com/file/d/1yyVmg9JbjS2zQ4bcBsjzucsayn_T5l0-/view
- Private handoff folder: https://drive.google.com/drive/folders/1dpr-1E-ClrQGctBUbcJtIxHR0pRuUwc0

## Binary paths intentionally NOT published to GitHub
**GLBs:** `assets/gertech_cube/parts/` — `corner_bracket.glb`, `cube_1m.glb`, `cube_bare_1m.glb`, `face_connector.glb`, `gold_rail.glb`, `reactor.glb`, and newer premium gallery samples `conduit_U.glb`, `cube_half.glb`, `manifold.glb`. Nine source meshes in this version. These have original user asset provenance and are **not** public domain simply because they can be opened. No other agent should place them in the public repository without owner clearance.

**PNG references:** `assets/gertech_cube/parts/cube_1m_0.png`, `assets/silhouette/demo_alpha_mask.png` (original package visuals) and eight authored neutral PBR textures: `assets/premium/brushed_metal_color.png`, `brushed_metal_normal.png`, `carbon_weave_color.png`, `carbon_weave_normal.png`, `ceramic_color.png`, `ceramic_normal.png`, `deck_color.png`, `deck_normal.png`. Generated textures are in the private complete ZIP; no claim is made they are separately committed.

**Public text import metadata:** `.import` sidecar files are provided for reference and may need reimport/regeneration by the Godot editor. Include image and mesh bytes from the verified ZIP under the same relative paths to reconstruct the *exact* premium project. Do not rename original files or modify the paths in scripts to silently suppress missing-asset errors.

## Reconstruction & security
The public code tree is a **code mirror**; it is not a fully self-contained public runnable distribution without the private binary assets. Obtain those only from the owner-authorized Drive source, preserve exact relative paths and test on a separate Godot 4.7 GL Compatibility copy. Replacing absent assets or granting public Drive access is not authorized by this manifest.

## Scope of the new visual-only package
The latest pass changes source `scripts/workshop.gd` and `project.godot` only relative to the modular reset ZIP, adds `graphics/premium_workshop_pass.gd` and `graphics/aqua_caustics.gdshader` and the above binary files, with no gameplay code changes in that latest pass. The cumulative package retains earlier visual Foundry skins and F9 reset from earlier same-day stages.
