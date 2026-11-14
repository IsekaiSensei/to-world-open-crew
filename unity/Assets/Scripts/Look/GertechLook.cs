using System;
using System.Globalization;
using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Shared GERTECH look palette. Hex values were sampled from the
    /// 2026-11-14 reference PNGs under <c>Assets/Art/Refs</c> (originals at
    /// <c>/workspace/gertech_shared_refs/visual_2026-11-14/</c>). Provisional,
    /// not canon.
    /// </summary>
    public static class GertechLook
    {
        // Corners of REF_01–09, 11, 13: true black space.
        public const string SpaceBlackHex = "#000000";
        // REF_14 plate background.
        public const string SpaceNavyHex = "#0C192A";
        // REF_05 bright gold rings.
        public const string GoldHex = "#BF8F43";
        // REF_10 corner joints (hotter gold).
        public const string GoldJointHex = "#EF9E29";
        // Highlight picked from bright gold pixels (R&gt;220) across the set.
        public const string GoldHighlightHex = "#E8C56A";
        // REF_03 chrome / silver torus.
        public const string ChromeHex = "#BDC0BC";
        // REF_09 cyan edge glow (REF_02 #35C4D7, REF_06 #37BCD1 are neighbors).
        public const string CyanEmissiveHex = "#35CAD8";
        // Median teal cluster across the set (REF_01 / REF_07 sphere accents).
        public const string TealHex = "#3A8D9F";

        public static readonly Color SpaceBlack = Hex(SpaceBlackHex);
        public static readonly Color SpaceNavy = Hex(SpaceNavyHex);
        public static readonly Color Gold = Hex(GoldHex);
        public static readonly Color GoldJoint = Hex(GoldJointHex);
        public static readonly Color GoldHighlight = Hex(GoldHighlightHex);
        public static readonly Color Chrome = Hex(ChromeHex);
        public static readonly Color CyanEmissive = Hex(CyanEmissiveHex);
        public static readonly Color Teal = Hex(TealHex);

        public static Color Hex(string value)
        {
            if (string.IsNullOrEmpty(value)) return Color.black;
            var hex = value[0] == '#' ? value.Substring(1) : value;
            if (hex.Length < 6) return Color.black;
            int r = int.Parse(hex.Substring(0, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
            int g = int.Parse(hex.Substring(2, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
            int b = int.Parse(hex.Substring(4, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
            float a = 1f;
            if (hex.Length >= 8)
                a = int.Parse(hex.Substring(6, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture) / 255f;
            return new Color(r / 255f, g / 255f, b / 255f, a);
        }

        public static Color WithAlpha(Color color, float alpha)
        {
            return new Color(color.r, color.g, color.b, alpha);
        }
    }

    [CreateAssetMenu(fileName = "GertechLookPalette", menuName = "GERTECH/Look/Palette", order = 0)]
    public sealed class GertechLookPalette : ScriptableObject
    {
        [SerializeField] Color spaceBlack = GertechLook.SpaceBlack;
        [SerializeField] Color spaceNavy = GertechLook.SpaceNavy;
        [SerializeField] Color gold = GertechLook.Gold;
        [SerializeField] Color goldJoint = GertechLook.GoldJoint;
        [SerializeField] Color goldHighlight = GertechLook.GoldHighlight;
        [SerializeField] Color chrome = GertechLook.Chrome;
        [SerializeField] Color cyanEmissive = GertechLook.CyanEmissive;
        [SerializeField] Color teal = GertechLook.Teal;

        public Color SpaceBlack => spaceBlack;
        public Color SpaceNavy => spaceNavy;
        public Color Gold => gold;
        public Color GoldJoint => goldJoint;
        public Color GoldHighlight => goldHighlight;
        public Color Chrome => chrome;
        public Color CyanEmissive => cyanEmissive;
        public Color Teal => teal;

        public void ResetToSampledDefaults()
        {
            spaceBlack = GertechLook.SpaceBlack;
            spaceNavy = GertechLook.SpaceNavy;
            gold = GertechLook.Gold;
            goldJoint = GertechLook.GoldJoint;
            goldHighlight = GertechLook.GoldHighlight;
            chrome = GertechLook.Chrome;
            cyanEmissive = GertechLook.CyanEmissive;
            teal = GertechLook.Teal;
        }
    }
}
