using Gertech.Core;
using Gertech.Core.Guide;
using Gertech.Look;
using UnityEditor;
using UnityEngine;

namespace Gertech.EditorTools
{
    /// <summary>
    /// Applies the provisional GERTECH look (palette, materials, PNG plates,
    /// helix visual, crystal block, flipbooks) when building the hub scene.
    /// </summary>
    public static class GertechLookBootstrap
    {
        const string ArtRefs = "Assets/Art/Refs";
        const string ArtCrops = "Assets/Art/Refs/crops";
        const string ArtMats = "Assets/Art/Materials";
        const string PalettePath = "Assets/Data/GertechLookPalette.asset";

        public static void ApplyLook(Transform hub, Camera camera, GameObject floor, DnaWormholeHelixPortal portal)
        {
            EnsureFolder("Assets", "Art");
            EnsureFolder("Assets/Art", "Refs");
            EnsureFolder("Assets/Art/Refs", "crops");
            EnsureFolder("Assets/Art/Refs", "batch2");
            EnsureFolder("Assets/Art/Refs", "characters");
            EnsureFolder("Assets/Art", "Materials");
            EnsureFolder("Assets", "Data");

            var palette = LoadOrCreatePalette();
            var gold = SaveMat("Gold.mat", GertechMaterialFactory.Gold(palette));
            var chrome = SaveMat("Chrome.mat", GertechMaterialFactory.Chrome(palette));
            var cyan = SaveMat("CyanEdge.mat", GertechMaterialFactory.CyanEdge(palette));
            var glass = SaveMat("CrystalGlass.mat", GertechMaterialFactory.CrystalGlass(palette));
            var space = SaveMat("SpaceFill.mat", GertechMaterialFactory.SpaceFill(palette));

            if (camera != null)
            {
                GertechBackdrop.ApplyCameraSpaceBackground(camera, palette);
                camera.backgroundColor = palette.SpaceBlack;
            }

            var lightGo = new GameObject("Cyan Rim Light", typeof(Light));
            var rim = lightGo.GetComponent<Light>();
            rim.type = LightType.Directional;
            rim.color = palette.CyanEmissive;
            rim.intensity = 0.55f;
            lightGo.transform.rotation = Quaternion.Euler(20f, 140f, 0f);

            var goldKey = new GameObject("Gold Key Light", typeof(Light));
            var key = goldKey.GetComponent<Light>();
            key.type = LightType.Directional;
            key.color = palette.GoldHighlight;
            key.intensity = 0.7f;
            goldKey.transform.rotation = Quaternion.Euler(35f, -50f, 0f);

            if (floor != null)
            {
                var floorRenderer = floor.GetComponent<MeshRenderer>();
                if (floorRenderer != null) floorRenderer.sharedMaterial = space;
                // Gold edge strip around the floor.
                var trim = GameObject.CreatePrimitive(PrimitiveType.Cube);
                trim.name = "Floor Gold Trim";
                trim.transform.position = floor.transform.position + new Vector3(0f, 0.12f, 0f);
                trim.transform.localScale = new Vector3(24.4f, 0.04f, 16.4f);
                var trimRenderer = trim.GetComponent<MeshRenderer>();
                if (trimRenderer != null) trimRenderer.sharedMaterial = gold;
            }

            var starfield = LoadTex(ArtCrops + "/starfield_from_ref02.png");
            var nebula = LoadTex(ArtCrops + "/nebula_from_ref14.png");
            var hero = LoadTex(ArtCrops + "/modular_block_hero_from_ref10.png");
            var ref01 = LoadTex(ArtRefs + "/GERTECH_REF_01_fractal_vortex_spheres.png");
            var ref02 = LoadTex(ArtRefs + "/GERTECH_REF_02_platonic_frames_crystal_sphere_vortex.png");
            var ref03 = LoadTex(ArtRefs + "/GERTECH_REF_03_gold_cube_torus_sphere.png");
            var ref04 = LoadTex(ArtRefs + "/GERTECH_REF_04_polyhedra_column_helix_vortex.png");
            var ref05 = LoadTex(ArtRefs + "/GERTECH_REF_05_gold_rings_icosahedron_stack.png");
            var ref06 = LoadTex(ArtRefs + "/GERTECH_REF_06_voronoi_gold_silver_vortex.png");
            var ref07 = LoadTex(ArtRefs + "/GERTECH_REF_07_torus_vortex_sphere_tree.png");
            var ref08 = LoadTex(ArtRefs + "/GERTECH_REF_08_foam_lattice_golden_spiral.png");
            var ref09 = LoadTex(ArtRefs + "/GERTECH_REF_09_gold_polyhedra_spiral_chain.png");
            var ref10 = LoadTex(ArtRefs + "/GERTECH_REF_10_modular_crystal_block_sheet.png");
            var ref11 = LoadTex(ArtRefs + "/GERTECH_REF_11_elemental_platonic_crystals.png");
            var ref12 = LoadTex(ArtRefs + "/GERTECH_REF_12_crystal_to_android_growth_30.png");
            var ref13 = LoadTex(ArtRefs + "/GERTECH_REF_13_helix_platonic_progression_30.png");
            var ref14 = LoadTex(ArtRefs + "/GERTECH_REF_14_nebula_triangle_module.png");

            var lookRoot = new GameObject("Look");
            if (hub != null) lookRoot.transform.SetParent(hub, false);

            // Sky / backdrop plates — PNG assist used directly.
            if (starfield != null)
            {
                GertechBackdrop.CreatePlate("Sky_Starfield", lookRoot.transform,
                    new Vector3(0f, 8f, 18f), new Vector3(0f, 180f, 0f),
                    new Vector2(32f, 32f), starfield);
                GertechBackdrop.CreatePlate("Sky_Starfield_Back", lookRoot.transform,
                    new Vector3(0f, 8f, -22f), Vector3.zero,
                    new Vector2(28f, 28f), starfield);
            }

            PlacePlate(lookRoot.transform, "Plate_REF01_FractalSpheres", ref01, new Vector3(-16f, 6f, 6f), new Vector3(0f, 110f, 0f), new Vector2(5f, 7.4f));
            PlacePlate(lookRoot.transform, "Plate_REF02_PlatonicSphere", ref02, new Vector3(16f, 6f, 6f), new Vector3(0f, -110f, 0f), new Vector2(5f, 7.4f));
            PlacePlate(lookRoot.transform, "Plate_REF03_GoldTorus", ref03, new Vector3(-12f, 5.5f, 12f), new Vector3(0f, 160f, 0f), new Vector2(4.2f, 6.2f));
            PlacePlate(lookRoot.transform, "Plate_REF04_HelixColumn", ref04, new Vector3(12f, 5.5f, 12f), new Vector3(0f, -160f, 0f), new Vector2(4.2f, 6.2f));
            PlacePlate(lookRoot.transform, "Plate_REF05_RingStack", ref05, new Vector3(-16f, 6f, -4f), new Vector3(0f, 70f, 0f), new Vector2(4f, 6f));
            PlacePlate(lookRoot.transform, "Plate_REF06_VoronoiLattice", ref06, new Vector3(0f, 0.05f, 0f), new Vector3(90f, 0f, 0f), new Vector2(10f, 8f));
            PlacePlate(lookRoot.transform, "Plate_REF07_TorusTree", ref07, new Vector3(16f, 6f, -4f), new Vector3(0f, -70f, 0f), new Vector2(4f, 6f));
            PlacePlate(lookRoot.transform, "Plate_REF08_GoldenSpiral", ref08, new Vector3(-10f, 7f, -12f), new Vector3(0f, 20f, 0f), new Vector2(4.5f, 6.7f));
            PlacePlate(lookRoot.transform, "Plate_REF09_PolyhedraChain", ref09, new Vector3(10f, 7f, -12f), new Vector3(0f, -20f, 0f), new Vector2(4.5f, 6.7f));
            PlacePlate(lookRoot.transform, "Plate_REF10_BlockSheet", ref10, new Vector3(-8f, 4.2f, 8f), new Vector3(0f, 170f, 0f), new Vector2(4.8f, 3.6f));
            PlacePlate(lookRoot.transform, "Plate_REF10_Hero", hero, new Vector3(8f, 4.2f, 8f), new Vector3(0f, -170f, 0f), new Vector2(3.2f, 2.6f));
            PlacePlate(lookRoot.transform, "Plate_REF11_Elementals", ref11, new Vector3(0f, 9.5f, 10f), new Vector3(0f, 180f, 0f), new Vector2(8f, 4.5f));
            PlacePlate(lookRoot.transform, "Plate_REF14_TriangleSheet", ref14, new Vector3(0f, 3.2f, 9f), new Vector3(0f, 180f, 0f), new Vector2(3.6f, 2.5f));

            if (portal != null)
            {
                var visual = DnaWormholeHelixVisual.Attach(portal);
                visual.Palette = palette;
                visual.VortexPlate = ref03 != null ? ref03 : ref07;
                visual.Rebuild();
            }

            var blockGo = new GameObject("ModularCrystalBlock");
            blockGo.transform.SetParent(lookRoot.transform, false);
            blockGo.transform.localPosition = new Vector3(0f, 1.1f, 2.2f);
            var block = blockGo.AddComponent<CrystalBlockBuilder>();
            block.Palette = palette;
            block.Nebula = nebula != null ? nebula : ref14;
            block.Size = 1.5f;
            block.Rebuild();

            var triangleGo = new GameObject("NebulaTriangleModule");
            triangleGo.transform.SetParent(lookRoot.transform, false);
            triangleGo.transform.localPosition = new Vector3(6.5f, 1.2f, 1.5f);
            triangleGo.transform.localRotation = Quaternion.Euler(0f, -25f, 0f);
            var triangle = triangleGo.AddComponent<TriangleModuleBuilder>();
            triangle.Palette = palette;
            triangle.Nebula = nebula != null ? nebula : ref14;
            triangle.Rebuild();

            var elementalGo = new GameObject("ElementalPlatonicCrystals");
            elementalGo.transform.SetParent(lookRoot.transform, false);
            elementalGo.transform.localPosition = new Vector3(0f, 2.2f, 6.5f);
            var row = elementalGo.AddComponent<ElementalCrystalRow>();
            row.Sheet = ref11;
            row.Rebuild();

            CreateFlipbook(lookRoot.transform, "Flipbook_REF12_CrystalToAndroid", ref12,
                new Vector3(-6.5f, 2.4f, -2.5f), new Vector3(0f, 25f, 0f), new Vector2(3.2f, 2.7f));
            CreateFlipbook(lookRoot.transform, "Flipbook_REF13_HelixPlatonic", ref13,
                new Vector3(6.5f, 2.4f, -2.5f), new Vector3(0f, -25f, 0f), new Vector2(3.2f, 2.7f));

            var ref15 = LoadTex(ArtRefs + "/batch2/GERTECH_REF_15_hex_honeycomb_cyan_spiral.png");
            var ref16 = LoadTex(ArtRefs + "/batch2/GERTECH_REF_16_gold_silver_ornate_hex_spiral.png");
            var ref17 = LoadTex(ArtRefs + "/batch2/GERTECH_REF_17_gold_sphere_chain_spiral.png");
            var ref18 = LoadTex(ArtRefs + "/batch2/GERTECH_REF_18_starship_hull_sheet.png");
            var ref19 = LoadTex(ArtRefs + "/batch2/GERTECH_REF_19_crystal_block_car_gertech_building.png");
            PlacePlate(lookRoot.transform, "Plate_REF15_HexHoneycomb", ref15, new Vector3(-18f, 6f, 2f), new Vector3(0f, 80f, 0f), new Vector2(4f, 6f));
            PlacePlate(lookRoot.transform, "Plate_REF16_OrnateHex", ref16, new Vector3(18f, 6f, 2f), new Vector3(0f, -80f, 0f), new Vector2(4f, 6f));
            PlacePlate(lookRoot.transform, "Plate_REF17_SphereChain", ref17, new Vector3(-14f, 7.5f, -8f), new Vector3(0f, 40f, 0f), new Vector2(4f, 6f));
            PlacePlate(lookRoot.transform, "Plate_REF18_StarshipSheet", ref18, new Vector3(0f, 4.8f, -14f), new Vector3(0f, 0f, 0f), new Vector2(5.4f, 4.0f));
            PlacePlate(lookRoot.transform, "Plate_REF19_CrystalCar", ref19, new Vector3(14f, 4.0f, 8f), new Vector3(0f, -150f, 0f), new Vector2(5.0f, 2.8f));

            var assemblyNebula = nebula != null ? nebula : ref14;
            CrystalBlockGrid.Build(lookRoot.transform, "Assembly_CarHullSection",
                ModularAssemblyPresets.CarHullSection(), new Vector3(-9.5f, 0.1f, -5.5f), palette, assemblyNebula, 0.4f, false);
            CrystalBlockGrid.Build(lookRoot.transform, "Assembly_HumanoidTorso",
                ModularAssemblyPresets.HumanoidTorso(), new Vector3(-6.5f, 0.1f, -5.5f), palette, assemblyNebula, 0.35f, true);
            CrystalBlockGrid.Build(lookRoot.transform, "Assembly_MachineCluster",
                ModularAssemblyPresets.MachineCluster(), new Vector3(6.5f, 0.1f, -5.5f), palette, assemblyNebula, 0.35f, false);
            var ship = StarshipHull.Build(lookRoot.transform, new Vector3(9.5f, 0.2f, -8.5f), palette, assemblyNebula);
            var vehicle = CrystalBlockVehicle.Build(lookRoot.transform, new Vector3(-11f, 0.2f, 0f), palette, assemblyNebula);

            var playerAnchor = new GameObject("PlayerAnchor");
            playerAnchor.transform.SetParent(lookRoot.transform, false);
            playerAnchor.transform.localPosition = new Vector3(0f, 0f, -1.5f);
            Transform forgeTf = hub != null ? FindChild(hub, "Forge") : null;
            Transform tetraTf = hub != null ? FindChild(hub, "TetraForge") : null;
            var guide = GuideCharacter.Build(lookRoot.transform, new Vector3(1.6f, 0f, 0.4f), palette, null, playerAnchor.transform);
            guide.PlayHint(0, forgeTf, tetraTf, portal != null ? portal.transform : null);

            // Tint station primitives that already exist under the hub.
            if (hub != null)
            {
                var renderers = hub.GetComponentsInChildren<MeshRenderer>(true);
                for (int i = 0; i < renderers.Length; i++)
                {
                    var r = renderers[i];
                    if (r == null || r.gameObject.name == "Hub Floor") continue;
                    if (r.GetComponent<GertechFlipbook>() != null) continue;
                    if (r.GetComponentInParent<CrystalBlockBuilder>() != null) continue;
                    if (r.GetComponentInParent<TriangleModuleBuilder>() != null) continue;
                    if (r.GetComponentInParent<ElementalCrystalRow>() != null) continue;
                    if (r.GetComponentInParent<DnaWormholeHelixVisual>() != null) continue;
                    if (r.GetComponentInParent<CrystalBlockGrid>() != null) continue;
                    if (r.GetComponentInParent<CrystalBlockVehicle>() != null) continue;
                    if (r.GetComponentInParent<StarshipHull>() != null) continue;
                    if (r.GetComponentInParent<GuideCharacter>() != null) continue;
                    if (r.gameObject.name.StartsWith("Plate_") || r.gameObject.name.StartsWith("Sky_") || r.gameObject.name.StartsWith("Flipbook_"))
                        continue;
                    // Alternate gold / chrome on workshop station blocks.
                    if (r.gameObject.name.Contains("Forge") || r.gameObject.name.Contains("Lathe") || r.gameObject.name.Contains("Welder"))
                        r.sharedMaterial = gold;
                    else if (r.gameObject.name.Contains("Printer") || r.gameObject.name.Contains("Quantum"))
                        r.sharedMaterial = chrome;
                    else if (r.gameObject.name.Contains("Assembly") || r.gameObject.name.Contains("Coral"))
                        r.sharedMaterial = glass;
                    else if (r.gameObject.name.Contains("Tetra") || r.gameObject.name.Contains("Tetris"))
                        r.sharedMaterial = cyan;
                }
            }

            AssetDatabase.SaveAssets();
            Debug.Log("[GERTECH] Look pass applied (provisional PNG assist; Godot remains source of truth for logic).");
        }

