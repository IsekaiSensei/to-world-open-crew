# GERTECH Unity Workshop

Parallel Unity (C#) scaffold of Ryan's GERTECH manufacturing universe, built for direct comparison with the Godot Aqua Workshop and the Roblox port.

**Source of truth:** the Godot project at [`../godot/GERTECH_Aqua_Workshop`](../godot/GERTECH_Aqua_Workshop) in this repository (`IsekaiSensei/to-world-open-crew`). Item ids, starter stock, foundry material rules, visor-chip upgrade, and workshop module names are copied from that tree.

Open this `unity/` folder in **Unity 6.3 LTS** (`6000.3.28f1` is the targeted editor version recorded in `ProjectSettings/ProjectVersion.txt`). Unity Editor / Hub are not assumed to be installed in every environment, and this tree does not include a signed-in license.

## How to open and build the hub scene

1. Install Unity Hub and Unity 6.3 LTS (6000.3.28f1 or another 6000.3 LTS patch).
2. In Hub, **Open** → choose this `unity/` folder (the directory that contains `Assets/`, `Packages/`, and `ProjectSettings/`).
3. Wait for first-time import. Unity will generate `.meta` files, a solution, and fill in missing Project Settings.
4. From the menu: **GERTECH → Build Workshop Hub Scene**. This creates:
   - `Assets/Data/Items/*.asset` — `ItemDefinition` ScriptableObjects
   - `Assets/Data/Stations/*.asset` — `StationDefinition` ScriptableObjects
   - `Assets/Data/Recipes/*.asset` — TETRAFORGE `CraftingRecipe` assets
   - `Assets/Scenes/WorkshopHub.unity` — hub with `WorkshopHub`, stations, and the DNA wormhole helix portal
5. Open `Assets/Scenes/WorkshopHub.unity` if it is not already active, and press Play.

The Editor script lives at `Assets/Editor/EditorBootstrap.cs`. You can also create definitions by hand from the **GERTECH** Create Asset menus.

## Layout

```text
Assets/Scripts/Core/          Gertech.Core     WorkshopHub, StationRegistry, AutosaveOnQuit,
                                               DnaWormholeHelixPortal
Assets/Scripts/Stations/      Gertech.Stations IStation, StationBase, StationDefinition,
                                               Forge, Assembly, coral growth vats, resin printer,
                                               3D printer, arc welder, lathe, quantum table
Assets/Scripts/Inventory/     Gertech.Inventory ItemDefinition, Inventory, InventoryPersistence
Assets/Scripts/Tetraforge/    Gertech.Tetraforge CraftingRecipe, TetraForgeStation,
                                               TetrisForgeFoundry (Godot foundry mapping stub)
Assets/Editor/                Scene / data bootstrap (Unity Editor only)
Assets/Data/                  ScriptableObject output (after bootstrap)
Packages/manifest.json        Built-in modules only
ProjectSettings/              Editor version (ProjectVersion.txt)
tools/compile-check/          Headless C# compile smoke test (not used by Unity)
```

Stations implement `IStation` (usually by subclassing `StationBase`) and register with `StationRegistry`. The hub discovers children and routes jobs; adding a station does not require changes to core routing.

## Inventory and saving

Item ids and starter counts match Godot `WorldSeed.STARTER_STOCK` / `ModuleTypes` in `../godot/GERTECH_Aqua_Workshop` (`ore` 120, `salvage` 56, `pure_component` 16, and the other zeroed ledger keys). Extra fabrication ids (`calcite_gear`, `resin_part`, `printed_component`, `weldment`, `turned_blank`, `etched_substrate`) are Unity-only outputs for the new station stubs.

JSON is written to `Application.persistentDataPath/gertech_worldseed_v1.json`, using the inventory subset of the Godot save (`version`, `realm_id`, `inventory`, `equipment`, `foundry_runs`). Godot's current save is `user://gertech_worldseed_v1.json`; a legacy `user://gertech_workshop.cfg` also exists in the Godot importer and is not read here. WorldSeed lattice data (vertices, edges, assemblies, tetras, event log) is not persisted in this scaffold. Autosave runs on quit via `AutosaveOnQuit`.

The loft stock exchange recipe from Godot (4 `packed_block` + 1 `forged_blank` → +1 `visor_chip_capacity`) is `WorkshopHub.TryBuildVisorChipUpgrade()`.

## Portal naming

Item transfer in and out of the workshop goes through `DnaWormholeHelixPortal`. That name refers to the DNA wormhole helix / Godot **05 / GALACTIC ETHER RELAY** ("DOUBLE HELIX OPENS THE POCKET DIMENSION"). Do not use other informal nicknames for this aperture in code or docs.

## Godot / Roblox (what this mirrors)

Canonical Godot project: [`../godot/GERTECH_Aqua_Workshop`](../godot/GERTECH_Aqua_Workshop). Project name: **GERTECH | Aqua Workshop + Forge Loft**. Main scene: `res://scenes/workshop.tscn` → `scripts/workshop.gd`. Godot 4.7, GL Compatibility.

- Playable systems in that package: walkable workshop rooms, `WorkshopInventory` (`workshop/inventory.gd`), Tetris Forge Foundry (`theme_foundry/forge_foundry.gd` + `core/tetris/tetromino_grid.gd`), WorldSeed lattice / `SeedAssembly` (`worldseed/`), minigame result interface. Mouse Maze, Dig Dug, Frogger, Breakout, Space Invaders, and Asteroids docks are environmental only.
- Godot rooms (workshop signs 01–07): Biomineral Foundry, Crystal Growth, Living Metal Lab, Fabrication Array (six printing vats), Galactic Ether Relay, Behavior Maze, Tetris Forge Foundry, plus loft stock exchange.
- No module or class named **TETRAFORGE** was found in the Godot tree. Unity therefore ships a recipe-driven `TetraForgeStation` and a material-mapping stub `TetrisForgeFoundry` for the Godot foundry.
- Coral growth vats, resin printer, 3D printer, arc welder, lathe, and the quantum table (micronized android avatar workbench) are canon workshop equipment; they are not separate Godot scripts in the Aqua Workshop package. They are stub stations here.
- The Roblox parallel lives in a sibling repository, [`IsekaiSensei/gertech-roblox`](https://github.com/IsekaiSensei/gertech-roblox), which also treats the Godot Aqua Workshop as source of truth.

See `COMPARISON.md` for the Unity vs Godot vs Roblox metrics template (values left blank).

## Compile check (no Unity Editor)

A .NET SDK can compile the runtime scripts against `tools/compile-check` UnityEngine stubs. That does **not** compile Editor scripts, does **not** import assets, and does **not** prove the project opens in Unity. From this `unity/` folder:

```bash
dotnet build tools/compile-check/GertechCompileCheck.csproj
dotnet run --project tools/compile-check/GertechCompileCheck.csproj
```
