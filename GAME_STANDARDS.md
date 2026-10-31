# UNIVERSAL GAME STANDARDS — EVERY GAME

**Owner: Isekai Ryan. Active reset: October 30, 2026.**

## Scope

One universal, **data-driven system** that compatible games plug into. **No active individual game projects, scripts, film renders, character runs, or story assignments.** First common mechanics: **bullets, potions, an unlimited backpack, transitions, save/load, spawners and spawn points**.

Canonical source files: [Shared JSON schema](UNIVERSAL_GAME_SCHEMA.json) · [Working data example](UNIVERSAL_GAME_EXAMPLE.json).

## 1. Items — the foundation

An item definition has a stable ID such as `core:ammo/light` or `core:potion/health`, a category, and portable properties. A backpack entry records a **unique entry ID**, its item-definition ID, quantity, and optional instance data. Identical items can stack. Equipped slots point to the **same backpack entry** and never duplicate inventory.

- **Bullets:** same ammo pool across games, separated by ammo type and quantity. A game may use only compatible types; all others stay stored intact.
- **Potions:** shared consumable definitions for healing, energy, buffs and status effects. Effects carry type, magnitude, optional duration and cooldown. Unsupported effects remain stored rather than being converted or lost.
- **Backpack:** **one persistent shared inventory for everything collected** — no game-imposed item count, weight, slot, or stack limit. The device's physical memory/storage remains finite; no arbitrary gameplay capacity restriction is imposed.

## 2. Spawn points — game-local location data

Every point has a world-local ID, position (2D or 3D), optional orientation, role and tags. Roles include player start, enemy, item drop, boss, checkpoint and other. Optional metadata includes enabled state and linked spawner instance. **A location belongs to its game/world**; its coordinates are never assumed to have the same meaning in another game. Cross-game exits explicitly map to a destination spawn point.

## 3. Spawners — reusable logic templates

A **universal spawner template** defines what it produces (item or entity definition ID), where (one or multiple world-local spawn points through an instance), when (interval/event/wave/on-enter/manual), limits (max alive, optional total budget, cooldown), and conditions.

Each game/world creates **spawner instances** that link universal templates to its own spawn points. Spawned item pickups use the same canonical item IDs and enter the shared backpack through the same normal add-item transaction.

A world may also impose an **optional aggregate spawn budget** to protect runtime performance. Per-spawner limits remain supported. These budgets limit active world spawning, **not** backpack capacity.

## 4. Persistence and transitions — never reset progress

**Decision:** Spawner and spawn-point progress **persists across game transitions**. A half-finished wave resumes consistently rather than silently restarting. Save and restore: enabled status, cooldowns, wave index, total spawned, live entity IDs and their state, reached checkpoints, and activated spawn points. Local spawner progress stays **namespaced to its originating game**; entering another game does not cause its waves to spawn there.

Inventory, equipment references, quantities, all portable item definitions, game-local states, and spawner state travel in the **same versioned save object**. Games are consumers, not owners, of the shared backpack. Unsupported entities and items remain intact in storage. No duplicate inventory, automatic reset, silent item conversion or deletion.

**Save/load** and **game transitions** use the same schema and atomic write/restore flow. A transition is considered completed only after the new game acknowledges successfully reading the portable state; failed transition must leave the last good save available. Future versions require explicit schema migration.

## 5. Implementation order

1. **Data format (current):** one JSON schema and example for items, backpack, spawners, spawn points and saved runtime state.
2. **Shared backpack:** add/remove/consume/equip as atomic inventory transactions; test unlimited-capacity gameplay behavior.
3. **Spawning adapter:** instantiate templates at game-local points; pickups enter shared backpack; serialize cooldowns/waves/checkpoints.
4. **Transitions/save-load:** verify one game's state survives entry to another and return, without item loss, restart or duplication.

Note: JSON Schema validates structure, not every cross-reference. Runtime must additionally verify that IDs are unique, spawner and equipment references resolve, state belongs to correct game, and quantities never go negative. The example is **specification data**, not a completed game, executable runtime or proof of inter-game compatibility.
