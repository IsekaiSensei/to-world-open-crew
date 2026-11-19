# TO FAIRY / GERTECH — modular World Seed and save-memory instructions
**Owner correction — 18 November 2026. Status: controlling design and migration policy; source implementation NOT owner-verified.**

## What was being explained, not newly invented
The TO FAIRY low-poly fantasy realm and a modular spacecraft are two presentations of the SAME mechanics. The World Seed generates an actually traversable 3D mass of constructible Platonic solids and rooms, not just vertices, Delaunay edges, or wireframe/lattice art. The generated mass is initially too large to move. A player must tumble/navigate out through its 3D rooms. A solver checks initial passability; human play attempts and times rate difficulty and reject excessive frustration. Then players mine and detach components, install mechanisms and power, rearrange real geometry, and make portions into spacecraft. Any removal/movement changes collision and may block the path back to dense central resources. The humans teach the fairies gears, electronics, digital circuitry and how to move their previously stationary spawners.

## Current executable foundation direction
A single initial WORKSHOP can physically fabricate/attach further 3D room modules and more buildable solids without a predetermined end; the world accumulates. Low-poly/cartoon physics are the feasible visual/gameplay abstraction for planetary/solar-system engineering, not a reason to remove construction consequences. The five Platonic solids require actual closed meshes, collision, distinct IDs, transforms, and meaningful ports. Graph data is subordinate support, never the only artifact. Detachable rooms, propulsion and spawner relocation are progression, not powers present on Day 1.

A SEPARATE source-only draft 'GERTECH_Pocket_Gertrude_WorldSeed_v2_UNVERIFIED.zip' was created from the owner's Day 01 connected room source in the 18 Nov 2026 chat. It contains 3D room floors/walls/door collision, powered links, a fabrication workbench that places any of five volumetric solids, an expandable room registry and v2 persistence. Geometry-math and static checks passed. **The Godot engine has NOT run it; no playable or owner-approved claim is authorized.** The previous Day 01 2D ZIP and 82-file GERTECH_Aqua_Workshop are unchanged.

## The SAVE FILE is the memory
Preserve original file bytes and stable world/entity/room/solid/spawner/part IDs; transforms, ports, topology, inventory, power/circuits, player/discovery state and events. Each feature is a real durable state transition; new events must never fabricate prior history. Before any rewrite import the last owner-accepted build/save and perform versioned, reversible migrations. Never silently reset progress or overwrite user://pocket_gertrude_day01.json, user://gertech_worldseed_v1.json, or user://gertech_workshop.cfg.

The older Aqua Workshop worldseed_v1 JSON contains realm_id, vertices, edges, assemblies, tetras, inventory, equipment, event_log, next_ids and foundry_runs. Its model is distinct from the later Day 01 grid/door JSON. The v2 draft preserves original Day 01 JSON in a distinct new save and can hold copied older Aqua Workshop source as explicitly **unmerged** archived data; semantic integration of the old graph and physical 3D world is NOT done. No cross-world state conversion or source merge should be claimed until mappings are reviewed and tested.

## Execution and quality gates
1. Locate actual latest source and save bytes; preserve originals.
2. Distinguish owner's explanatory history from explicit new work orders.
3. Implement the next minimal additive part in an isolated branch/copy; don't gut the previous game.
4. Show actual 3D geometry and effect, not mockups. Round-trip stable IDs and player changes through versioned save.
5. Test geometry, input, collision, links, inventory consistency and save migration IN GODOT; report static-only checks separately.
6. Promote only after owner acceptance and Godot runtime verification. Follow subsequent approved builds rather than regenerating Day 1.

Controlling World Bible: https://docs.google.com/document/d/1wiIjBtDvhunHwL7XHHaK-IFejjtd4SeIq-0z6vG7ofE/edit

Current owner orders: https://docs.google.com/document/d/1qHzHhlbDweQQrqcOT8rxuurhSO9SpKmRWs4iqY-CWzc/edit

Older TO FAIRY research: https://docs.google.com/document/d/1AcvfYaYAXq2HpUs4c0WE3dFybbsp_bIPkqnqgghYu7k/edit

Previous Godot build handoff is LEGACY source evidence, not the new TO FAIRY runtime. Its existing saved state and private assets must remain intact.
