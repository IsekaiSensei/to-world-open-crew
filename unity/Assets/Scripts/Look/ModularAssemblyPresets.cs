using System.Collections.Generic;
using UnityEngine;

namespace Gertech.Look
{
    /// <summary>
    /// Voxel layouts sketched from the REF_10 "Forms Everything" row and
    /// the REF_18 starship sheet. Provisional, not canon.
    /// </summary>
    public static class ModularAssemblyPresets
    {
        public static Vector3Int[] CarHullSection()
        {
            var cells = new List<Vector3Int>();
            // Arched shell, hollow interior — a car-hull "section" 7 long, 5 wide, 3 high.
            for (int z = 0; z < 7; z++)
            for (int x = 0; x < 5; x++)
            for (int y = 0; y < 3; y++)
            {
                bool side = x == 0 || x == 4;
                bool roof = y == 2 && x > 0 && x < 4;
                bool rail = y == 0 && (x == 1 || x == 3);
                bool nose = z == 0 && y < 2 && x > 0 && x < 4 && x != 2;
                bool tail = z == 6 && y < 2 && (side || x == 2);
                if (side || roof || rail || nose || tail)
                    cells.Add(new Vector3Int(x, y, z));
            }
            return cells.ToArray();
        }

        public static Vector3Int[] HumanoidTorso()
        {
            var cells = new List<Vector3Int>();
            // Shoulders, chest, waist. Width x=0..4, height y=0..4, depth z=0..2.
            for (int x = 1; x <= 3; x++)
            for (int z = 0; z <= 2; z++)
            {
                cells.Add(new Vector3Int(x, 0, z)); // waist
                cells.Add(new Vector3Int(x, 1, z));
                cells.Add(new Vector3Int(x, 2, z)); // chest
            }
            for (int x = 0; x <= 4; x++)
            for (int z = 0; z <= 2; z++)
                cells.Add(new Vector3Int(x, 3, z)); // shoulders
            cells.Add(new Vector3Int(2, 4, 1)); // neck
            // Upper arms
            cells.Add(new Vector3Int(0, 2, 1));
            cells.Add(new Vector3Int(4, 2, 1));
            return Unique(cells);
        }

        public static Vector3Int[] MachineCluster()
        {
            var cells = new List<Vector3Int>();
            // Irregular stacked cluster from the REF_10 "machine cluster" icon.
            AddBox(cells, 0, 0, 0, 3, 2, 3);
            AddBox(cells, 2, 0, 2, 3, 3, 2);
            AddBox(cells, 1, 2, 1, 2, 2, 2);
            cells.Add(new Vector3Int(3, 3, 3));
            cells.Add(new Vector3Int(3, 4, 3));
            cells.Add(new Vector3Int(0, 2, 0));
            cells.Add(new Vector3Int(-1, 0, 1));
            return Unique(cells);
        }

        public static Vector3Int[] StarshipHullSection()
        {
            var cells = new List<Vector3Int>();
            // Segmented cylinder along Z, 11 long, 5x5 with chamfered corners.
            int length = 11;
            for (int z = 0; z < length; z++)
            for (int x = 0; x < 5; x++)
            for (int y = 0; y < 5; y++)
            {
                bool corner = (x == 0 || x == 4) && (y == 0 || y == 4);
                bool hollow = x > 0 && x < 4 && y > 0 && y < 4 && z > 0 && z < length - 1;
                if (corner || hollow) continue;
                cells.Add(new Vector3Int(x, y, z));
            }
            // Short wing nubs mid-ship.
            cells.Add(new Vector3Int(-1, 2, 6));
            cells.Add(new Vector3Int(5, 2, 6));
            return Unique(cells);
        }

        static void AddBox(List<Vector3Int> cells, int x, int y, int z, int w, int h, int d)
        {
            for (int iz = 0; iz < d; iz++)
            for (int iy = 0; iy < h; iy++)
            for (int ix = 0; ix < w; ix++)
                cells.Add(new Vector3Int(x + ix, y + iy, z + iz));
        }

        static Vector3Int[] Unique(List<Vector3Int> cells)
        {
            var set = new HashSet<Vector3Int>();
            var list = new List<Vector3Int>();
            for (int i = 0; i < cells.Count; i++)
            {
                if (set.Add(cells[i])) list.Add(cells[i]);
            }
            return list.ToArray();
        }
    }
}
