# GERTECH ORBITAL NETWORK DESIGN
**Canonical design page · Owner-supplied architecture consolidated 26 November 2026**
**Status: DESIGN ONLY.** No orbital infrastructure, Near-Dyson network, manifold navigation, or orbital aggregation system is claimed as implemented. This is the single active title for this design lane. Other summaries should link here rather than create parallel master documents.

## 1. Purpose and layer boundaries

TO WORLD uses distinct layers that can connect through defined interfaces without sharing or replacing one another's mechanisms:

| Layer | Governs | Does not govern |
|---|---|---|
| **Orbital** | Celestial mechanics, trajectories, transfer corridors, rendezvous, station-keeping, orbital resource movement | Pocket-dimension connections or workshop fabrication |
| **Gate** | GERTECH pocket-dimension connections and engineered Gate behavior | Celestial orbital transfers |
| **Workshop** | Making, processing, assembly, repair, fabrication and material accounting | Orbital trajectory rules or Gate connection physics |
| **WorldSeed** | Persistent spatial structure, entities, stable IDs, topology and saved world state | The physical transport law used by another layer |

**Layer governance rule:** each layer owns its own mechanism. Connections between layers are explicit interfaces and do not make the mechanisms interchangeable.

### Two distinct transportation systems

**A. Orbital transportation — physical celestial mechanics.** This includes Lagrange regions, halo/Lissajous orbits, invariant manifolds, rendezvous, relative motion and trajectory corrections. An orbital transfer is not a Gate jump.

**B. Gate transportation — GERTECH pocket connection.** This uses the established Gate vocabulary and mechanism: superconducting GOLD-line torus support, aligned entangled double-helix connection, and stable aperture only when the required conditions cohere. Misalignment produces chaotic non-connection. A Gate jump is not a low-energy orbital transfer.

The Gate description above is established project design vocabulary, not a claim of demonstrated real-world wormhole engineering or a working current-game portal.

## 2. Orbital mechanics reference

- In the circular restricted three-body model, L1, L2 and L3 are collinear equilibrium points and are dynamically unstable.
- L4 and L5 are triangular equilibrium points, 60 degrees ahead of and behind the secondary body's orbital position. Their linear stability is conditional on the system mass ratio; the familiar Routh threshold is approximately 0.0385 for the smaller body's normalized mass parameter.
- Spacecraft do not simply park at unstable points. They may fly halo or Lissajous orbits around them and require mission-specific station-keeping.
- Trojan asteroids orbit the Sun in a planet-sharing orbit near L4 or L5. They do not orbit the planet. Their libration paths may be tadpole or horseshoe-shaped.
- Stable and unstable invariant manifolds associated with suitable periodic orbits form transport structures in phase space. They can provide low-energy pathways between orbital regions, but are not free transport and do not remove insertion, targeting or correction requirements.
- A manifold transfer is an actual trajectory design problem; it is not a teleportation mechanic.

This page is a design reference. Mission-specific numerical claims, trajectory solutions and operational costs require source-specific research and validation before use.

## 3. Near-Dyson / Orbital Network concept

**Near-Dyson** means a sparse, layered energy-distribution network, not a solid Dyson sphere and not a dense shell of collectors. It is a design concept only.

Possible conceptual layers:
1. **Primary collectors:** inner heliocentric solar-collection assets.
2. **Beam relays / power nodes:** selected heliocentric and planetary-region relay positions, chosen by line of sight, orbital dynamics and mission need.
3. **Local terminals and storage:** receivers near Earth, Mars, asteroid-industry locations and habitats.
4. **Beam management:** microwave or laser transmission, acquisition, pointing, tracking, reception and relay/re-amplification where separately justified.
5. **Maintenance and resilience:** dust and micrometeoroid response, thermal-cycle repair, alignment calibration, electronics swaps, radiator/tank repair, and redundant routes.

Energy transport and mass transport remain separate jobs:
- The Near-Dyson network moves energy and control/communications signals where specified.
- Directed orbital aggregation moves physical mass.
- They may support each other, but one is not the mechanism of the other.

## 4. Directed orbital aggregation concept

Owner-supplied design concept: survey small bodies, model long-horizon orbital flows, and use carefully timed small delta-v inputs, sails or other specified perturbation techniques to guide relative motion and reduce encounter velocities. Candidate outcomes include controlled rendezvous, shepherding, capture and eventual aggregation where the physical conditions permit.

Keep feasibility explicitly unresolved. Chaos can amplify errors; it is not automatically a capture aid. Horseshoe motion does not become a tadpole orbit merely because a generic push is applied. Each maneuver requires an explicit target orbit, perturbation and stability analysis. Gravitational reaccumulation, rubble-pile behavior, contact dynamics and active shepherding are separate design questions.

## 5. Operating scales

A single simulation can be navigated through three operating scales. These are an organizational and game-design frame, not three separate games or evidence of implementation.

| Scale | Player viewpoint | Candidate activities |
|---|---|---|
| **MICRO** | Maker at the bench | assemble, repair, inspect joints, replace components, process materials |
| **MESO** | Pilot in orbital corridors | insertion, rendezvous, halo-orbit station-keeping, intercepts, manifold navigation |
| **MACRO** | Captain at the system map | allocate resources, route fleets, manage collector/relay/terminal network and system resilience |

The camera scale changes; the underlying world and its authoritative state do not fork.

## 6. Arcade-to-simulation production references

