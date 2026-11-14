using Gertech.Inventory;
using Gertech.Stations;
using UnityEngine;

namespace Gertech.Core
{
    /// <summary>
    /// Workshop authority: owns the persistent inventory, registers stations,
    /// ticks running jobs, and routes items into a named station or through
    /// the DNA wormhole helix portal. Mirrors the role of Godot
    /// <c>scripts/workshop.gd</c> + <c>workshop/inventory.gd</c>, without the
    /// walkable 3D environment.
    /// </summary>
    public sealed class WorkshopHub : MonoBehaviour
    {
        [SerializeField] DnaWormholeHelixPortal portal;
        [SerializeField] bool loadSaveOnAwake = true;

        readonly StationRegistry registry = new StationRegistry();
        Inventory.Inventory inventory;

        public StationRegistry Registry => registry;
        public Inventory.Inventory Inventory => inventory;
        public DnaWormholeHelixPortal Portal => portal;

        public void Awake()
        {
            EnsureInventory();
            if (loadSaveOnAwake)
                InventoryPersistence.Load(inventory);
            DiscoverStations();
            if (portal == null)
                portal = GetComponentInChildren<DnaWormholeHelixPortal>(true);
            if (portal != null)
                portal.Bind(inventory);
        }

        public void EnsureInventory()
        {
            if (inventory == null)
                inventory = new Inventory.Inventory();
        }

        public void DiscoverStations()
        {
            registry.Clear();
            var found = GetComponentsInChildren<StationBase>(true);
            for (int i = 0; i < found.Length; i++)
                registry.Register(found[i]);
        }

        public void RegisterStation(IStation station)
        {
            registry.Register(station);
        }

        void Update()
        {
            if (inventory == null) return;
            foreach (var station in registry.All)
                station.Tick(Time.deltaTime, inventory);
        }

        public bool TryStartStation(string stationId)
        {
            var station = registry.Get(stationId);
            if (station == null) return false;
            return station.TryStart(inventory);
        }

        /// <summary>
        /// Spends items from the workshop ledger to start a station job.
        /// Stations pull their own recipe or definition costs.
        /// </summary>
        public bool RouteToStation(string stationId)
        {
            return TryStartStation(stationId);
        }

        public bool TransferInThroughPortal(string itemId, int count)
        {
            return portal != null && portal.TryTransferIntoWorkshop(itemId, count);
        }

        public bool TransferOutThroughPortal(string itemId, int count)
        {
            return portal != null && portal.TryTransferOutOfWorkshop(itemId, count);
        }

        /// <summary>
        /// Godot loft stock exchange: 4 packed_block + 1 forged_blank -&gt; +1 visor_chip_capacity.
        /// </summary>
        public bool TryBuildVisorChipUpgrade()
        {
            if (inventory == null) return false;
            var cost = new[]
            {
                new ItemStack(ItemIds.PackedBlock, 4),
                new ItemStack(ItemIds.ForgedBlank, 1)
            };
            if (!inventory.Consume(cost)) return false;
            inventory.SetEquipment(
                ItemIds.EquipmentVisorChipCapacity,
                inventory.EquipmentAmount(ItemIds.EquipmentVisorChipCapacity) + 1);
            return true;
        }

        public bool SaveInventory()
        {
            return inventory != null && InventoryPersistence.Save(inventory);
        }

        public void BindPortal(DnaWormholeHelixPortal helixPortal)
        {
            portal = helixPortal;
            if (portal != null && inventory != null)
                portal.Bind(inventory);
        }
    }
}
