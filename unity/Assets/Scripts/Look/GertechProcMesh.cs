using System.Collections.Generic;
using UnityEngine;

namespace Gertech.Look
{
    /// <summary>Small procedural mesh helpers used by the helix, crystal block, and triangle module.</summary>
    public static class GertechProcMesh
    {
        public static Mesh Torus(float radius, float tube, int sides, int rings)
        {
            sides = Mathf.Max(3, sides);
            rings = Mathf.Max(3, rings);
            var verts = new Vector3[(sides + 1) * (rings + 1)];
            var norms = new Vector3[verts.Length];
            var uvs = new Vector2[verts.Length];
            var tris = new List<int>();
            int i = 0;
            for (int r = 0; r <= rings; r++)
            {
                float u = (r / (float)rings) * Mathf.PI * 2f;
                var c = new Vector3(Mathf.Cos(u) * radius, 0f, Mathf.Sin(u) * radius);
                for (int s = 0; s <= sides; s++)
                {
                    float v = (s / (float)sides) * Mathf.PI * 2f;
                    var n = new Vector3(Mathf.Cos(u) * Mathf.Cos(v), Mathf.Sin(v), Mathf.Sin(u) * Mathf.Cos(v));
                    verts[i] = c + n * tube;
                    norms[i] = n;
                    uvs[i] = new Vector2(r / (float)rings, s / (float)sides);
                    i++;
                }
            }
            for (int r = 0; r < rings; r++)
            {
                for (int s = 0; s < sides; s++)
                {
                    int a = r * (sides + 1) + s;
                    int b = a + sides + 1;
                    tris.Add(a); tris.Add(b); tris.Add(a + 1);
                    tris.Add(a + 1); tris.Add(b); tris.Add(b + 1);
                }
            }
            return Finish("Torus", verts, norms, uvs, tris);
        }

        public static Mesh TubeHelix(float radius, float height, float tube, int turns, int steps, int sides, float phase)
        {
            steps = Mathf.Max(8, steps);
            sides = Mathf.Max(3, sides);
            turns = Mathf.Max(1, turns);
            int rings = steps + 1;
            var verts = new Vector3[rings * (sides + 1)];
            var norms = new Vector3[verts.Length];
            var uvs = new Vector2[verts.Length];
            var tris = new List<int>();
            int i = 0;
            for (int s = 0; s <= steps; s++)
            {
                float t = s / (float)steps;
                float ang = t * turns * Mathf.PI * 2f + phase;
                var center = new Vector3(Mathf.Cos(ang) * radius, (t - 0.5f) * height, Mathf.Sin(ang) * radius);
                var tangent = new Vector3(-Mathf.Sin(ang) * radius, height / steps, Mathf.Cos(ang) * radius).normalized;
                var normal = Vector3.Cross(tangent, Vector3.up);
                if (normal.sqrMagnitude < 0.0001f) normal = Vector3.Cross(tangent, Vector3.right);
                normal.Normalize();
                var binorm = Vector3.Cross(tangent, normal).normalized;
                for (int k = 0; k <= sides; k++)
                {
                    float v = (k / (float)sides) * Mathf.PI * 2f;
                    var n = normal * Mathf.Cos(v) + binorm * Mathf.Sin(v);
                    verts[i] = center + n * tube;
                    norms[i] = n;
                    uvs[i] = new Vector2(t, k / (float)sides);
                    i++;
                }
            }
            for (int s = 0; s < steps; s++)
            {
                for (int k = 0; k < sides; k++)
                {
                    int a = s * (sides + 1) + k;
                    int b = a + sides + 1;
                    tris.Add(a); tris.Add(b); tris.Add(a + 1);
                    tris.Add(a + 1); tris.Add(b); tris.Add(b + 1);
                }
            }
            return Finish("HelixTube", verts, norms, uvs, tris);
        }