These are design mappings for player interaction and teaching loops, not implemented minigames or current task assignments.

| Reference | Candidate simulation expression |
|---|---|
| Tempest / Tron / Rez | geometry and flow control, beam alignment, relay lock, halo-orbit station-keeping |
| Centipede / Breakout | clear/build under pressure, lattice assembly, micrometeoroid repair, salvage and rubble processing |
| Light-cycle / interception | relative-velocity matching, interception and drifter capture |
| Minesweeper / Bubble Bobble | deduction, fault detection, containment and cascade prevention |
| EVE Online | macro logistics, resource allocation and fleet routing |
| Space Engineers | modular lattice construction and structural integrity |
| Kerbal Space Program | orbital relative motion, rendezvous and low-delta-v intercepts |

The same player can zoom from maker to pilot to captain. The arcade reference supplies an interaction grammar; it does not replace the underlying simulation.

## 7. Status and implementation boundary

| Topic | Status |
|---|---|
| Orbital and Gate transport distinction | DESIGN ARCHITECTURE / GOVERNANCE RULE |
| Near-Dyson energy-distribution network | DESIGN ONLY |
| Halo/Lissajous and invariant-manifold navigation | DESIGN ONLY |
| Directed orbital aggregation | DESIGN ONLY / feasibility unresolved |
| MICRO / MESO / MACRO frame | DESIGN ONLY |
| Arcade-to-simulation mappings | DESIGN ONLY |
| Gate torus / entangled double-helix mechanism | Existing GERTECH design vocabulary; not current-game implementation |
| Current Aqua Workshop orbital layer | Not implemented / not claimed |
| WorldSeed inventory ↔ universal shared backpack | UNRESOLVED; integration not verified |

## 8. Required source and status discipline

Every addition must identify its source and state. Use:
- **OWNER-STATED / OWNER-SUPPLIED / OWNER-APPROVED** for provenance.
- **DESIGN ONLY** for concepts, architectures and visual/system proposals not implemented.
- **ACTIVE BUILD** only for source-backed current work, with runtime evidence stated separately.
- **HISTORICAL PROTOTYPE** for prior builds that are not the current baseline.
- **UNRESOLVED** for missing mappings, implementation facts, parameters or approvals.

A design document does not prove code exists. Source code does not prove runtime behavior. A static test does not prove an engine launch. An issue or order posted does not prove another agent read or accepted it.

## 9. Current game baseline reference

The current source-level game record remains **GERTECH Aqua Workshop + Forge Loft**, with one playable 10×20 Tetris / Forge Foundry (TETRAFORGE). The other six arcade docks are scenery only. The WorldSeed 1.0 graph, local inventory and save/reset pathways are present in the source record; Godot runtime remains unverified in the handoff environment. The Aqua Workshop is legacy source/save schema relative to the separate TO FAIRY World Seed direction and must not be overwritten by it.

See [current Godot handoff](../game/GODOT_CURRENT_BUILD_HANDOFF.md), [TO FAIRY World Seed instructions](../game/TO_FAIRY_WORLD_SEED_CURRENT_INSTRUCTIONS_2026-11-18.md), and [game progression/build audit](../game/GERTECH_MAN_IN_THE_POCKET_PROGRESSION_AND_BUILD_AUDIT_2026-11-11.md).

## 10. Document control

This is the sole active title for the orbital/network design lane: `design/GERTECH_ORBITAL_NETWORK_DESIGN.md`. Earlier conversational labels and temporary filenames are aliases or historical references, not competing masters. Update this page additively; preserve dated source records and never imply the design became active build without a verified implementation and explicit owner direction.


## 11. Vessel / colony-ship architecture interface

The orbital and Near-Dyson network design can support the vessel concepts indexed in [Astrofarmers Union & Vessel Interconnection](ASTROFARMERS_UNION_AND_VESSEL_INTERCONNECTION_INDEX_2026-11-27.md). This is a cross-reference, not a claim that these vessels or their mechanics are implemented.

The connected design vocabulary currently distinguishes:
- **Dragon:** capital-ship / host architecture, described as able to house other vessels or systems. Its exact relationship to the Leviathan remains open.
- **Behemoth Leviathan:** world-colony ship and one of the player's starting assets.
- **Fairy Ship:** shuttle in relation to the Leviathan, while giant relative to its own occupants and described as having a colony-ship scale or identity.
- **Starting group:** Behemoth Leviathan, Fairy Ship, and crew; the opening objective involves extracting Gertrude from the Fairy Ship.

The orbital layer can govern actual trajectories, rendezvous, transfer corridors, and station-keeping for these vessels. The Gate layer may provide a separately designed pocket connection. Workshop processes may fabricate and maintain components. WorldSeed may represent persistent vessels, rooms, crew, and docking state if a future schema is specified. **These are interfaces between layers, not interchangeable mechanisms.**

The owner's “Voltroning” direction means components can connect into configurations selected for a particular game's needs while retaining their own identities and independent usefulness. Do not assume every vessel must merge into the Dragon, that the Dragon and Leviathan are the same ship, or that a capital-ship configuration is the only valid arrangement.

The November 11 [solar Dragon handoff](../game/handoffs/TO_DOG_SOLAR_DRAGON_SHARED_MAP_WINDOW_2026-11-11.md) is related design history, but does not establish that its Dragon power-station imagery is the same entity or configuration as this capital-ship host concept.
