using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Plays a grid sprite sheet (REF_12 and REF_13 are 6 columns × 5 rows = 30 frames).
    /// A small UV inset hides gold gutters on the assist sheets.
    /// </summary>
    public sealed class GertechFlipbook : MonoBehaviour
    {
        public const int RefSheetColumns = 6;
        public const int RefSheetRows = 5;

        [SerializeField] Texture sheet;
        [SerializeField] int columns = RefSheetColumns;
        [SerializeField] int rows = RefSheetRows;
        [SerializeField] float framesPerSecond = 8f;
        [SerializeField] float uvInset = 0.02f;
        [SerializeField] bool play = true;
        [SerializeField] int frame;

        Material material;
        float elapsed;

        public Texture Sheet
        {
            get { return sheet; }
            set { sheet = value; ApplySheet(); }
        }

        public int Columns { get { return columns; } set { columns = Mathf.Max(1, value); } }
        public int Rows { get { return rows; } set { rows = Mathf.Max(1, value); } }
        public float FramesPerSecond { get { return framesPerSecond; } set { framesPerSecond = Mathf.Max(0.01f, value); } }
        public int FrameCount { get { return Mathf.Max(1, columns) * Mathf.Max(1, rows); } }

        void Awake()
        {
            EnsureMaterial();
            ShowFrame(frame);
        }

        void Update()
        {
            if (!play || sheet == null) return;
            elapsed += Time.deltaTime;
            var step = 1f / framesPerSecond;
            if (elapsed < step) return;
            elapsed -= step;
            ShowFrame((frame + 1) % FrameCount);
        }

        public void Configure(Texture texture, int cols, int rowCount, float fps)
        {
            sheet = texture;
            columns = Mathf.Max(1, cols);
            rows = Mathf.Max(1, rowCount);
            framesPerSecond = Mathf.Max(0.01f, fps);
            EnsureMaterial();
            ShowFrame(0);
        }

        public void ShowFrame(int index)
        {
            frame = ((index % FrameCount) + FrameCount) % FrameCount;
            EnsureMaterial();
            if (material == null) return;
            float w = 1f / columns;
            float h = 1f / rows;
            int col = frame % columns;
            int rowFromTop = frame / columns;
            // Unity texture UV origin is bottom-left; sheets are authored top-left.
            int rowFromBottom = rows - 1 - rowFromTop;
            var scale = new Vector2(w * (1f - uvInset * 2f), h * (1f - uvInset * 2f));
            var offset = new Vector2(col * w + w * uvInset, rowFromBottom * h + h * uvInset);
            material.mainTextureScale = scale;
            material.mainTextureOffset = offset;
            material.SetTextureScale("_MainTex", scale);
            material.SetTextureOffset("_MainTex", offset);
            material.SetTextureScale("_BaseMap", scale);
            material.SetTextureOffset("_BaseMap", offset);
        }

        void EnsureMaterial()
        {
            if (material != null)
            {
                ApplySheet();
                return;
            }
            var renderer = GetComponent<MeshRenderer>();
            if (renderer == null) renderer = gameObject.AddComponent<MeshRenderer>();
            if (GetComponent<MeshFilter>() == null)
            {
                // Prefer a quad if the object was created as a primitive; otherwise add a filter only.
                gameObject.AddComponent<MeshFilter>();
            }
            material = GertechMaterialFactory.UnlitPlate(sheet, Color.white, "Gertech Flipbook");
            renderer.sharedMaterial = material;
            renderer.material = material;
        }

        void ApplySheet()
        {
            if (material == null || sheet == null) return;
            material.mainTexture = sheet;
            material.SetTexture("_MainTex", sheet);
            material.SetTexture("_BaseMap", sheet);
        }
    }
}
