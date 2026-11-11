# GERTECH / AQUA WORKSHOP + LOFT FORGE FOUNDRY

**A Godot 4 project, not a screenplay or an environment sketch.** Open `project.godot` in Godot 4 and run the project. The main scene is `res://scenes/workshop.tscn`. The workshop is a navigable, 3D GERTECH factory beneath San Diego Bay, with an attached Tetris-style forge that deposits real results into the shared workshop inventory.

## Walkthrough space

- Arrive at the undersea observation hall with structural trusses, catwalk-like ceiling runs, seabed glass and service rails.
- Visit the **biomineral/shell foundry**: calcite growth, chalk gears, layered shells, carbon-mineral workbenches.
- Enter the **vacuum-crystal growth gallery**: five faceted reactors and seed inspection benches.
- Examine the **living-metal loom**: flexible open-weave tendon/limb constructs and an articulated assembly frame.
- Explore the **six-vat printing room**, with independent material feed pipes and numbered vats.
- Stand before the **DNA double-helix Galactic Ether Relay**, which opens the pocket-dimension seam.
- See the **Mouse Maze behavior exhibit**, with a visor mouse, chipped roach, snail, food and portal. This area is environmental, not an implemented maze game.
- Walk past seven **physical material-intake docks**: Mouse Maze / Dig Dug / Breakout / Frogger / Asteroids / Space Invaders / Tetris Foundry. Their goods travel through the loft overhead manifold. Only the Tetris foundry is playable in this package.
- Explore the new **Forge Foundry floor**: ore/salvage/alloy hoppers, row-casting chamber, heating crucible, 14-block/7-tier Loft specimen storage, output conveyor, central stock exchange.

## Controls

| Input | Workshop | Tetris Forge |
|---|---|---|
| WASD | Walk | A/D move, W rotate, S soft drop |
| Mouse | Look | Cursor available |
| Shift | Sprint | — |
| Space | Jump / rise when flying | Hard drop |
| N | Switch walk / free-fly | — |
| Ctrl | Descend in free-fly | — |
| H | Show/hide navigation HUD | — |
| E | Start forge when at operator console | — |
| K | Build visor chip upgrade at stock exchange | — |
| Arrow keys | — | Left/right move, up rotate, down soft drop |
| C | — | Hold/swap piece |
| P | — | Pause/unpause |
| Esc | Release pointer | End run, return to workshop, deposit results |

The forge operator console is on the **east/northeast side of the DNA chamber**, in front of the hot foundry. The `E` prompt appears when near it. The material exchange is on the foundry's inner side; it displays the `K` prompt when in range.

## Actual material process

The workshop initially has a labeled quantity of **staging stock** (ore, salvage, pure components). The forge receives only stock the workshop actually has. Every locked tetromino uses four material units. Alloy-enabled pieces mix pure components with base material. Filled rows crystallize into persistent `packed_block` items; salvage-rich rows can make `stabilized_frame`, alloy rows can yield `forged_blank`, and residual chamber material becomes `scrap` at the end of the run. When you return, the material receipts are deposited and saved to `user://gertech_workshop.cfg` (normal Godot per-user storage). Finished products appear physically on the shared conveyor. Forge heat, score, rows and piece holds are included in the result dictionary.

The workshop exchange can spend **4 packed blocks + 1 forged blank** to build increased mouse-visor chip capacity. That equipment is held in the workshop, with a method to inject it into a future maze config. **The complete Mouse Maze, Dig Dug, Frogger, Breakout, Space Invaders, and Asteroids game loops are not implemented**; their docks are positioned and routed as environmental infrastructure, not falsely claimed to be playable minigames.

## Scene and code boundaries

```text
scenes/workshop.tscn                  Original 3D workshop main scene
scripts/workshop.gd                  Full workshop environment, foundry, docks and HUD
scripts/explorer.gd                  3D first-person walk / free camera
workshop/inventory.gd                Persistent inventory, results, equipment
core/game_loop/minigame_interface.gd Generic result/config interface
core/tetris/tetromino_grid.gd        Theme-free tetromino grid/line rules
theme_foundry/forge_foundry.tscn     Foundry operator scene
theme_foundry/forge_foundry.gd       Visual theme and material-to-output mapping
```

**Independence rule:** the core scripts do not import `workshop/` or the foundry theme. The workshop owns material meaning and persistence; the foundry can be reused by any host that supplies `inputs` and receives `minigame_finished(result)`.

## Source and scope

