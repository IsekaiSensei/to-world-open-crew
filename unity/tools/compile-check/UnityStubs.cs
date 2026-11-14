// Minimal UnityEngine stubs for headless compile/smoke tests only.
// Not used by the Unity Editor and not a substitute for the real engine.
using System;
using System.Collections.Generic;

namespace UnityEngine.Rendering
{
    public enum BlendMode
    {
        Zero = 0,
        One = 1,
        SrcAlpha = 5,
        OneMinusSrcAlpha = 10
    }
}

namespace UnityEngine
{
    public enum Space { World, Self }
    public enum PrimitiveType { Sphere, Capsule, Cylinder, Cube, Plane, Quad }
    public enum LightType { Spot, Directional, Point, Area }
    public enum CameraClearFlags { Skybox, SolidColor, Depth, Nothing }
    public enum TextureWrapMode { Repeat, Clamp, Mirror }
    public enum FilterMode { Point, Bilinear, Trilinear }
    public enum HideFlags { None }
    public enum MaterialGlobalIlluminationFlags { None, RealtimeEmissive, BakedEmissive, EmissiveIsBlack }

    public struct Color
    {
        public float r, g, b, a;
        public Color(float r, float g, float b, float a = 1f) { this.r = r; this.g = g; this.b = b; this.a = a; }
        public static Color black { get { return new Color(0, 0, 0, 1); } }
        public static Color white { get { return new Color(1, 1, 1, 1); } }
        public static Color Lerp(Color a, Color b, float t)
        {
            t = Mathf.Clamp(t, 0f, 1f);
            return new Color(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t);
        }
        public static Color operator *(Color c, float f) { return new Color(c.r * f, c.g * f, c.b * f, c.a); }
        public static Color operator *(float f, Color c) { return c * f; }
    }

    public struct Vector2
    {
        public float x, y;
        public Vector2(float x, float y) { this.x = x; this.y = y; }
        public static Vector2 zero { get { return new Vector2(0, 0); } }
        public static Vector2 one { get { return new Vector2(1, 1); } }
        public static Vector2 operator *(Vector2 v, float f) { return new Vector2(v.x * f, v.y * f); }
        public static Vector2 operator +(Vector2 a, Vector2 b) { return new Vector2(a.x + b.x, a.y + b.y); }
    }

    public struct Vector3
    {
        public float x, y, z;
        public Vector3(float x, float y, float z) { this.x = x; this.y = y; this.z = z; }
        public float magnitude { get { return Mathf.Sqrt(x * x + y * y + z * z); } }
        public float sqrMagnitude { get { return x * x + y * y + z * z; } }
        public Vector3 normalized
        {
            get
            {
                var m = magnitude;
                return m > 0.00001f ? new Vector3(x / m, y / m, z / m) : zero;
            }
        }
        public void Normalize()
        {
            var n = normalized;
            x = n.x; y = n.y; z = n.z;
        }
        public static Vector3 zero { get { return new Vector3(0, 0, 0); } }
        public static Vector3 one { get { return new Vector3(1, 1, 1); } }
        public static Vector3 up { get { return new Vector3(0, 1, 0); } }
        public static Vector3 down { get { return new Vector3(0, -1, 0); } }
        public static Vector3 right { get { return new Vector3(1, 0, 0); } }
        public static Vector3 left { get { return new Vector3(-1, 0, 0); } }
        public static Vector3 forward { get { return new Vector3(0, 0, 1); } }
        public static Vector3 back { get { return new Vector3(0, 0, -1); } }
        public static Vector3 operator +(Vector3 a, Vector3 b) { return new Vector3(a.x + b.x, a.y + b.y, a.z + b.z); }
        public static Vector3 operator -(Vector3 a, Vector3 b) { return new Vector3(a.x - b.x, a.y - b.y, a.z - b.z); }
        public static Vector3 operator -(Vector3 a) { return new Vector3(-a.x, -a.y, -a.z); }
        public static Vector3 operator *(Vector3 a, float f) { return new Vector3(a.x * f, a.y * f, a.z * f); }
        public static Vector3 operator *(float f, Vector3 a) { return a * f; }
        public static Vector3 operator /(Vector3 a, float f) { return new Vector3(a.x / f, a.y / f, a.z / f); }
        public static Vector3 Cross(Vector3 a, Vector3 b)
        {
            return new Vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
        }
        public static float Dot(Vector3 a, Vector3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
        public static Vector3 Lerp(Vector3 a, Vector3 b, float t)
        {
            t = Mathf.Clamp(t, 0f, 1f);
            return a + (b - a) * t;
        }
        public static Vector3 MoveTowards(Vector3 current, Vector3 target, float maxDistanceDelta)
        {
            var d = target - current;
            var dist = d.magnitude;
            if (dist <= maxDistanceDelta || dist < 0.00001f) return target;
            return current + d / dist * maxDistanceDelta;
        }
    }

