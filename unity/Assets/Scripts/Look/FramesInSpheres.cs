using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Gold / chrome frames inside crystal spheres (REF_02 / REF_03 language),
    /// placed at Godot SPHERES_ORIGIN for the frames_and_progression view.
    /// </summary>
    public static class FramesInSpheres
    {
        public static Transform Build(Transform parent, Vector3 origin, GertechLookPalette palette)
        {
            var root = new GameObject("Look_Frames_In_Spheres");
            root.transform.SetParent(parent, false);
            root.transform.position = origin;

            var glass = GertechMaterialFactory.CrystalGlass(palette);
            var gold = GertechMaterialFactory.Gold(palette);
            var chrome = GertechMaterialFactory.Chrome(palette);
            PlaceOne(root.transform, "Sphere_0", Vector3.zero, 1.15f, glass, gold, true);
            PlaceOne(root.transform, "Sphere_1", new Vector3(3.2f, 0.2f, 0.4f), 0.95f, glass, chrome, false);
            PlaceOne(root.transform, "Sphere_2", new Vector3(6.2f, 0.1f, -0.3f), 1.05f, glass, gold, true);
            return root.transform;
        }

        static void PlaceOne(Transform parent, string name, Vector3 local, float radius, Material glass, Material frame, bool cubeFrame)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            go.transform.localPosition = local;

            var shell = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            shell.name = "CrystalShell";
            shell.transform.SetParent(go.transform, false);
            shell.transform.localScale = Vector3.one * (radius * 2f);
            var shellRenderer = shell.GetComponent<MeshRenderer>();
            if (shellRenderer != null) shellRenderer.sharedMaterial = glass;

            if (cubeFrame)
            {
                var torus = GertechProcMesh.MeshObject("GoldTorus", GertechProcMesh.Torus(radius * 0.72f, 0.035f, 10, 20), frame, go.transform);
                if (torus != null) torus.transform.localRotation = Quaternion.Euler(90f, 0f, 0f);
                var cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                cube.name = "GoldCubeFrame";
                cube.transform.SetParent(go.transform, false);
                cube.transform.localScale = Vector3.one * (radius * 0.85f);
                var cubeRenderer = cube.GetComponent<MeshRenderer>();
                if (cubeRenderer != null) cubeRenderer.sharedMaterial = frame;
            }
            else
            {
                GertechProcMesh.MeshObject("ChromeIcosa", GertechProcMesh.Icosahedron(radius * 0.55f), frame, go.transform);
            }
        }
    }
}
