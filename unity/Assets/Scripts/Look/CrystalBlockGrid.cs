using System.Collections.Generic;
using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Assembles REF_10 Modular Crystal Blocks on a voxel grid. Shared faces
    /// omit duplicate gold edge bars; shared corners share one joint.
    /// </summary>
    public sealed class CrystalBlockGrid : MonoBehaviour
    {
        [SerializeField] float cellSize = 0.55f;
        [SerializeField] Texture nebula;
        [SerializeField] GertechLookPalette palette;
        [SerializeField] bool includeHelixChannels = true;
        [SerializeField] Vector3Int[] voxels = new Vector3Int[0];

        Transform built;
        Transform seedRoot;
        Transform latticeRoot;
        Transform fillRoot;
        float growth = 1f;

        public float CellSize
        {
            get { return cellSize; }
            set { cellSize = Mathf.Max(0.05f, value); }
        }

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

        public bool IncludeHelixChannels
        {
            get { return includeHelixChannels; }
            set { includeHelixChannels = value; }
        }

        public Vector3Int[] Voxels
        {
            get { return voxels; }
            set { voxels = value ?? new Vector3Int[0]; }
        }

        public int VoxelCount { get { return voxels != null ? voxels.Length : 0; } }

        public float Growth
        {
            get { return growth; }
            set { ApplyGrowth(value); }
        }

        public void SetVoxels(IList<Vector3Int> list)
        {
            if (list == null || list.Count == 0)
            {
                voxels = new Vector3Int[0];
                return;
            }
            voxels = new Vector3Int[list.Count];
            for (int i = 0; i < list.Count; i++) voxels[i] = list[i];
        }

        public void Rebuild()
        {
            if (built != null) Object.Destroy(built.gameObject);

            var root = new GameObject("CrystalBlockGrid");
            root.transform.SetParent(transform, false);
            built = root.transform;

            seedRoot = NewChild(built, "Seed");
            latticeRoot = NewChild(built, "Lattice");
            fillRoot = NewChild(built, "Fill");

            var glass = GertechMaterialFactory.CrystalGlass(palette);
            var gold = GertechMaterialFactory.GoldGlow(palette);
            var joint = GertechMaterialFactory.GoldJoint(palette);
            var cyan = GertechMaterialFactory.CyanEdge(palette);
            var nebulaMat = nebula != null
                ? GertechMaterialFactory.UnlitPlate(nebula, Color.white, "Grid Nebula")
                : GertechMaterialFactory.NebulaFill(palette);

            var occupied = new HashSet<Vector3Int>();
            if (voxels != null)
            {
                for (int i = 0; i < voxels.Length; i++) occupied.Add(voxels[i]);
            }

            var edges = new HashSet<string>();
            var corners = new HashSet<Vector3Int>();
            float half = cellSize * 0.5f;
            float bar = cellSize * 0.045f;

            foreach (var v in occupied)
            {
                var center = CellCenter(v);
                var body = GameObject.CreatePrimitive(PrimitiveType.Cube);
                body.name = "CrystalGlass";
                body.transform.SetParent(fillRoot, false);
                body.transform.localPosition = center;
                body.transform.localScale = Vector3.one * (cellSize * 0.96f);
                ApplyMat(body, glass);

                var quad = GameObject.CreatePrimitive(PrimitiveType.Quad);
                quad.name = "InnerNebula";
                quad.transform.SetParent(fillRoot, false);
                quad.transform.localPosition = center;
                quad.transform.localScale = new Vector3(cellSize * 0.7f, cellSize * 0.7f, 1f);
                ApplyMat(quad, nebulaMat);

                if (includeHelixChannels)
                {
                    var helixA = GertechProcMesh.TubeHelix(cellSize * 0.14f, cellSize * 0.8f, cellSize * 0.016f, 2, 24, 5, 0f);
                    var ha = GertechProcMesh.MeshObject("HelixChannelA", helixA, cyan, fillRoot);
                    ha.transform.localPosition = center;
                    var helixB = GertechProcMesh.TubeHelix(cellSize * 0.14f, cellSize * 0.8f, cellSize * 0.016f, 2, 24, 5, Mathf.PI);
                    var hb = GertechProcMesh.MeshObject("HelixChannelB", helixB, gold, fillRoot);
                    hb.transform.localPosition = center;
                }

                for (int x = 0; x <= 1; x++)
                for (int y = 0; y <= 1; y++)
                for (int z = 0; z <= 1; z++)
                    corners.Add(new Vector3Int(v.x + x, v.y + y, v.z + z));

                AddEdge(edges, v.x, v.y, v.z, v.x + 1, v.y, v.z);
                AddEdge(edges, v.x, v.y + 1, v.z, v.x + 1, v.y + 1, v.z);
                AddEdge(edges, v.x, v.y, v.z + 1, v.x + 1, v.y, v.z + 1);
                AddEdge(edges, v.x, v.y + 1, v.z + 1, v.x + 1, v.y + 1, v.z + 1);
                AddEdge(edges, v.x, v.y, v.z, v.x, v.y + 1, v.z);
                AddEdge(edges, v.x + 1, v.y, v.z, v.x + 1, v.y + 1, v.z);
                AddEdge(edges, v.x, v.y, v.z + 1, v.x, v.y + 1, v.z + 1);
                AddEdge(edges, v.x + 1, v.y, v.z + 1, v.x + 1, v.y + 1, v.z + 1);
                AddEdge(edges, v.x, v.y, v.z, v.x, v.y, v.z + 1);
                AddEdge(edges, v.x + 1, v.y, v.z, v.x + 1, v.y, v.z + 1);
                AddEdge(edges, v.x, v.y + 1, v.z, v.x, v.y + 1, v.z + 1);
                AddEdge(edges, v.x + 1, v.y + 1, v.z, v.x + 1, v.y + 1, v.z + 1);
            }

            foreach (var key in edges)
            {
                Vector3Int a, b;
                ParseEdge(key, out a, out b);
                var pa = CornerPos(a);
                var pb = CornerPos(b);
                var mid = (pa + pb) * 0.5f;
                var delta = pb - pa;
                var barGo = GameObject.CreatePrimitive(PrimitiveType.Cube);
                barGo.name = "GoldEdge";
                barGo.transform.SetParent(latticeRoot, false);
                barGo.transform.localPosition = mid;
                float length = Mathf.Max(delta.magnitude, 0.001f);
                if (Mathf.Abs(delta.x) > Mathf.Abs(delta.y) && Mathf.Abs(delta.x) > Mathf.Abs(delta.z))
                    barGo.transform.localScale = new Vector3(length, bar, bar);
                else if (Mathf.Abs(delta.y) > Mathf.Abs(delta.z))
                    barGo.transform.localScale = new Vector3(bar, length, bar);
                else
                    barGo.transform.localScale = new Vector3(bar, bar, length);
                ApplyMat(barGo, gold);
            }

            foreach (var c in corners)
            {
                var jointGo = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                jointGo.name = "CornerJoint";
                jointGo.transform.SetParent(latticeRoot, false);
                jointGo.transform.localPosition = CornerPos(c);
                jointGo.transform.localScale = Vector3.one * (bar * 2.4f);
                ApplyMat(jointGo, joint);
            }

            var seed = GameObject.CreatePrimitive(PrimitiveType.Cube);
            seed.name = "CrystalSeed";
            seed.transform.SetParent(seedRoot, false);
            seed.transform.localPosition = OccupiedCentroid(occupied);
            seed.transform.localScale = Vector3.one * (cellSize * 0.45f);
            ApplyMat(seed, glass);

            ApplyGrowth(growth);
        }

        public void ApplyGrowth(float value)
        {
            growth = Mathf.Clamp01(value);
            if (seedRoot == null || latticeRoot == null || fillRoot == null) return;

            // 0–0.33 seed, 0.33–0.66 energized lattice, 0.66–1 finished block.
            float seedScale = growth < 0.33f
                ? Mathf.Clamp01(growth / 0.33f)
                : Mathf.Lerp(1f, 0.15f, Mathf.Clamp01((growth - 0.33f) / 0.67f));
            seedRoot.localScale = Vector3.one * Mathf.Max(0.05f, seedScale);
            seedRoot.gameObject.SetActive(growth < 0.95f);

            float lattice = Mathf.Clamp01((growth - 0.28f) / 0.35f);
            latticeRoot.localScale = Vector3.one * Mathf.Max(0.05f, lattice);
            latticeRoot.gameObject.SetActive(growth >= 0.28f);

            float fill = Mathf.Clamp01((growth - 0.62f) / 0.38f);
            fillRoot.localScale = Vector3.one * Mathf.Max(0.05f, fill);
            fillRoot.gameObject.SetActive(growth >= 0.62f);
        }

        public static CrystalBlockGrid Build(
            Transform parent,
            string objectName,
            Vector3Int[] layout,
            Vector3 localPosition,
            GertechLookPalette palette,
            Texture nebula,
            float cellSize = 0.55f,
            bool helix = true)
        {
            var go = new GameObject(objectName);
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            var grid = go.AddComponent<CrystalBlockGrid>();
            grid.palette = palette;
            grid.nebula = nebula;
            grid.cellSize = cellSize;
            grid.includeHelixChannels = helix;
            grid.voxels = layout ?? new Vector3Int[0];
            grid.Rebuild();
            return grid;
        }

        Vector3 CellCenter(Vector3Int v)
        {
            return new Vector3((v.x + 0.5f) * cellSize, (v.y + 0.5f) * cellSize, (v.z + 0.5f) * cellSize);
        }

        Vector3 CornerPos(Vector3Int c)
        {
            return new Vector3(c.x * cellSize, c.y * cellSize, c.z * cellSize);
        }

        Vector3 OccupiedCentroid(HashSet<Vector3Int> occupied)
        {
            if (occupied == null || occupied.Count == 0) return Vector3.zero;
            var sum = Vector3.zero;
            foreach (var v in occupied) sum += CellCenter(v);
            return sum / occupied.Count;
        }

        static void AddEdge(HashSet<string> edges, int ax, int ay, int az, int bx, int by, int bz)
        {
            if (ax > bx || (ax == bx && ay > by) || (ax == bx && ay == by && az > bz))
            {
                int tx = ax, ty = ay, tz = az;
                ax = bx; ay = by; az = bz;
                bx = tx; by = ty; bz = tz;
            }
            edges.Add(ax + "," + ay + "," + az + ":" + bx + "," + by + "," + bz);
        }

        static void ParseEdge(string key, out Vector3Int a, out Vector3Int b)
        {
            var parts = key.Split(':');
            a = ParseCorner(parts[0]);
            b = ParseCorner(parts[1]);
        }

        static Vector3Int ParseCorner(string s)
        {
            var p = s.Split(',');
            return new Vector3Int(int.Parse(p[0]), int.Parse(p[1]), int.Parse(p[2]));
        }

        static Transform NewChild(Transform parent, string name)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            return go.transform;
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

    /// <summary>
    /// Optional seed → energized lattice → finished block playback (REF_10).
    /// </summary>
    public sealed class CrystalBlockGrowth : MonoBehaviour
    {
        [SerializeField] CrystalBlockGrid grid;
        [SerializeField] float duration = 2.4f;
        float elapsed;
        bool playing;

        public CrystalBlockGrid Grid
        {
            get { return grid; }
            set { grid = value; }
        }

        public float Duration
        {
            get { return duration; }
            set { duration = Mathf.Max(0.1f, value); }
        }

        public void Play()
        {
            elapsed = 0f;
            playing = true;
            if (grid != null) grid.ApplyGrowth(0f);
        }

        public void StopAt(float growth)
        {
            playing = false;
            if (grid != null) grid.ApplyGrowth(growth);
        }

        void Update()
        {
            if (!playing || grid == null) return;
            elapsed += Time.deltaTime;
            float u = Mathf.Clamp01(elapsed / duration);
            grid.ApplyGrowth(u);
            if (u >= 1f) playing = false;
        }
    }
}