    public struct Vector3Int : IEquatable<Vector3Int>
    {
        public int x, y, z;
        public Vector3Int(int x, int y, int z) { this.x = x; this.y = y; this.z = z; }
        public static Vector3Int zero { get { return new Vector3Int(0, 0, 0); } }
        public bool Equals(Vector3Int other) { return x == other.x && y == other.y && z == other.z; }
        public override bool Equals(object obj) { return obj is Vector3Int && Equals((Vector3Int)obj); }
        public override int GetHashCode() { return (x * 73856093) ^ (y * 19349663) ^ (z * 83492791); }
        public static bool operator ==(Vector3Int a, Vector3Int b) { return a.Equals(b); }
        public static bool operator !=(Vector3Int a, Vector3Int b) { return !a.Equals(b); }
    }

    public struct Quaternion
    {
        public float x, y, z, w;
        public static Quaternion identity { get { return new Quaternion { w = 1f }; } }
        public static Quaternion AngleAxis(float angle, Vector3 axis) { return Euler(0f, angle, 0f); }
        public static Quaternion Euler(float x, float y, float z) { return identity; }
        public static Quaternion LookRotation(Vector3 forward) { return identity; }
        public static Quaternion LookRotation(Vector3 forward, Vector3 upwards) { return identity; }
        public static Quaternion operator *(Quaternion a, Quaternion b) { return a; }
    }

    public class Object
    {
        public string name { get; set; }
        public HideFlags hideFlags { get; set; }
        public static void Destroy(Object obj) { }
        public static void DestroyImmediate(Object obj) { }
        public static T FindFirstObjectByType<T>() where T : Object { return default(T); }
        public static implicit operator bool(Object obj) { return obj != null; }
    }

    public class Component : Object
    {
        public GameObject gameObject { get; set; }
        public Transform transform { get; set; }

        public T GetComponent<T>() { return gameObject != null ? gameObject.GetComponent<T>() : default(T); }
        public T GetComponentInParent<T>()
        {
            var found = GetComponent<T>();
            if (found != null) return found;
            if (transform != null && transform.parent != null)
                return transform.parent.GetComponentInParent<T>();
            return default(T);
        }
        public T GetComponentInChildren<T>(bool includeInactive = false)
        {
            return gameObject != null ? gameObject.GetComponentInChildren<T>(includeInactive) : default(T);
        }
        public T[] GetComponentsInChildren<T>(bool includeInactive = false)
        {
            return gameObject != null ? gameObject.GetComponentsInChildren<T>(includeInactive) : new T[0];
        }
    }

    public class Behaviour : Component
    {
        public bool enabled { get; set; } = true;
    }

    public class MonoBehaviour : Behaviour
    {
        public static void DontDestroyOnLoad(Object target) { }
    }

    public class ScriptableObject : Object
    {
        public static T CreateInstance<T>() where T : ScriptableObject
        {
            return (T)Activator.CreateInstance(typeof(T));
        }
    }

    public class Transform : Component
    {
        public Vector3 position { get; set; }
        public Vector3 localPosition { get; set; }
        public Vector3 localScale { get; set; }
        public Quaternion rotation { get; set; }
        public Quaternion localRotation { get; set; }
        public Transform parent { get; set; }
        readonly List<Transform> children = new List<Transform>();
        public int childCount { get { return children.Count; } }

        public Transform()
        {
            localScale = Vector3.one;
            rotation = Quaternion.identity;
            localRotation = Quaternion.identity;
        }

        public void SetParent(Transform newParent, bool worldPositionStays = true)
        {
            if (parent != null) parent.children.Remove(this);
            parent = newParent;
            if (parent != null) parent.children.Add(this);
        }

        public void Rotate(Vector3 axis, float angle, Space relativeTo = Space.Self) { }
        public void LookAt(Vector3 worldPosition) { rotation = Quaternion.LookRotation(worldPosition - position); }
        public void LookAt(Transform target)
        {
            if (target != null) LookAt(target.position);
        }

        public Transform GetChild(int index)
        {
            return index >= 0 && index < children.Count ? children[index] : null;
        }
    }

    public class GameObject : Object
    {
        readonly List<object> components = new List<object>();

        public GameObject() { Init("GameObject"); }
        public GameObject(string objectName) { Init(objectName); }
        public GameObject(string objectName, params Type[] componentsToAdd)
        {
            Init(objectName);
            if (componentsToAdd == null) return;
            for (int i = 0; i < componentsToAdd.Length; i++)
                AddComponent(componentsToAdd[i]);
        }

        void Init(string objectName)
        {
            name = objectName;
            transform = new Transform();
            transform.gameObject = this;
            transform.name = objectName;
            components.Add(transform);
        }

