# GERTECH Premium Workshop — Godot GDScript indentation hotfix (2026-11-11)
**From:** ChatGPT / Aqua Workshop development window. **Scope:** exact packaging correction; **NOT** new game mechanics or film directions.

## Symptom and verified cause
Owner's Godot 4.7.2.stable editor screenshot showed **Parser Error: Used space character for indentation instead of tab as used before in the file** at `res://scripts/workshop.gd:372`, with 19 errors visible in the debugger. The prior `GERTECH_Aqua_Workshop_Premium_Graphics_First_2026-11-11.zip` had 4-space indentation in newly added portions of four scripts, while their earlier portions used tab indentation. This is a **confirmed source text error**, not yet a verified successful engine launch.

## CURRENT COMPLETE PROJECT ZIP — private Google Drive
**Use this full replacement ZIP instead of the earlier Premium Graphics First archive:**
- Filename: `GERTECH_Aqua_Workshop_Premium_Graphics_Indent_Hotfix_2026-11-11.zip`
- Private Drive: https://drive.google.com/file/d/1YopNqejIvn7NhLGknxvE9kWgMp261bh1/view?usp=drivesdk
- SHA-256: `94dc667a0120e16fdb17a159f43822f5bedc818414566e1045b68f88fac0f23c`
- Size: **1,535,538 bytes**, ZIP 82 members, ZIP CRC PASS.
- Project root inside ZIP: `GERTECH_Aqua_Workshop/`; `project.godot`, main scene `scenes/workshop.tscn`, main script `scripts/workshop.gd`; targets Godot **4.7**, GL Compatibility.

**Small patch:** `GERTECH_Indent_Hotfix_4_Scripts_2026-11-11.zip`
- Private Drive: https://drive.google.com/file/d/1G-kQdX9LbN6SztlcT1W8Dn41hUcd2uKm/view?usp=drivesdk
- SHA-256: `70045f97c6f5d46081181027024099faff61dfc52c817197ac04eba059ab615b`, 25,383 bytes / 4 members, ZIP CRC PASS.
- Apply only to the **matching Premium Graphics First** project, replacing four files with the enclosed paths; otherwise use the full ZIP to avoid stale sources.

**Previous package (historical, DO NOT use for a new import):**
`GERTECH_Aqua_Workshop_Premium_Graphics_First_2026-11-11.zip` SHA-256 `cc8c3ed6cb41ecac102715b06256ebb9630aeacb4507b6370822d8ca27124276`; 1,534,914 bytes. Original is retained for audit and should not be overwritten/deleted.

## Only four changed files relative to previous full ZIP
- `scripts/workshop.gd`: normalize `_add_gertech_sample_parts()` and `_reset_workshop_in_place()` blocks, including two-tab nested `return`.
- `workshop/inventory.gd`: normalize body of `reset_workshop_to_empty()`.
- `worldseed/seed_renderer.gd`: normalize formerly space-indented batched display functions and redraw block.
- `worldseed/world_seed.gd`: normalize body of `reset_to_empty_starter_stock()`.
All changed lines differ **only in leading whitespace**. Apart from these four text scripts, archive members are byte-identical. No gameplay, inventory, WorldSeed data schema, Foundry loop, reset logic, quality settings, shader/mesh/texture, paths or save format changed.

## GitHub CURRENT SOURCE ALREADY CORRECT — verified by blob hash
The four fixed ZIP sources **exactly match** existing public GitHub source blob SHA-1 values at `godot/GERTECH_Aqua_Workshop/` on `main`:
| File | GitHub blob SHA-1 |
|---|---|
| `scripts/workshop.gd` | `8923b3790f1d8275a2c54ea606f1b723fc92edde` |
| `workshop/inventory.gd` | `cec3988fb8acaa6c2d0de9b2c21761615805428a` |
| `worldseed/seed_renderer.gd` | `609b9f61be403fa9eb209b61a2c7271431e04dfc` |
| `worldseed/world_seed.gd` | `4ad393190ab1804acc323122eb548ff670ada1cf` |

**DO NOT needlessly replace GitHub source:** it is already tab-normalized, and overwriting would risk parallel authors' changes. Commit/publish this manifest and reference instead. The private ZIP is the working package; public source intentionally omits original private GLB/JPEG media. Source dependency manifest: `godot/GERTECH_Aqua_Workshop/ASSET_SOURCE_MANIFEST.md`.

## Actual tests / outstanding
**PASS (performed on actual local ZIPs):** archive CRC and 82/4-member inventories; SHA-256 hashes; exact four-file diff; each changed file identical once leading whitespace is stripped; 0 remaining space-indented lines across all four repaired scripts; Git blob SHAs compared; `tests/check_voxel_tetra.py` passes all three assertions (6 tetrahedra/voxel, conforming shared faces across x/y/z, no artificial boundary or nonmanifold triangle on shared faces).

**Known facts:** The three other `graphics/*.gd` files that use spaces are **uniformly spaces-only** within each file; mixing in these files was not detected and this hotfix does not alter them. The corrected scripts are uniformly tab-indented.

**NOT TESTED:** Godot launch, full project import/parse, Foundry play, reset/save operation, FPS/performance, or visual QC on Steam Deck. No Godot executable was available here. Owner/Grok should open **the NEW full ZIP as a separate project**, check Godot 4.7.2 debugger for next parser/import errors, and report exact paths/lines and screenshots. No claim the previous 19 errors have been cleared by a real engine run.

## Cross-window direction
- One game, one `godot/GERTECH_Aqua_Workshop/` source tree. Do not create a competing project or reintroduce the space-indented earlier ZIP.
- Owner has invited Grok to review this fix; posting a link is **not** a confirmed Grok read/test.
- No new minigames, source-art renaming, character/lore injection or film changes.
- Existing living brainstorm: https://github.com/IsekaiSensei/chat.work.open.ai/blob/main/brainstorm/GERTECH_SHARED_BRAINSTORM_2026-11-10.md
- Existing full build handoff: https://github.com/IsekaiSensei/to-world-open-crew/blob/main/game/GODOT_CURRENT_BUILD_HANDOFF.md
