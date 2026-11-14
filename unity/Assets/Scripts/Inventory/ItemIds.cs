using System.Collections.Generic;

namespace Gertech.Inventory
{
    /// <summary>
    /// Stable item identifiers. Keys match the Godot WorldSeed STARTER_STOCK /
    /// ModuleTypes module strings, plus a few workshop fabrication outputs.
    /// </summary>
    public static class ItemIds
    {
        // Godot ModuleTypes / WorldSeed inventory keys
        public const string Ore = "ore";
        public const string Soil = "soil";
        public const string Salvage = "salvage";
        public const string PureComponent = "pure_component";
        public const string Alloy = "alloy";
        public const string PackedBlock = "packed_block";
        public const string ForgedBlank = "forged_blank";
        public const string StabilizedFrame = "stabilized_frame";
        public const string Scrap = "scrap";
        public const string Food = "food";
        public const string LaborToken = "labor_token";
        public const string DefenseTech = "defense_tech";
        public const string Core = "core";

        // Additional fabrication outputs used by Unity station stubs
        public const string CalciteGear = "calcite_gear";
        public const string ResinPart = "resin_part";
        public const string PrintedComponent = "printed_component";
        public const string Weldment = "weldment";
        public const string TurnedBlank = "turned_blank";
        public const string EtchedSubstrate = "etched_substrate";

        public const string EquipmentVisorChipCapacity = "visor_chip_capacity";

        /// <summary>Starter quantities copied from Godot WorldSeed.STARTER_STOCK.</summary>
        public static Dictionary<string, int> CreateStarterStock()
        {
            return new Dictionary<string, int>
            {
                { Ore, 120 },
                { Salvage, 56 },
                { PureComponent, 16 },
                { Soil, 0 },
                { Food, 0 },
                { LaborToken, 0 },
                { PackedBlock, 0 },
                { StabilizedFrame, 0 },
                { ForgedBlank, 0 },
                { Alloy, 0 },
                { Scrap, 0 },
                { DefenseTech, 0 },
                { Core, 0 },
                { CalciteGear, 0 },
                { ResinPart, 0 },
                { PrintedComponent, 0 },
                { Weldment, 0 },
                { TurnedBlank, 0 },
                { EtchedSubstrate, 0 }
            };
        }

        public static Dictionary<string, int> CreateStarterEquipment()
        {
            return new Dictionary<string, int>
            {
                { EquipmentVisorChipCapacity, 1 }
            };
        }
    }
}
