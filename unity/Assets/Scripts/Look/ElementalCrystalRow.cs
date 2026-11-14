using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// REF_11: five elemental Platonic crystals (fire tetra, frost cube,
    /// lightning octa, sun stand-in, vortex icosa) using CrystalNebula
    /// element ids 1–5, matching Godot's elemental row. The reference
    /// sheet can still be shown as a back plate.
    /// </summary>
    public sealed class ElementalCrystalRow : MonoBehaviour
    {
        [SerializeField] Texture sheet;
        [SerializeField] float spacing = 3.4f;
        Transform built;

        public Texture Sheet { get { return sheet; } set { sheet = value; } }
        public float Spacing { get { return spacing; } set { spacing = value; } }

        static readonly Color[] Edges =
        {
            new Color(1f, 0.6f, 0.3f),
            new Color(0.75f, 1f, 1f),
            new Color(0.85f, 0.7f, 1f),
            new Color(1f, 0.85f, 0.5f),
            new Color(0.8f, 0.9f, 1f)
        };

        void Awake()
        {
            if (built == null) Rebuild();
        }

        public void Rebuild()
        {
            if (built != null) Object.Destroy(built.gameObject);
            var root = new GameObject("ElementalCrystalRow");
            root.transform.SetParent(transform, false);
            built = root.transform;

            const int count = 5;
            for (int i = 0; i < count; i++)
            {
                float x = (2f - i) * spacing;
                var pedestal = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
                pedestal.name = "Look_Element_Pedestal_" + i;
                pedestal.transform.SetParent(built, false);
                pedestal.transform.localPosition = new Vector3(x, 0.5f, 0f);
                pedestal.transform.localScale = new Vector3(0.84f, 0.5f, 0.84f);
                var pedMat = GertechMaterialFactory.GoldChrome(Edges[i], 0.25f, 0f, "Element Pedestal " + i, null);
                var pedRenderer = pedestal.GetComponent<MeshRenderer>();
                if (pedRenderer != null) pedRenderer.sharedMaterial = pedMat;

                var holder = new GameObject("Look_Element_Spin_" + i);
                holder.transform.SetParent(built, false);
                holder.transform.localPosition = new Vector3(x, 2.25f, 0f);
                holder.AddComponent<LookSpin>().DegreesPerSecond = 18f * (i % 2 == 0 ? 1f : -1f);

                float radius = i == 1 ? 0.95f : 1.05f;
                var crystalMat = GertechMaterialFactory.CrystalElement(i + 1, radius, 1f, 0.78f, Edges[i], "Element Crystal " + i);
                if (i == 1)
                {
                    var cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                    cube.name = "Look_Element_1";
                    cube.transform.SetParent(holder.transform, false);
                    cube.transform.localScale = Vector3.one * (radius * 1.5f);
                    cube.transform.localRotation = Quaternion.Euler(0f, 28f, 0f);
                    var cubeRenderer = cube.GetComponent<MeshRenderer>();
                    if (cubeRenderer != null) cubeRenderer.sharedMaterial = crystalMat;
                }
                else
                {
                    GertechProcMesh.MeshObject("Look_Element_" + i, MeshFor(i, radius), crystalMat, holder.transform);
                }
            }

            if (sheet != null)
            {
                var plate = GameObject.CreatePrimitive(PrimitiveType.Quad);
                plate.name = "ElementalSheetAssist";
                plate.transform.SetParent(built, false);
                plate.transform.localPosition = new Vector3(0f, 2.4f, 2.2f);
                plate.transform.localRotation = Quaternion.Euler(0f, 180f, 0f);
                plate.transform.localScale = new Vector3(spacing * 5.2f, 2.2f, 1f);
                var renderer = plate.GetComponent<MeshRenderer>();
                if (renderer != null)
                    renderer.sharedMaterial = GertechMaterialFactory.UnlitPlate(sheet, Color.white, "Elemental Sheet");
            }
        }

        static Mesh MeshFor(int index, float radius)
        {
            if (index == 0) return GertechProcMesh.Tetrahedron(radius * 0.7f);
            if (index == 2) return GertechProcMesh.Octahedron(radius);
            if (index == 4) return GertechProcMesh.Icosahedron(radius);
            return GertechProcMesh.Icosahedron(radius); // sun dodeca stand-in
        }
    }

    /// <summary>Tiny Y-axis spinner used by look-pass pieces.</summary>
    public sealed class LookSpin : MonoBehaviour
    {
        public float DegreesPerSecond = 12f;
        void Update()
        {
            transform.Rotate(Vector3.up, DegreesPerSecond * Time.deltaTime, Space.Self);
        }
    }
}
