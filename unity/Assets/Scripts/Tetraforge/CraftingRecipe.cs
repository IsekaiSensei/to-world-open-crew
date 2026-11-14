using System.Collections.Generic;
using Gertech.Inventory;
using UnityEngine;

namespace Gertech.Tetraforge
{
    [CreateAssetMenu(fileName = "CraftingRecipe", menuName = "GERTECH/Tetraforge/Crafting Recipe", order = 0)]
    public sealed class CraftingRecipe : ScriptableObject
    {
        [SerializeField] string id;
        [SerializeField] string displayName;
        [SerializeField] [TextArea] string description;
        [SerializeField] float processSeconds = 3f;
        [SerializeField] List<ItemStack> inputs = new List<ItemStack>();
        [SerializeField] List<ItemStack> outputs = new List<ItemStack>();

        public string Id => id;
        public string DisplayName => string.IsNullOrEmpty(displayName) ? id : displayName;
        public string Description => description;
        public float ProcessSeconds => Mathf.Max(0.01f, processSeconds);
        public IReadOnlyList<ItemStack> Inputs => inputs;
        public IReadOnlyList<ItemStack> Outputs => outputs;

        public void Configure(
            string recipeId,
            string recipeDisplayName,
            string recipeDescription,
            float seconds,
            IEnumerable<ItemStack> recipeInputs,
            IEnumerable<ItemStack> recipeOutputs)
        {
            id = recipeId;
            displayName = recipeDisplayName;
            description = recipeDescription;
            processSeconds = seconds;
            inputs = recipeInputs != null ? new List<ItemStack>(recipeInputs) : new List<ItemStack>();
            outputs = recipeOutputs != null ? new List<ItemStack>(recipeOutputs) : new List<ItemStack>();
        }
    }
}
