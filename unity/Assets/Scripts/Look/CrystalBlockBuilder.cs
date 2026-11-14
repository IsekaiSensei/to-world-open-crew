using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// REF_10 Modular Crystal Block: crystal-glass cube, gold edge bars and
    /// corner joints, inner nebula quad, and a helix energy channel.
    /// </summary>
    public sealed class CrystalBlockBuilder : MonoBehaviour
    {
        [SerializeField] float size = 1.4f;
        [SerializeField] Texture nebula;
        [SerializeField] GertechLookPalette palette;
        Transform built;

        public Texture Nebula
        {
            get { return nebula; }
            set { nebula = value; }
        }

        public GertechLookPalette Palette
        {
            get { return palette; }
            set { palette = value; }
        }

        public float Size
        {
            get { return size; }
            set { size = Mathf.Max(0.2f, value); }
        }

        void Awake()
        {
            if (built == null) Rebuild();
        }

        public void Rebuild()
        {
            if (built != null) Object.Destroy(built.gameObject);

            var glass = GertechMaterialFactory.CrystalGlass(palette);
            var gold = GertechMaterialFactory.Gold(palette);
            var joint = GertechMaterialFactory.GoldJoint(palette);
            var cyan = GertechMaterialFactory.CyanEdge(palette);

            var root = new GameObject("CrystalBlock");
            root.transform.SetParent(transform, false);
            built = root.transform;

            var body = GameObject.CreatePrimitive(PrimitiveType.Cube);
            body.name = "CrystalGlass";
            body.transform.SetParent(built, false);
            body.transform.localScale = Vector3.one * size;
            ApplyMat(body, glass);

            float half = size * 0.5f;
            float bar = size * 0.045f;
            // 12 gold edge bars
            AddBar(new Vector3(0f, half, half), new Vector3(size, bar, bar), gold);
            AddBar(new Vector3(0f, half, -half), new Vector3(size, bar, bar), gold);
            AddBar(new Vector3(0f, -half, half), new Vector3(size, bar, bar), gold);
            AddBar(new Vector3(0f, -half, -half), new Vector3(size, bar, bar), gold);
            AddBar(new Vector3(half, 0f, half), new Vector3(bar, size, bar), gold);
            AddBar(new Vector3(half, 0f, -half), new Vector3(bar, size, bar), gold);
            AddBar(new Vector3(-half, 0f, half), new Vector3(bar, size, bar), gold);
            AddBar(new Vector3(-half, 0f, -half), new Vector3(bar, size, bar), gold);
            AddBar(new Vector3(half, half, 0f), new Vector3(bar, bar, size), gold);
            AddBar(new Vector3(half, -half, 0f), new Vector3(bar, bar, size), gold);
            AddBar(new Vector3(-half, half, 0f), new Vector3(bar, bar, size), gold);
            AddBar(new Vector3(-half, -half, 0f), new Vector3(bar, bar, size), gold);

            float signs = 1f;
            for (int x = -1; x <= 1; x += 2)
            for (int y = -1; y <= 1; y += 2)
            for (int z = -1; z <= 1; z += 2)
            {
                var corner = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                corner.name = "CornerJoint";
                corner.transform.SetParent(built, false);
                corner.transform.localPosition = new Vector3(x, y, z) * half;
                corner.transform.localScale = Vector3.one * (bar * 2.4f);
                ApplyMat(corner, joint);
                signs = -signs;
            }

            var nebulaMat = nebula != null
                ? GertechMaterialFactory.UnlitPlate(nebula, Color.white, "Crystal Nebula")
                : GertechMaterialFactory.EmissiveUnlit(
                    palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive,
                    0.6f, "Crystal Nebula Fallback");
            var quad = GameObject.CreatePrimitive(PrimitiveType.Quad);
            quad.name = "InnerNebula";
            quad.transform.SetParent(built, false);
            quad.transform.localScale = new Vector3(size * 0.72f, size * 0.72f, 1f);
            ApplyMat(quad, nebulaMat);

            var helixA = GertechProcMesh.TubeHelix(size * 0.16f, size * 0.85f, size * 0.018f, 2, 48, 6, 0f);
            GertechProcMesh.MeshObject("HelixChannelA", helixA, cyan, built);
            var helixB = GertechProcMesh.TubeHelix(size * 0.16f, size * 0.85f, size * 0.018f, 2, 48, 6, Mathf.PI);
            GertechProcMesh.MeshObject("HelixChannelB", helixB, gold, built);
        }

        void AddBar(Vector3 localPos, Vector3 scale, Material mat)
        {
            var bar = GameObject.CreatePrimitive(PrimitiveType.Cube);
            bar.name = "GoldEdge";
            bar.transform.SetParent(built, false);
            bar.transform.localPosition = localPos;
            bar.transform.localScale = scale;
            ApplyMat(bar, mat);
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
