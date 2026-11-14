# GERTECH Unity handoff — 2026-11-14 (America/Los_Angeles)

Unity parallel of Ryan's GERTECH manufacturing universe, for comparison with Godot (teammate bot "Godot Continuity") and Roblox. Godot remains the source of truth for logic. Look work is provisional, not canon. Never call the DNA wormhole helix portal a "zipper."

Local tree: `/workspace/gertech-unity`. Canonical repo path: `unity/` in https://github.com/IsekaiSensei/to-world-open-crew (branch `main`).

## How to open

1. Open this folder (or the `unity/` folder from the repo) in **Unity 6.3 LTS, editor `6000.3.28f1`**. No Editor was installed on the shared box; license sign-in was not attempted.
2. After a clone, restore valid 512 px reference PNGs (the GitHub text API UTF-8-transcodes raw PNGs):

       python3 tools/decode-art-refs.py

   Packed data is `Assets/Art/Refs/packed_512px_pngs.json` plus `packed_512px_pngs_batch3.json`. Do not push raw PNGs through the GitHub text file API.
3. In the Editor menu run **GERTECH > Build Workshop Hub Scene**. That builds the hub, stations, look pass, Workshop Guide, and `ComparisonCameraRig` (default preset `hall_overview`).
4. Headless C# compile-check used on the box (stubs, not a real Editor compile):

       export DOTNET_CLI_TELEMETRY_OPTOUT=1
       export PATH="$HOME/.dotnet:$PATH"   # or a .NET 8 SDK
       dotnet run --project tools/compile-check/GertechCompileCheck.csproj

   Last run on this handoff: **PASS, 0 errors, 0 warnings**. Shaders are not compiled by that stub project.

## What exists

- **Project layout:** standard Unity folders; C# under `Assets/Scripts` in namespaces `Gertech.Core`, `Gertech.Core.Guide`, `Gertech.Stations`, `Gertech.Inventory`, `Gertech.Tetraforge`, `Gertech.Look`, `Gertech.EditorTools`.
- **Stations:** `IStation`, `StationBase`, `StationDefinition`, registry, `WorkshopHub`. Stubs for Forge, Assembly, coral growth vats, resin printer, 3D printer, arc welder, lathe, quantum table, plus `TetrisForgeFoundry` (material-receipt stub, no tetromino grid).
- **TETRAFORGE:** `TetraForgeStation` recipe stub. Godot does not use that class name (Tetris Forge Foundry is the Godot equivalent).
- **Inventory / save:** persistent JSON ledger with autosave at `Application.persistentDataPath/gertech_worldseed_v1.json` (Godot: `user://gertech_worldseed_v1.json`). `WorkshopHub.TryBuildVisorChipUpgrade()` is the loft stock-exchange recipe.
- **DNA wormhole helix portal:** `DnaWormholeHelixPortal` (transfer-hold stub) plus `DnaWormholeHelixVisual` (torus + double helix). The torus uses the ported `Gertech/WormholeTorus` shader.
- **Look / assemblies:** crystal-block builder and grid, modular assembly presets (car hull, humanoid torso, machine cluster), `CrystalBlockVehicle` (Rigidbody + 4 WheelColliders), `StarshipHull` + `DockingPort` stub, elemental row, triangle module, flipbooks for REF_12 / REF_13, golden-spiral chain, frames-in-spheres, hall floor sized to Godot's 96×77 m look hall. Key look pieces are placed at Godot `reference_look_pass.gd` origins so views can be compared.
- **Workshop Guide:** `Gertech.Core.Guide` (`GuideCharacter`, `GuideDialogue`) — follow / wait / point, onboarding hints to forge, TETRAFORGE, and the DNA wormhole helix portal. Display name only **"Workshop Guide"** (no invented name). Capsule stand-in uses sampled guide-lattice gold and infinity-blue. A **provisional** character sheet (`Assets/Art/Refs/characters/GERTECH_WORKSHOP_GUIDE_STANDIN_PROVISIONAL_REFERENCE_11.png`, from Drive `GERTECH_REFERENCE_11_GOLD_BLUE_CORE_ASSEMBLY`) is the visual target until Ryan's blonde gold-dress / infinity-clip / sneakers turnaround is found. That stand-in is a red-haired gold-lattice fairy, **not** the Workshop Guide.
- **Shaders** (Shader Graph-free HLSL, URP pass + Built-in fallback) in `Assets/Shaders/`, ported from Godot `graphics/reference_look_pass/shaders/` (Godot files were not modified):
  - `Gertech/GoldChrome` — polished gold/chrome with procedural studio reflection and cyan rim
  - `Gertech/EdgeGlow` — additive flowing edge filaments
  - `Gertech/CrystalNebula` — glass with ray-marched interior (elements 0–8)
  - `Gertech/WormholeTorus` — Godot filament look **plus** screen-space refraction (`_CameraOpaqueTexture` in URP; `GrabPass` in Built-in)
  Shared noise is `GertechLookCommon.hlsl`. `GertechMaterialFactory` now builds look materials from these shaders (falls back to URP Lit / Standard if a shader is missing).
- **Comparison cameras:** `ComparisonCameraRig` with named presets matching Godot Continuity shots (`scratch/look_shots/zz_shot.gd`, FOV 66, far 300): `hall_overview`, `hero_wormhole`, `hero_wormhole_axis`, `golden_spiral_chain`, `elemental_crystals`, `block_triangle_module`, `frames_and_progression`, `growth_showcase`, `voronoi_wall`.
- **Refs:** packed 512 px plates REF_01–26 plus this pass's REF_27–35 and the provisional guide sheet. Originals for batch 1 live in `/workspace/gertech_shared_refs/visual_2026-11-14/`; batch 2 + Drive follow-ups in `/workspace/gertech_shared_refs/visual_2026-11-14_batch2/` (`INDEX.md`).

