using Gertech.Inventory;
using UnityEngine;

namespace Gertech.Core
{
    /// <summary>
    /// Placeholder for item transfer into and out of the workshop.
    /// Named for the DNA wormhole helix / Godot "05 / GALACTIC ETHER RELAY"
    /// ("DOUBLE HELIX OPENS THE POCKET DIMENSION") that is the pocket-dimension
    /// aperture on the Aqua Workshop floor. This is a transfer portal, not a
    /// crafting station.
    /// </summary>
    public sealed class DnaWormholeHelixPortal : MonoBehaviour
    {
        [SerializeField] string displayName = "DNA Wormhole Helix / Galactic Ether Relay";

        Inventory.Inventory workshop;
        readonly Inventory.Inventory transit = new Inventory.Inventory(
            new System.Collections.Generic.Dictionary<string, int>(),
            new System.Collections.Generic.Dictionary<string, int>(),
            0,
            "helix_transit");

        public string DisplayName => displayName;
        public Inventory.Inventory TransitHold => transit;

        public void Bind(Inventory.Inventory workshopInventory)
        {
            workshop = workshopInventory;
        }

        public bool TryTransferIntoWorkshop(string itemId, int count)
        {
            if (workshop == null || string.IsNullOrEmpty(itemId) || count <= 0) return false;
            if (transit.Amount(itemId) < count) return false;
            if (!transit.Consume(new[] { new ItemStack(itemId, count) })) return false;
            workshop.Add(itemId, count);
            return true;
        }

        public bool TryTransferOutOfWorkshop(string itemId, int count)
        {
            if (workshop == null || string.IsNullOrEmpty(itemId) || count <= 0) return false;
            if (!workshop.Consume(new[] { new ItemStack(itemId, count) })) return false;
            transit.Add(itemId, count);
            return true;
        }

        /// <summary>Places items into the transit hold (outside the workshop) so they can be transferred in.</summary>
        public void DepositToTransit(string itemId, int count)
        {
            transit.Add(itemId, count);
        }
    }
}
