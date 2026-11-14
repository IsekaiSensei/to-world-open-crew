using Gertech.Look;
using Gertech.Stations;
using UnityEngine;

namespace Gertech.Core.Guide
{
    public enum GuideMode
    {
        Wait = 0,
        Follow = 1,
        Point = 2
    }

    /// <summary>
    /// Stand-in for the Workshop Guide (player's guide). Visual target is the
    /// gold-dress / crystal-lattice / infinity-clip turnaround in
    /// Assets/Art/Refs/characters when that sheet is on disk. Named only
    /// "Workshop Guide" — no invented name.
    /// </summary>
    public sealed class GuideCharacter : MonoBehaviour
    {
        public const string DisplayName = GuideDialogue.CharacterLabel;

        [SerializeField] GertechLookPalette palette;
        [SerializeField] GuideDialogue dialogue;
        [SerializeField] Transform player;
        [SerializeField] Transform pointTarget;
        [SerializeField] GuideMode mode = GuideMode.Wait;
        [SerializeField] float followDistance = 1.8f;
        [SerializeField] float moveSpeed = 2.4f;
        [SerializeField] int hintIndex;
        [SerializeField] string currentLine;

        Transform built;
        Transform pointer;

        public GuideDialogue Dialogue
        {
            get { return dialogue; }
            set { dialogue = value; }
        }

        public Transform Player
        {
            get { return player; }
            set { player = value; }
        }

        public GuideMode Mode { get { return mode; } }
        public string CurrentLine { get { return currentLine; } }
        public int HintIndex { get { return hintIndex; } }
        public string Label { get { return DisplayName; } }

        public void Rebuild()
        {
            if (built != null) Object.Destroy(built.gameObject);

            var lattice = GertechMaterialFactory.CrystalLattice(palette);
            var gold = GertechMaterialFactory.Gold(palette);
            var accent = GertechMaterialFactory.InfinityAccent(palette);
            var chrome = GertechMaterialFactory.Chrome(palette);

            var root = new GameObject("WorkshopGuideVisual");
            root.transform.SetParent(transform, false);
            built = root.transform;

            var body = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            body.name = "DressStandIn";
            body.transform.SetParent(built, false);
            body.transform.localPosition = new Vector3(0f, 0.9f, 0f);
            body.transform.localScale = new Vector3(0.55f, 0.9f, 0.55f);
            ApplyMat(body, lattice);

            var head = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            head.name = "Head";
            head.transform.SetParent(built, false);
            head.transform.localPosition = new Vector3(0f, 1.85f, 0f);
            head.transform.localScale = Vector3.one * 0.32f;
            ApplyMat(head, gold);

            // Blue infinity accent (hair clip): two interlocking rings.
            var ringA = GertechProcMesh.Torus(0.09f, 0.018f, 16, 8);
            var clipA = GertechProcMesh.MeshObject("InfinityRingA", ringA, accent, built);
            clipA.transform.localPosition = new Vector3(-0.05f, 2.02f, 0.12f);
            clipA.transform.localRotation = Quaternion.Euler(90f, 0f, 25f);
            var ringB = GertechProcMesh.Torus(0.09f, 0.018f, 16, 8);
            var clipB = GertechProcMesh.MeshObject("InfinityRingB", ringB, accent, built);
            clipB.transform.localPosition = new Vector3(0.05f, 2.02f, 0.12f);
            clipB.transform.localRotation = Quaternion.Euler(90f, 0f, -25f);

            // Sneakers (stand-in).
            PlaceBox(built, "SneakerL", new Vector3(-0.16f, 0.08f, 0.08f), new Vector3(0.16f, 0.1f, 0.28f), chrome);
            PlaceBox(built, "SneakerR", new Vector3(0.16f, 0.08f, 0.08f), new Vector3(0.16f, 0.1f, 0.28f), chrome);

            pointer = PlaceBox(built, "Pointer", new Vector3(0.45f, 1.35f, 0.15f), new Vector3(0.06f, 0.06f, 0.7f), accent).transform;
            pointer.gameObject.SetActive(false);
        }