        public Transform transform { get; set; }
        public bool activeSelf { get; private set; } = true;
        public void SetActive(bool value) { activeSelf = value; }

        public T AddComponent<T>() where T : Component, new()
        {
            var component = new T();
            Bind(component);
            return component;
        }

        public Component AddComponent(Type type)
        {
            var component = (Component)Activator.CreateInstance(type);
            Bind(component);
            return component;
        }

        void Bind(Component component)
        {
            component.gameObject = this;
            component.transform = transform;
            component.name = name;
            components.Add(component);
        }

        public T GetComponent<T>()
        {
            for (int i = 0; i < components.Count; i++)
            {
                if (components[i] is T)
                    return (T)components[i];
            }
            return default(T);
        }

        public T GetComponentInChildren<T>(bool includeInactive = false)
        {
            var self = GetComponent<T>();
            if (self != null) return self;
            if (transform == null) return default(T);
            for (int i = 0; i < transform.childCount; i++)
            {
                var child = transform.GetChild(i);
                if (child == null || child.gameObject == null) continue;
                var found = child.gameObject.GetComponentInChildren<T>(includeInactive);
                if (found != null) return found;
            }
            return default(T);
        }

        public T[] GetComponentsInChildren<T>(bool includeInactive = false)
        {
            var list = new List<T>();
            Collect(this, list);
            return list.ToArray();
        }

        static void Collect<T>(GameObject go, List<T> list)
        {
            for (int i = 0; i < go.components.Count; i++)
            {
                if (go.components[i] is T)
                    list.Add((T)go.components[i]);
            }
            if (go.transform == null) return;
            for (int i = 0; i < go.transform.childCount; i++)
            {
                var child = go.transform.GetChild(i);
                if (child != null && child.gameObject != null)
                    Collect(child.gameObject, list);
            }
        }

        public static GameObject CreatePrimitive(PrimitiveType type)
        {
            var go = new GameObject(type.ToString());
            go.AddComponent<MeshFilter>();
            go.AddComponent<MeshRenderer>();
            return go;
        }
    }

    public class Texture : Object
    {
        public int width { get; set; }
        public int height { get; set; }
        public TextureWrapMode wrapMode { get; set; }
        public FilterMode filterMode { get; set; }
    }

    public class Texture2D : Texture
    {
        public Texture2D() { }
        public Texture2D(int width, int height) { this.width = width; this.height = height; }
    }

    public class Sprite : Object { }
    public class Shader : Object
    {
        public static Shader Find(string name)
        {
            return new Shader { name = name ?? "Stub" };
        }
    }

    public class Material : Object
    {
        public Shader shader { get; set; }
        public Color color { get; set; }
        public Texture mainTexture { get; set; }
        public Vector2 mainTextureScale { get; set; }
        public Vector2 mainTextureOffset { get; set; }
        public int renderQueue { get; set; }
        public MaterialGlobalIlluminationFlags globalIlluminationFlags { get; set; }

        public Material() { }
        public Material(Shader shader) { this.shader = shader; }

        public void SetColor(string name, Color value) { }
        public void SetFloat(string name, float value) { }
        public void SetInt(string name, int value) { }
        public void SetTexture(string name, Texture value) { }
        public void SetTextureScale(string name, Vector2 value) { }
        public void SetTextureOffset(string name, Vector2 value) { }
        public void SetOverrideTag(string name, string value) { }
        public void EnableKeyword(string keyword) { }
        public void DisableKeyword(string keyword) { }
        public void CopyPropertiesFromMaterial(Material mat) { }
    }

    public class Mesh : Object
    {
        public Vector3[] vertices { get; set; }
        public Vector3[] normals { get; set; }
        public Vector2[] uv { get; set; }
        public int[] triangles { get; set; }
        public void RecalculateNormals() { }
        public void RecalculateBounds() { }
        public void Clear() { }
    }

    public class Renderer : Component
    {
        public Material material { get; set; }
        public Material sharedMaterial { get; set; }
    }

    public class MeshFilter : Component
    {
        public Mesh mesh { get; set; }
        public Mesh sharedMesh { get; set; }
    }

    public class MeshRenderer : Renderer { }

    public class LineRenderer : Renderer
    {
        public int positionCount { get; set; }
        public float startWidth { get; set; }
        public float endWidth { get; set; }
        public bool useWorldSpace { get; set; }
        public bool loop { get; set; }
        public Color startColor { get; set; }
        public Color endColor { get; set; }
        Vector3[] positions = new Vector3[0];
        public void SetPosition(int index, Vector3 position)
        {
            if (positions == null || positions.Length != positionCount)
                positions = new Vector3[Math.Max(positionCount, index + 1)];
            if (index >= 0 && index < positions.Length) positions[index] = position;
        }
        public void SetPositions(Vector3[] value) { positions = value ?? new Vector3[0]; positionCount = positions.Length; }
    }

