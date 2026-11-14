using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// REF_14 nebula triangle module: cyan edge bars, gold corner brackets,
    /// nebula-filled triangular face.
    /// </summary>
    public sealed class TriangleModuleBuilder : MonoBehaviour
    {
        [SerializeField] float size = 2.2f;
        [SerializeField] Texture nebula;
        [SerializeField] GertechLookPalette palette;
        Transform built;

        public Texture Nebula { get { return nebula; } set { nebula = value; } }
        public GertechLookPalette Palette { get { return palette; } set { palette = value; } }

        void Awake()
        {
            if (built == null) Rebuild();
        }

        public void Rebuild()
        {
            if (built != null) Object.Destroy(built.gameObject);
            var root = new GameObject("TriangleModule");
            root.transform.SetParent(transform, false);
            built = root.transform;

            var gold = GertechMaterialFactory.GoldJoint(palette);
            var cyan = GertechMaterialFactory.CyanEdge(palette);
            var faceMat = nebula != null
                ? GertechMaterialFactory.UnlitPlate(nebula, Color.white, "Triangle Nebula")
                : GertechMaterialFactory.CrystalGlass(palette);

            var face = GertechProcMesh.EquilateralTriangle(size);
            GertechProcMesh.MeshObject("NebulaFace", face, faceMat, built);

            float h = size * Mathf.Sqrt(3f) * 0.5f;
            var corners = new[]
            {
                new Vector3(0f, 0f, h * 2f / 3f),
                new Vector3(-size * 0.5f, 0f, -h / 3f),
                new Vector3(size * 0.5f, 0f, -h / 3f)
            };
            for (int i = 0; i < 3; i++)
            {
                var bracket = GameObject.CreatePrimitive(PrimitiveType.Cube);
                bracket.name = "GoldCornerBracket";
                bracket.transform.SetParent(built, false);
                bracket.transform.localPosition = corners[i];
                bracket.transform.localScale = Vector3.one * (size * 0.12f);
                ApplyMat(bracket, gold);

                var next = corners[(i + 1) % 3];
                var mid = (corners[i] + next) * 0.5f;
                var edge = GameObject.CreatePrimitive(PrimitiveType.Cube);
                edge.name = "CyanEdgeBar";
                edge.transform.SetParent(built, false);
                edge.transform.localPosition = mid;
                var delta = next - corners[i];
                edge.transform.localRotation = Quaternion.LookRotation(delta.normalized, Vector3.up);
                edge.transform.localScale = new Vector3(size * 0.05f, size * 0.05f, delta.magnitude);
                ApplyMat(edge, cyan);
            }
        }

        static void ApplyMat(GameObject go, Material mat)
        {
            var renderer = go.GetComponent<MeshRenderer>();
            if (renderer != null)
            {
                renderer.sharedMaterial = mat;
                renderer.material = mat;
            }
        }
    }
}
