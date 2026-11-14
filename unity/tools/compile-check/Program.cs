using System;
using System.Collections.Generic;
using System.IO;
using Gertech.Core;
using Gertech.Inventory;
using Gertech.Stations;
using Gertech.Tetraforge;
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
