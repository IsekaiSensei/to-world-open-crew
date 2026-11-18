# Logic Gate Sking — TO WORLD / GERTECH

**Status:** Working playable browser prototype, November 7, 2026. This is a new owner-requested game branch, not a replacement for the existing universal game standards or a Meta render order.

## Play

Open [index.html](./index.html) as a local file in Firefox, Chrome, or another modern browser. It is a single self-contained HTML file with no downloads, accounts, network requests, images, fonts, or dependencies.

1. Read the target truth table and the clue.
2. Choose a gate with the buttons or the 1–9 keys.
3. Tap **CLOCK PULSE** (Space) or use **AUTO CLOCK**.
4. Match every expected output in the run; then choose **NEXT COURSE** (N).

The eight courses demonstrate: buffer, NOT, AND, OR, XOR, NAND, XNOR, and a clocked register with a LOAD input (the B column). The player-visible results are true Boolean evaluations, not a cosmetic animation. Wrong answers receive row-by-row feedback. The visual pulse is the "ski" metaphor; the working title uses the owner's original spelling "Sking."

## Scientific and lore boundary

- In ordinary digital electronics a quartz crystal can stabilize a clock oscillator. It is not itself a computation device or energy supply.
- Boolean gates perform logic; clocked state elements store and update information at chosen edges.
- Superconducting single-flux-quantum electronics can implement classical digital logic using Josephson junctions and cryogenic hardware; this small browser prototype does **not** simulate an SFQ device.
- Helium superfluidity and superconductivity are distinct. Neither powers the existing DNA wormhole, which remains TO WORLD's established entrance to the pocket dimension.
- Gameplay clock runs at deliberately slow **visible simulation speeds**, not hardware frequencies.
- The game identifies every state with readable 0/1 and gate labels, not color alone.

**World Bible reference:** https://docs.google.com/document/d/1wiIjBtDvhunHwL7XHHaK-IFejjtd4SeIq-0z6vG7ofE/edit

**Research:** Veritasium's *I finally saw quantum mechanics with my own eyes...*, Nov. 4 2026: https://www.youtube.com/watch?v=KfODG5REyss ; 2026 review of superconductor computing: https://doi.org/10.1109/MC.2025.3636343

## Next build candidates

A full adder, ALU course, edge timing/setup-hold minigame, wiring editor, and a Godot port are further work; they are **not yet implemented**.

This experiment is kept under `prototypes/` on a feature branch to protect the repository's active universal game standards.