        public void WaitNear(Transform who)
        {
            if (who != null) player = who;
            mode = GuideMode.Wait;
            if (pointer != null) pointer.gameObject.SetActive(false);
        }

        public void Follow(Transform who)
        {
            if (who != null) player = who;
            mode = GuideMode.Follow;
            if (pointer != null) pointer.gameObject.SetActive(false);
        }

        public void PointTo(Transform target)
        {
            pointTarget = target;
            mode = GuideMode.Point;
            if (pointer != null) pointer.gameObject.SetActive(target != null);
        }

        public bool TryPointToId(string id, Transform forge, Transform tetraforge, Transform portal)
        {
            if (string.IsNullOrEmpty(id)) return false;
            if (id == StationIds.Forge || id == "forge") { PointTo(forge); return forge != null; }
            if (id == StationIds.TetraForge || id == "tetraforge") { PointTo(tetraforge); return tetraforge != null; }
            if (id == "dna_wormhole_helix_portal" || id == "portal") { PointTo(portal); return portal != null; }
            return false;
        }

        public bool PlayHint(int index, Transform forge, Transform tetraforge, Transform portal)
        {
            if (dialogue == null) dialogue = GuideDialogue.CreateDefaultOnboarding();
            var hints = dialogue.Hints;
            if (hints == null || index < 0 || index >= hints.Length) return false;
            hintIndex = index;
            var hint = hints[index];
            currentLine = hint != null ? hint.Line : null;
            if (hint == null) return false;
            switch (hint.Action)
            {
                case GuideHintAction.FollowPlayer:
                    Follow(player);
                    break;
                case GuideHintAction.PointAt:
                    TryPointToId(hint.PointTargetId, forge, tetraforge, portal);
                    break;
                default:
                    WaitNear(player);
                    break;
            }
            return true;
        }

        public bool PlayNextHint(Transform forge, Transform tetraforge, Transform portal)
        {
            return PlayHint(hintIndex + 1, forge, tetraforge, portal);
        }

        void Update()
        {
            if (player == null) return;
            if (mode == GuideMode.Follow)
            {
                var toPlayer = player.position - transform.position;
                toPlayer.y = 0f;
                if (toPlayer.magnitude > followDistance)
                {
                    var dest = player.position - toPlayer.normalized * followDistance;
                    dest.y = transform.position.y;
                    transform.position = Vector3.MoveTowards(transform.position, dest, moveSpeed * Time.deltaTime);
                }
                var look = player.position;
                look.y = transform.position.y;
                transform.LookAt(look);
            }
            else if (mode == GuideMode.Point && pointTarget != null)
            {
                var look = pointTarget.position;
                look.y = transform.position.y;
                transform.LookAt(look);
                if (pointer != null) pointer.gameObject.SetActive(true);
            }
            else if (mode == GuideMode.Wait && player != null)
            {
                var look = player.position;
                look.y = transform.position.y;
                transform.LookAt(look);
            }
        }

        public static GuideCharacter Build(
            Transform parent,
            Vector3 localPosition,
            GertechLookPalette palette,
            GuideDialogue dialogue,
            Transform player)
        {
            var go = new GameObject(DisplayName);
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            var guide = go.AddComponent<GuideCharacter>();
            guide.palette = palette;
            guide.dialogue = dialogue != null ? dialogue : GuideDialogue.CreateDefaultOnboarding();
            guide.player = player;
            guide.Rebuild();
            return guide;
        }

        static GameObject PlaceBox(Transform parent, string name, Vector3 pos, Vector3 scale, Material mat)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.name = name;
            go.transform.SetParent(parent, false);
            go.transform.localPosition = pos;
            go.transform.localScale = scale;
            ApplyMat(go, mat);
            return go;
        }

        static void ApplyMat(GameObject go, Material mat)
        {
            var renderer = go.GetComponent<MeshRenderer>();
            if (renderer != null)
            {
                renderer.sharedMaterial = mat;
                renderer.material = mat;
            }
        }
    }
}