- Extended the original `GERTECH_Aqua_Workshop` project created in this conversation, preserving the scene, structures, rooms and exploratory controls.
- The physical loft/foundry interpretation uses the owner's October 22, 2026 original Loft Codex and the present conversation's production graph and Tetris Forge Foundry direction.
- No external downloaded models, textures, shaders, plugins or internet services. All machines, labels and geometry are Godot nodes constructed by the scene script.
- Intended for Godot 4.x's **GL Compatibility** renderer, including lower-powered Linux devices and Steam Deck. Source and resource dependencies have been structurally reviewed. **A Godot executable was not available in this authoring environment, so an engine launch and on-device performance test could not be completed here.**


## Silhouette -> tetrahedra -> persistent GERTECH assembly (new)

**Press Y** while exploring. This uses a small, transparently labeled *generic demo silhouette* (not Ryan's vehicle) to create an actual connected 3D volume. The sampler reads the PNG's alpha mask, selects 2D cells, extrudes them into a small stack of 3D voxels, and splits each occupied voxel into **six face-conforming tetrahedra**. Every vertex, gold edge, tetra and Assembly goes into the existing `WorldSeed` save and event log; the renderer only displays stored geometry. This is more silhouette-faithful than unconstrained Delaunay over a concave object's point cloud. Boundary resolution is limited by the sampling cell size.

The source-to-WorldSeed API is `SilhouetteTetraMesher.build_from_image(seed, path, kind, options)`; it accepts an alpha-masked PNG. For clean solid-colored backgrounds you can try `options.mask_mode = "corner_color"`, but complex photos need a cutout/mask before they can give an accurate silhouette. Alternatively, call `build_from_outline(seed, normalized_polygon, kind, options)` to use an editable polygon directly. Both methods build **extrusions of 2D shapes**, not inferred full 3D anatomy or car geometry from a single photograph. The source image remains unchanged, and the original user references are not replaced by the demo.

The sampler does a connection and collision preflight, bounds the voxel count, builds gold joints and tetras from one shared topological grid, and creates a persistent Assembly. By default all new vertices are **EMPTY sockets**. The optional `place_from_inventory` spends actual `packed_block` units from the SAME WorldSeed inventory if available; it never grants free modules. `Y` tries to place at most six and does not repeat once its demo Assembly exists. Press `G` to grow the original Fairy lattice, `B` to occupy empty sockets from foundry stock, `V` for planar Delaunay, `T` for unconstrained 3D Delaunay of existing points.

**Different 3D procedures have different contracts:** `Delaunay3D` generates tetrahedra of a point cloud's convex hull and is useful for local free-form interiors, not a watertight representation of arbitrary concave silhouettes; the masked-cell tetra split preserves the accepted silhouette's voxelized domain by construction. It is not a constrained-Delaunay tetrahedralizer or an image-to-3D model generator. For arbitrary closed 3D imported meshes, a separate true mesh-interior sampling/collision stage is still required.

**Runtime limitations:** Source references and syntax structure have been inspected, but Godot 4 itself is not installed in the authoring container, so this ZIP is not yet engine-compiled, Steam-Deck-tested, or verified in a production export. Existing scenes and original GERTECH GLBs are retained. This adds no character identities, invented canon or changes to existing Google/Meta film orders.

## 2026-11-11 Visual / Reset pass (incremental)

- **F9 twice within 5 seconds:** from the **workshop**, clears WorldSeed vertices/edges/assemblies/tetrahedra, resets Foundry inventory/progress to starting stock, and returns the player to the entrance facing level. Fixed workshop architecture and the working Tetris Foundry code remain.
- One backup is saved to `user://gertech_worldseed_before_reset.json` before the persistent game ledger is reset.
- **Fresh games now begin with an empty construction graph** rather than automatically generating 36 starter vertices. The existing manual `G` key builds a scaffold on demand.
- Modular 3D cosmetic parts use batched gold frames, crystal shells, and procedurally shaded starfield interiors. They visualize *stored* WorldSeed vertices only. **Gold framing is decorative; valid connections are exclusively rendered from stored WorldSeed edges.**
- Two static crystal/gold sample modules sit on **existing arrival-gallery benches** so the look is visible without producing fake game items.
- Foundry script indentation normalized to tabs throughout to resolve the prior mixed-space parser error.
- This is a **visual prototype**. Nebula lighting and material quality will differ from reference JPEGs; images are art references, not extracted geometry or textures.
- **Godot runtime NOT tested here:** no Godot executable in this environment. The ZIP CRC, source diffs, and Python geometry tests were checked, but on-machine engine parser/import/fps still need verification.
