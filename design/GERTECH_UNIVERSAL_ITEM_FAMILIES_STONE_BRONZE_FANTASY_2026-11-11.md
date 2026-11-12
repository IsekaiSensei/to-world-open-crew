# GERTECH / TO WORLD — ONE SHARED ITEM SET: STONE → BRONZE → METAL / FANTASY
**Owner direction, November 11, 2026.** **STATUS: FUTURE GAME DESIGN / CATALOG BRIEF. No source code, game catalog, recipe, save schema, runtime inventory, assets, or minigame implementation changed by this document.**

> **Owner exact text:** "on set of items. inventorys from games. we start with every craftings games basics. dagger, pike spear, staff. stone and bronze age tools and weapons the fantasy tier is the metal supply line"

## 1. Single item catalog, one backpack, many games
The owner wants **one set of item definitions carried across games**, not multiple incompatible inventories. Preserve [GAME_STANDARDS.md](../GAME_STANDARDS.md) as the authority: stable item-definition IDs (e.g. `core:equipment/dagger` is a **proposed example**, not a registered ID), unique backpack **entry IDs**, stack quantities, per-instance data, no arbitrary game-imposed backpack capacity, equipped slots referencing the SAME entry, one atomic shared save and per-game state. A game can display only relevant equipment while keeping unrecognized gear intact. Do not rebuild duplicate game-specific balances or mint a fresh item on entering a minigame.

**Source status distinction:** The [universal schema](../UNIVERSAL_GAME_SCHEMA.json) and [example](../UNIVERSAL_GAME_EXAMPLE.json) are **data contract/reference**, not a validated cross-game runtime. The current [Godot Aqua Workshop](../godot/GERTECH_Aqua_Workshop/) maintains a REAL local `WorldSeed.inventory` materials dictionary and `WorkshopInventory` interface, but the unified adapter between that ledger and the universal backpack is **not established/tested**. Preserve both; build an explicit versioned adapter later, not a blind merge.

## 2. Default item families — foundational tool/weapon vocabulary
These are **families of item shapes/uses**, not one-off predetermined craft recipes or minigame-exclusive drops.

| Owner-named family | Stone / early baseline | Bronze-age extension | Future metal/fantasy direction |
|---|---|---|---|
| **Dagger** | Stone or flint blade with handle | Bronze dagger | Fabricated advanced metal blade / crystal-or-superconducting modules only if later approved |
| **Spear** | Wooden shaft with stone point | Bronze point/shaft fitting | Upgraded modular point, sockets and shaft |
| **Pike** | Long wooden pole / point | Bronze-tipped pole weapon | Engineered long-shaft assembly |
| **Staff** | Wooden staff | Bound/reinforced staff | Metal and eventual crystal or gold-line functionality, with approval |
| Axe / hatchet | Stone chopping head | Bronze cutting head | Shop-grade cutter / specialty axe |
| Pick | Stone pick/head | Bronze mining pick | Industrial extractor |
| Hammer / mallet | Stone hammer, wooden mallet | Bronze striking tools | Precision assembly/forge hammer |
| Knife / chisel / awl | Flint, bone or stone edged-point tools | Bronze equivalents | Finishing, carving and assembly tools |
| Hoe / sickle / simple implements | Wood/stone/bone | Bronze head/edge | Agricultural and manufacturing use |

The first **four named families** (dagger, pike, spear, staff) are direct owner requirements; additional generic tools are common-crafting-genre **candidate examples** and are not an assertion that each has been individually approved or implemented. Distinguish functional equipment from raw stock and parts. Keep exact per-tier recipes, durability, weapon mechanics, damage, mounts, animations and capacity **unassigned** until detailed owner/game-design approval.

## 3. Supply line is the fantasy-tier foundation
**Proposed visual/manufacturing progression** (not a physics or rarity mandate):
- **Early material gathering:** timber/shaft stock, rock/flint, bone, fiber/cord, hide, clay; quarrying, splitting, shaping, lashing and assembly.
- **Copper/bronze chain:** excavate copper and tin ores, sort/refine, smelt the metals, alloy bronze, cast or form components, shape edges, attach shafts/handles, inspect and finish; by-products should be accounted for.
- **Advanced metal/fantasy chain:** usable metal stock from the real workshop supply network → precision cutting/forming/mounting → component assemblies → optional source-approved GERTECH crystal structures and **gold-line superconducting circuitry**. A fantasy appearance/function evolves out of the **metal supply line**, not a free item spawned by a score, cosmetic skin or random unaccounted supply.
- Many **different minigame tools** can contribute to the same job (e.g. assembly or refinement); one minigame may perform several operations. The selected **operation + material + target item/assembly + tool capabilities** determines the result, not the minigame's title.

**Tier is not a replacement item catalog.** A dagger, spear, pike or staff retains a recognizable item family and can change material/components and eventually functions, with any equip/stats conversion explicit and persistent. The owner's existing **"Color is what / shape is what it does"** design convention applies to clear readable equipment and process visuals.

## 4. Future item/recipe schema questions, not code
**Candidate data layers:** item family ID, portable instance ID, physical/material composition, tier or fabrication grade, base shape and sockets, attachments, quality/finish, current durability if later selected, compatible equipment/tool operations, source/provenance, owner/custody, and assembly state. Existing JSON `item_definition` supports `category: "equipment"`, `subtype`, and a free-form `properties` object; `item_entry` permits `instance_data`. Do not introduce incompatible top-level schema keys without migration. Game-specific transient state belongs in namespaced game save state; backpack entries remain portable.

