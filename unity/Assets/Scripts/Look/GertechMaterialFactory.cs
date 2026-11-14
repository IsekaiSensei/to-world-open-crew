using UnityEngine;
using UnityEngine.Rendering;

namespace Gertech.Look
{
    /// <summary>
    /// Builds URP Lit-compatible materials (falls back to Built-in Standard or Unlit).
    /// Sets both URP (<c>_BaseColor</c>, <c>_Smoothness</c>, <c>_Surface</c>) and
    /// Built-in (<c>_Color</c>, <c>_Glossiness</c>) property names.
    /// </summary>
    public static class GertechMaterialFactory
    {
        public const string UrpLitName = "Universal Render Pipeline/Lit";
        public const string StandardName = "Standard";
        public const string UnlitColorName = "Unlit/Color";
        public const string UnlitTextureName = "Unlit/Texture";
        public const string SpritesName = "Sprites/Default";

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

        public static Material Gold(GertechLookPalette palette = null)
        {
            var gold = palette != null ? palette.Gold : GertechLook.Gold;
            return Metal(gold, 0.92f, 0.72f, "Gertech Gold");
        }

        public static Material GoldJoint(GertechLookPalette palette = null)
        {
            var gold = palette != null ? palette.GoldJoint : GertechLook.GoldJoint;
            var mat = Metal(gold, 0.88f, 0.65f, "Gertech Gold Joint");
            ApplyEmission(mat, gold, 1.6f);
            return mat;
        }

        public static Material Chrome(GertechLookPalette palette = null)
        {
            var chrome = palette != null ? palette.Chrome : GertechLook.Chrome;
            return Metal(chrome, 0.98f, 0.85f, "Gertech Chrome");
        }

        public static Material CyanEdge(GertechLookPalette palette = null)
        {
            var cyan = palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive;
            var mat = Metal(cyan, 0.35f, 0.7f, "Gertech Cyan Edge");
            ApplyEmission(mat, cyan, 3.2f);
            return mat;
        }

        public static Material CrystalGlass(GertechLookPalette palette = null)
        {
            var cyan = palette != null ? palette.CyanEmissive : GertechLook.CyanEmissive;
            var tint = GertechLook.WithAlpha(Color.Lerp(Color.white, cyan, 0.28f), 0.18f);
            var mat = new Material(FindLitShader()) { name = "Gertech Crystal Glass" };
            ApplyColor(mat, tint);
            ApplyMetal(mat, 0.08f, 0.95f);
            ApplyTransparent(mat);
            ApplyEmission(mat, GertechLook.WithAlpha(cyan, 1f), 0.35f);
            return mat;
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
