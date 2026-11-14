using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// REF_11: five elemental Platonic crystals shown as UV slices of the sheet
    /// (fire, frost, lightning, sun, vortex).
    /// </summary>
    public sealed class ElementalCrystalRow : MonoBehaviour
    {
        [SerializeField] Texture sheet;
        [SerializeField] float width = 6f;
        [SerializeField] float height = 1.6f;
        Transform built;

        public Texture Sheet { get { return sheet; } set { sheet = value; } }

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
            if (sheet == null) return;

            const int count = 5;
            float cell = width / count;
            for (int i = 0; i < count; i++)
            {
                var plate = GameObject.CreatePrimitive(PrimitiveType.Quad);
                plate.name = "Elemental_" + i;
                plate.transform.SetParent(built, false);
                plate.transform.localPosition = new Vector3((i - (count - 1) * 0.5f) * cell, 0f, 0f);
                plate.transform.localScale = new Vector3(cell * 0.92f, height, 1f);
                var mat = GertechMaterialFactory.UnlitPlate(sheet, Color.white, "Elemental " + i);
                // Sheet is a single row of five; crop vertically to the crystal band (~0.32–0.70 of UV).
                float w = 1f / count;
                var scale = new Vector2(w * 0.92f, 0.36f);
                var offset = new Vector2(i * w + w * 0.04f, 0.32f);
                mat.mainTextureScale = scale;
                mat.mainTextureOffset = offset;
                mat.SetTextureScale("_MainTex", scale);
                mat.SetTextureOffset("_MainTex", offset);
                mat.SetTextureScale("_BaseMap", scale);
                mat.SetTextureOffset("_BaseMap", offset);
                var renderer = plate.GetComponent<MeshRenderer>();
                if (renderer != null)
                {
                    renderer.sharedMaterial = mat;
                    renderer.material = mat;
                }
            }
        }
    }
}
