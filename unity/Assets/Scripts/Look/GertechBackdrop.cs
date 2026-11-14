using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Unlit textured plate or sky quad that shows a reference PNG directly
    /// (backdrop, decal, or flipbook screen).
    /// </summary>
    public static class GertechBackdrop
    {
        public static GameObject CreatePlate(
            string name,
            Transform parent,
            Vector3 localPosition,
            Vector3 localEuler,
            Vector2 size,
            Texture texture,
            Material material = null)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Quad);
            go.name = name;
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            go.transform.localRotation = Quaternion.Euler(localEuler.x, localEuler.y, localEuler.z);
            go.transform.localScale = new Vector3(size.x, size.y, 1f);
            var renderer = go.GetComponent<MeshRenderer>();
            if (renderer != null)
            {
                var mat = material != null
                    ? material
                    : GertechMaterialFactory.UnlitPlate(texture, Color.white, name + " Plate");
                renderer.sharedMaterial = mat;
                renderer.material = mat;
            }
            return go;
        }

        public static void ApplyCameraSpaceBackground(Camera camera, GertechLookPalette palette = null)
        {
            if (camera == null) return;
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = palette != null ? palette.SpaceBlack : GertechLook.SpaceBlack;
        }
    }
}
