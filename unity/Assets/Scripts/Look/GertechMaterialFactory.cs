using UnityEngine;
using UnityEngine.Rendering;

namespace Gertech.Look
{
    /// <summary>
    /// Builds look-pass materials from the ported Gertech HLSL shaders
    /// (GoldChrome, EdgeGlow, CrystalNebula, WormholeTorus). Falls back to
    /// URP Lit / Built-in Standard / Unlit when a shader is missing.
    /// Sets both custom and URP/Built-in property names.
    /// </summary>
    public static class GertechMaterialFactory
    {
        public const string UrpLitName = "Universal Render Pipeline/Lit";
        public const string StandardName = "Standard";
        public const string UnlitColorName = "Unlit/Color";
        public const string UnlitTextureName = "Unlit/Texture";
        public const string SpritesName = "Sprites/Default";
        public const string GoldChromeName = "Gertech/GoldChrome";
        public const string EdgeGlowName = "Gertech/EdgeGlow";
        public const string CrystalNebulaName = "Gertech/CrystalNebula";
        public const string WormholeTorusName = "Gertech/WormholeTorus";

        public static Shader FindLitShader()
        {
            var shader = Shader.Find(UrpLitName);
            if (shader != null) return shader;
            shader = Shader.Find(StandardName);
            if (shader != null) return shader;
            shader = Shader.Find(UnlitColorName);
            return shader;
        }

        public static Shader FindUnlitShader(bool textured)
        {
            var shader = Shader.Find(textured ? UnlitTextureName : UnlitColorName);
            if (shader != null) return shader;
            shader = Shader.Find(SpritesName);
            if (shader != null) return shader;
            return FindLitShader();
        }

        public static Shader FindLookShader(string shaderName)
        {
            if (!string.IsNullOrEmpty(shaderName))
            {
                var shader = Shader.Find(shaderName);
                if (shader != null) return shader;
            }
            return FindLitShader();
        }

        public static Material LookMaterial(string shaderName, string name)
        {
            return new Material(FindLookShader(shaderName)) { name = name };
        }

        public static Material Gold(GertechLookPalette palette = null)
        {
            var gold = palette != null ? palette.Gold : GertechLook.Gold;
            return GoldChrome(gold, 0.2f, 0f, "Gertech Gold", palette);
        }

        public static Material GoldJoint(GertechLookPalette palette = null)
        {
            var gold = palette != null ? palette.GoldJoint : GertechLook.GoldJoint;
            return GoldChrome(gold, 0.22f, 0.35f, "Gertech Gold Joint", palette);
        }

        public static Material Chrome(GertechLookPalette palette = null)
        {
            var chrome = palette != null ? palette.Chrome : GertechLook.Chrome;
            return GoldChrome(chrome, 0.08f, 0f, "Gertech Chrome", palette);
        }

        public static Material CyanEdge(GertechLookPalette palette = null)
        {
            var cyan = palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive;
            var mat = LookMaterial(EdgeGlowName, "Gertech Cyan Edge");
            ApplyColor(mat, cyan);
            mat.SetColor("_Color", cyan);
            mat.SetFloat("_Energy", 1.6f);
            mat.SetFloat("_FlowSpeed", 0.5f);
            mat.SetFloat("_FlowDensity", 3f);
            mat.SetFloat("_Soft", 1.5f);
            mat.SetFloat("_Fade", 1f);
            ApplyEmission(mat, cyan, 3.2f);
            ApplyTransparent(mat);
            return mat;
        }

        public static Material CrystalGlass(GertechLookPalette palette = null)
        {
            var cyan = palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive;
            return CrystalElement(6, 1f, 0.6f, 0.85f, cyan, "Gertech Crystal Glass", 0f);
        }

        public static Material SpaceFill(GertechLookPalette palette = null)
        {
            var color = palette != null ? palette.SpaceNavy : GertechLook.SpaceNavy;
            var mat = new Material(FindLitShader()) { name = "Gertech Space Fill" };
            ApplyColor(mat, color);
            ApplyMetal(mat, 0.1f, 0.25f);
            return mat;
        }

        public static Material UnlitPlate(Texture texture, Color tint, string name)
        {
            var shader = FindUnlitShader(texture != null);
            var mat = new Material(shader) { name = name };
            ApplyColor(mat, tint);
            if (texture != null)
            {
                mat.mainTexture = texture;
                mat.SetTexture("_BaseMap", texture);
                mat.SetTexture("_MainTex", texture);
            }
            return mat;
        }

        public static Material EmissiveUnlit(Color color, float intensity, string name)
        {
            var mat = new Material(FindUnlitShader(false)) { name = name };
            var lit = new Color(color.r * intensity, color.g * intensity, color.b * intensity, color.a);
            ApplyColor(mat, lit);
            ApplyEmission(mat, color, intensity);
            return mat;
        }

        public static Material Metal(Color color, float metallic, float smoothness, string name)
        {
            var mat = new Material(FindLitShader()) { name = name };
            ApplyColor(mat, color);
            ApplyMetal(mat, metallic, smoothness);
            return mat;
        }

        public static Material GoldGlow(GertechLookPalette palette = null)
        {
            var color = palette != null ? palette.GoldGlow : GertechLook.GoldGlow;
            return GoldChrome(color, 0.16f, 0f, "GERTECH Gold Glow", palette);
        }

