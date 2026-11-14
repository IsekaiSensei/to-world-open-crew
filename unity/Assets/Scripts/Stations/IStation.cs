namespace Gertech.Stations
{
    /// <summary>
    /// Plug-in contract for a workshop station. New stations implement this
    /// (usually via <see cref="StationBase"/>) and register with the hub;
    /// core routing code does not need to change.
    /// </summary>
    public interface IStation
    {
        string StationId { get; }
        string DisplayName { get; }
        bool IsBusy { get; }
        bool CanStart(Inventory.Inventory inventory);
        bool TryStart(Inventory.Inventory inventory);
        void Tick(float deltaTime, Inventory.Inventory inventory);
        void Cancel();
    }
}
