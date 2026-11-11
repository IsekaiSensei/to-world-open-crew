# Garden drop: Platonic solids puzzle rooms — from Cube window

**Status:** ROUGH / PROPOSAL / ADDITIVE ONLY  
**Handle:** Grok (this window, via Ryan / IsekaiSensei)  
**Date:** 2026-11-11  
**Related:** world_seed_v0_1 (construction DNA, already lists tetra/cube/octa/dodeca/icosa/sphere seeds), GAME_STANDARDS.md, UNIVERSAL_GAME_SCHEMA.json, design/SATURN_ASTRA_MODULAR_COCKPIT_WORLD_SEED_2026-11-10.md, existing lattice row in concept art, coordination/GODOT_WINDOW_INCLUDE_2026-11-11.md

## Situation from this window (Oct 17 request, reviewed Nov 11)

Ryan asked Meta and Muse for a **3D version of the movie Cube**, but **not horror** — pure puzzle — and **not only cubes**: rooms/modules built from **all five Platonic solids** (tetrahedron, cube/hexahedron, octahedron, dodecahedron, icosahedron).

This maps cleanly onto the existing World Seed construction grammar and the block library that already references those shapes as seeds. Saturn Astra cockpit remains the current owner-selected reference module; this is an additive puzzle-chamber proposal only.

## What can be merged / added (data + visual continuity, no new game)

### 1. Module templates in module_catalog.json / world_seed
- Add five (or seven, including sphere + torus as connectors/transitions) reusable module templates whose geometry is the Platonic solid (or its dual/wireframe lattice).
- Ports on each face, with lock family matching the existing cube-frame connectors and gold joints already present in GERTECH meshes.
- Function computed from topology: different solid types have different numbers of faces/exits (4, 6, 8, 12, 20), creating natural puzzle constraints (path length, symmetry matching, face-alignment requirements).

### 2. Puzzle mechanics (non-horror, additive)
- Navigation rooms: player moves between chambers by aligning faces (rotation of modules, color/symbol matching on ports, or simple key/item from shared backpack).
- No lethal traps. Success is spatial reasoning, pattern completion, or cooperative multi-player face matching.
- Spawner templates can place puzzle items or temporary markers at face centers.
- Transitions between solid types use the existing world.transition_destinations or explicit port connections.

### 3. Visual / lattice continuity
- Reuse the mandatory crystal/transparent lattice edge style already required for concept pages (tetra, cube, octa, dodeca, icosa + sphere + torus row).
- Gold face contacts / couplers from existing workshop and gummy-ship references.
- Isolated Godot 4 test scene recommended first (per GODOT_WINDOW_INCLUDE): import existing cube GLBs, then add simple procedural or imported solid frames. Do not overwrite world_seed_v0_1 or the finished game.

### 4. Schema fit
- Items: optional puzzle keys or face-match tokens (category: material or key) enter the shared unlimited backpack.
- Entities: optional light markers or non-hostile puzzle guardians if desired later.
- Spawn points: one per chamber face or center, namespaced to the puzzle world.
- Persistence: chamber state (rotated, locked, solved) saves with the world-local spawner/progress data.

## Constraints (do not violate)
- Additive only. Do not replace Saturn Astra cockpit, rear-load path, or existing cube-frame construction DNA.
- No horror elements, lethal mechanisms, or dark claustrophobia.
- Art stays in Drive; code/manifests in GitHub. No private GLB/JPEG bytes on public repo.
- Meta/Muse original order remains scoped; this is a public Garden proposal for other windows (ChatGPT, bots) to implement against the schema.
- Originals untouched. World Seed v0.1 is construction data, not the finished game.

## Suggestion for other windows
ChatGPT / other Godot windows: read this drop + world_seed_v0_1/module_catalog.json + UNIVERSAL_GAME_SCHEMA.json. Propose concrete module template JSON fragments and one isolated test scene import of existing cube GLBs + simple solid frames. QC against GAME_STANDARDS.md. Sphere / Continuity bots can track receipt.

## Evidence
- Original request filed privately 2026-10-17 as proposals/ORDER_2026-10-17_META_MUSE_3D_PLATONIC_SOLIDS_CUBE_PUZZLE.md (shared-room).
- Lattice row already in concept art and Butt Dialer source-seed format.
- world_seed README explicitly notes the block library depicts tetra/cube/octa/dodeca/icosa/sphere seeds.
- GODOT_WINDOW_INCLUDE already assigns first delivery of real cube/gold-joint models into isolated test scene.

## Still unknown
- Exact face-port normals and lock families for non-cube solids (needs measured or owner-approved geometry).
- Whether rooms are full solid volumes or wireframe/lattice shells.
- Owner GO on specific puzzle rules or integration priority versus Saturn cockpit.

---

This file is a **Garden drop only**. It is not canon, not a private Book, and not published as a finished Page until reviewed and accepted.
