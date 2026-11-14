using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Comparison stub: a crystal-block car hull with a Rigidbody and four
    /// WheelColliders. Layout follows the REF_10 car-hull section / REF_19 photo.
    /// Physics are not tuned in the Editor on this box.
    /// </summary>
    public sealed class CrystalBlockVehicle : MonoBehaviour
    {
        [SerializeField] CrystalBlockGrid hull;
        [SerializeField] Rigidbody body;
        [SerializeField] float motorTorque;
        [SerializeField] float steerAngle;

        readonly WheelCollider[] wheels = new WheelCollider[4];

        public CrystalBlockGrid Hull { get { return hull; } }
        public Rigidbody Body { get { return body; } }
        public WheelCollider[] Wheels { get { return wheels; } }

        public static CrystalBlockVehicle Build(
            Transform parent,
            Vector3 localPosition,
            GertechLookPalette palette,
            Texture nebula)
        {
            var go = new GameObject("CrystalBlockVehicle");
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            var vehicle = go.AddComponent<CrystalBlockVehicle>();
            vehicle.hull = CrystalBlockGrid.Build(
                go.transform,
                "CarHullSection",
                ModularAssemblyPresets.CarHullSection(),
                Vector3.zero,
                palette,
                nebula,
                0.45f,
                false);
            vehicle.body = go.AddComponent<Rigidbody>();
            vehicle.body.mass = 1200f;

            // Four wheels under the 5x3x7 hull (cell 0.45).
            float cell = 0.45f;
            float y = -0.08f;
            Vector3[] corners =
            {
                new Vector3(0.2f * cell, y, 1.2f * cell),
                new Vector3(4.8f * cell, y, 1.2f * cell),
                new Vector3(0.2f * cell, y, 5.8f * cell),
                new Vector3(4.8f * cell, y, 5.8f * cell)
            };
            string[] names = { "WheelFL", "WheelFR", "WheelRL", "WheelRR" };
            for (int i = 0; i < 4; i++)
            {
                var wheelGo = new GameObject(names[i]);
                wheelGo.transform.SetParent(go.transform, false);
                wheelGo.transform.localPosition = corners[i];
                var col = wheelGo.AddComponent<WheelCollider>();
                col.radius = 0.22f;
                col.suspensionDistance = 0.08f;
                vehicle.wheels[i] = col;
            }
            return vehicle;
        }

        public void SetDrive(float torque, float steer)
        {
            motorTorque = torque;
            steerAngle = steer;
            for (int i = 0; i < wheels.Length; i++)
            {
                if (wheels[i] == null) continue;
                wheels[i].motorTorque = torque;
                if (i < 2) wheels[i].steerAngle = steer;
            }
        }
    }
}
