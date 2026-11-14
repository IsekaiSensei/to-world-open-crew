using UnityEngine;

namespace Gertech.Core
{
    /// <summary>Writes the workshop inventory when the application quits or this object is destroyed.</summary>
    public sealed class AutosaveOnQuit : MonoBehaviour
    {
        [SerializeField] WorkshopHub hub;

        void Awake()
        {
            if (hub == null)
                hub = GetComponent<WorkshopHub>() ?? GetComponentInParent<WorkshopHub>();
        }

        void OnApplicationQuit()
        {
            Save();
        }

        void OnDestroy()
        {
            Save();
        }

        void Save()
        {
            if (hub != null)
                hub.SaveInventory();
        }
    }
}
