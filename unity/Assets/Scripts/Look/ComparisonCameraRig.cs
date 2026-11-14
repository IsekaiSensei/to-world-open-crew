using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Named camera presets matching Godot Continuity's look-pass views
    /// (scratch/look_shots/zz_shot.gd). Positions and look-at points are
    /// copied so Unity and Godot shots can be compared side by side.
    /// No frame-time numbers are recorded here.
    /// </summary>
    public sealed class ComparisonCameraRig : MonoBehaviour
    {
        public struct ViewPreset
        {
            public string Name;
            public Vector3 Position;
            public Vector3 LookAt;
            public Vector3 PlayerPosition;
            public ViewPreset(string name, Vector3 position, Vector3 lookAt, Vector3 playerPosition)
            {
                Name = name;
                Position = position;
                LookAt = lookAt;
                PlayerPosition = playerPosition;
            }
        }

        // Name, camera position, look-at, player floor mark — same as Godot VIEWS.
        public static readonly ViewPreset[] Presets =
        {
            new ViewPreset("hall_overview", new Vector3(0f, 13.2f, 37f), new Vector3(0f, 3f, -8f), new Vector3(0f, 0.45f, 31.8f)),
            new ViewPreset("hero_wormhole", new Vector3(-20.5f, 4f, 31f), new Vector3(-34f, 5.8f, 35.4f), new Vector3(-20.5f, 0.45f, 31f)),
            new ViewPreset("hero_wormhole_axis", new Vector3(-19.5f, 6.4f, 34.2f), new Vector3(-30f, 6f, 34.2f), new Vector3(-19.5f, 0.45f, 34.2f)),
            new ViewPreset("golden_spiral_chain", new Vector3(-38.5f, 5f, 30.4f), new Vector3(-41f, 6.2f, 37.3f), new Vector3(-38.5f, 0.45f, 30.4f)),
            new ViewPreset("elemental_crystals", new Vector3(26.1f, 5.4f, 28.4f), new Vector3(26.1f, 2.1f, 36.4f), new Vector3(26.1f, 0.45f, 27.6f)),
            new ViewPreset("block_triangle_module", new Vector3(25.6f, 2.5f, 26.4f), new Vector3(25.6f, 1.6f, 30.8f), new Vector3(26f, 0.45f, 27f)),
            new ViewPreset("frames_and_progression", new Vector3(12.6f, 4.3f, 9.4f), new Vector3(26f, 2.6f, 5.4f), new Vector3(12.6f, 0.45f, 9f)),
            new ViewPreset("growth_showcase", new Vector3(-13f, 2.1f, -29f), new Vector3(-13f, 1.6f, -34.2f), new Vector3(-13f, 0.45f, -29f)),
            new ViewPreset("voronoi_wall", new Vector3(-37.5f, 5.4f, 3f), new Vector3(-47.2f, 5.6f, 3f), new Vector3(-37.5f, 0.45f, 3f)),
        };

        [SerializeField] Camera target;
        [SerializeField] string currentPreset = "hall_overview";
        [SerializeField] int currentIndex;

        public Camera Target { get { return target; } set { target = value; } }
        public string CurrentPreset { get { return currentPreset; } }
        public int CurrentIndex { get { return currentIndex; } }

        public static ComparisonCameraRig Build(Transform parent, Camera camera)
        {
            var go = new GameObject("ComparisonCameraRig");
            if (parent != null) go.transform.SetParent(parent, false);
            var rig = go.AddComponent<ComparisonCameraRig>();
            rig.target = camera != null ? camera : go.AddComponent<Camera>();
            rig.target.fieldOfView = GertechLookLayout.ComparisonFov;
            rig.target.farClipPlane = GertechLookLayout.ComparisonFar;
            rig.ApplyPreset("hall_overview");
            return rig;
        }

        public bool ApplyPreset(string name)
        {
            for (int i = 0; i < Presets.Length; i++)
            {
                if (Presets[i].Name == name) return ApplyIndex(i);
            }
            return false;
        }

        public bool ApplyIndex(int index)
        {
            if (index < 0 || index >= Presets.Length) return false;
            currentIndex = index;
            currentPreset = Presets[index].Name;
            Apply(Presets[index], target);
            return true;
        }

        public static void Apply(ViewPreset preset, Camera camera)
        {
            if (camera == null) return;
            camera.fieldOfView = GertechLookLayout.ComparisonFov;
            camera.farClipPlane = GertechLookLayout.ComparisonFar;
            camera.transform.position = preset.Position;
            camera.transform.LookAt(preset.LookAt);
        }
    }
}
