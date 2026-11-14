using System;
using System.Collections.Generic;
using System.IO;
using Gertech.Core;
using Gertech.Inventory;
using Gertech.Stations;
using Gertech.Tetraforge;
using Gertech.Look;
using Gertech.Core.Guide;
using UnityEngine;

namespace Gertech.CompileCheck
{
    public static class Program
    {
        public static int Main()
        {
            int failures = 0;
            Application.persistentDataPath = Path.Combine(Path.GetTempPath(), "gertech-unity-compile-check");
            if (Directory.Exists(Application.persistentDataPath))
                Directory.Delete(Application.persistentDataPath, true);
            Directory.CreateDirectory(Application.persistentDataPath);

            var inventory = new Gertech.Inventory.Inventory();
            if (inventory.Amount(ItemIds.Ore) != 120) Fail(ref failures, "starter ore");
            if (inventory.EquipmentAmount(ItemIds.EquipmentVisorChipCapacity) != 1) Fail(ref failures, "starter visor chips");

            if (!inventory.Consume(new[] { new ItemStack(ItemIds.Ore, 4) })) Fail(ref failures, "consume ore");
            if (inventory.Amount(ItemIds.Ore) != 116) Fail(ref failures, "ore remainder");
            inventory.Add(ItemIds.PackedBlock, 1);
            if (inventory.Amount(ItemIds.PackedBlock) != 1) Fail(ref failures, "add packed block");

            if (!InventoryPersistence.Save(inventory)) Fail(ref failures, "save");
            var reloaded = new Gertech.Inventory.Inventory();
            if (!InventoryPersistence.Load(reloaded)) Fail(ref failures, "load");
            if (reloaded.Amount(ItemIds.Ore) != 116) Fail(ref failures, "loaded ore");
            if (reloaded.Amount(ItemIds.PackedBlock) != 1) Fail(ref failures, "loaded packed block");
            if (reloaded.EquipmentAmount(ItemIds.EquipmentVisorChipCapacity) != 1) Fail(ref failures, "loaded equipment");

            var hubGo = new GameObject("WorkshopHub");
            var hub = hubGo.AddComponent<WorkshopHub>();
            var portal = hubGo.AddComponent<DnaWormholeHelixPortal>();
            var tetra = hubGo.AddComponent<TetraForgeStation>();
            var foundry = hubGo.AddComponent<TetrisForgeFoundry>();
            var forge = hubGo.AddComponent<ForgeStation>();

            var recipe = ScriptableObject.CreateInstance<CraftingRecipe>();
            recipe.Configure(
                "packed_block_from_ore",
                "Packed Block from Ore",
                "smoke",
                1f,
                new[] { new ItemStack(ItemIds.Ore, 4) },
                new[] { new ItemStack(ItemIds.PackedBlock, 1) });
            tetra.SetRecipes(new List<CraftingRecipe> { recipe });
            tetra.name = "TetraForge";

            var forgeDef = ScriptableObject.CreateInstance<StationDefinition>();
            forgeDef.Configure(
                StationIds.Forge,
                "Forge",
                "smoke",
                1f,
                new[] { new ItemStack(ItemIds.Ore, 4) },
                new[] { new ItemStack(ItemIds.ForgedBlank, 1) },
                null);
            forge.Definition = forgeDef;

            hub.Awake();
            if (hub.Registry.Count < 3) Fail(ref failures, "registry count " + hub.Registry.Count);

            int oreBeforeForge = hub.Inventory.Amount(ItemIds.Ore);
            if (!hub.RouteToStation(StationIds.Forge)) Fail(ref failures, "start forge");
            // Advance the 1s timer
            for (int i = 0; i < 80; i++)
                hub.Registry.Get(StationIds.Forge).Tick(0.05f, hub.Inventory);
            if (hub.Inventory.Amount(ItemIds.Ore) != oreBeforeForge - 4) Fail(ref failures, "forge consume");
            if (hub.Inventory.Amount(ItemIds.ForgedBlank) < 1) Fail(ref failures, "forge output");

            if (!hub.RouteToStation(StationIds.TetraForge)) Fail(ref failures, "start tetraforge");
            for (int i = 0; i < 40; i++)
                tetra.Tick(0.05f, hub.Inventory);
            if (hub.Inventory.Amount(ItemIds.PackedBlock) < 1) Fail(ref failures, "tetraforge output");

            int runsBefore = hub.Inventory.FoundryRuns;
            if (!foundry.TryStart(hub.Inventory)) Fail(ref failures, "tetris foundry stub");
            if (hub.Inventory.FoundryRuns != runsBefore + 1) Fail(ref failures, "foundry run count");
            if (hub.Inventory.Amount(ItemIds.PackedBlock) < 1) Fail(ref failures, "foundry packed block");

            portal.DepositToTransit(ItemIds.Salvage, 3);
            if (!hub.TransferInThroughPortal(ItemIds.Salvage, 2)) Fail(ref failures, "portal in");
            if (!hub.TransferOutThroughPortal(ItemIds.Salvage, 1)) Fail(ref failures, "portal out");
            if (portal.TransitHold.Amount(ItemIds.Salvage) != 2) Fail(ref failures, "transit remainder");

            hub.Inventory.Add(ItemIds.PackedBlock, 8);
            hub.Inventory.Add(ItemIds.ForgedBlank, 2);
            if (!hub.TryBuildVisorChipUpgrade()) Fail(ref failures, "visor upgrade");
            if (hub.Inventory.EquipmentAmount(ItemIds.EquipmentVisorChipCapacity) != 2)
                Fail(ref failures, "visor capacity");

            if (!hub.SaveInventory()) Fail(ref failures, "hub save");

            var gold = GertechLook.Hex(GertechLook.GoldHex);
            if (Math.Abs(gold.r - 0xBF / 255f) > 0.01f) Fail(ref failures, "gold hex");
            var palette = ScriptableObject.CreateInstance<GertechLookPalette>();
            palette.ResetToSampledDefaults();
            var goldMat = GertechMaterialFactory.Gold(palette);
            if (goldMat == null) Fail(ref failures, "gold material");
            var glass = GertechMaterialFactory.CrystalGlass(palette);
            if (glass == null) Fail(ref failures, "crystal glass");
            var torus = GertechProcMesh.Torus(1f, 0.2f, 8, 12);
            if (torus == null || torus.vertices == null || torus.vertices.Length == 0)
                Fail(ref failures, "torus mesh");
            var helixMesh = GertechProcMesh.TubeHelix(0.4f, 1.5f, 0.03f, 3, 24, 5, 0f);
            if (helixMesh == null || helixMesh.vertices == null || helixMesh.vertices.Length == 0)
                Fail(ref failures, "helix mesh");

            var visual = DnaWormholeHelixVisual.Attach(portal);
            if (visual == null) Fail(ref failures, "helix visual attach");
            visual.Palette = palette;
            visual.Rebuild();

            var blockGo = new GameObject("CrystalBlockTest");
            var block = blockGo.AddComponent<CrystalBlockBuilder>();
            block.Palette = palette;
            block.Rebuild();

            var triGo = new GameObject("TriangleTest");
            var tri = triGo.AddComponent<TriangleModuleBuilder>();
            tri.Palette = palette;
            tri.Rebuild();

            var flipGo = GameObject.CreatePrimitive(PrimitiveType.Quad);
            var flip = flipGo.AddComponent<GertechFlipbook>();
            flip.Configure(new Texture2D(64, 64), GertechFlipbook.RefSheetColumns, GertechFlipbook.RefSheetRows, 8f);
            flip.ShowFrame(7);
            if (flip.FrameCount != 30) Fail(ref failures, "flipbook 30 frames");

            var cam = new GameObject("Cam").AddComponent<Camera>();
            GertechBackdrop.ApplyCameraSpaceBackground(cam, palette);
            if (cam.backgroundColor.r != 0f) Fail(ref failures, "space black camera");

            var rowGo = new GameObject("ElementalRow");
            var row = rowGo.AddComponent<ElementalCrystalRow>();
            row.Rebuild();

            if (Math.Abs(GertechLook.Hex(GertechLook.NebulaVioletHex).r - 0x70 / 255f) > 0.01f)
                Fail(ref failures, "nebula violet hex");
            if (Math.Abs(GertechLook.Hex(GertechLook.GoldGlowHex).r - 0xDC / 255f) > 0.01f)
                Fail(ref failures, "gold glow hex");

            var carVoxels = ModularAssemblyPresets.CarHullSection();
            var torsoVoxels = ModularAssemblyPresets.HumanoidTorso();
            var clusterVoxels = ModularAssemblyPresets.MachineCluster();
            var shipVoxels = ModularAssemblyPresets.StarshipHullSection();
            if (carVoxels.Length < 8) Fail(ref failures, "car hull voxels");
            if (torsoVoxels.Length < 8) Fail(ref failures, "torso voxels");
            if (clusterVoxels.Length < 8) Fail(ref failures, "machine cluster voxels");
            if (shipVoxels.Length < 16) Fail(ref failures, "starship voxels");

            var gridGo = new GameObject("GridTest");
            var grid = gridGo.AddComponent<CrystalBlockGrid>();
            grid.Palette = palette;
            grid.SetVoxels(carVoxels);
            grid.Rebuild();
            if (grid.VoxelCount != carVoxels.Length) Fail(ref failures, "grid voxel count");
            grid.ApplyGrowth(0.2f);
            grid.ApplyGrowth(0.5f);
            grid.ApplyGrowth(1f);
            var growth = gridGo.AddComponent<CrystalBlockGrowth>();
            growth.Grid = grid;
            growth.Play();
            growth.StopAt(1f);

            var vehicle = CrystalBlockVehicle.Build(null, Vector3.zero, palette, null);
            if (vehicle == null || vehicle.Body == null) Fail(ref failures, "vehicle rigidbody");
            if (vehicle.Wheels == null || vehicle.Wheels.Length != 4) Fail(ref failures, "vehicle wheels");
            vehicle.SetDrive(10f, 8f);

            var ship = StarshipHull.Build(null, Vector3.zero, palette, null);
            if (ship == null || ship.DockingPort == null) Fail(ref failures, "starship docking port");
            var dockProbe = new GameObject("DockProbe");
            if (!ship.DockingPort.TryDock(dockProbe.transform)) Fail(ref failures, "dock");
            if (!ship.DockingPort.Occupied) Fail(ref failures, "dock occupied");
            ship.DockingPort.Undock();
            if (ship.DockingPort.Occupied) Fail(ref failures, "undock");

            var player = new GameObject("PlayerAnchor");
            player.transform.position = new Vector3(2f, 0f, 0f);
            var dialogue = GuideDialogue.CreateDefaultOnboarding();
            if (dialogue.Hints == null || dialogue.Hints.Length < 4) Fail(ref failures, "guide dialogue hints");
            if (dialogue.SpeakerName != GuideCharacter.DisplayName) Fail(ref failures, "guide speaker name");
            var guide = GuideCharacter.Build(null, Vector3.zero, palette, dialogue, player.transform);
            if (guide.Label != "Workshop Guide") Fail(ref failures, "guide label");
            if (!guide.PlayHint(0, forge.transform, tetra.transform, portal.transform))
                Fail(ref failures, "guide welcome hint");
            if (!guide.TryPointToId("forge", forge.transform, tetra.transform, portal.transform))
                Fail(ref failures, "guide point forge");
            guide.Follow(player.transform);
            guide.WaitNear(player.transform);

            if (failures == 0)
            {
                Console.WriteLine("PASS — runtime scripts compiled and smoke tests succeeded.");
                Console.WriteLine(hub.Inventory.Summary());
                Console.WriteLine("Save path: " + InventoryPersistence.SavePath);
                return 0;
            }

            Console.Error.WriteLine("FAIL — " + failures + " smoke assertion(s).");
            return 1;
        }

        static void Fail(ref int failures, string label)
        {
            failures++;
            Console.Error.WriteLine("assertion failed: " + label);
        }
    }
}
