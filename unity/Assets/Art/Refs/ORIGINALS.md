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


## GitHub copies

The `.png` files in this folder on GitHub are **not valid PNGs**. They were published through a text-only file API that UTF-8-transcoded the bytes (file sizes on GitHub are ~1.5× the real PNGs). Do not use those blobs as textures.

Valid 512 px copies are stored as ASCII in `packed_512px_pngs.json`. After a clone, restore them with:

```bash
python3 tools/decode-art-refs.py
```

That overwrites the transcoded `.png` paths with the correct bytes (the working tree will show those files as modified until the transcoded blobs are removed from git). On this shared box, `/workspace/gertech-unity/Assets/Art/Refs/` already has valid 512 px files, and the originals remain at the path above.

REF_12 and REF_13 are **6×5 sprite sheets** (30 frames). On the originals each cell is exactly 229×229 px. `GertechFlipbook` uses 6 columns × 5 rows with a small UV inset to hide the gold gutters.

## Batch 2

Full-resolution copies: `/workspace/gertech_shared_refs/visual_2026-11-14_batch2/` (`INDEX.md` lists what arrived). Unity 512 px palette-reduced unique plates:

| File | Original px | Original bytes | Committed px |
|---|---|---|---|
| batch2/GERTECH_REF_15_hex_honeycomb_cyan_spiral.png | 784x1168 | 536,122 | 344x512 |
| batch2/GERTECH_REF_16_gold_silver_ornate_hex_spiral.png | 784x1168 | 473,882 | 344x512 |
| batch2/GERTECH_REF_17_gold_sphere_chain_spiral.png | 784x1168 | 303,360 | 344x512 |
| batch2/GERTECH_REF_18_starship_hull_sheet.png | 1448x1086 | 3,794,010 | 512x384 |
| batch2/GERTECH_REF_19_crystal_block_car_gertech_building.png | 1672x941 | 3,279,599 | 512x288 |

These are stored in `packed_512px_pngs.json` (do not push raw PNGs through the text file API). Restore with `python3 tools/decode-art-refs.py`.

Drive follow-up plates (originals in `/workspace/gertech_shared_refs/visual_2026-11-14_batch2/`, sourced from Drive folder `1wZLgBCGOoOL-r5bW4xJ95fyCS4F50ULT`):

| File | Original px | Original bytes | Committed px |
|---|---|---|---|
| batch2/GERTECH_REF_20_voronoi_gold_silver_cyan_blackhole.png | 784x1168 | 479,193 | 344x512 |
| batch2/GERTECH_REF_21_fractal_recursive_hex_voronoi.png | 784x1168 | 764,684 | 344x512 |
| batch2/GERTECH_REF_22_kepler_sphere_packing_spiral.png | 784x1168 | 289,117 | 344x512 |
| batch2/GERTECH_REF_23_star_tetrahedron_crystal_sphere.png | 784x1168 | 381,032 | 344x512 |
| batch2/GERTECH_REF_24_gold_chrome_hypercube_frame.png | 784x1168 | 196,422 | 344x512 |
| batch2/GERTECH_REF_25_wordless_modular_build_sheet.png | 2000x2000 | 497,906 | 512x512 |
| batch2/GERTECH_REF_26_assembled_modular_cluster.png | 1000x1000 | 142,799 | 512x512 |

Shader/camera pass plates (512 px packed; originals in `/workspace/gertech_shared_refs/visual_2026-11-14/` for 27/28 and `visual_2026-11-14_batch2/` for 29–35 and the guide stand-in):

| File | Original px | Motif |
|---|---|---|
| batch2/GERTECH_REF_27_crystal_block_world_hall.png | 1624x750 | Hall / room reference |
| batch2/GERTECH_REF_28_galaxy_crystal_machine_cluster.png | 750x749 | Machine cluster |
| batch2/GERTECH_REF_29_ether_relay_network.png | 1168x784 | Ether network |
| batch2/GERTECH_REF_30_ether_growth_progression_5x5.png | 1254x1254 | 5×5 progression |
| batch2/GERTECH_REF_31_ether_galaxy_node_interior.png | 784x1168 | Node interior |
| batch2/GERTECH_REF_32_ether_mana_flow_lattice.png | 784x1168 | Mana-flow lattice |
| batch2/GERTECH_REF_33_ether_dyson_orbital_relay.png | 1168x784 | Dyson / orbital relay |
| batch2/GERTECH_REF_34_gdr07_wormhole_icosahedron.png | 1600x1600 | Wormhole icosahedron |
| batch2/GERTECH_REF_35_gdr07_fleet_wormhole_cover.png | 2048x1152 | Fleet cover (has labels) |
| characters/GERTECH_WORKSHOP_GUIDE_STANDIN_PROVISIONAL_REFERENCE_11.png | 1024x1536 | Provisional guide stand-in |

