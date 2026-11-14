// Minimal UnityEngine stubs for headless compile/smoke tests only.
// Not used by the Unity Editor and not a substitute for the real engine.
using System;

namespace UnityEngine
{
    public class Object
    {
        public string name { get; set; }

        public static void Destroy(Object obj) { }
        public static void DestroyImmediate(Object obj) { }
        public static T FindFirstObjectByType<T>() where T : Object { return default(T); }
    }

    public class Component : Object
    {
        public GameObject gameObject { get; set; }
        public Transform transform { get; set; }

        public T GetComponent<T>() { return gameObject != null ? gameObject.GetComponent<T>() : default(T); }

        public T GetComponentInParent<T>() { return GetComponent<T>(); }

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
    }

    public class GameObject : Object
    {
        readonly System.Collections.Generic.List<object> components = new System.Collections.Generic.List<object>();

        public GameObject() { name = "GameObject"; }
        public GameObject(string objectName) { name = objectName; }

        public Transform transform { get; set; }

        public T AddComponent<T>() where T : Component, new()
        {
            var component = new T();
            component.gameObject = this;
            component.name = name;
            components.Add(component);
            return component;
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
            return GetComponent<T>();
        }

        public T[] GetComponentsInChildren<T>(bool includeInactive = false)
        {
            var list = new System.Collections.Generic.List<T>();
            for (int i = 0; i < components.Count; i++)
            {
                if (components[i] is T)
                    list.Add((T)components[i]);
            }
            return list.ToArray();
        }
    }

    public class Sprite : Object { }

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
    }

    public static class JsonUtility
    {
        public static string ToJson(object obj) { return "{}"; }
        public static string ToJson(object obj, bool prettyPrint) { return "{}"; }
        public static T FromJson<T>(string json) { return Activator.CreateInstance<T>(); }
    }
}
