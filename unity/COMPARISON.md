# GERTECH manufacturing universe — Unity vs Godot vs Roblox

Comparison template for the Unity scaffold in this folder, the Godot Aqua Workshop (owned for continuity work by the teammate bot "Godot Continuity"), and a Roblox port if one is added later.

**Do not invent measurements.** Leave cells as `TODO` until a recorded procedure has been run on named builds. Dates and engine versions below the tables should be filled in at measurement time.

## Builds under comparison

| Engine | Project / path | Version / commit | Date measured | Notes |
|---|---|---|---|---|
| Unity | `/workspace/gertech-unity` | TODO (target editor 6000.3.28f1) | TODO | Scaffold; no Editor run on the shared box at creation |
| Godot | `/workspace/godot-current-review/extract/GERTECH_Aqua_Workshop` (also `godot_nov10_ro/`, Godot Continuity candidates, full-restored zip) | TODO (project features: Godot 4.7) | TODO | Current baseline, 2026-11-11; runtime not verified on this box in the review inventory |
| Roblox | TODO — none found on this box | TODO | TODO | No `.rbxl` / `.luau` / Rojo tree located |

## Primary metrics

Define the procedure in the "How to measure" column before filling results. Use the same task, scene, and hardware for all three engines when possible.

| Metric | How to measure | Unit | Unity | Godot | Roblox | Hardware / notes |
|---|---|---|---|---|---|---|
| Iteration speed | TODO (example: time from "add a new station type" to seeing it run in Play / Run) | TODO | TODO | TODO | TODO | TODO |
| 3D tools | TODO (example: time or step count to import a workshop mesh, assign a material, and place it in the hub) | TODO | TODO | TODO | TODO | TODO |
| Physics | TODO (example: stability, step time, or feature check on a named body / joint setup) | TODO | TODO | TODO | TODO | TODO |
| Vehicles | TODO (example: time to stand up a driveable workshop vehicle and a single handling check) | TODO | TODO | TODO | TODO | TODO |
| Docking | TODO (example: time or reliability to dock two modules / a vehicle at a workshop intake dock) | TODO | TODO | TODO | TODO | TODO |

## Optional supporting metrics

Add rows only when a procedure exists. All values start as TODO.

| Metric | How to measure | Unit | Unity | Godot | Roblox | Notes |
|---|---|---|---|---|---|---|
| Cold project open | TODO | seconds | TODO | TODO | TODO | |
| Enter Play / Run | TODO | seconds | TODO | TODO | TODO | |
| Script compile / reload | TODO | seconds | TODO | TODO | TODO | |
| Package / export build | TODO | seconds | TODO | TODO | TODO | |
| Save / load inventory round-trip | TODO | pass/fail + time | TODO | TODO | TODO | Godot: `user://gertech_worldseed_v1.json`; Unity: `Application.persistentDataPath/gertech_worldseed_v1.json` |

## Module parity (not a performance score)

Factual checklist of manufacturing modules. Mark presence only after inspecting the named build. `P` = present and playable, `S` = stub / environmental only, `N` = not present, `TODO` = not yet checked on that build.

| Module | Unity (`gertech-unity`) | Godot Aqua Workshop (as surveyed 2026-11-14) | Roblox |
|---|---|---|---|
| Workshop hub | S (`WorkshopHub`) | P (`scripts/workshop.gd`, walkable 3D) | TODO |
| Persistent inventory | S (JSON ledger) | P (`WorkshopInventory` + `WorldSeed` JSON) | TODO |
| Forge | S (`ForgeStation`) | P as Tetris Forge Foundry | TODO |
| Assembly | S (`AssemblyStation` timer job) | P as `SeedAssembly` WorldSeed resource (graph, not a timer station) | TODO |
| TETRAFORGE (named) | S (`TetraForgeStation` recipes) | N (name not found) | TODO |
| Tetris Forge Foundry | S (`TetrisForgeFoundry` material-receipt stub; no tetromino grid) | P (`forge_foundry.gd` + `tetromino_grid.gd`) | TODO |
| Coral growth vats | S | S / environmental (Biomineral Foundry room; no vat script) | TODO |
| Resin printer | S | S / environmental (Fabrication Array) | TODO |
| 3D printer | S | S / environmental (Fabrication Array, six vats) | TODO |
| Arc welder | S | N as a named script | TODO |
| Lathe | S | N as a named script | TODO |
| Quantum table | S (timer stub + canon description) | N as a named script (described in owner canon / world bible) | TODO |
| DNA wormhole helix portal | S (`DnaWormholeHelixPortal` transfer hold) | P as environmental Galactic Ether Relay / DNA helix aperture (not an inventory API of this name) | TODO |
| Loft stock exchange / visor chip | S (`TryBuildVisorChipUpgrade`) | P (K key at exchange console) | TODO |
| WorldSeed lattice / tetra mesher | N | P (`worldseed/`) | TODO |
| Intake docks (Mouse Maze, Dig Dug, Breakout, Frogger, Asteroids, Space Invaders) | N | S (placed and routed; game loops not implemented) | TODO |
| Vehicles | N | TODO | TODO |
| Docking (physical) | N | TODO | TODO |

## Procedure log

Record each measurement run here (date in America/Los_Angeles, operator, build hashes, raw notes). Do not backfill.

| Date (PT) | Metric | Engine | Result | Raw notes / link |
|---|---|---|---|---|
| TODO | TODO | TODO | TODO | TODO |