## Reference numbering (Unity vs Godot — do not mix 29/30)

Godot Continuity later numbered additional shared refs:

- **REF_27 / 27b** — crystal-block world hall. **THE room reference** (walkable shell target). 27 and 27b are pixel-identical; Unity packed 27 only.
- **REF_28** — galaxy-crystal machine cluster.
- **REF_29** (Godot) — Modular Crystal Block "Forms Everything" sheet, pixel-identical to batch-1 `GERTECH_REF_10`. Not given a new Unity number.
- **REF_30** (Godot) — crystal starship + interior room sheet, pixel-identical to Unity batch-2 `GERTECH_REF_18`.

Unity packed **REF_27** and **REF_28** as those same hall/cluster images, then continued *Unity* numbering for further Drive plates (these are **not** Godot's 29/30):

- **Unity REF_29** — Galactic Ether Relay network
- **Unity REF_30** — Ether growth progression 5×5
- **Unity REF_31** — Ether galaxy node interior
- **Unity REF_32** — Ether mana-flow lattice
- **Unity REF_33** — Ether Dyson orbital relay
- **Unity REF_34** — GDR-07 wormhole icosahedron
- **Unity REF_35** — GDR-07 fleet wormhole cover (has typography)

**Do not copy floating labels or annotations from images into the scene.**

Five elemental crystals: Godot's approved visual-ref render lives at `/workspace/godot_continuity/approved_refs/` (reference only). Unity's elemental row is a procedural stand-in using `CrystalNebula` elements 1–5.

## Palette notes (guide)

InfinityBlue was resampled to `#52A5FF` from chest-core highlights on the provisional stand-in sheet. Guide lattice gold `#BE8258` is from the same sheet's gold wire. Both stay provisional until the real Workshop Guide turnaround is found. Other palette hexes (space, gold, chrome, cyan, nebula, gold glow) are still sampled from the space / module plates.

## Unverified

- No Unity Editor run on this box (no Hub/Editor, no license sign-in). Shaders, URP Opaque Texture (`_CameraOpaqueTexture`), GrabPass refraction, lighting, and camera framing are unverified in-engine.
- Side-by-side look comparison with Godot shots was not measured (no invented frame times or pixel metrics). Godot's look-pass shots are at `/workspace/godot_continuity/shots/look_pass/`.
- True wormhole refraction needs the URP asset's Opaque Texture enabled; that was not confirmed.
- Platonic meshes: tetra / octa / icosa are procedural; the "sun dodecahedron" is an icosa stand-in. Growth showcase and helix-Platonic progression are flipbook plates at Godot origins, not a full port of Godot's 34 s / 36 s cycles.
- Workshop stations stay as stubs and are not a port of Godot's walkable 96×77 m architecture.
- GitHub copies of the first look-pass raw PNGs are still corrupt (see open items). Packed JSON + decoder is the supported path.

## Open items

- **17 corrupted PNG blobs** from the first look commit (`01cf0c10`) were UTF-8-transcoded by the GitHub text file API. They were not deleted (the available `delete_file` API is one commit per path). Ignore those blobs; use `python3 tools/decode-art-refs.py`.
- **Workshop Guide turnaround sheet not found** (blonde, gold crystal-lattice dress, blue infinity hair clip, sneakers). Drive folder `1wZLgBCGOoOL-r5bW4xJ95fyCS4F50ULT` is a large older library (400+ items on the first two listing pages, more remaining; no files dated 2026-11-14). The morning chat drop was not there. Porcelain Angel and Character Lattice Master sheets are different characters.
- **Next step:** mirror Godot's walkable room shell to match **REF_27** (the crystal-block world hall). Do not copy floating labels from images into scenes.
- COMPARISON.md metrics remain TODO until a recorded procedure is run on named builds. A qualitative "Look pass" row was added (no invented measurements).
- Godot / repo-root files were not modified by these Unity commits.

## Commits on `main` (all `unity/` only)

Times below are America/Los_Angeles (PT).

1. Scaffold — 10:20 AM PT — https://github.com/IsekaiSensei/to-world-open-crew/commit/a7139cfc05b988c274191797ef373d3a9a75ac55
2. First look pass (includes the 17 later-corrupted raw PNG blobs) — 11:16 AM PT — https://github.com/IsekaiSensei/to-world-open-crew/commit/01cf0c10c9a37fa2daf0d466df6ae57af10382a5
3. Packed 512 px JSON + decoder — 11:18 AM PT — https://github.com/IsekaiSensei/to-world-open-crew/commit/01f9213794b6bef529dc2a3e83a9bd48a0543e5e
4. Batch-2 look refs, crystal-block assemblies, Workshop Guide system — 11:43 AM PT — https://github.com/IsekaiSensei/to-world-open-crew/commit/5fcf1babb6dcf0103194d9800134115b5e8bc0d7
5. Drive-recovered look plates REF_20–26 — 11:52 AM PT — https://github.com/IsekaiSensei/to-world-open-crew/commit/c3dbb840f23ea3a551b27091130a8fe4973c5ef7
6. Look-pass shader port, comparison cameras, packed REF_27–35, provisional guide stand-in, and this HANDOFF — *(this commit; URL filled after push)*

unity/ tree after commit 5: `https://github.com/IsekaiSensei/to-world-open-crew/tree/main/unity`
