using System;

namespace Gertech.Inventory
{
    [Serializable]
    public struct ItemStack
    {
        public string itemId;
        public int count;

        public ItemStack(string itemId, int count)
        {
            this.itemId = itemId ?? string.Empty;
            this.count = count;
        }

        public bool IsValid => !string.IsNullOrEmpty(itemId) && count > 0;
    }
}
