using UnityEngine;

namespace Gertech.Stations
{
    /// <summary>
    /// Default timer-job station: consume definition inputs, wait, emit outputs.
    /// Concrete stations subclass this without changing the hub or registry.
    /// </summary>
    public abstract class StationBase : MonoBehaviour, IStation
    {
        [SerializeField] StationDefinition definition;

        float remaining;
        bool busy;

        public StationDefinition Definition
        {
            get { return definition; }
            set { definition = value; }
        }

        public virtual string StationId
        {
            get { return definition != null && !string.IsNullOrEmpty(definition.Id) ? definition.Id : name; }
        }

        public virtual string DisplayName
        {
            get { return definition != null ? definition.DisplayName : name; }
        }

        public virtual bool IsBusy => busy;
        public virtual float RemainingSeconds => busy ? remaining : 0f;

        public virtual bool CanStart(Inventory.Inventory inventory)
        {
            if (busy || definition == null || inventory == null) return false;
            return inventory.CanConsume(definition.Inputs);
        }

        public virtual bool TryStart(Inventory.Inventory inventory)
        {
            if (!CanStart(inventory)) return false;
            if (!inventory.Consume(definition.Inputs)) return false;
            busy = true;
            remaining = definition.ProcessSeconds;
            OnProcessStarted(inventory);
            return true;
        }

        public virtual void Tick(float deltaTime, Inventory.Inventory inventory)
        {
            if (!busy || inventory == null) return;
            remaining -= deltaTime;
            if (remaining > 0f) return;
            remaining = 0f;
            busy = false;
            inventory.Add(definition.Outputs);
            OnProcessCompleted(inventory);
        }

        public virtual void Cancel()
        {
            busy = false;
            remaining = 0f;
        }

        protected virtual void OnProcessStarted(Inventory.Inventory inventory) { }
        protected virtual void OnProcessCompleted(Inventory.Inventory inventory) { }
    }
}
