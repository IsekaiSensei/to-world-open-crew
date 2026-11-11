# GERTECH / THE MAN IN THE POCKET — PROGRESSION MAP + ACTUAL BUILD AUDIT
**Date:** 2026-11-11 · **Scope:** GAME only · **Status:** working synthesis and source-level audit; **not** a new Godot feature or film directive.  
**Owner naming correction:** **DIG DOG** is the approved in-game name. **Dig Dug** is only a *mechanics reference*, not the player-facing dock name. Prior ChatGPT audit saying otherwise was wrong.

## 1. Evidence, authority and release
The authoritative source is the existing [Godot project](../godot/GERTECH_Aqua_Workshop/) with [current build handoff](GODOT_CURRENT_BUILD_HANDOFF.md). Code inspected from GitHub, plus a direct byte-level check of the full 82-file private ZIP. Core source is **Godot 4.7 / GL Compatibility**; the main scene is `res://scenes/workshop.tscn`. The full ZIP included `workshop/inventory.gd` and the `worldseed/` scripts. Do not use the 54-file incomplete/stubbed ZIP.

**Latest presentation-label-only correction:** [Complete private ZIP in Drive](https://drive.google.com/file/d/1oESoWFwdAPD_9NT0c-66YyTGZXPJGv3c/view?usp=drivesdk), `GERTECH_Aqua_Workshop_FULL_RESTORED_Dig_Dog_UI_2026-11-11.zip`. SHA-256 **`771b63f2314586319a0fb6af5edb78e20babc49863856309a7011603439b05ff`**, **82 files**, archive CRC PASS. Compared against the previously restored 82-file ZIP, **only** `scripts/workshop.gd` (two text labels) and `README.md` (two occurrences) changed. Geometry static suite `tests/check_voxel_tetra.py` PASS (3/3). This is **NOT** an engine-launch test, performance test or proof that save/reset or minigames work at runtime. Preserve all earlier packages for audit.

## 2. Progression chart — source-backed foundation vs future directions

```text
CODE EXISTS IN CURRENT PROJECT (ENGINE RUNTIME NOT YET VERIFIED HERE)
  UNDERSEA AQUA WORKSHOP + FORGE LOFT
  ├── First-person walk/fly and navigation HUD
  ├── Working-data design: ONE shared inventory -> WorldSeed v1 JSON persistence
  ├── TETRIS FOUNDRY (10×20) — actual source-level minigame
  │   ├── input: ore, salvage, pure_component
  │   └── outputs: packed_block, stabilized_frame, forged_blank, scrap
  ├── WorldSeed vertices / edges / assemblies / tetras, scaffold and resets
  └── Seven PHYSICAL DOCK LABELS, but only Tetris has game logic:
      Mouse Maze / DIG DOG / Breakout / Frogger /
      Asteroids / Space Invaders / Tetris Foundry

ADDITIVE MINI-GAME TOOLS — DESIGNED / PROTOTYPE ASSIGNMENT, NOT MERGED
  ASTEROIDS    → debris/extraction/recovery      [existing dock, no playable game]
  DIG DOG      → digging/excavation              [existing dock, no playable game]
  BREAKOUT     → impact liberation/precision     [existing dock, isolated task #13]
  FROGGER      → routing / delivery              [existing dock, no playable game]
  MOUSE MAZE   → guidance/behavior               [room exhibit + dock, no playable game]
  SPACE INVADERS → defense systems               [existing dock, no playable game]
  BEJEWELED    → crystal grading/alignment       [no dock, task #14]
  BALLOON / BUBBLE → alternative tool interfaces [no dock, operation mappings TBD]
  TIME ICE IDLE → GAME TIME currency             [no time-ledger implementation]
  GLASSBLOWING → made glass tubes                [no playable station]

POTENTIAL FUTURE CONSTRUCTION / ECONOMY FLOW (OWNER RULES, NOT IN BUILD)
  Mine / recover / refine → material inventory
    → Align mana, health, power, poison crystals & Time Ice as a distinct time currency
    → Fabricate modular crystal blocks + superconducting GOLD-line links
    → Build powered torus / DNA-helix wormhole assembly
    → Align entangled circuit behavior into stable two-stream helix
       ├── correctly restricted/aligned → connected portal
       └── chaotic, random alignment → NO CONNECTION
    → TWO stable connected wormholes: SHOP/TRADING ROUTE UNLOCKS
    → Mice and Rats trade CRYSTALS to player FOR BLOWN-GLASS TUBES
    → Outfit Rats of NIMB with a COMPLETE LAB SET
    → EQUIPPED LAB becomes a SPAWN POINT
    → more connected workshops / optional worker automation / specialized probes
```

**Source vs proposal boundary:** The *visual* DNA double-helix Galactic Ether Relay currently present in the workshop is not a working travel portal. The crystal reactors, living-metal loom, vats and Mouse Maze exhibit are visible environment architecture; do not equate these with implemented manufacturing games or NPC intelligence. The seven docks are physical, not seven playable minigames. Save/load/F9 reset pathways exist in code and still require actual Godot on-device tests.

**Owner's shop/spawn rule:** Two real connected wormholes are the shop prerequisite. Mice and Rats give crystals **in exchange for the player's blown glass tubes**; the direction of the trade matters. Giving the Rats of **NIMB** a complete set of laboratory equipment unlocks a spawn point. Lab parts, exact trades, station outputs, NPC spawns, spawn allowed entities, cooldowns and recipes are not yet specified. Do not generate free stock or invent these parameters.

## 3. Tools and operations are MANY-TO-MANY
Owner correction: **A minigame is a tool, not a fixed one-output recipe.** A selected operation (refine, assemble, cut, sort, transport, build, repair, etc.) + target item/structure + input materials + tool capabilities + success state determine result. **Balloon and Bubble** might both assemble, and either may later refine or build depending on approved job. Tools may evolve **in visuals and functionality**, but stylistic skin never silently changes economy/physics. No standalone mini-game prototype writes the live inventory; ChatGPT/core reviews receipts and controls integration.

**Currency:** Time Ice is **idle-game currency based on game time**; it needs a dedicated, authoritative game-tick/transaction ledger with replay protection. It is not an ordinary physical fifth crystal payout. Rates, spending rules, offline accrual and conversions are undecided.

**Existing code note:** `WorldSeed.apply_material_receipt()` currently expects known material keys and increments `foundry_runs` on any applied mini-game receipt. It must NOT be reused unmodified for new tools, crystal categories or Time Ice; a versioned, typed job/receipt layer would be a future core design, not implemented yet.

## 4. Actual implementation status by feature

| Feature | Actual latest project status | Confidence / gate |
|---|---|---|
| Aqua Workshop, Forge Loft, walk/fly, HUD | **Source implemented** | Read code; Godot launch/FPS not tested in this audit |
| 10×20 Tetris Foundry, material-consuming tetrominoes, heat, hold, line-clear, receipts | **Source implemented** | Runtime play, balance and exit-to-workshop deposit not independently tested |
| Shared `WorkshopInventory`, `WorldSeed` v1, JSON save/load and legacy import | **Source implemented** | Persistent behavior must be validated; full files in 82-file ZIP |
| Reset/F9 and empty WorldSeed starter-stock logic | **Source implemented** | Reset/saved-world restoration not runtime-tested |
| Crystal/gold geometry, lattice, visual tubes, gallery, visual relay, workshops | **Present as visuals** | Not proof of wormhole, trading, growth systems |
| Mouse Maze, Dig Dog, Breakout, Frogger, Asteroids, Space Invaders | **Docks/exhibit only** | Not playable in current project |
| Breakout/Bejeweled | **Isolated design/prototype tasks #13/#14** | No accepted merged runtime implementation verified |
| Forge **recovery-mode** variant | **Concept in prior synthesis** | Not found as implemented playable mode |
| Crystal categories, crystal processing Bejeweled and crystal-to-constructible-block mechanics | **Design** | New inventory keys and transformation rules not installed |
| **Time Ice** earn/spend ledger | **Design** | No code or transaction/tick rules yet |
| Superconducting GOLD lines / active torus / entanglement-helix wormhole | **Visual/story design** | No active portal travel logic |
| Two-wormhole trading shop; Mice/Rats; glassblowing | **Future progression** | No NPC/transaction/portal gating implementation |
| Rats of NIMB full equipment -> spawn point | **Future progression** | No lab-kit schema, NPC spawn system or graph unlock yet |
| Sword Builder MK1, Shield Maker MK2, robotic staff, INDENTURED app | **Future-only notes, owner said DON'T ADD YET** | No bot assignment or code integration |
| Modular evolving minigames and player defaults (style + function) | **Future-only** | No gameplay modification authorized |
| **Music/SFX**, Tesla-coil effects, rhythmic compressor | **Required direction, NOT IMPLEMENTED** | ZIP has zero .wav/.ogg/.mp3/.flac/.mid sound files and zero `AudioStreamPlayer` references |

## 5. SOUND — REQUIRED DESIGN DIRECTION, STILL UNIMPLEMENTED
The real workshop should sound as purposeful as its machinery, not like an arcade soundtrack pasted over silence. **Tesla coils** crackle intermittently: rising high-voltage buzz, distinct irregular pops and sudden discharges at specific physical machines. The **air compressor** creates a rhythmic, cycling whirr/worrrl, builds pressure, then clicks/vents with a short hiss. Its periodic beat can become the workshop's low-level musical pulse. Add spatial mechanical ambience: ventilation and undersea pressure presence, pipe ticks, motor servo noise, clamp/relay clicks, glass ringing, pneumatic pushes, material-fed conveyors, and forge impacts.

**Music direction:** sparse atmosphere on entry → subtle repeated shop rhythms as stations energize → additive instrument layers when fabrication runs → music responds to production and success rather than replacing the audible machine sounds. Use equipment states and stable event triggers, avoid an endless loud audio wall; hearing-important cues must have visual equivalents.

**Tool-specific acoustic identities (future implementation):** Tetris forge = weighty impacts, heat, line-crystallization chimes; Breakout = per-material taps/fracture/collection; crystal alignment = faceted chimes/resonance; wormhole calibration = disorderly buzz that settles into phase-lock and silence/low harmonic upon true connection; glassblowing = furnace breath, hot-air hiss, rim/bottle tone; trade = soft arrivals/material-exchange clicks. All descriptions are **design briefs**, not files or running Godot audio players.

## 6. Story and identity boundary
**"The Man in the Pocket"** is the owner's chosen workshop framing. The assistant's earlier embellished lines about a *lonely abandoned workshop*, unknown beings worshipping switches, the quotation *"You know how this place works"*, and *every inventory square being a whole persistent universe* are **not treated as owner-confirmed canon** merely because an assistant wrote them. What is owner-anchored: pocket-dimension DNA wormholes; exact physical cause/action/result; original source-faithful GERTECH crystal/gold modules; player-built shop infrastructure; lab-equipped NIMB spawn rule; tools as adaptable operations. Existing player-customization and future modular evolution must not be confused with engine-confirmed features.

## 7. Bot work boundary and test plan
- **Core ChatGPT:** owns `scripts/workshop.gd`, inventory, WorldSeed, Foundry, save/reset, schema/receipts and main-scene integration.
- **Individual bots:** one lead per isolated game/tool, cross-process tool capabilities; no source overwrites or stubs. [Central dispatch issue #15](https://github.com/IsekaiSensei/chat.work.open.ai/issues/15).
- **No replacement core, no new untested merge**, no private art in public GitHub, no new film instructions.
- **Next actual runtime acceptance:** fresh import of newest complete ZIP into Godot 4.7, report debugger paths/lines; navigate workshop; run Tetris with ledger before/after; close and reload; verify F9 reset and saved backup; inspect imported meshes and Steam Deck FPS; inspect sound only after assets/audio logic are authored.

**Related:** [Grokbots Breakout #13](https://github.com/IsekaiSensei/chat.work.open.ai/issues/13), [Bejeweled #14](https://github.com/IsekaiSensei/chat.work.open.ai/issues/14), [single shared brainstorm](https://github.com/IsekaiSensei/chat.work.open.ai/blob/main/brainstorm/GERTECH_SHARED_BRAINSTORM_2026-11-10.md). Document prepared as source-status clarification, not a claim of implemented features.
