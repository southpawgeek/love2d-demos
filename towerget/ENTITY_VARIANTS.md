# Towerget Entity Variants (Reuse First)

This game currently has four “entity roles”:
`Mob` (enemies), `Block` (towers you place), `Projectile` (bullets fired by blocks), and `Hoem` (the core you must protect).

The goal of this document is to define a consistent rule for *how to add new variants* without copy-pasting “all-new” entity files.

## What the code does today (anchors)

- `Play:update(dt)` owns the collections:
  - `self.mobs` (spawned periodically)
  - `self.blocks` (created on mouse click)
  - `self.hoem` (created once)
- `Block:update(dt)` is the source of truth for firing:
  - it accumulates `self.fire`
  - when `self.fire >= self.speed`, it spawns new `Projectile(self.x, self.y, random_angle)`
  - it stores them in `self.projectiles` and removes dead ones
- `Mob:update(dt)` moves each mob toward a destination using `destx/desty`:
  - `self.x/self.y` change by `cos(angle) * self.speed * dt`, same for `y`
- Collisions are handled by role-specific `collides(...)` calls:
  - `Block:collides(mob)` is used for mob impact on blocks
  - `Projectile:collides(mob)` is used for bullet damage on mobs
  - `Mob:collides(hoem)` is used for mob damage on the core

## Entity contract (keep variants drop-in compatible)

When you add a new variant, it must remain compatible with how `Play.lua` and the other entities call into it.

### Required methods

- `init(...)`
- `update(dt)` (mutate position/state over time)
- `render()` (draw)
- `exit()` (set `alive = false` or otherwise mark for removal)
- Collision method matching the call site:
  - `Block:collides(mob)`
  - `Projectile:collides(mob)`
  - `Mob:collides(hoem)`

### Required “shape” fields

New variants should use these fields (even if values change):

- `Mob`: `x`, `y`, `destx`, `desty`, `speed`, `size`, `alive`
- `Block`: `x`, `y`, `health`, `maxhealth`, `points`, `projectiles`, `fire`, `speed`, `healthPercent()`
- `Projectile`: `x`, `y`, `angle`, `speed`, `size`, `duration`, `alive`
- `Hoem`: `x`, `y`, `health`, `maxhealth`, `size`, `score`, `alive`

## Reuse-before-replace rule (the ladder)

Use this ladder when implementing a new variant:

1. **Stats-only variants:** override fields (`speed`, `size`, `duration`, `health`, `points`, colors, etc.) via a config table. No new files.
2. **Spawn/fire pattern variants:** parameterize *what* gets spawned (angle(s), projectile type, number of bullets per shot). Still no new files.
3. **Movement/logic variants:** inject behavior via function fields (e.g. `moveFn`, `fireFn`, `homingFn`) so the existing entity class calls the injected function. No new files.
4. **Collision/layout changes:** if and only if the hitbox math becomes fundamentally different, override collision behavior (either replace `collidesFn` or add a richer `hitbox` structure).
5. **New entity file only if required:** create a new entity class file when the update/render/collision interface must diverge so much that forcing it into the existing contract would make the code fragile.

## Optional: behavior reuse via mixins

This repo uses `towerget/lib/class.lua`, which supports `__includes` mixins.

If a variant’s differences are mostly “add/override a small set of methods” (e.g. custom `render()` or a custom movement step), prefer a mixin over forking the whole entity into a new file.

## How variants should be represented

### Prefer “type + config”, not new constructors

Add a `type` (string) and a `cfg` (table of overrides) and keep the entity class itself as generic.

Example intent (pseudo-code):

```lua
local mob = Mob(hoem.x, hoem.y, MobTypes['fast'])
-- or:
local mob = Mob(hoem.x, hoem.y)
applyConfig(mob, MobTypes['fast'])
```

If you choose the “apply after construction” approach, make sure it overrides *all* fields that were randomly generated in `init` (`Mob.speed`, `Mob.size`, `Block.health`, etc.), otherwise variants will look inconsistent.

### Centralize variant configs

Create one small file (or section) that holds all configs, e.g.:

- `MobTypes`
- `ProjectileTypes`
- `BlockTypes`
- `HoemTypes` (if/when you add multiple cores)

Configs should be simple data first (ranges, scalar values, constants), and only add function fields for steps 2–4 of the ladder.

## Where the code must be made parameterizable (practical notes)

To support variants cleanly, you’ll need “hooks” at the existing call sites:

1. `Play:update(dt)`
   - today: `Mob(self.hoem.x, self.hoem.y)` and `Block(click.x, click.y)`
   - desired: `Mob(..., MobTypes[mobType])` and `Block(..., BlockTypes[blockType])`
2. `Block:update(dt)`
   - today: `Projectile(self.x, self.y, random_angle)`
   - desired variants:
     - projectile stats (speed/duration/size/color)
     - firing pattern (single angle vs spread vs rotating barrels)

If you don’t parameterize these two areas, you’ll end up creating new entity files just to change what gets spawned.

## Naming + typos

The core is currently named `Hoem` in code and files. Keep consistent naming for now, even if the word is off; the variant system should treat it as the “core role” regardless of spelling.

## Quick examples of what counts as “reuse”

- “Fast small mob”: override `speed` range + `size` range (stats-only).
- “Tank mob”: override `speed` lower + `health` higher *if you add mob health fields*; otherwise you’ll need collision/damage contract changes.
- “Shorter bullet”: override `duration` and `speed` (projectile stats-only).
- “Spread shot”: parameterize the “angles to spawn” generator; still uses the same `Projectile:collides(mob)` logic.
- “Homing bullet”: inject a movement function for `Projectile:update(dt)` (movement/logic variants via behavior injection).