        static void PlacePlate(Transform parent, string name, Texture tex, Vector3 pos, Vector3 euler, Vector2 size)
        {
            if (tex == null) return;
            GertechBackdrop.CreatePlate(name, parent, pos, euler, size, tex);
        }

        static void CreateFlipbook(Transform parent, string name, Texture sheet, Vector3 pos, Vector3 euler, Vector2 size)
        {
            if (sheet == null) return;
            var go = GertechBackdrop.CreatePlate(name, parent, pos, euler, size, sheet);
            var flip = go.AddComponent<GertechFlipbook>();
            flip.Configure(sheet, GertechFlipbook.RefSheetColumns, GertechFlipbook.RefSheetRows, 8f);
        }

        static GertechLookPalette LoadOrCreatePalette()
        {
            var palette = AssetDatabase.LoadAssetAtPath<GertechLookPalette>(PalettePath);
            if (palette == null)
            {
                palette = ScriptableObject.CreateInstance<GertechLookPalette>();
                palette.ResetToSampledDefaults();
                AssetDatabase.CreateAsset(palette, PalettePath);
            }
            else
            {
                palette.ResetToSampledDefaults();
                EditorUtility.SetDirty(palette);
            }
            return palette;
        }

        static Material SaveMat(string fileName, Material mat)
        {
            var path = ArtMats + "/" + fileName;
            var existing = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (existing != null)
            {
                existing.shader = mat.shader;
                existing.CopyPropertiesFromMaterial(mat);
                EditorUtility.SetDirty(existing);
                return existing;
            }
            AssetDatabase.CreateAsset(mat, path);
            return mat;
        }

        static Texture2D LoadTex(string path)
        {
            return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        }

        static Transform FindChild(Transform root, string childName)
        {
            if (root == null) return null;
            if (root.name == childName) return root;
            for (int i = 0; i < root.childCount; i++)
            {
                var found = FindChild(root.GetChild(i), childName);
                if (found != null) return found;
            }
            return null;
        }

        static void EnsureFolder(string parent, string name)
        {
            if (!AssetDatabase.IsValidFolder(parent + "/" + name))
                AssetDatabase.CreateFolder(parent, name);
        }
    }
}
