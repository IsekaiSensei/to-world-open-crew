# GERTECH ART DIRECTION — SCROLLS, LATTICE & RENDERER LANGUAGE
**Owner-supplied art-direction addendum · 26 November 2026**
**Status:** Directional reference. This page does not approve a new character, asset, render, or game feature.

## 1. Scrolls are JPEG reference systems, not LoRAs

TO WORLD's cross-sandbox visual reference method uses **Scrolls**: curated JPEG reference sheets/pages that carry an approved subject, geometry, identity, and matrix of visual/structural constraints into different AI sandboxes.

Do not call these LoRAs, claim trained weights, or assume a JPEG itself executes geometry. A Scroll is a human-readable visual reference that helps different systems converge on shared vocabulary and preserve identity. It can communicate appearance and visible relationships; it does not automatically provide machine-readable dimensions, fabrication tolerances, animation rigs, collision, or a production-ready 3D mesh.

Anime, sci-fi, steampunk, photoreal and cinematic treatments are rendering sandboxes. The shared vocabulary (for example lattice, matrix, vertex, edge, face, mesh, torus and helix) remains outside any one sandbox.

## 2. Matrix vocabulary

Keep these concepts distinct:
- **Geometric Matrix:** structural relationships, topology, symmetry, proportions, connections and geometric constraints.
- **Production Matrix:** prompt/render delivery conditions, camera framing, media format, continuity, output and QC constraints.

Do not rename Matrix as a Constraint Graph. Do not imply a reference image alone encodes every numeric constraint.

## 3. Shape and function must remain separate from decoration

A visible lattice, gold rail, edge filament or glow is not proof of a working port, load path, electrical channel, connection or mount. Gold lattice edges remain decorative until the relevant ports, channels, mounts and physical relationships are verified in the source/model.

In design documentation, use the owner's structural term **lattice** when it describes the actual geometry. In renderer prompts or spoken dialogue where the renderer blocks the term, use visually legible, renderer-compatible descriptions such as **armature**, **model mesh**, or **wire mesh**. Do not let a workaround alter the design meaning.

## 4. Preserve identity and source geometry

Use exact supplied character and object references. Do not redraw, rename, reassign, or merge identities without owner direction. Adapt subject geometry to the chosen asset while preserving the approved camera-view stations/angles when applying a common Lattice Master. New derivations are additional pages; do not replace source masters or existing character sheets.

The source pixels and owner-approved correction outrank AI captions, filenames, generated labels, and an agent's invented interpretation. Mark missing source assets as unavailable rather than substitute a guess.

## 5. Visual communication

- Structural function should be readable through shape, connection and material, not color alone.
- Avoid red-only status/value coding. Pair color with silhouette, labels, texture, motion, position or sound.
- Keep material appearance separate from physical behavior and game capability.
- A rendered reference is not proof of a mesh, collider, port, animation or runtime feature.

## 6. Evidence labels

Use separate states for SOURCE FOUND, PIXELS INSPECTED, SCROLL ASSEMBLED, MODEL/GEOMETRY PRESENT, RENDERED, QC REVIEWED, OWNER APPROVED and IMPLEMENTED. Do not compress them into a single "done" badge.


## 7. Shared voxel world — cross-platform spatial language
**Owner-stated direction · 27 November 2026.** Voxels are the shared spatial language for the cross-platform WorldSeed. TO FAIRY Spawners and Leylines belong to that shared voxel world and are encountered, seen and interacted with through the POV / third-person presentation system.

The distinction for every art, design and engineering team:
- **Shared seed:** the persistent world and its spatial facts. It must not fork into separate platform-specific worlds.
- **Voxel:** a platform-independent spatial unit through which the shared world can be represented and interpreted. A voxel is not, by itself, the identity or complete behavior of the thing occupying it.
- **Spawner / Leyline:** recognizable world infrastructure with its own identity, extent, connections, state and behavior. It may occupy or influence many voxels; do not reduce an entire Spawner or Leyline to one cell.
- **POV / third-person system:** a presentation and interaction perspective over the shared seed. It renders and exposes the same underlying spatial facts; it does not define a separate world.
- **Platform renderers:** may differ in camera, visual style, resolution, controls and interaction details while remaining aligned to the same shared spatial facts and persistent state.

**Spatial hierarchy and implementation distinction:** Sparse Voxel Octrees (SVOs) are a candidate data structure for organizing sparse voxel space hierarchically, supporting spatial queries and different levels of detail. An SVO is not the WorldSeed itself, not the construction Lattice, and not a replacement for stable entity IDs, topology, save history or gameplay rules. Keep construction relationships (such as Vertex → Line → Face → Mesh and seed/cluster/structure growth) distinct from the spatial subdivision used to index occupied space. Connect them through stable references rather than treating their hierarchies as identical.

**Art-direction consequence:** when depicting a Spawner, Leyline, room, structure or machine, show its relationship to the surrounding voxel world and preserve its recognizable identity across viewpoints and platform renderers. A change of camera or level of detail must not imply that the underlying object, its connections or its state has changed. Do not use voxel appearance alone as proof of collision, ports, physical connectivity, gameplay behavior or implementation.

**Status discipline:** the shared voxel spatial language is OWNER-STATED direction. The SVO connection is a technical design proposal. Exact voxel scale, world partitioning, entity-to-voxel mapping, streaming, synchronization, renderer adapters and Godot implementation remain UNRESOLVED / engineering decisions. No SVO implementation or cross-platform runtime behavior is claimed by this art-direction entry.
