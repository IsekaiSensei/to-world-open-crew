using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using UnityEngine;

namespace Gertech.Inventory
{
    /// <summary>
    /// JSON save/load for the inventory ledger. File name and object keys follow
    /// the inventory subset of Godot <c>user://gertech_worldseed_v1.json</c>
    /// (version, realm_id, inventory, equipment, foundry_runs). Vertices, edges,
    /// assemblies, tetras, and the event log are not written in this scaffold.
    /// Godot also has a legacy <c>user://gertech_workshop.cfg</c> importer;
    /// that ConfigFile format is not read here.
    /// </summary>
    public static class InventoryPersistence
    {
        public const string FileName = "gertech_worldseed_v1.json";
        public const string CurrentVersion = "1.0";

        public static string SavePath => Path.Combine(Application.persistentDataPath, FileName);

        public static bool Save(Inventory inventory)
        {
            if (inventory == null) return false;
            try
            {
                Directory.CreateDirectory(Application.persistentDataPath);
                File.WriteAllText(SavePath, WriteJson(inventory), Encoding.UTF8);
                return true;
            }
            catch (Exception ex)
            {
                Debug.LogError("[GERTECH] Inventory save failed: " + ex.Message);
                return false;
            }
        }

        public static bool Load(Inventory inventory)
        {
            if (inventory == null) return false;
            if (!File.Exists(SavePath)) return false;
            try
            {
                var json = File.ReadAllText(SavePath, Encoding.UTF8);
                string realmId;
                int foundryRuns;
                var stacks = new Dictionary<string, int>();
                var equipment = new Dictionary<string, int>();
                if (!TryParse(json, out realmId, out foundryRuns, stacks, equipment))
                    return false;
                inventory.ReplaceFrom(stacks, equipment, foundryRuns, realmId);
                return true;
            }
            catch (Exception ex)
            {
                Debug.LogError("[GERTECH] Inventory load failed: " + ex.Message);
                return false;
            }
        }

        public static string WriteJson(Inventory inventory)
        {
            var sb = new StringBuilder();
            sb.Append("{\n");
            sb.Append("  \"version\": \"").Append(CurrentVersion).Append("\",\n");
            sb.Append("  \"realm_id\": \"").Append(Escape(inventory.RealmId)).Append("\",\n");
            sb.Append("  \"inventory\": ");
            WriteIntMap(sb, inventory.Stacks, "  ");
            sb.Append(",\n");
            sb.Append("  \"equipment\": ");
            WriteIntMap(sb, inventory.Equipment, "  ");
            sb.Append(",\n");
            sb.Append("  \"foundry_runs\": ").Append(inventory.FoundryRuns.ToString(CultureInfo.InvariantCulture)).Append("\n");
            sb.Append("}\n");
            return sb.ToString();
        }

        static void WriteIntMap(StringBuilder sb, IReadOnlyDictionary<string, int> map, string indent)
        {
            sb.Append("{\n");
            if (map != null)
            {
                bool first = true;
                foreach (var pair in map)
                {
                    if (string.IsNullOrEmpty(pair.Key)) continue;
                    if (!first) sb.Append(",\n");
                    first = false;
                    sb.Append(indent).Append("  \"").Append(Escape(pair.Key)).Append("\": ");
                    sb.Append(pair.Value.ToString(CultureInfo.InvariantCulture));
                }
                if (!first) sb.Append("\n");
            }
            sb.Append(indent).Append("}");
        }

        static string Escape(string value)
        {
            if (string.IsNullOrEmpty(value)) return string.Empty;
            return value.Replace("\\", "\\\\").Replace("\"", "\\\"");
        }

