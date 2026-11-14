using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Comparison stub: a crystal-block starship hull (REF_18) with a cyan
    /// ring engine at the front and a DockingPort attach point.
    /// </summary>
    public sealed class StarshipHull : MonoBehaviour
    {
        [SerializeField] CrystalBlockGrid hull;
        [SerializeField] DockingPort dockingPort;

        public CrystalBlockGrid Hull { get { return hull; } }
        public DockingPort DockingPort { get { return dockingPort; } }

        public static StarshipHull Build(
            Transform parent,
            Vector3 localPosition,
            GertechLookPalette palette,
            Texture nebula)
        {
            var go = new GameObject("StarshipHull");
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            var ship = go.AddComponent<StarshipHull>();
            const float cell = 0.4f;
            ship.hull = CrystalBlockGrid.Build(
                go.transform,
                "StarshipHullSection",
                ModularAssemblyPresets.StarshipHullSection(),
                Vector3.zero,
                palette,
                nebula,
                cell,
                true);

            // Cyan ring engine at the front (low Z) of the 5x5x11 hull.
            var cyan = GertechMaterialFactory.CyanEdge(palette);
            var glow = GertechMaterialFactory.GoldGlow(palette);
            var ring = GertechProcMesh.Torus(cell * 1.6f, cell * 0.18f, 24, 12);
            var ringGo = GertechProcMesh.MeshObject("CyanRingEngine", ring, cyan, go.transform);
            ringGo.transform.localPosition = new Vector3(2.5f * cell, 2.5f * cell, -0.15f);
            ringGo.transform.localRotation = Quaternion.Euler(90f, 0f, 0f);
            var trim = GertechProcMesh.Torus(cell * 1.85f, cell * 0.06f, 24, 8);
            var trimGo = GertechProcMesh.MeshObject("EngineGoldTrim", trim, glow, go.transform);
            trimGo.transform.localPosition = ringGo.transform.localPosition;
            trimGo.transform.localRotation = ringGo.transform.localRotation;

            var portGo = new GameObject("DockingPort");
            portGo.transform.SetParent(go.transform, false);
            // Rear face of the cylinder.
            portGo.transform.localPosition = new Vector3(2.5f * cell, 2.5f * cell, 11f * cell + 0.1f);
            ship.dockingPort = portGo.AddComponent<DockingPort>();
            return ship;
        }
    }

    /// <summary>
    /// Empty docking attach point for future vehicle / relay comparison tests.
    /// </summary>
    public sealed class DockingPort : MonoBehaviour
    {
        [SerializeField] bool occupied;
        [SerializeField] Transform docked;

        public bool Occupied { get { return occupied; } }
        public Transform Docked { get { return docked; } }

        public bool TryDock(Transform other)
        {
            if (occupied || other == null) return false;
            occupied = true;
            docked = other;
            other.SetParent(transform, true);
            other.localPosition = Vector3.zero;
            return true;
        }

        public void Undock()
        {
            if (docked != null) docked.SetParent(null, true);
            docked = null;
            occupied = false;
        }
    }
}
