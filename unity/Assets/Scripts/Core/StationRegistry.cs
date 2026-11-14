using System;
using System.Collections.Generic;
using Gertech.Stations;

namespace Gertech.Core
{
    /// <summary>
    /// Lookup table for plugged-in stations. The hub is the usual owner;
    /// stations can be added or replaced without editing registry internals.
    /// </summary>
    public sealed class StationRegistry
    {
        readonly Dictionary<string, IStation> stations = new Dictionary<string, IStation>(StringComparer.Ordinal);

        public int Count => stations.Count;
        public IEnumerable<IStation> All => stations.Values;

        public void Register(IStation station)
        {
            if (station == null || string.IsNullOrEmpty(station.StationId)) return;
            stations[station.StationId] = station;
        }

        public void Unregister(string stationId)
        {
            if (string.IsNullOrEmpty(stationId)) return;
            stations.Remove(stationId);
        }

        public void Clear()
        {
            stations.Clear();
        }

        public bool TryGet(string stationId, out IStation station)
        {
            station = null;
            if (string.IsNullOrEmpty(stationId)) return false;
            return stations.TryGetValue(stationId, out station);
        }

        public IStation Get(string stationId)
        {
            IStation station;
            return TryGet(stationId, out station) ? station : null;
        }
    }
}