        /// <summary>
        /// Minimal parser for this file's one-level object-of-ints schema. Not a general JSON library.
        /// </summary>
        public static bool TryParse(
            string json,
            out string realmId,
            out int foundryRuns,
            Dictionary<string, int> stacks,
            Dictionary<string, int> equipment)
        {
            realmId = "gertech_aqua_world";
            foundryRuns = 0;
            if (string.IsNullOrEmpty(json) || stacks == null || equipment == null) return false;
            stacks.Clear();
            equipment.Clear();

            if (!TryExtractObject(json, "inventory", out var inventoryBody)) return false;
            TryExtractObject(json, "equipment", out var equipmentBody);
            ParseIntMap(inventoryBody, stacks);
            if (!string.IsNullOrEmpty(equipmentBody)) ParseIntMap(equipmentBody, equipment);

            if (TryExtractString(json, "realm_id", out var realm) && !string.IsNullOrEmpty(realm))
                realmId = realm;
            if (TryExtractInt(json, "foundry_runs", out var runs))
                foundryRuns = Math.Max(0, runs);
            return true;
        }

        static bool TryExtractObject(string json, string key, out string body)
        {
            body = null;
            var needle = "\"" + key + "\"";
            var keyIndex = json.IndexOf(needle, StringComparison.Ordinal);
            if (keyIndex < 0) return false;
            var brace = json.IndexOf('{', keyIndex + needle.Length);
            if (brace < 0) return false;
            int depth = 0;
            for (int i = brace; i < json.Length; i++)
            {
                char c = json[i];
                if (c == '{') depth++;
                else if (c == '}')
                {
                    depth--;
                    if (depth == 0)
                    {
                        body = json.Substring(brace + 1, i - brace - 1);
                        return true;
                    }
                }
            }
            return false;
        }

        static bool TryExtractString(string json, string key, out string value)
        {
            value = null;
            var needle = "\"" + key + "\"";
            var keyIndex = json.IndexOf(needle, StringComparison.Ordinal);
            if (keyIndex < 0) return false;
            var colon = json.IndexOf(':', keyIndex + needle.Length);
            if (colon < 0) return false;
            var startQuote = json.IndexOf('"', colon + 1);
            if (startQuote < 0) return false;
            var endQuote = json.IndexOf('"', startQuote + 1);
            if (endQuote < 0) return false;
            value = json.Substring(startQuote + 1, endQuote - startQuote - 1);
            return true;
        }

        static bool TryExtractInt(string json, string key, out int value)
        {
            value = 0;
            var needle = "\"" + key + "\"";
            var keyIndex = json.IndexOf(needle, StringComparison.Ordinal);
            if (keyIndex < 0) return false;
            var colon = json.IndexOf(':', keyIndex + needle.Length);
            if (colon < 0) return false;
            int i = colon + 1;
            while (i < json.Length && char.IsWhiteSpace(json[i])) i++;
            int start = i;
            if (i < json.Length && (json[i] == '-' || json[i] == '+')) i++;
            while (i < json.Length && char.IsDigit(json[i])) i++;
            if (start == i) return false;
            return int.TryParse(json.Substring(start, i - start), NumberStyles.Integer, CultureInfo.InvariantCulture, out value);
        }

        static void ParseIntMap(string body, Dictionary<string, int> target)
        {
            if (string.IsNullOrEmpty(body) || target == null) return;
            int i = 0;
            while (i < body.Length)
            {
                var q1 = body.IndexOf('"', i);
                if (q1 < 0) break;
                var q2 = body.IndexOf('"', q1 + 1);
                if (q2 < 0) break;
                var key = body.Substring(q1 + 1, q2 - q1 - 1);
                var colon = body.IndexOf(':', q2 + 1);
                if (colon < 0) break;
                int n = colon + 1;
                while (n < body.Length && char.IsWhiteSpace(body[n])) n++;
                int start = n;
                if (n < body.Length && (body[n] == '-' || body[n] == '+')) n++;
                while (n < body.Length && char.IsDigit(body[n])) n++;
                int parsed;
                if (int.TryParse(body.Substring(start, n - start), NumberStyles.Integer, CultureInfo.InvariantCulture, out parsed))
                    target[key] = Math.Max(0, parsed);
                i = n;
            }
        }
    }
}