    public class Camera : Behaviour
    {
        public CameraClearFlags clearFlags { get; set; }
        public Color backgroundColor { get; set; }
        public float fieldOfView { get; set; }
        public float nearClipPlane { get; set; }
        public float farClipPlane { get; set; }
    }

    public class Light : Behaviour
    {
        public LightType type { get; set; }
        public Color color { get; set; }
        public float intensity { get; set; }
    }

    public class PropertyAttribute : Attribute { }

    [AttributeUsage(AttributeTargets.Field)]
    public sealed class SerializeField : Attribute { }

    [AttributeUsage(AttributeTargets.Field)]
    public sealed class HeaderAttribute : PropertyAttribute
    {
        public HeaderAttribute(string header) { }
    }

    [AttributeUsage(AttributeTargets.Field)]
    public sealed class TooltipAttribute : PropertyAttribute
    {
        public TooltipAttribute(string tooltip) { }
    }

    [AttributeUsage(AttributeTargets.Field)]
    public sealed class TextAreaAttribute : PropertyAttribute
    {
        public TextAreaAttribute() { }
        public TextAreaAttribute(int minLines, int maxLines) { }
    }

    [AttributeUsage(AttributeTargets.Field)]
    public sealed class RangeAttribute : PropertyAttribute
    {
        public RangeAttribute(float min, float max) { }
    }

    [AttributeUsage(AttributeTargets.Class)]
    public sealed class CreateAssetMenuAttribute : Attribute
    {
        public string fileName { get; set; }
        public string menuName { get; set; }
        public int order { get; set; }
    }

    [AttributeUsage(AttributeTargets.Class)]
    public sealed class AddComponentMenuAttribute : Attribute
    {
        public AddComponentMenuAttribute(string menuName) { }
        public AddComponentMenuAttribute(string menuName, int order) { }
    }

    public class Rigidbody : Component
    {
        public float mass { get; set; } = 1f;
        public bool isKinematic { get; set; }
        public Vector3 velocity { get; set; }
        public Vector3 angularVelocity { get; set; }
        public bool useGravity { get; set; } = true;
    }

    public class WheelCollider : Component
    {
        public float radius { get; set; } = 0.3f;
        public float suspensionDistance { get; set; }
        public float motorTorque { get; set; }
        public float brakeTorque { get; set; }
        public float steerAngle { get; set; }
    }

    public static class Debug
    {
        public static void Log(object message) { Console.WriteLine(message); }
        public static void LogWarning(object message) { Console.WriteLine("WARN " + message); }
        public static void LogError(object message) { Console.Error.WriteLine("ERROR " + message); }
    }

    public static class Application
    {
        public static string persistentDataPath { get; set; } = "/tmp/gertech-unity-compile-check";
        public static bool isPlaying { get { return true; } }
    }

    public static class Time
    {
        public static float deltaTime { get; set; } = 0.016f;
    }

    public static class Mathf
    {
        public const float PI = 3.14159274f;
        public const float Deg2Rad = PI / 180f;
        public const float Rad2Deg = 180f / PI;
        public static float Pow(float f, float p) { return (float)System.Math.Pow(f, p); }
        public static float Max(float a, float b) { return a > b ? a : b; }
        public static int Max(int a, int b) { return a > b ? a : b; }
        public static float Min(float a, float b) { return a < b ? a : b; }
        public static int Min(int a, int b) { return a < b ? a : b; }
        public static int Clamp(int value, int min, int max)
        {
            if (value < min) return min;
            if (value > max) return max;
            return value;
        }
        public static float Clamp(float value, float min, float max)
        {
            if (value < min) return min;
            if (value > max) return max;
            return value;
        }
        public static float Clamp01(float value) { return Clamp(value, 0f, 1f); }
        public static float Lerp(float a, float b, float t)
        {
            t = Clamp01(t);
            return a + (b - a) * t;
        }
        public static float Sin(float f) { return (float)Math.Sin(f); }
        public static float Cos(float f) { return (float)Math.Cos(f); }
        public static float Sqrt(float f) { return (float)Math.Sqrt(f); }
        public static float Abs(float f) { return Math.Abs(f); }
        public static int FloorToInt(float f) { return (int)Math.Floor(f); }
        public static float Repeat(float t, float length)
        {
            return t - (float)Math.Floor(t / length) * length;
        }
    }

    public static class JsonUtility
    {
        public static string ToJson(object obj) { return "{}"; }
        public static string ToJson(object obj, bool prettyPrint) { return "{}"; }
        public static T FromJson<T>(string json) { return Activator.CreateInstance<T>(); }
    }
}
