using UnityEngine;

namespace Gertech.Core.Guide
{
    public enum GuideHintAction
    {
        Speak = 0,
        WaitNearPlayer = 1,
        FollowPlayer = 2,
        PointAt = 3
    }

    [System.Serializable]
    public sealed class GuideHint
    {
        [SerializeField] string id;
        [TextArea] [SerializeField] string line;
        [SerializeField] GuideHintAction action = GuideHintAction.Speak;
        [SerializeField] string pointTargetId;

        public string Id { get { return id; } }
        public string Line { get { return line; } }
        public GuideHintAction Action { get { return action; } }
        public string PointTargetId { get { return pointTargetId; } }

        public void Configure(string hintId, string hintLine, GuideHintAction hintAction, string targetId)
        {
            id = hintId;
            line = hintLine;
            action = hintAction;
            pointTargetId = targetId;
        }
    }

    /// <summary>
    /// Onboarding lines and hint hooks for the Workshop Guide (the player's guide).
    /// </summary>
    [CreateAssetMenu(fileName = "WorkshopGuideDialogue", menuName = "GERTECH/Guide/Dialogue", order = 0)]
    public sealed class GuideDialogue : ScriptableObject
    {
        public const string CharacterLabel = "Workshop Guide";

        [SerializeField] string speakerName = CharacterLabel;
        [SerializeField] GuideHint[] hints = new GuideHint[0];

        public string SpeakerName { get { return speakerName; } }
        public GuideHint[] Hints { get { return hints ?? new GuideHint[0]; } }

        /// <summary>
        /// Default first-visit beats: greet, then point at the Forge, TETRAFORGE,
        /// and the DNA wormhole helix portal.
        /// </summary>
        public static GuideDialogue CreateDefaultOnboarding()
        {
            var dialogue = CreateInstance<GuideDialogue>();
            dialogue.speakerName = CharacterLabel;
            dialogue.hints = new[]
            {
                Hint("welcome", "Welcome to the workshop. I am the Workshop Guide — I will stay near you and point out the stations.", GuideHintAction.WaitNearPlayer, null),
                Hint("forge", "The Forge is where ore is worked into blanks. Start here when you have raw stock.", GuideHintAction.PointAt, "forge"),
                Hint("tetraforge", "TETRAFORGE takes packed recipes and returns finished components.", GuideHintAction.PointAt, "tetraforge"),
                Hint("portal", "The DNA wormhole helix portal moves stock in and out of transit. It is a torus of distortion with a helix inside.", GuideHintAction.PointAt, "dna_wormhole_helix_portal"),
                Hint("follow", "I can follow you around the floor, or wait here if you would rather walk the stations yourself.", GuideHintAction.FollowPlayer, null)
            };
            return dialogue;
        }

        static GuideHint Hint(string id, string line, GuideHintAction action, string target)
        {
            var hint = new GuideHint();
            hint.Configure(id, line, action, target);
            return hint;
        }
    }
}