        public static Mesh EquilateralTriangle(float size)
        {
            float h = size * Mathf.Sqrt(3f) * 0.5f;
            var verts = new[]
            {
                new Vector3(0f, 0f, h * 2f / 3f),
                new Vector3(-size * 0.5f, 0f, -h / 3f),
                new Vector3(size * 0.5f, 0f, -h / 3f)
            };
            var norms = new[] { Vector3.up, Vector3.up, Vector3.up };
            var uvs = new[] { new Vector2(0.5f, 1f), new Vector2(0f, 0f), new Vector2(1f, 0f) };
            var tris = new List<int> { 0, 1, 2, 0, 2, 1 };
            return Finish("Triangle", verts, norms, uvs, tris);
        }

        public static GameObject MeshObject(string name, Mesh mesh, Material material, Transform parent)
        {
            var go = new GameObject(name);
            if (parent != null) go.transform.SetParent(parent, false);
            var filter = go.AddComponent<MeshFilter>();
            filter.sharedMesh = mesh;
            filter.mesh = mesh;
            var renderer = go.AddComponent<MeshRenderer>();
            renderer.sharedMaterial = material;
            renderer.material = material;
            return go;
        }

        static Mesh Finish(string name, Vector3[] verts, Vector3[] norms, Vector2[] uvs, List<int> tris)
        {
            var mesh = new Mesh { name = name };
            mesh.vertices = verts;
            mesh.normals = norms;
            mesh.uv = uvs;
            mesh.triangles = tris.ToArray();
            mesh.RecalculateBounds();
            if (norms == null || norms.Length == 0) mesh.RecalculateNormals();
            return mesh;
        }

        public static Mesh Tetrahedron(float radius)
        {
            float a = radius;
            var verts = new[]
            {
                new Vector3(a, a, a),
                new Vector3(a, -a, -a),
                new Vector3(-a, a, -a),
                new Vector3(-a, -a, a)
            };
            var tris = new[] { 0, 2, 1, 0, 1, 3, 0, 3, 2, 1, 2, 3 };
            return FinishPoly("Tetrahedron", verts, tris);
        }

        public static Mesh Octahedron(float radius)
        {
            var verts = new[]
            {
                new Vector3(radius, 0f, 0f), new Vector3(-radius, 0f, 0f),
                new Vector3(0f, radius, 0f), new Vector3(0f, -radius, 0f),
                new Vector3(0f, 0f, radius), new Vector3(0f, 0f, -radius)
            };
            var tris = new[]
            {
                0, 2, 4, 2, 1, 4, 1, 3, 4, 3, 0, 4,
                0, 5, 2, 2, 5, 1, 1, 5, 3, 3, 5, 0
            };
            return FinishPoly("Octahedron", verts, tris);
        }

        public static Mesh Icosahedron(float radius)
        {
            float t = 1.6180339887f;
            var raw = new[]
            {
                new Vector3(-1, t, 0), new Vector3(1, t, 0), new Vector3(-1, -t, 0), new Vector3(1, -t, 0),
                new Vector3(0, -1, t), new Vector3(0, 1, t), new Vector3(0, -1, -t), new Vector3(0, 1, -t),
                new Vector3(t, 0, -1), new Vector3(t, 0, 1), new Vector3(-t, 0, -1), new Vector3(-t, 0, 1)
            };
            var verts = new Vector3[raw.Length];
            for (int i = 0; i < raw.Length; i++) verts[i] = raw[i].normalized * radius;
            var tris = new[]
            {
                0,11,5, 0,5,1, 0,1,7, 0,7,10, 0,10,11,
                1,5,9, 5,11,4, 11,10,2, 10,7,6, 7,1,8,
                3,9,4, 3,4,2, 3,2,6, 3,6,8, 3,8,9,
                4,9,5, 2,4,11, 6,2,10, 8,6,7, 9,8,1
            };
            return FinishPoly("Icosahedron", verts, tris);
        }

        static Mesh FinishPoly(string name, Vector3[] verts, int[] tris)
        {
            var mesh = new Mesh { name = name };
            mesh.vertices = verts;
            mesh.triangles = tris;
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
            return mesh;
        }

    }
}
