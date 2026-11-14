using System;
using System.Collections.Generic;
using System.Text;

namespace Gertech.Inventory
{
    /// <summary>
    /// Mutable item and equipment ledger. Item ids align with Godot
    /// <c>WorldSeed.inventory</c> / <c>WorkshopInventory</c>.
    /// </summary>
    public sealed class Inventory
    {
        public event Action Changed;

        readonly Dictionary<string, int> stacks;
        readonly Dictionary<string, int> equipment;

        public int FoundryRuns { get; set; }
        public string RealmId { get; set; }

        public Inventory()
            : this(ItemIds.CreateStarterStock(), ItemIds.CreateStarterEquipment(), 0, "gertech_aqua_world")
        {
        }

        public Inventory(
            Dictionary<string, int> initialStacks,
            Dictionary<string, int> initialEquipment,
            int foundryRuns,
            string realmId)
        {
            stacks = new Dictionary<string, int>(initialStacks ?? ItemIds.CreateStarterStock());
            equipment = new Dictionary<string, int>(initialEquipment ?? ItemIds.CreateStarterEquipment());
            FoundryRuns = Math.Max(0, foundryRuns);
            RealmId = string.IsNullOrEmpty(realmId) ? "gertech_aqua_world" : realmId;
        }

        public IReadOnlyDictionary<string, int> Stacks => stacks;
        public IReadOnlyDictionary<string, int> Equipment => equipment;

        public int Amount(string itemId)
        {
            if (string.IsNullOrEmpty(itemId)) return 0;
            int value;
            return stacks.TryGetValue(itemId, out value) ? Math.Max(0, value) : 0;
        }

        public int EquipmentAmount(string key)
        {
            if (string.IsNullOrEmpty(key)) return 0;
            int value;
            return equipment.TryGetValue(key, out value) ? Math.Max(0, value) : 0;
        }

        public void SetEquipment(string key, int value)
        {
            if (string.IsNullOrEmpty(key)) return;
            equipment[key] = Math.Max(0, value);
            RaiseChanged();
        }

        public bool CanConsume(IEnumerable<ItemStack> costs)
        {
            if (costs == null) return true;
            foreach (var stack in costs)
            {
                if (!stack.IsValid) continue;
                if (Amount(stack.itemId) < stack.count) return false;
            }
            return true;
        }

        public bool CanConsume(IReadOnlyDictionary<string, int> costs)
        {
            if (costs == null) return true;
            foreach (var pair in costs)
            {
                if (pair.Value < 0) return false;
                if (Amount(pair.Key) < pair.Value) return false;
            }
            return true;
        }

        public bool Consume(IEnumerable<ItemStack> costs)
        {
            if (!CanConsume(costs)) return false;
            if (costs == null) return true;
            foreach (var stack in costs)
            {
                if (!stack.IsValid) continue;
                stacks[stack.itemId] = Amount(stack.itemId) - stack.count;
            }
            RaiseChanged();
            return true;
        }

        public bool Consume(IReadOnlyDictionary<string, int> costs)
        {
            if (!CanConsume(costs)) return false;
            if (costs == null) return true;
            foreach (var pair in costs)
            {
                if (pair.Value == 0) continue;
                stacks[pair.Key] = Amount(pair.Key) - pair.Value;
            }
            RaiseChanged();
            return true;
        }

        public void Add(string itemId, int count)
        {
            if (string.IsNullOrEmpty(itemId) || count == 0) return;
            stacks[itemId] = Math.Max(0, Amount(itemId) + count);
            RaiseChanged();
        }

        public void Add(IEnumerable<ItemStack> outputs)
        {
            if (outputs == null) return;
            bool any = false;
            foreach (var stack in outputs)
            {
                if (!stack.IsValid) continue;
                stacks[stack.itemId] = Math.Max(0, Amount(stack.itemId) + stack.count);
                any = true;
            }
            if (any) RaiseChanged();
        }

        public void Add(IReadOnlyDictionary<string, int> outputs)
        {
            if (outputs == null) return;
            bool any = false;
            foreach (var pair in outputs)
            {
                if (string.IsNullOrEmpty(pair.Key) || pair.Value == 0) continue;
                stacks[pair.Key] = Math.Max(0, Amount(pair.Key) + pair.Value);
                any = true;
            }
            if (any) RaiseChanged();
        }

        /// <summary>
        /// Mirrors Godot <c>WorldSeed.apply_material_receipt</c>: consume inputs, then credit outputs.
        /// </summary>
        public bool ApplyMaterialReceipt(IReadOnlyDictionary<string, int> consumed, IReadOnlyDictionary<string, int> produced)
        {
            if (!CanConsume(consumed)) return false;
            Consume(consumed);
            Add(produced);
            return true;
        }

        public void ReplaceFrom(Dictionary<string, int> newStacks, Dictionary<string, int> newEquipment, int foundryRuns, string realmId)
        {
            stacks.Clear();
            if (newStacks != null)
            {
                foreach (var pair in newStacks)
                    stacks[pair.Key] = Math.Max(0, pair.Value);
            }
            equipment.Clear();
            if (newEquipment != null)
            {
                foreach (var pair in newEquipment)
                    equipment[pair.Key] = Math.Max(0, pair.Value);
            }
            FoundryRuns = Math.Max(0, foundryRuns);
            if (!string.IsNullOrEmpty(realmId)) RealmId = realmId;
            RaiseChanged();
        }

        public string Summary()
        {
            var sb = new StringBuilder();
            sb.AppendFormat(
                "ORE {0}  |  SALVAGE {1}  |  PURE {2}  |  PACKED {3}  |  BLANKS {4}  |  SCRAP {5}  |  VISOR CHIPS {6}",
                Amount(ItemIds.Ore),
                Amount(ItemIds.Salvage),
                Amount(ItemIds.PureComponent),
                Amount(ItemIds.PackedBlock),
                Amount(ItemIds.ForgedBlank),
                Amount(ItemIds.Scrap),
                EquipmentAmount(ItemIds.EquipmentVisorChipCapacity));
            return sb.ToString();
        }

        void RaiseChanged()
        {
            var handler = Changed;
            if (handler != null) handler();
        }
    }
}
