# GERTECH reference PNGs

These textures are **provisional look-assist plates**, not canon. Godot (`../godot/GERTECH_Aqua_Workshop` in the repo, or the sibling Godot project) stays the source of truth for logic.

## Originals

All fourteen owner references live on the shared box at:

`/workspace/gertech_shared_refs/visual_2026-11-14/`

Copies in this folder are **downscaled** (longest edge 512 px) and saved as 256-color PNGs so they can ship through the GitHub file API. Use the originals at the path above when a higher-resolution assist is needed. A 1024 px set was prepared first but was too large for a single commit payload.

| File | Original px | Original bytes | Committed px |
|---|---|---|---|
| GERTECH_REF_01_fractal_vortex_spheres.png | 784x1168 | 1,255,244 | 344x512 |
| GERTECH_REF_02_platonic_frames_crystal_sphere_vortex.png | 784x1168 | 1,055,082 | 344x512 |
| GERTECH_REF_03_gold_cube_torus_sphere.png | 784x1168 | 966,320 | 344x512 |
| GERTECH_REF_04_polyhedra_column_helix_vortex.png | 784x1168 | 1,653,970 | 344x512 |
| GERTECH_REF_05_gold_rings_icosahedron_stack.png | 784x1168 | 1,547,790 | 344x512 |
| GERTECH_REF_06_voronoi_gold_silver_vortex.png | 784x1168 | 1,208,513 | 344x512 |
| GERTECH_REF_07_torus_vortex_sphere_tree.png | 784x1168 | 1,101,714 | 344x512 |
| GERTECH_REF_08_foam_lattice_golden_spiral.png | 784x1168 | 1,967,583 | 344x512 |
| GERTECH_REF_09_gold_polyhedra_spiral_chain.png | 784x1168 | 1,506,917 | 344x512 |
| GERTECH_REF_10_modular_crystal_block_sheet.png | 1448x1086 | 2,497,705 | 512x384 |
| GERTECH_REF_11_elemental_platonic_crystals.png | 2048x1152 | 1,132,834 | 512x288 |
| GERTECH_REF_12_crystal_to_android_growth_30.png | 1374x1145 | 2,400,144 | 512x427 |
| GERTECH_REF_13_helix_platonic_progression_30.png | 1374x1145 | 2,457,315 | 512x427 |
| GERTECH_REF_14_nebula_triangle_module.png | 2000x1378 | 831,260 | 512x353 |

Crops (from the originals, then downscaled):

- `crops/starfield_from_ref02.png` (512x512) — star-dust bands from REF_02, used as a sky/backdrop plate
- `crops/nebula_from_ref14.png` (512x486) — interior nebula of the REF_14 triangle, used inside the crystal block and triangle module
- `crops/modular_block_hero_from_ref10.png` (512x412) — featured cube from the REF_10 model sheet, used as a decal/plate

REF_12 and REF_13 are **6×5 sprite sheets** (30 frames). On the originals each cell is exactly 229×229 px. `GertechFlipbook` uses 6 columns × 5 rows with a small UV inset to hide the gold gutters.
