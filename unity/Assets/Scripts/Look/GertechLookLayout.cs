using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Godot reference-look-pass placements, copied from
    /// graphics/reference_look_pass/reference_look_pass.gd so Unity views
    /// can be lined up with the shared look-pass shots. Hall is 96 x 77 m.
    /// </summary>
    public static class GertechLookLayout
    {
        public static readonly Vector3 WormholeOrigin = new Vector3(-30f, 6.2f, 34.2f);
        public static readonly Vector3 SpiralChainOrigin = new Vector3(-41f, 6.4f, 37.3f);
        public static readonly Vector3 ElementsOrigin = new Vector3(26.1f, 0f, 36.4f);
        public static readonly Vector3 BlocksOrigin = new Vector3(25.5f, 0f, 30.8f);
        public static readonly Vector3 SpheresOrigin = new Vector3(24.5f, 0f, 5.5f);
        public static readonly Vector3 ProgressionOrigin = new Vector3(18.6f, 0f, 5.6f);
        public static readonly Vector3 GrowthOrigin = new Vector3(-13f, 0f, -34f);
        public static readonly Vector3 VoronoiPanelOrigin = new Vector3(-47.25f, 5.6f, 7.5f);
        public static readonly Vector3 FoamPanelOrigin = new Vector3(-47.25f, 5.6f, -1.5f);
        public const float HallWidth = 96f;
        public const float HallDepth = 77f;
        public const float ComparisonFov = 66f;
        public const float ComparisonFar = 300f;
    }
}
