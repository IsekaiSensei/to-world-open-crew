using System.Collections.Generic;
using Gertech.Inventory;
using UnityEngine;

namespace Gertech.Stations
{
    [CreateAssetMenu(fileName = "StationDefinition", menuName = "GERTECH/Stations/Station Definition", order = 0)]
    public sealed class StationDefinition : ScriptableObject
    {
        [SerializeField] string id;
        [SerializeField] string displayName;
        [SerializeField] [TextArea] string description;
        [SerializeField] float processSeconds = 2f;
        [SerializeField] List<ItemStack> inputs = new List<ItemStack>();
        [SerializeField] List<ItemStack> outputs = new List<ItemStack>();
        [SerializeField] string godotModuleName;

        public string Id => id;
        public string DisplayName => string.IsNullOrEmpty(displayName) ? id : displayName;
        public string Description => description;
        public float ProcessSeconds => Mathf.Max(0.01f, processSeconds);
        public IReadOnlyList<ItemStack> Inputs => inputs;
        public IReadOnlyList<ItemStack> Outputs => outputs;
        public string GodotModuleName => godotModuleName;

        public void Configure(
            string stationId,
            string stationDisplayName,
            string stationDescription,
            float seconds,
            IEnumerable<ItemStack> stationInputs,
            IEnumerable<ItemStack> stationOutputs,
            string godotName = null)
        {
            id = stationId;
            displayName = stationDisplayName;
            description = stationDescription;
            processSeconds = seconds;
            inputs = stationInputs != null ? new List<ItemStack>(stationInputs) : new List<ItemStack>();
            outputs = stationOutputs != null ? new List<ItemStack>(stationOutputs) : new List<ItemStack>();
            godotModuleName = godotName ?? string.Empty;
        }
    }
}
