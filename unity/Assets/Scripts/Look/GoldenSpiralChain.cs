using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// REF_09-style golden-spiral chain of faceted gold polyhedra. Placement
    /// matches Godot Look_Golden_Spiral_Polyhedra_Chain (YZ plane, faces -Z).
    /// </summary>
    public static class GoldenSpiralChain
    {
        const float Phi = 1.6180339887f;

        public static Transform Build(Transform parent, Vector3 origin, GertechLookPalette palette)
        {
            var root = new GameObject("Look_Golden_Spiral_Polyhedra_Chain");
            root.transform.SetParent(parent, false);
            root.transform.position = origin;
            root.transform.rotation = Quaternion.Euler(0f, 90f, 0f);

            var gold = GertechMaterialFactory.Gold(palette);
            var cyan = GertechMaterialFactory.CyanEdge(palette);
            var icosa = GertechProcMesh.Icosahedron(1f);
            var octa = GertechProcMesh.Octahedron(1f);

            float th = 0f;
            int i = 0;
            while (true)
            {
                float r = 0.32f * Mathf.Pow(Phi, th * 2f / Mathf.PI);
                if (r > 3.55f) break;
                float size = 0.21f * r;
                var p = new Vector3(0f, Mathf.Sin(th) * r, Mathf.Cos(th) * r);
                var go = new GameObject("Look_Spiral_Polyhedron_" + i.ToString("00"));
                go.transform.SetParent(root.transform, false);
                go.transform.localPosition = p;
                go.transform.localRotation = Quaternion.AngleAxis(th * 1.7f * Mathf.Rad2Deg, new Vector3(0.3f, 1f, 0.2f).normalized);
                go.transform.localScale = Vector3.one * size;
                var filter = go.AddComponent<MeshFilter>();
                filter.sharedMesh = (i % 2 == 0) ? icosa : octa;
                var renderer = go.AddComponent<MeshRenderer>();
                renderer.sharedMaterial = gold;
                th += 0.46f;
                i++;
            }

            var core = GameObject.CreatePrimitive(PrimitiveType.Quad);
            core.name = "Look_Spiral_Black_Core";
            core.transform.SetParent(root.transform, false);
            core.transform.localPosition = new Vector3(-0.15f, 0f, 0f);
            core.transform.localRotation = Quaternion.Euler(0f, 90f, 0f);
            core.transform.localScale = new Vector3(2.6f, 2.6f, 1f);
            var coreRenderer = core.GetComponent<MeshRenderer>();
            if (coreRenderer != null) coreRenderer.sharedMaterial = cyan;
            return root.transform;
        }
    }
}
