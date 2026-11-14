# Per-ref look mapping (provisional)

How the Unity hub uses each PNG. All of this is a look assist; it does not change workshop logic.

| Ref | Subject | Unity use |
|---|---|---|
| 01 | Fractal gold / silver / teal sphere cluster, spiral into a dark core | Backdrop / look plate |
| 02 | Gold Platonic frames inside a crystal sphere, cyan vortex, star dust | Backdrop plate; star-dust source for the sky plate |
| 03 | Gold cube / torus / chrome rings in a crystal sphere over a vortex | Backdrop plate; torus informs the DNA wormhole helix ring |
| 04 | Column of gold platonic frames with a cyan helix-vortex | Backdrop plate |
| 05 | Gold and chrome ring stack, icosahedra, cyan sparks | Backdrop plate |
| 06 | Gold / silver Voronoi lattice spiralling into a black core, cyan edges | Backdrop / floor decal plate |
| 07 | Distortion torus above a fractal gold / chrome / teal sphere tree | Backdrop plate; torus inform the helix ring |
| 08 | Foam / Voronoi golden-spiral lattice | Backdrop plate |
| 09 | Golden-spiral chain of gold polyhedra, cyan edges | Backdrop plate |
| 10 | Modular Crystal Block model sheet | `CrystalBlockBuilder` (glass cube, gold edge bars, corner joints, inner nebula, helix channel); hero crop + full sheet as plates |
| 11 | Five elemental Platonic crystals (fire, frost, lightning, sun, vortex) | Row of five UV-sliced plates from the sheet, plus the full sheet |
| 12 | 30-frame crystal seed → winged android sheet (6×5) | `GertechFlipbook` display |
| 13 | 30-frame helix → Platonic-frame progression (6×5) | `GertechFlipbook` display |
| 14 | Nebula triangle module with gold corner brackets and cyan bars | `TriangleModuleBuilder`; nebula crop reused in the crystal block |

## Batch 2 (2026-11-14)

Originals: `/workspace/gertech_shared_refs/visual_2026-11-14_batch2/` (see that folder's `INDEX.md`). Only 8 of the 24 images Ryan sent were in this executor's attachments; 3 were pixel-identical re-sends of REF_03 / REF_08 / REF_10. Unique new plates:

| Ref | Subject | Unity use |
|---|---|---|
| 15 | Gold honeycomb / hex tiles, cyan edges, spiral into a black core | Backdrop / look plate |
| 16 | Ornate gold / silver hex spiral into a black core, cyan edges | Backdrop / look plate |
| 17 | Golden-spiral chains of gold spheres into a black hole | Backdrop / look plate |
| 18 | Starship hull sheet (crystal-block hull, stages 7–8–9, orthos, interior gem pedestal, cyan ring engine) | Backdrop plate; informs `StarshipHull` + `DockingPort` stub |
| 19 | Photo-style crystal-block car in front of a GERTECH building | Backdrop plate; informs `CrystalBlockVehicle` and palette (violet / magenta nebula, warm-orange gold glow) |
| 10 (also in batch 2) | Modular Crystal Block infographic: seed → energized lattice → finished block; forms triangle module, machine cluster, car hull section, humanoid torso, starship hull section | `CrystalBlockGrid` / `ModularAssemblyPresets` (deduped gold edges and corner joints) plus the existing single-block builder |

**Workshop Guide** (Ryan, 2026-11-14): the gold-dress character turnaround is the **player's guide**, not just a costume ref. Name her only **Workshop Guide** (no invented name). The sheet itself was not in the 8 delivered files; when it arrives, put it in `Assets/Art/Refs/characters/` as the visual target. Unity stand-in: `Gertech.Core.Guide.GuideCharacter` (gold / crystal-lattice capsule, blue infinity accent) with `GuideDialogue` onboarding that can follow or wait near the player and point to the Forge, TETRAFORGE, and the DNA wormhole helix portal.

