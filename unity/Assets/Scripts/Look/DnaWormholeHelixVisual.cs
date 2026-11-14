using Gertech.Core;
using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Visual for the DNA wormhole helix: a torus of distortion (glass / chrome ring
    /// with an optional vortex plate) and a double helix inside. Attach to the same
    /// object as <see cref="DnaWormholeHelixPortal"/> or a child of it.
    /// True screen-space refraction is not included; the ring is a glass/chrome stand-in.
    /// </summary>
    public sealed class DnaWormholeHelixVisual : MonoBehaviour
    {
        [SerializeField] float torusRadius = 1.35f;
        [SerializeField] float torusTube = 0.18f;
        [SerializeField] float helixRadius = 0.45f;
        [SerializeField] float helixHeight = 1.8f;
        [SerializeField] float helixTube = 0.035f;
        [SerializeField] int helixTurns = 3;
        [SerializeField] float spinDegreesPerSecond = 12f;
        [SerializeField] Texture vortexPlate;
        [SerializeField] GertechLookPalette palette;

        Transform spinRoot;
        LineRenderer strandA;
        LineRenderer strandB;

        public Texture VortexPlate
        {
            get { return vortexPlate; }
            set { vortexPlate = value; }
        }

        public GertechLookPalette Palette
        {
            get { return palette; }
            set { palette = value; }
        }

        public static DnaWormholeHelixVisual Attach(DnaWormholeHelixPortal portal)
        {
            if (portal == null) return null;
            var visual = portal.GetComponent<DnaWormholeHelixVisual>();
            if (visual == null) visual = portal.gameObject.AddComponent<DnaWormholeHelixVisual>();
            visual.Rebuild();
            return visual;
        }

        void Awake()
        {
            if (spinRoot == null) Rebuild();
        }

        void Update()
        {
            if (spinRoot == null) return;
            spinRoot.Rotate(Vector3.up, spinDegreesPerSecond * Time.deltaTime, Space.Self);
        }

        public void Rebuild()
        {
            if (spinRoot != null)
            {
                Object.Destroy(spinRoot.gameObject);
                spinRoot = null;
            }

            var rootGo = new GameObject("DnaWormholeHelixVisual");
            rootGo.transform.SetParent(transform, false);
            spinRoot = rootGo.transform;

            var glass = GertechMaterialFactory.CrystalGlass(palette);
            var chrome = GertechMaterialFactory.Chrome(palette);
            var gold = GertechMaterialFactory.Gold(palette);
            var cyan = GertechMaterialFactory.CyanEdge(palette);

            var torus = GertechProcMesh.Torus(torusRadius, torusTube, 16, 32);
            GertechProcMesh.MeshObject("DistortionTorus", torus, glass, spinRoot);

            var inner = GertechProcMesh.Torus(torusRadius, torusTube * 0.45f, 12, 24);
            GertechProcMesh.MeshObject("ChromeRing", inner, chrome, spinRoot);

            if (vortexPlate != null)
            {
                var plate = GameObject.CreatePrimitive(PrimitiveType.Quad);
                plate.name = "VortexPlate";
                plate.transform.SetParent(spinRoot, false);
                plate.transform.localRotation = Quaternion.Euler(90f, 0f, 0f);
                plate.transform.localScale = new Vector3(torusRadius * 1.6f, torusRadius * 1.6f, 1f);
                var renderer = plate.GetComponent<MeshRenderer>();
                if (renderer != null)
                    renderer.sharedMaterial = GertechMaterialFactory.UnlitPlate(vortexPlate, Color.white, "Helix Vortex Plate");
            }

            var strandMeshA = GertechProcMesh.TubeHelix(helixRadius, helixHeight, helixTube, helixTurns, 64, 6, 0f);
            GertechProcMesh.MeshObject("HelixStrandA", strandMeshA, gold, spinRoot);
            var strandMeshB = GertechProcMesh.TubeHelix(helixRadius, helixHeight, helixTube, helixTurns, 64, 6, Mathf.PI);
            GertechProcMesh.MeshObject("HelixStrandB", strandMeshB, cyan, spinRoot);

            strandA = BuildStrandLine("HelixLineA", 0f, gold);
            strandB = BuildStrandLine("HelixLineB", Mathf.PI, cyan);
        }

        LineRenderer BuildStrandLine(string name, float phase, Material mat)
        {
            var go = new GameObject(name);
            go.transform.SetParent(spinRoot, false);
            var line = go.AddComponent<LineRenderer>();
            line.useWorldSpace = false;
            line.loop = false;
            line.startWidth = helixTube * 1.2f;
            line.endWidth = helixTube * 1.2f;
            line.material = mat;
            line.sharedMaterial = mat;
            const int count = 65;
            line.positionCount = count;
            for (int i = 0; i < count; i++)
            {
                float t = i / (float)(count - 1);
                float ang = t * helixTurns * Mathf.PI * 2f + phase;
                line.SetPosition(i, new Vector3(
                    Mathf.Cos(ang) * helixRadius,
                    (t - 0.5f) * helixHeight,
                    Mathf.Sin(ang) * helixRadius));
            }
            return line;
        }
    }
}
