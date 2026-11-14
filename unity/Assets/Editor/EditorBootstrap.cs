using System.Collections.Generic;
using Gertech.Core;
using Gertech.Inventory;
using Gertech.Stations;
using Gertech.Tetraforge;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace Gertech.EditorTools
{
    /// <summary>
    /// Builds ScriptableObject data and a playable Workshop Hub scene.
    /// Menu: GERTECH / Build Workshop Hub Scene
    /// </summary>
    public static class EditorBootstrap
    {
        const string ItemsDir = "Assets/Data/Items";
        const string StationsDir = "Assets/Data/Stations";
        const string RecipesDir = "Assets/Data/Recipes";
        const string ScenePath = "Assets/Scenes/WorkshopHub.unity";

        [MenuItem("GERTECH/Build Workshop Hub Scene")]
        public static void BuildWorkshopHubScene()
        {
            EnsureFolders();

            var items = CreateItems();
            var recipes = CreateRecipes();
            var defs = CreateStationDefinitions();

            if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                return;

            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

            var camGo = new GameObject("Main Camera", typeof(Camera));
            camGo.tag = "MainCamera";
            camGo.transform.position = new Vector3(0f, 8f, -18f);
            camGo.transform.rotation = Quaternion.Euler(20f, 0f, 0f);
            var camera = camGo.GetComponent<Camera>();
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = new Color(0.03f, 0.05f, 0.09f);

            var lightGo = new GameObject("Directional Light", typeof(Light));
            var light = lightGo.GetComponent<Light>();
            light.type = LightType.Directional;
            lightGo.transform.rotation = Quaternion.Euler(50f, -30f, 0f);

            var floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
            floor.name = "Hub Floor";
            floor.transform.position = new Vector3(0f, -0.1f, 0f);
            floor.transform.localScale = new Vector3(24f, 0.2f, 16f);

            var hubGo = new GameObject("WorkshopHub");
            var hub = hubGo.AddComponent<WorkshopHub>();
            hubGo.AddComponent<AutosaveOnQuit>();

            var portalGo = new GameObject("DnaWormholeHelixPortal");
            portalGo.transform.SetParent(hubGo.transform, false);
            portalGo.transform.position = new Vector3(0f, 0f, -6f);
            var portal = portalGo.AddComponent<DnaWormholeHelixPortal>();
            hub.BindPortal(portal);

            PlaceStation<ForgeStation>(hubGo.transform, "Forge", new Vector3(-8f, 0f, 0f), defs["forge"]);
            PlaceStation<AssemblyStation>(hubGo.transform, "Assembly", new Vector3(-5f, 0f, 0f), defs["assembly"]);
            PlaceStation<CoralGrowthVatStation>(hubGo.transform, "CoralGrowthVats", new Vector3(-2f, 0f, 0f), defs["coral_growth_vats"]);
            PlaceStation<ResinPrinterStation>(hubGo.transform, "ResinPrinter", new Vector3(1f, 0f, 0f), defs["resin_printer"]);
            PlaceStation<ThreeDPrinterStation>(hubGo.transform, "ThreeDPrinter", new Vector3(4f, 0f, 0f), defs["three_d_printer"]);
            PlaceStation<ArcWelderStation>(hubGo.transform, "ArcWelder", new Vector3(7f, 0f, 0f), defs["arc_welder"]);
            PlaceStation<LatheStation>(hubGo.transform, "Lathe", new Vector3(-8f, 0f, 4f), defs["lathe"]);
            PlaceStation<QuantumTableStation>(hubGo.transform, "QuantumTable", new Vector3(-4f, 0f, 4f), defs["quantum_table"]);

            var tetraGo = PlaceStation<TetraForgeStation>(hubGo.transform, "TetraForge", new Vector3(0f, 0f, 4f), defs["tetraforge"]);
            tetraGo.GetComponent<TetraForgeStation>().SetRecipes(new List<CraftingRecipe>
            {
                recipes["packed_block_from_ore"],
                recipes["forged_blank_mix"],
                recipes["visor_chip_stock"]
            });

            PlaceStation<TetrisForgeFoundry>(hubGo.transform, "TetrisForgeFoundry", new Vector3(4f, 0f, 4f), defs["tetris_forge_foundry"]);

            hub.DiscoverStations();
            EditorSceneManager.SaveScene(scene, ScenePath);
            AssetDatabase.Refresh();
            Debug.Log("[GERTECH] Workshop hub scene saved to " + ScenePath + ". Items: " + items.Count + ".");
        }

        static T PlaceStation<T>(Transform parent, string objectName, Vector3 position, StationDefinition definition)
            where T : StationBase
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.name = objectName;
            go.transform.SetParent(parent, false);
            go.transform.position = position + new Vector3(0f, 0.5f, 0f);
            go.transform.localScale = new Vector3(1.2f, 1f, 1.2f);
            var station = go.AddComponent<T>();
            station.Definition = definition;
            return station as T;
        }

        static void EnsureFolders()
        {
            CreateFolder("Assets", "Data");
            CreateFolder("Assets/Data", "Items");
            CreateFolder("Assets/Data", "Stations");
            CreateFolder("Assets/Data", "Recipes");
            CreateFolder("Assets", "Scenes");
        }

        static void CreateFolder(string parent, string name)
        {
            if (!AssetDatabase.IsValidFolder(parent + "/" + name))
                AssetDatabase.CreateFolder(parent, name);
        }

        static Dictionary<string, ItemDefinition> CreateItems()
        {
            var map = new Dictionary<string, ItemDefinition>();
            AddItem(map, ItemIds.Ore, "Ore", "Raw ore staging stock (Godot starter).");
            AddItem(map, ItemIds.Soil, "Soil", "Growth medium.");
            AddItem(map, ItemIds.Salvage, "Salvage", "Reclaimed parts.");
            AddItem(map, ItemIds.PureComponent, "Pure Component", "Refined component stock.");
            AddItem(map, ItemIds.Alloy, "Alloy", "Mixed metal stock.");
            AddItem(map, ItemIds.PackedBlock, "Packed Block", "Crystallized foundry row output.");
            AddItem(map, ItemIds.ForgedBlank, "Forged Blank", "Foundry / forge blank.");
            AddItem(map, ItemIds.StabilizedFrame, "Stabilized Frame", "Salvage-rich foundry frame.");
            AddItem(map, ItemIds.Scrap, "Scrap", "Residual chamber material.");
            AddItem(map, ItemIds.Food, "Food", "Colony / exhibit feed (Godot key, unused by stubs).");
            AddItem(map, ItemIds.LaborToken, "Labor Token", "Godot ledger key.");
            AddItem(map, ItemIds.DefenseTech, "Defense Tech", "Godot ledger key.");
            AddItem(map, ItemIds.Core, "Core", "Godot ModuleTypes core.");
            AddItem(map, ItemIds.CalciteGear, "Calcite Gear", "Biomineral / coral-vat grown gear.");
            AddItem(map, ItemIds.ResinPart, "Resin Part", "Cured resin print.");
            AddItem(map, ItemIds.PrintedComponent, "Printed Component", "General 3D-printed part.");
            AddItem(map, ItemIds.Weldment, "Weldment", "Arc-welded assembly.");
            AddItem(map, ItemIds.TurnedBlank, "Turned Blank", "Lathe output.");
            AddItem(map, ItemIds.EtchedSubstrate, "Etched Substrate", "Quantum table etched layer stack.");
            return map;
        }

        static void AddItem(Dictionary<string, ItemDefinition> map, string id, string display, string description)
        {
            var path = ItemsDir + "/" + id + ".asset";
            var asset = AssetDatabase.LoadAssetAtPath<ItemDefinition>(path);
            if (asset == null)
            {
                asset = ScriptableObject.CreateInstance<ItemDefinition>();
                AssetDatabase.CreateAsset(asset, path);
            }
            asset.Configure(id, display, description);
            EditorUtility.SetDirty(asset);
            map[id] = asset;
        }

        static Dictionary<string, CraftingRecipe> CreateRecipes()
        {
            var map = new Dictionary<string, CraftingRecipe>();
            AddRecipe(map, "packed_block_from_ore", "Packed Block from Ore",
                "Simplified stand-in for a crystallized foundry row (Godot spends 4 units per locked tetromino).",
                3f,
                new[] { new ItemStack(ItemIds.Ore, 4) },
                new[] { new ItemStack(ItemIds.PackedBlock, 1) });
            AddRecipe(map, "forged_blank_mix", "Forged Blank Mix",
                "Ore plus pure component, analogous to an alloy-enabled foundry row.",
                4f,
                new[] { new ItemStack(ItemIds.Ore, 2), new ItemStack(ItemIds.PureComponent, 2) },
                new[] { new ItemStack(ItemIds.ForgedBlank, 1) });
            AddRecipe(map, "visor_chip_stock", "Visor Chip Stock",
                "Same cost as the Godot loft stock exchange upgrade, emitted as packed work rather than equipment.",
                5f,
                new[] { new ItemStack(ItemIds.PackedBlock, 4), new ItemStack(ItemIds.ForgedBlank, 1) },
                new[] { new ItemStack(ItemIds.PrintedComponent, 1) });
            return map;
        }

        static void AddRecipe(
            Dictionary<string, CraftingRecipe> map,
            string id,
            string display,
            string description,
            float seconds,
            ItemStack[] inputs,
            ItemStack[] outputs)
        {
            var path = RecipesDir + "/" + id + ".asset";
            var asset = AssetDatabase.LoadAssetAtPath<CraftingRecipe>(path);
            if (asset == null)
            {
                asset = ScriptableObject.CreateInstance<CraftingRecipe>();
                AssetDatabase.CreateAsset(asset, path);
            }
            asset.Configure(id, display, description, seconds, inputs, outputs);
            EditorUtility.SetDirty(asset);
            map[id] = asset;
        }

        static Dictionary<string, StationDefinition> CreateStationDefinitions()
        {
            var map = new Dictionary<string, StationDefinition>();
            AddDef(map, StationIds.Forge, "Forge", "Consumes ore, yields a forged blank.", 2.5f,
                new[] { new ItemStack(ItemIds.Ore, 4) },
                new[] { new ItemStack(ItemIds.ForgedBlank, 1) },
                "Tetris Forge Foundry (related)");
            AddDef(map, StationIds.Assembly, "Assembly", "Packed block plus blank become a stabilized frame.", 3f,
                new[] { new ItemStack(ItemIds.PackedBlock, 2), new ItemStack(ItemIds.ForgedBlank, 1) },
                new[] { new ItemStack(ItemIds.StabilizedFrame, 1) },
                "SeedAssembly / living-metal articulated frame");
            AddDef(map, StationIds.CoralGrowthVats, "Coral Growth Vats", "Grows calcite gears from soil and salvage.", 6f,
                new[] { new ItemStack(ItemIds.Soil, 1), new ItemStack(ItemIds.Salvage, 2) },
                new[] { new ItemStack(ItemIds.CalciteGear, 1) },
                "01 / Biomineral Foundry");
            AddDef(map, StationIds.ResinPrinter, "Resin Printer", "Prints a resin part from pure components.", 4f,
                new[] { new ItemStack(ItemIds.PureComponent, 2) },
                new[] { new ItemStack(ItemIds.ResinPart, 1) },
                "04 / Fabrication Array");
            AddDef(map, StationIds.ThreeDPrinter, "3D Printer", "Prints a general component from packed stock.", 4f,
                new[] { new ItemStack(ItemIds.PackedBlock, 1), new ItemStack(ItemIds.PureComponent, 1) },
                new[] { new ItemStack(ItemIds.PrintedComponent, 1) },
                "04 / Fabrication Array");
            AddDef(map, StationIds.ArcWelder, "Arc Welder", "Welds salvage into a weldment.", 3f,
                new[] { new ItemStack(ItemIds.Salvage, 3) },
                new[] { new ItemStack(ItemIds.Weldment, 1) },
                null);
            AddDef(map, StationIds.Lathe, "Lathe", "Turns a forged blank.", 3f,
                new[] { new ItemStack(ItemIds.ForgedBlank, 1) },
                new[] { new ItemStack(ItemIds.TurnedBlank, 1) },
                null);
            AddDef(map, StationIds.QuantumTable, "Quantum Table",
                "Micronized android avatar etches a substrate from pure components.", 5f,
                new[] { new ItemStack(ItemIds.PureComponent, 2) },
                new[] { new ItemStack(ItemIds.EtchedSubstrate, 1) },
                "Quantum table (canon; not a separate Godot class)");
            AddDef(map, StationIds.TetraForge, "TETRAFORGE", "Recipe-driven multi-input crafter. Recipes override these default stacks.", 3f,
                new[] { new ItemStack(ItemIds.Ore, 4) },
                new[] { new ItemStack(ItemIds.PackedBlock, 1) },
                "No Godot TETRAFORGE module; see Tetris Forge Foundry");
            AddDef(map, StationIds.TetrisForgeFoundry, "Tetris Forge Foundry",
                "Stub of the Godot playable foundry. Material receipts are computed in code, not from these stacks.", 0.1f,
                new ItemStack[0],
                new ItemStack[0],
                "07 / TETRIS FORGE FOUNDRY");
            return map;
        }

        static void AddDef(
            Dictionary<string, StationDefinition> map,
            string id,
            string display,
            string description,
            float seconds,
            ItemStack[] inputs,
            ItemStack[] outputs,
            string godotName)
        {
            var path = StationsDir + "/" + id + ".asset";
            var asset = AssetDatabase.LoadAssetAtPath<StationDefinition>(path);
            if (asset == null)
            {
                asset = ScriptableObject.CreateInstance<StationDefinition>();
                AssetDatabase.CreateAsset(asset, path);
            }
            asset.Configure(id, display, description, seconds, inputs, outputs, godotName);
            EditorUtility.SetDirty(asset);
            map[id] = asset;
        }
    }
}
