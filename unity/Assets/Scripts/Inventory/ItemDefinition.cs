using UnityEngine;

namespace Gertech.Inventory
{
    [CreateAssetMenu(fileName = "ItemDefinition", menuName = "GERTECH/Inventory/Item Definition", order = 0)]
    public sealed class ItemDefinition : ScriptableObject
    {
        [SerializeField] string id;
        [SerializeField] string displayName;
        [SerializeField] [TextArea] string description;
        [SerializeField] Sprite icon = null;

        public string Id => id;
        public string DisplayName => string.IsNullOrEmpty(displayName) ? id : displayName;
        public string Description => description;
        public Sprite Icon => icon;

        public void Configure(string itemId, string itemDisplayName, string itemDescription)
        {
            id = itemId;
            displayName = itemDisplayName;
            description = itemDescription;
        }
    }
}
