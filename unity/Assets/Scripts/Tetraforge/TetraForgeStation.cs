using System.Collections.Generic;
using Gertech.Stations;
using UnityEngine;

namespace Gertech.Tetraforge
{
    /// <summary>
    /// Recipe-driven multi-input crafting station. There is no class or module
    /// named TETRAFORGE in the surveyed Godot Aqua Workshop. Godot's closest
    /// playable equivalent is the Tetris Forge Foundry (see
    /// <see cref="TetrisForgeFoundry"/>). This station is the Unity-native
    /// recipe path requested when a direct port is not available.
    /// </summary>
    public sealed class TetraForgeStation : StationBase
    {
        [SerializeField] List<CraftingRecipe> recipes = new List<CraftingRecipe>();
        [SerializeField] int selectedRecipeIndex;

        CraftingRecipe activeRecipe;
        float remaining;
        bool recipeJobBusy;

        public IReadOnlyList<CraftingRecipe> Recipes => recipes;

        public int SelectedRecipeIndex
        {
            get { return selectedRecipeIndex; }
            set { selectedRecipeIndex = recipes == null || recipes.Count == 0 ? 0 : Mathf.Clamp(value, 0, recipes.Count - 1); }
        }

        public CraftingRecipe SelectedRecipe
        {
            get
            {
                if (recipes == null || recipes.Count == 0) return null;
                SelectedRecipeIndex = selectedRecipeIndex;
                return recipes[selectedRecipeIndex];
            }
        }

        public override string StationId => StationIds.TetraForge;
        public override string DisplayName => "TETRAFORGE";
        public override bool IsBusy => recipeJobBusy;
        public override float RemainingSeconds => recipeJobBusy ? remaining : 0f;
        public override bool CanStart(Inventory.Inventory inventory)
        {
            var recipe = SelectedRecipe;
            if (recipeJobBusy || recipe == null || inventory == null) return false;
            return inventory.CanConsume(recipe.Inputs);
        }

        public override bool TryStart(Inventory.Inventory inventory)
        {
            var recipe = SelectedRecipe;
            if (!CanStart(inventory)) return false;
            if (!inventory.Consume(recipe.Inputs)) return false;
            activeRecipe = recipe;
            recipeJobBusy = true;
            remaining = recipe.ProcessSeconds;
            return true;
        }

        public override void Tick(float deltaTime, Inventory.Inventory inventory)
        {
            if (!recipeJobBusy || inventory == null || activeRecipe == null) return;
            remaining -= deltaTime;
            if (remaining > 0f) return;
            inventory.Add(activeRecipe.Outputs);
            activeRecipe = null;
            recipeJobBusy = false;
            remaining = 0f;
        }

        public override void Cancel()
        {
            activeRecipe = null;
            recipeJobBusy = false;
            remaining = 0f;
            base.Cancel();
        }

        public void SetRecipes(IEnumerable<CraftingRecipe> list)
        {
            recipes = list != null ? new List<CraftingRecipe>(list) : new List<CraftingRecipe>();
            SelectedRecipeIndex = 0;
        }
    }
}
