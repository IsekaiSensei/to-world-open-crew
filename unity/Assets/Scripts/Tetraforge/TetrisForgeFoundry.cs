using System.Collections.Generic;
using Gertech.Inventory;
using Gertech.Stations;
using UnityEngine;

namespace Gertech.Tetraforge
{
    /// <summary>
    /// Unity stand-in for Godot <c>theme_foundry/forge_foundry.gd</c> plus
    /// <c>core/tetris/tetromino_grid.gd</c>, hosted from the workshop as
    /// "07 / TETRIS FORGE FOUNDRY". The full tetromino loop is not ported.
    /// A simplified foundry run applies the same material mapping:
    /// each locked piece spends 4 material units; cleared rows produce
    /// packed_block, salvage-rich rows also produce stabilized_frame,
    /// alloy / pure-rich rows produce forged_blank, and leftover chamber
    /// stock becomes scrap. Results are deposited through
    /// <see cref="Inventory.Inventory.ApplyMaterialReceipt"/>, matching
    /// Godot <c>WorkshopInventory.deposit_from_minigame</c>.
    /// </summary>
    public sealed class TetrisForgeFoundry : StationBase
    {
        [SerializeField] int targetLines = 8;
        [SerializeField] int unitsPerPiece = 4;
        [SerializeField] int estimatedPieces = 8;

        public override string StationId => StationIds.TetrisForgeFoundry;
        public override string DisplayName => "TETRIS / FORGE FOUNDRY";

        public override bool CanStart(Inventory.Inventory inventory)
        {
            if (IsBusy || inventory == null) return false;
            return inventory.Amount(ItemIds.Ore) + inventory.Amount(ItemIds.Salvage) + inventory.Amount(ItemIds.PureComponent) >= unitsPerPiece;
        }

        public override bool TryStart(Inventory.Inventory inventory)
        {
            if (!CanStart(inventory)) return false;
            // Consume a representative batch up front, then credit outputs immediately
            // as a stub for one completed foundry run. No tetromino grid is simulated.
            var consumed = BuildConsumed(inventory);
            if (consumed.Count == 0) return false;
            var produced = BuildProduced(consumed);
            if (!inventory.ApplyMaterialReceipt(consumed, produced)) return false;
            inventory.FoundryRuns += 1;
            return true;
        }

        public override void Tick(float deltaTime, Inventory.Inventory inventory)
        {
            // Instant stub run; nothing to tick. Override so StationBase does not
            // also apply StationDefinition inputs/outputs.
        }

        Dictionary<string, int> BuildConsumed(Inventory.Inventory inventory)
        {
            int budget = Mathf.Max(unitsPerPiece, estimatedPieces * unitsPerPiece);
            var consumed = new Dictionary<string, int>();
            Take(inventory, consumed, ItemIds.Ore, ref budget);
            Take(inventory, consumed, ItemIds.Salvage, ref budget);
            Take(inventory, consumed, ItemIds.PureComponent, ref budget);
            return consumed;
        }

        static void Take(Inventory.Inventory inventory, Dictionary<string, int> dest, string id, ref int budget)
        {
            if (budget <= 0) return;
            int take = Mathf.Min(budget, inventory.Amount(id));
            if (take <= 0) return;
            dest[id] = take;
            budget -= take;
        }

        Dictionary<string, int> BuildProduced(Dictionary<string, int> consumed)
        {
            int total = 0;
            foreach (var pair in consumed) total += pair.Value;
            int rows = Mathf.Max(1, total / Mathf.Max(1, unitsPerPiece * 2));
            rows = Mathf.Min(targetLines, rows);
            int salvage = 0;
            int pure = 0;
            int value;
            if (consumed.TryGetValue(ItemIds.Salvage, out value)) salvage = value;
            if (consumed.TryGetValue(ItemIds.PureComponent, out value)) pure = value;

            var produced = new Dictionary<string, int> { { ItemIds.PackedBlock, rows } };
            if (salvage >= 4) produced[ItemIds.StabilizedFrame] = Mathf.Max(1, salvage / 4);
            if (pure >= 2) produced[ItemIds.ForgedBlank] = Mathf.Max(1, pure / 2);
            int leftover = total - rows * unitsPerPiece;
            if (leftover > 0) produced[ItemIds.Scrap] = leftover;
            return produced;
        }
    }
}
