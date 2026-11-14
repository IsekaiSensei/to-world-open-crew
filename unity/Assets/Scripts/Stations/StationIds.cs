namespace Gertech.Stations
{
    /// <summary>
    /// Stable station identifiers. Unity manufacturing stubs use the first block.
    /// Godot Aqua Workshop room ids are listed for name parity with the 01-07 signs
    /// in <c>scripts/workshop.gd</c>.
    /// </summary>
    public static class StationIds
    {
        public const string Forge = "forge";
        public const string Assembly = "assembly";
        public const string CoralGrowthVats = "coral_growth_vats";
        public const string ResinPrinter = "resin_printer";
        public const string ThreeDPrinter = "three_d_printer";
        public const string ArcWelder = "arc_welder";
        public const string Lathe = "lathe";
        public const string QuantumTable = "quantum_table";
        public const string TetraForge = "tetraforge";
        public const string TetrisForgeFoundry = "tetris_forge_foundry";

        // Godot walkable rooms / docks (environmental in the Godot package except Tetris Foundry)
        public const string BiomineralFoundry = "biomineral_foundry";
        public const string CrystalGrowth = "crystal_growth";
        public const string LivingMetalLab = "living_metal_lab";
        public const string FabricationArray = "fabrication_array";
        public const string GalacticEtherRelay = "galactic_ether_relay";
        public const string BehaviorMaze = "behavior_maze";
        public const string LoftStockExchange = "loft_stock_exchange";
    }
}