        public static Material CrystalLattice(GertechLookPalette palette = null)
        {
            var gold = palette != null ? palette.Gold : GertechLook.Gold;
            var teal = palette != null ? palette.Teal : GertechLook.Teal;
            var mix = Color.Lerp(gold, teal, 0.18f);
            mix.a = 0.92f;
            return GoldChrome(mix, 0.25f, 0.4f, "GERTECH Crystal Lattice", palette);
        }

        public static Material GuideLattice(GertechLookPalette palette = null)
        {
            var gold = palette != null ? palette.GuideLatticeGold : GertechLook.GuideLatticeGold;
            return GoldChrome(gold, 0.28f, 0.55f, "GERTECH Guide Lattice", palette);
        }

        public static Material InfinityAccent(GertechLookPalette palette = null)
        {
            var color = palette != null ? palette.InfinityBlue : GertechLook.InfinityBlue;
            var mat = LookMaterial(EdgeGlowName, "GERTECH Infinity Blue");
            ApplyColor(mat, color);
            mat.SetColor("_Color", color);
            mat.SetFloat("_Energy", 2.4f);
            mat.SetFloat("_FlowSpeed", 0.35f);
            mat.SetFloat("_FlowDensity", 2.5f);
            mat.SetFloat("_Soft", 1.2f);
            mat.SetFloat("_Fade", 1f);
            ApplyEmission(mat, color, 2.4f);
            ApplyTransparent(mat);
            return mat;
        }

        public static Material NebulaFill(GertechLookPalette palette = null)
        {
            var a = palette != null ? palette.NebulaViolet : GertechLook.NebulaViolet;
            var edge = palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive;
            return CrystalElement(0, 1f, 1f, 0.85f, edge, "GERTECH Nebula Fill", 0f);
        }

        public static Material WormholeTorus(GertechLookPalette palette = null)
        {
            var mat = LookMaterial(WormholeTorusName, "Gertech Wormhole Torus");
            mat.SetFloat("_Speed", 0.35f);
            mat.SetFloat("_Energy", 1.25f);
            mat.SetFloat("_DistortStrength", 0.06f);
            ApplyTransparent(mat);
            return mat;
        }

        public static Material CrystalElement(int element, float radius, float density, float alphaBase, Color edgeColor, string name, float helixChannel = 0f)
        {
            var mat = LookMaterial(CrystalNebulaName, name);
            mat.SetInt("_Element", element);
            mat.SetFloat("_Element", element);
            mat.SetFloat("_Radius", radius);
            mat.SetFloat("_Density", density);
            mat.SetFloat("_HelixChannel", helixChannel);
            mat.SetFloat("_AlphaBase", alphaBase);
            mat.SetColor("_EdgeColor", edgeColor);
            mat.SetFloat("_EdgeGlow", 0.9f);
            mat.SetFloat("_Energy", 1f);
            ApplyColor(mat, GertechLook.WithAlpha(edgeColor, alphaBase));
            ApplyTransparent(mat);
            return mat;
        }

        public static Material GoldChrome(Color baseColor, float roughness, float engrave, string name, GertechLookPalette palette = null)
        {
            var rim = palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive;
            var mat = LookMaterial(GoldChromeName, name);
            ApplyColor(mat, baseColor);
            mat.SetColor("_BaseColor", baseColor);
            mat.SetFloat("_Roughness", roughness);
            mat.SetColor("_RimColor", rim);
            mat.SetFloat("_RimStrength", 0.7f);
            mat.SetFloat("_RimPower", 3f);
            mat.SetFloat("_EnvStrength", 0.85f);
            mat.SetFloat("_Engrave", engrave);
            ApplyMetal(mat, 1f, 1f - roughness);
            ApplyEmission(mat, baseColor, 0.5f);
            return mat;
        }

        public static void ApplyColor(Material mat, Color color)
        {
            if (mat == null) return;
            mat.color = color;
            mat.SetColor("_BaseColor", color);
            mat.SetColor("_Color", color);
        }

        public static void ApplyMetal(Material mat, float metallic, float smoothness)
        {
            if (mat == null) return;
            mat.SetFloat("_Metallic", metallic);
            mat.SetFloat("_Smoothness", smoothness);
            mat.SetFloat("_Glossiness", smoothness);
            mat.SetFloat("_WorkflowMode", 1f);
        }

        public static void ApplyEmission(Material mat, Color color, float intensity)
        {
            if (mat == null) return;
            var emission = color * intensity;
            emission.a = 1f;
            mat.SetColor("_EmissionColor", emission);
            mat.EnableKeyword("_EMISSION");
            mat.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
        }

        public static void ApplyTransparent(Material mat)
        {
            if (mat == null) return;
            mat.SetFloat("_Surface", 1f);
            mat.SetFloat("_Blend", 0f);
            mat.SetInt("_SrcBlend", (int)BlendMode.SrcAlpha);
            mat.SetInt("_DstBlend", (int)BlendMode.OneMinusSrcAlpha);
            mat.SetInt("_ZWrite", 0);
            mat.SetOverrideTag("RenderType", "Transparent");
            mat.renderQueue = 3000;
            mat.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
        }
    }
}
