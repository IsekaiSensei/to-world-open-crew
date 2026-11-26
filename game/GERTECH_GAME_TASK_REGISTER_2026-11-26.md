# GERTECH GAME TASK REGISTER — REVISED 26 NOVEMBER 2026
**Scope:** current game source, active verification work and separate design backlog.
**Purpose:** This register supplements the progression/build audit and current handoff. It does not declare new gameplay implemented.

## A. Current source baseline

**Project:** GERTECH Aqua Workshop + Forge Loft
**Status:** ACTIVE BUILD SOURCE / RUNTIME UNVERIFIED
**Single playable minigame:** 10×20 Tetris / Forge Foundry (**TETRAFORGE**).
**Other six docks:** Mouse Maze, DIG DOG, Breakout, Frogger, Asteroids and Space Invaders are scenery / dock infrastructure only; no playable loop is claimed for them in the current source.
**WorldSeed 1.0:** graph, local inventory, assembly structures and save/reset paths are source-present in the historical Aqua Workshop code. Godot editor/engine launch, live gameplay, persistence, reset and Steam Deck performance remain unverified in the current handoff environment.
**Separation:** Aqua Workshop is retained as legacy source/save schema. TO FAIRY World Seed instructions (18 Nov) are a distinct direction and must not overwrite this project.
**Inventory bridge:** local WorldSeed inventory ↔ universal shared backpack = **UNRESOLVED**. No duplicate ledgers, assumed adapter, silent conversion or save migration.

Source links: [current build handoff](GODOT_CURRENT_BUILD_HANDOFF.md) · [TO FAIRY World Seed direction](TO_FAIRY_WORLD_SEED_CURRENT_INSTRUCTIONS_2026-11-18.md) · [source project](../godot/GERTECH_Aqua_Workshop/).

## B. Active verification lane — existing build only

These are verification targets for the existing source, not authorization for feature expansion:
1. Import the complete current source into the intended Godot 4.7 environment and record exact version, renderer and import results.
2. Launch the main scene and walk/fly the workshop; record debugger output and any parser/runtime faults.
3. Play a complete TETRAFORGE round and inspect material debits, outputs and receipts.
4. Close/reopen and verify persisted state, save/load and backup behavior.
5. Verify F9 reset semantics and recovery from the pre-reset backup without damaging original saves.
6. Inspect existing source GLBs/resources and the actual scene scale/materials.
7. Run Steam Deck controller/input and FPS checks on device.

**No PASS may be recorded from static source inspection alone.** Record each as NOT RUN / PASS / FAIL / BLOCKED with evidence. Existing code, save schemas, inventory and main scene are protected from unrelated orbital/visual design edits.

## C. Separate design backlog — no implementation authorization

All entries below remain **DESIGN ONLY** unless explicitly noted otherwise:
- Two transport systems: Orbital vs Gate.
- Near-Dyson / Orbital Network.
- Halo/Lissajous orbit operations and invariant-manifold transfer navigation.
- Directed orbital aggregation and small-body capture.
- MICRO / MESO / MACRO operating scales.
- Classic arcade-to-simulation loop mappings.
- Orbital energy distribution and physical mass aggregation as complementary but separate systems.
- Candidate manufacturing chain beyond TETRAFORGE, including crystal processing, glassblowing, portal calibration, NIMB lab/spawn progression and related stations.
- Candidate music/SFX language (Tesla-coil discharge, compressor cycle, machinery ambience) until audio assets/code are actually present.
- Any additional minigame or worker automation not already authorized by an existing scoped task.

See [canonical Orbital Network Design](../design/GERTECH_ORBITAL_NETWORK_DESIGN.md). Candidate manufacturing and progression detail remains in the [source-backed progression/build audit](GERTECH_MAN_IN_THE_POCKET_PROGRESSION_AND_BUILD_AUDIT_2026-11-11.md).

## D. Historical prototypes — do not promote automatically

- Older 31-file WorldSeed, 2D Day 01 builds, 82-file Aqua Workshop packages, browser assembly viewers, Unity ports and other dated prototypes remain distinct historical source records.
- A source archive or prior test receipt does not prove it is the current build.
- The current handoff's Aqua Workshop legacy status and separate TO FAIRY direction remain controlling.

## E. Governance rules

1. Every feature/task records provenance, scope, date, status and source path.
2. DESIGN ONLY is not implementation. ACTIVE BUILD requires a current source location. Runtime-verified requires real engine evidence.
3. HISTORICAL PROTOTYPE never becomes active by proximity or name similarity.
4. UNRESOLVED remains explicit; do not fill gaps by inference.
5. The Orbital, Gate, Workshop and WorldSeed layers each own their mechanism.
6. New design tasks belong in the design backlog, not the active implementation queue.
7. Additions preserve existing source and save behavior; no silent replacement, stubs or auto-merge.

