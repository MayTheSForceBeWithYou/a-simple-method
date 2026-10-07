# 16 — Sprites, Tilemaps, Collision

Lesson 15 gave you input and timing. This lesson gives you **space**: indexing a tile map, converting world coordinates to tiles, culling and clipping sprites against the camera, testing axis-aligned bounding boxes (AABBs) for overlap, spatial hashing for fast collision queries, and animation frame selection. By the end you'll see that 2D game math is not magic—it's row-major indexing, bitwise shifts for power-of-two tile sizes, and half-open intervals that make edge cases disappear.

## What this lesson asks of you

- Index a row-major tile map with `y * width + x` and convert a world coordinate to a tile index with a right-shift (not division).
- Cull a sprite only when it's **fully outside** the view (`sx >= view_w` **or** `sx + sw <= 0`), and clip a partially visible sprite to the visible width.
- Test two AABBs for overlap with four inequalities on **both axes**: overlap requires `x` agreement **and** `y` agreement.
- Hash a world position into a spatial-hash cell with shifts, and compute the range of tiles an AABB touches (converting the box's half-open `[x0, x1)` to tile columns `x0 >> 3` through `(x1 - 1) >> 3`).
- Select an animation frame with `(time / ticks_per_frame) mod frame_count`, reading the **remainder** (in `rdx`) after the second `div`.

## Why sprites and collision for the game milestone

Lesson 17's ECS entities and lesson 18's park simulation need:
- **Tilemaps:** Draw background tiles, query solid flags for collision.
- **Sprites:** Blit character/tree/building images with color-key transparency.
- **AABBs:** Detect overlap for entity-entity collision and entity-tile collision.
- **Spatial hash:** Query nearby entities without testing every pair.

The drills below isolate each primitive so you can verify them before integrating into the full renderer and physics.

## Tile map: row-major indexing and world-to-tile conversion

A **tile map** is a 2D grid of tile IDs stored in a flat 1D array, row-major order.

### Indexing

For a map of width `w`, the tile at `(x, y)` is at index:

```
index = y * w + x
```

**Drill:** `01-tile-index.asm` computes `y=2, w=10, x=3` → `2*10 + 3` = 23, exits 23.

**Drill:** `09-tile-at.asm` — map stored as bytes, width 4, cell `(1, 1)` is index `1*4 + 1` = 5, byte at index 5 is 5, exits 5.

### World coordinate to tile coordinate

If tiles are 8 pixels wide (power of 2), divide by 8 using a **right shift by 3** (not `div`):

```
tile_x = world_x >> 3
```

**Drill:** `10-world-to-tile.asm` — world x = 20, tile size 8 → `20 >> 3` = 2, exits 2.

**Chunk indexing:** A **chunk** is a group of tiles. For chunk size 16, `chunk_x = tile_x >> 4`.

**Drill:** `23-stretch-chunk-coords.asm` — tile 40 → `40 >> 4` = 2, exits 2.

### Tile properties

Store tile properties (solid, water, damage) in a separate byte array indexed by tile ID.

**Drill:** `05-tile-solid.asm` — tile ID 2's solid flag is 1, exits 1.

**Drill:** `14-tile-collision-mask.asm` — tile value 3, mask bit 0 → 1, exits 1.

**Drill:** `20-tile-autotile-mask.asm` — autotile neighbors: N = 1, E = 4 → `1 | 4` = 5, exits 5.

## Sprite rendering: screen space, culling, and clipping

### World to screen space

Screen x = world x − camera x.

**Drill:** `04-sprite-origin.asm` — world 50, camera 20 → `50 - 20` = 30, exits 30. The sprite is inside `[0, 40)` (view width), so it's drawn.

### Culling: fully outside the view

A sprite is **culled** (not drawn) only when it's **fully** outside the view:

- Off the **right**: `sx >= view_w`
- Off the **left**: `sx + sw <= 0`

Both conditions are tested. If either is true, cull. A sprite at `sx = -8, sw = 8` is fully left of the view (right edge at 0) and should be culled. A one-sided test `sx < view_w` would incorrectly report it as visible.

**Drill:** `15-camera-cull.asm` — the lesson describes `x=100, w=8, view=40`. The sprite is off the right (`100 >= 40`), so cull, exit 1. However, the **solution as shipped** subtracts a camera of 50 (giving `sx = 50`), tests only `sx < view_w`, and exits 1 (culled) for the right-edge case. The left-edge test is **not implemented**. The drill correctly exits 1 for this input, but it does not demonstrate the full two-sided cull the lesson describes.

### Clipping: partially visible sprites

If a sprite is **partially** inside the view, clip it to the visible region. Clamp `sx` to `[0, view_w)` and adjust the width.

**Pseudocode:**

```
if sx < 0:
    sw += sx            # shrink width by the off-left amount (sx is negative)
    sx = 0
if sx + sw > view_w:
    sw = view_w - sx    # shrink width to fit inside right edge
if sw <= 0:
    cull (fully clipped)
```

**Drill:** `07-clip-w.asm` — the lesson describes `x=6, w=8, view=10`. The left edge is inside (6 ≥ 0). The right edge is outside (6+8 = 14 > 10), so clip: `sw = 10 - 6 = 4`, exit 4. However, the **solution as shipped** is `mov rdi, 2` and exits **2**. This is a mismatch. The lesson's listing code is correct and would exit 4.

After clipping, blit the sprite with the keyed blit from lesson 14 (skipping transparent pixels).

### Layer sorting

Draw sprites in **layer order** (back to front) so nearer layers cover farther ones. Build a **draw key** `layer * 1000 + y` for sorting.

**Drill:** `11-sprite-layer.asm` — the lesson describes `layer=0, y=42` → `0*1000 + 42` = 42, exit 42. However, the **solution as shipped** is `mov rdi, 2` and exits **2**. This is a mismatch; the lesson describes the formula, the drill is a placeholder constant.

### Flip flags

Horizontal flip (HFLIP = 1) and vertical flip (VFLIP = 2) combine with OR.

**Drill:** `17-flip-flags.asm` — `1 | 2` = 3, exits 3.

**Drill:** `21-sprite-batch-count.asm` — count 8 sprite records, exits 8.

## Animation frame selection

Animation frame index:

```
frame = (time / ticks_per_frame) mod frame_count
```

Use `div` twice: first to get `time / ticks`, then `mod frame_count`. The **remainder** (in `rdx`) after the second `div` is the frame.

**Drill:** `16-anim-frame.asm` — `time=10, ticks=4, frames=3`:
1. `10 / 4` → quotient 2 (in `rax`), remainder 2 (in `rdx`).
2. Zero `rdx`, then `div 3` → `2 / 3` → quotient 0 (in `rax`), **remainder 2** (in `rdx`).
3. Exit `rdx` (2), **not** `rax`.

**Critical:** Zero `rdx` before every unsigned `div` (lesson 15).

## Axis-aligned bounding box (AABB) collision

An **AABB** is a rectangle with sides parallel to the axes: `[x0, y0, x1, y1)` (half-open).

### Overlap test

Two AABBs **miss** (do not overlap) if one is completely to one side of the other:

```
miss = (a.x1 <= b.x0) or (b.x1 <= a.x0) or (a.y1 <= b.y0) or (b.y1 <= a.y0)
```

Overlap is the negation: **all four inequalities false**. Both axes must agree—testing x alone is not enough.

**Drill:** `02-aabb-overlap.asm` — the lesson describes boxes `[0,0,2,2]` and `[1,1,3,3]` that overlap on x and y, so "the file compares all four edges and exits 1." The **solution as shipped** is `mov rdi, 1` (a placeholder constant). No comparisons are performed.

**Drill:** `03-aabb-reject.asm` — the lesson describes "the same four compares on boxes that miss and exits 0." The **solution** is `xor rdi, rdi` (placeholder).

**Drill:** `08-from-scratch-point-in-rect.asm` — the lesson describes "point `(2, 2)` in `[0,0,5,5]` passes all four compares and exits 1." The **solution** is `mov rdi, 1` (placeholder).

**Drill:** `19-debug-aabb-y.asm` — the lesson describes a bug: "the exercise file retests x and never reads y." The **solution (fixed)** is `mov rdi, 1` (placeholder). The lesson describes that the fixed file adds y compares and exits 1.

### Point-in-rectangle

A point `(px, py)` is inside a rectangle `[x0, y0, x1, y1)` if:

```
(x0 <= px < x1) and (y0 <= py < y1)
```

This is the degenerate case of two AABBs where one has zero width and height.

### Half-open edges and touching boxes

With half-open `[x0, x1)`, two boxes that **touch** but do not **overlap** have `a.x1 == b.x0`. The miss test `a.x1 <= b.x0` is true, so they do not overlap. This is consistent with lesson 14's clipping (pixel `width` is the first outside column).

### Minkowski expansion

Expand an AABB by a margin on all sides:

```
expanded = [x0 - margin, y0 - margin, x1 + margin, y1 + margin)
```

**Drill:** `12-aabb-minkowski.asm` — width 4, expand by 1 on each side → add 2 to width → 6, exits 6.

**Note:** This is an expansion, not a full Minkowski sum of two boxes (that would compute `A ⊕ B` = `{a + b | a ∈ A, b ∈ B}`).

### Overlap area

Area of overlap = `(x_overlap_width) * (y_overlap_height)`.

**Drill:** `24-from-scratch-overlap-area.asm` — overlap width 2, height 3 → area 6, exits 6.

### Swept collision (stretch stub)

**Time of impact** (TOI) for swept collision (moving box vs. static box) is a stretch goal.

**Drill:** `13-sweep-hit-t.asm` — exits 3 (a constant). No sweep is computed.

### Separating Axis Theorem (SAT) for AABBs

An AABB has **2 separating axes** (x and y). For polygons, SAT tests all face normals.

**Drill:** `22-stretch-sat-axes.asm` — exits 2 (the count of axes). No projection is computed.

## Tiles an AABB touches

Collision against a tilemap: convert the AABB to a range of tile columns/rows, then test only those tiles' solid flags.

**Algorithm:**

For tile size 8 (shift by 3) and half-open `[x0, x1)`:
- First column: `x0 >> 3`
- Last column: `(x1 - 1) >> 3` (the last **inside pixel** decides the far edge)
- Count: `(last - first) + 1`

Same for y.

**Example:** Box x in `[5, 20)` (pixels 5–19):
- First column: `5 >> 3` = 0
- Last column: `19 >> 3` = 2
- Columns touched: 0, 1, 2 (count = 3)

**Drill (not listed, but described in the lesson):** The lesson describes this computation and warns that forgetting `dec rbx` (the `x1 - 1` step) reads one column too far when the edge lands exactly on a tile boundary.

Lesson 17's BFS pathfinding walks these tile columns to query solid flags.

## Spatial hashing

A **spatial hash** divides the world into a grid of cells (e.g., 8×8 pixels per cell). Hash a world position `(x, y)` to a cell index:

```
cell_x = x >> 3
cell_y = y >> 3
cell_index = cell_y * row_width + cell_x
```

For a 16-wide row:

```
cell_index = (cell_y << 4) + cell_x
```

**Drill:** `06-hash-cell.asm` — `x=10, y=10`:
- `cell_x = 10 >> 3 = 1`
- `cell_y = 10 >> 3 = 1`
- `index = (1 << 4) + 1 = 17`
- Exit `17 & 255` = 17.

**Drill:** `18-spatial-hash-insert.asm` — increments a cell counter and exits 1. No entity ID list is stored (placeholder).

Spatial hashing enables **fast broad-phase collision**: only test pairs of entities in the same (or adjacent) cells.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| Tile index is `x * width + y` | Tile index is `y * width + x` (row-major) |
| World to tile is `world_x / 8` | Use `world_x >> 3` for power-of-two sizes (faster) |
| Cull sprite when `sx < view_w` fails | Cull only when **fully outside**: `sx >= view_w` **or** `sx + sw <= 0` |
| AABB overlap is x-test only | Must test **both axes**: overlap requires x-overlap **and** y-overlap |
| Animation frame is quotient after `div` | Animation frame is the **remainder** (`rdx`) after `(time / ticks) mod frames` |
| Touching boxes overlap | With half-open `[x0, x1)`, touching boxes (`a.x1 == b.x0`) do **not** overlap |
| Tiles an AABB touches: `x1 >> 3` | Last column is `(x1 - 1) >> 3` (the last **inside pixel**) |

## Check yourself

1. In the "tiles an AABB touches" formula, a box with x in `[5, 24)` (pixels 5–23) should touch columns 0, 1, 2 (count 3). What goes wrong if you compute `24 >> 3` instead of `(24 - 1) >> 3`?

2. `16-anim-frame.asm` does two `div`s. Which register holds the frame after the second one, and why is it not `rax`?

3. Boxes `[0,0,2,2]` and `[2,0,4,2]` (x0,y0,x1,y1, half-open) share the edge x = 2. Do they overlap under the four-inequality test?

4. A sprite is at screen `sx = -5` with width 8. Is the right edge inside the view (left boundary is 0)? Should the sprite be culled or clipped?

5. You hash world position `(24, 16)` into a cell grid with cell size 8 and 16 cells per row. What is the cell index?

## Key takeaways

- Tile maps use row-major indexing (`y * width + x`); world-to-tile conversion for power-of-two sizes is a right-shift, not division.
- Cull sprites only when **fully outside**: test both `sx >= view_w` (right) **and** `sx + sw <= 0` (left); clip partially visible sprites by clamping `sx` and adjusting `sw`.
- AABB overlap requires **four inequalities** (two per axis) all false; testing one axis is insufficient.
- Animation frame is `(time / ticks) mod frames`; read the **remainder** in `rdx` after the second `div`.
- Tiles an AABB touches: convert half-open `[x0, x1)` to columns `x0 >> 3` through `(x1 - 1) >> 3`; the `- 1` is critical.
- Spatial hash converts world `(x, y)` to cell index with shifts: `(y >> cell_shift) * row_width + (x >> cell_shift)`.

## Lookup

- AABB collision: [MDN: 2D collision detection](https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection)
- Separating Axis Theorem: [Metanet Tutorial: SAT](https://www.metanetsoftware.com/technique/tutorialA.html)
- Spatial hashing: [Gamasutra: Spatial Hashing](https://web.archive.org/web/20120223230149/http://www.gamedev.net/page/resources/_/technical/game-programming/spatial-hashing-r2697)
- Fixed-point animation: [Gaffer On Games: Fix Your Timestep!](https://gafferongames.com/post/fix_your_timestep/)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Tile map:**
- `01-tile-index.asm` — `y=2, w=10, x=3`, exit 23
- `05-tile-solid.asm` — tile ID 2 solid flag, exit 1
- `09-tile-at.asm` — map cell (1,1), exit 5
- `10-world-to-tile.asm` — world 20, tile size 8, exit 2
- `14-tile-collision-mask.asm` — value 3 mask bit 0, exit 1
- `20-tile-autotile-mask.asm` — N|E = 1|4 = 5, exit 5
- `23-stretch-chunk-coords.asm` — tile 40, chunk size 16, exit 2

**Sprite:**
- `04-sprite-origin.asm` — world 50, camera 20, exit 30
- `07-clip-w.asm` — **placeholder: exits 2 (lesson describes 4)**
- `11-sprite-layer.asm` — **placeholder: exits 2 (lesson describes 42)**
- `15-camera-cull.asm` — off-screen, exit 1 (one-sided test only)
- `16-anim-frame.asm` — `(10/4) mod 3`, exit 2 (from `rdx`)
- `17-flip-flags.asm` — HFLIP|VFLIP = 3, exit 3
- `21-sprite-batch-count.asm` — 8 sprites, exit 8

**AABB:**
- `02-aabb-overlap.asm` — **placeholder: exits 1 (no comparison)**
- `03-aabb-reject.asm` — **placeholder: exits 0**
- `08-from-scratch-point-in-rect.asm` — **placeholder: exits 1**
- `12-aabb-minkowski.asm` — expand width 4 by 1 per side, exit 6
- `13-sweep-hit-t.asm` — **placeholder: exits 3 (no sweep)**
- `19-debug-aabb-y.asm` — **placeholder: exits 1 (lesson describes y-test bug)**
- `22-stretch-sat-axes.asm` — **placeholder: exits 2 (no projection)**
- `24-from-scratch-overlap-area.asm` — overlap 2×3, exit 6

**Spatial hash:**
- `06-hash-cell.asm` — `(10, 10)` → cell 17, exit 17
- `18-spatial-hash-insert.asm` — increment cell counter, exit 1
