# TO WORLD — Universal Construction DNA / World Seed v0.1

**Status:** runnable data prototype, not a finished Godot game or physically certified construction system. The newer owner-selected [Saturn Astra modular cockpit world seed](../design/SATURN_ASTRA_MODULAR_COCKPIT_WORLD_SEED_2026-11-10.md) is a separate design target; this construction prototype does not yet implement it. Owner's construction grammar: Geometry → Connection → Material → Function → Assembly → Transformation.

**The cube does not know it is a spaceship.** Its definition is context-independent. Assembly behavior follows from validated neighbors, compatible ports, active devices, connectivity, state and world context.

**Primary art evidence:** LATTICE CASTLE — MODULAR CONSTRUCTION SHEET, LATTICE BLOCK LIBRARY — BUILD SHEET, Galaxy Cubes. Source images are not modified or embedded in GitHub. The printed geometry labels and visual mechanisms are reference concepts, not measured or validated engineering specifications.

## No inventory gating on building

`scan` creates a reusable, persistent Construction DNA blueprint. `dog_build` instantiates a copy and emits a stepwise build job; **no backpack component stacks, blueprints to reacquire, or part collection are required**. Galactic Ether Relay is the in-world construction/delivery mechanism; actual power/energy limitations are not simulated yet. Optional gameplay resource systems must not become prerequisites for this mode.

Legacy ammo/potion/equipment backpack in `to-world-open-crew` remains intact for other gameplay; it is **not** the construction source of truth. A scan saves a *blueprint for in-game use*, not a statement of real-world IP ownership.

## Files
- `world_seed.schema.json`: JSON Schema for the separate construction domain.
- `module_catalog.json`: material and connector properties + reusable module definitions.
- `examples/bridge_seed.json`: three identical cube modules linked into a load-path bridge prototype; the role is inferred from connected supports.
- `examples/corvette_38_source_manifest.json`: 38 deliberately unresolved source slots with owner reference provenance, **not** a fake reconstruction.
- `examples/dog_builder.json`: TO DOG role as autonomous scanner/fabricator, not a pile of parts to loot.
- `world_seed.py`: standard-library loader, validation, scan, move, clone, builds, roles, SHA-256, file save.
- `tests/test_world_seed.py`: tested invariants and rejection of bad connections, tampering, missing source geometry, inventory gating.

## Try it (Python 3.10+)
```
cd TO_WORLD_WORLD_SEED_v0_1
python3 -m unittest discover -s tests -v
python3 world_seed.py examples/bridge_seed.json
```

## Engineering invariants
1. A module template has no fixed purpose like ship/castle/fairy.
2. Module instance has stable ID, template ID, 3D pose, material, per-face state and current state.
3. Ports connect only when both ends support the requested channel, same lock family, matching opposite normals and coincident world positions (prototype currently yaw-only in 90° increments).
4. An occupied port cannot be connected again. The connection graph is explicit, never inferred from closeness alone.
5. Function is computed from topology and state; `bridge` example additionally requires two distinct grounded endpoints and a continuous structural path.
6. Scanned DNA never consumes or stores item quantities in inventory; user can rebuild and modify copies without mutating its source.
7. Appearance, detail level and hardware profiles are render preferences, not the saved construction truth.
8. A claimed exact asset without source part IDs and measured transforms must remain `incomplete`, NOT reconstructed via guesses.
9. Rigid movement changes every pose without changing topology, port identities or blueprint DNA.
10. Galactic Ether Relay transports a build specification across locations, preserving IDs inside the blueprint; it is fiction, not a verified physical process.

## Evidence limits
LATTICE CASTLE shows a 1–7 progression visually (seed → tile/frame → framed module → crystal infill → decorated module → finished architectural unit), followed by reusable towers, bridges, walls, roofs, windows, courtyards and connected city layout. The block library separately depicts tetra/cube/octa/dodeca/icosa/sphere seeds; tiles, 6-way hubs, rods, hinges, 90° elbows, ring locks, frames, panel infills and repeat/scale sequences. The exact manufacturing tolerances, electrical bus protocols, structural capacities, module sizes and all 38 Corvette placements have **not** been established from those images.

**ZIPPER continuity:** Current Drive ZIPPER.txt 016=GLAMOUR, 017=TRANSMUTE, 018=MEND. Related 020=SHRINK, 024=BRIDGE, 029=ONE WALKOUT MANY ROOMS, 030=GERTECH TILED CAVERN. No original scripts edited or renumbered.

## Next proof gates
- Recover each of the 38 original Corvette module identities and positions from authentic original game walkthrough frames, not a generic substitute.
- Make a measured port specification and Godot mesh bindings; test build → save → reload → rebuild visually in Godot.
- Author load-bearing, pressure, navigation, power and simulation rules as optional component systems, not as facts claimed from concept art.

## Godot bridge preview
`godot/WorldSeedPreview.gd` is an optional Godot 4 Node3D script that draws the **verified demo cube-frame topology** from `examples/bridge_seed.json`. It has not been executed in Godot and does not scan 2D images, reconstruct the missing Corvette, or render the other unbound module types. Place the example JSON at the exported `res://` path and attach the script to a Node3D.