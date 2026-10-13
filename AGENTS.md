# Project X Agent Guide

## North Star

Project X is currently a PC-first Godot 4 single-player apocalypse survival prototype. Its production presentation is a static clickable shelter map, a county location map, and fixed-location scavenging UI. The preserved farming/life-simulation code is historical and reusable, but it is not the default game or the current roadmap.

Read `task_plan.md`, `CONTEXT.md`, and the relevant module documentation before making a major decision.

## Current Priority

The apocalypse flow is implemented through day seven and visually hardened: shelter, county map, three scavenging locations, inventory/storage, home facilities, deterministic day-four settlement, the authored day-five radio event, the day-six hanging-pack event, the day-seven shelter-tarp event, new-game/continue, autosave, restore, and a 34-step visual E2E. The safety-zone facility foundation is complete: a saved main-house interior plus saved chicken-coop and livestock-pen hotspots, with deterministic daily maintenance and restore coverage but no fabricated animal-production economy. The next priority is complete-slice acceptance and a keep/adjust/remove boundary list. Do not start residents, farming, social/economy systems, or resume the old farm roadmap in the same module unless the user explicitly changes direction.

## Architecture

- Treat time, saves, inventory, farming, cooking, animals, relationships, and economy as domain modules.
- Treat maps, sprites, collision geometry, UI, and scene coordinates as replaceable presentation adapters.
- Author every presentation element that Godot can edit visually as a saved scene or resource: maps, TileMap layers, object placement, spawn points, collisions, interaction areas, occlusion regions, animation frames, UI layout, and designer-facing tuning values. Do not generate the formal version of these elements from gameplay code or hide their coordinates in scripts.
- Code is reserved for behavior, domain rules, state transitions, persistence, validation, and genuinely dynamic runtime effects. Runtime fallbacks may exist for missing private assets, but they are not the editable production source of truth.
- Keep interfaces small and deep. Stable IDs and pure snapshots cross seams; Node references and texture dimensions do not.
- Preserve working domain modules and tests while replacing the old prototype presentation.

## Art Policy

- Apocalypse visuals use the existing original/local apocalypse assets as the active baseline. Preserved Super Retro World - Farming assets apply only to archived life-simulation scenes unless explicitly reused behind a replaceable presentation seam.
- Core identity remains original for a future distributable version: player, major residents, outdoor terrain, world maps, major building exteriors, crops, cooking art, UI, icons, shops, careers, and apocalypse content.
- Mineral Town art is reference-only except for the explicit private whitelist: animals and selected indoor architecture/furniture.
- Whitelisted art stays under `assets/private/` and must be replaceable without changing domain logic or saves.
- Do not use the full Mineral Town farm map, original protagonist, residents, or UI as the formal runtime foundation.
- Fixed apocalypse UI baseline: 480×256 content, compact 8–10 px UI type, nearest-neighbor scaling. Character-canvas and movement rules apply only to preserved legacy scenes; the apocalypse shelter has no persistent avatar.
- TileSets are for repeatable terrain and structures. Sprites are for characters, crops, animals, props, effects, and distinctive buildings.
- A module is not complete with grey boxes alone. It needs enough coherent art to be readable and playtestable.

## Workflow

1. Re-read `task_plan.md` before scope decisions.
2. Use `grilling` for decisions that would change scope, art policy, or the current phase.
3. Use `codebase-design` to place interfaces and seams before adding another manager or public method.
4. Implement one complete module at a time.
5. Validate new resources in this order: Godot import, automated tests, headless startup, visual capture.
6. Update Chinese documentation and all three planning files after the module.
7. Preserve user changes. Do not delete private reference assets or rewrite working systems without explicit approval.
8. For editor-authorable work, open and verify the complete Godot scene/resource in the editor. A text-generated or runtime-generated result is not accepted until the user can select, move, resize, paint, and inspect it visually without editing code.

## Definition of Done

A completed module includes specification, implementation, minimum usable art, tests, Godot validation, visual review, Chinese documentation, and planning-file updates.