**Job receipt principle:** same source item is debited/modified once, output instance references are unique, salvaged offcuts/failed attempts are explicit, abort/rollback does not double charge, no weapon/equipment dupes on travel, no auto-recipe unlock and no silent destruction of items a game cannot use. When a tool transforms an existing item, preserve item identity/parentage in provenance where possible. Transporting an item does not mean crafting a new copy.

**The project's currently implemented Tetris Foundry** consumes ore/salvage/pure_component and produces packed_block, stabilized_frame, forged_blank and scrap. It does **not** currently create finished daggers, spears, pikes, staffs, bronze ingots or fantasy weapons; this catalog is future progression, not a claim about the existing 82-file build. Current engine runtime was not verified in this design pass.

## 5. Delivery and ownership boundary
**Core ChatGPT:** owns shared backpack / WorldSeed adapter, authoritative item IDs and inventory-saving transactions, and eventual player/robot tooling integration. **Grok/Grokbots:** can document or make isolated tested minigame tools only with explicit scoped assignment; each minigame is a tool, not an alternate stock authority. Do not overwrite core source, add stubs, auto-merge drafts or write private owner art to public GitHub. Existing future-only rule for Sword Builder MK 1 / Shield Maker MK2 / INDENTURED / evolving player defaults remains **DO NOT IMPLEMENT YET**.

Read next: [universal item standards](../GAME_STANDARDS.md); [universal schema](../UNIVERSAL_GAME_SCHEMA.json); [actual implementation/progression audit](../game/GERTECH_MAN_IN_THE_POCKET_PROGRESSION_AND_BUILD_AUDIT_2026-11-11.md); [one shared brainstorming file](https://github.com/IsekaiSensei/chat.work.open.ai/blob/main/brainstorm/GERTECH_SHARED_BRAINSTORM_2026-11-10.md). This is a design record **only**, not an engine feature.

## 6. Owner addition — buildable Players Backpacks, player-ready worlds, cross-genre loadouts, reset cleanup

**Owner exact words (2026-11-11):** "thats one thing the player need to build so their would can have Players. and we'll call them Players Backpacks. and have fantasy and call of duty types being made and traded with the rats and mice the battle filed cleaner and clearing team who goes out when you hit reset"

**STATUS: FUTURE-PROGRESSION OWNER CONCEPT — NOT YET IMPLEMENTED; NO CHANGES TO THE LIVE GODOT GAME.**

### Core distinctions
1. **Players Backpacks is the owner's exact name of a buildable item/equipment family.** Players fabricate these so their worlds can **have Players**. This is a progression/build requirement for making a world ready to receive/host Players. It is not merely a cosmetic illustration and should not be silently equated to a loose item-stack UI.
2. **Two design layers must coexist:** (a) the existing **universal backpack** under GAME_STANDARDS.md is the software authority for portable item ownership and one persistent cross-game inventory; (b) a physically craftable **Players Backpacks** item/equipment/registration object is a future manufactured world-entry artifact. Neither design demands a second inventory database. Do not weaken the existing unlimited-backpack rule by silently introducing capacity/weight/slot limits.
3. **Fantasy and "Call of Duty types"** are two owner-named equipment/loadout styles/families that can be **MADE and TRADED**, not a request to copy proprietary franchise assets, characters, names or maps. Fantasy examples derive from the existing dagger/pike/spear/staff + stone/bronze/metal crafting line. Contemporary military/FPS-style equipment types are a category; exact item list, mechanics, tiers and recipes are **NOT approved yet**.
4. **Rats and mice** are the recurring traders and now also a **battlefield cleaner and clearing team**, deployed **when the player hits Reset**. This is a world event and cleanup/recovery role triggered by reset: show an actual team going out, not merely a hidden deletion. Exact salvage ownership, recovered item payouts, clearing destinations and timing remain undecided; never create free stock.
5. **Critical Reset distinction:** Current Godot's F9 workshop reset uses reset_workshop_to_empty(), backs up the former WorldSeed save, then resets local WorldSeed state to empty scaffold/starter stock. GAME_STANDARDS.md separately requires portable backpack/player progress persistence across game transitions. This new battlefield-cleaning event is **not wired to either**. **Do not change, intercept, or conflate F9 reset, game transition, stage reset/battlefield clear, respawn, or a full save wipe** until owner approves an exact trigger and semantics. Preserve existing reset behavior.
6. **Possible later progression gate:** manufacture equipment/Players Backpacks in the shop → trade using rat/mouse routes → the player's world gains player-ready entry/spawn capability after legitimate requirements are met. This linkage is a **proposal**, not an approved fixed recipe, number-of-players rule, or completed spawning system. Buildability/world-player purpose are owner-defined; activation conditions are open.
7. **Source/data boundaries:** Portable item definitions and individual entries have stable IDs; trade consumes inventory once and preserves provenance; any battlefield recovery must be accounted for and spawns must use world-local IDs and persistent state. No duplicate item pools, direct minigame ledger writes, automatic code merges, invented NPC identities, or publication of private art.
8. **Open design questions, not a request to implement:** Does each Players Backpacks object represent world admission, inventory equipment, spawn eligibility, or all three? Which Reset activates the cleanup team? What is collected and retained, and what is restored? Are fantasy and military types backpacks, loadouts, traded equipment, or all three? Preserve all as undecided.

All these systems remain FUTURE DESIGN ONLY. Existing Aqua Workshop gameplay, inventory, Foundry and save/reset code stay untouched.
