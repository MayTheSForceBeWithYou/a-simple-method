# 17 — Entities, Pathfinding, UI

Lesson 16 gave you sprites and collision. This lesson gives you **entities** (structure-of-arrays component storage), **breadth-first search** (BFS) for grid pathfinding with parent tracking, **A\*** heuristics (Manhattan distance `h`, cost-so-far `g`, score `f = g + h`), and **UI panels** (hit testing, focus cycling, layout stacking). By the end you'll see that an entity-component system is not magic—it's parallel arrays indexed by entity ID, and that pathfinding is a FIFO queue plus a `visited` bit array plus a `parent[]` backpointer array.

## What this lesson asks of you

- Read one entity's position from parallel `xs` and `ys` arrays (structure-of-arrays, or SoA).
- Test a component bit in a mask byte, spawn an entity by incrementing an ID counter, and push a freed ID onto a free-list stack.
- Compute A\* score `f = g + h` from path cost `g` (distance from start) and Manhattan-distance heuristic `h` (estimate to goal).
- Advance UI focus with `inc` then `mod` (wrapping), and stack panel rows by adding `height + padding` to the y cursor.
- Clamp a guest stat (e.g., happiness ≤ 100) **after** adding a bonus, not before.

## Why ECS, pathfinding, and UI for the park milestone

Lesson 18's park simulation needs:
- **Entities:** Guests, trees, buildings, paths—all stored in parallel component arrays.
- **Pathfinding:** Guests walk from ride to ride; BFS finds the shortest path on the tile grid.
- **UI:** Click a guest to see stats, click a building to open a menu.

The drills below isolate each primitive. Many search and UI drills are **placeholder constants** (the course will expand them in future updates). Where the solution computes a real value (e.g., entity-update checksum, focus wraparound), the lesson shows the full listing.

## Entity-component system (ECS): structure of arrays

An **entity** is an integer ID. Each entity's components (position, velocity, health, etc.) are stored in **parallel arrays**:

```asm
section .data
    xs:  dq 0, 5, 0     ; x positions
    ys:  dq 0, 6, 0     ; y positions
    vxs: dq 1, 2, 3     ; x velocities
    alive: db 1, 0, 1   ; alive flags
```

Entity 1's position is `(xs[1], ys[1])` = `([xs+8], [ys+8])` = `(5, 6)`.

**Drill:** `01-soa-pos.asm` reads entity 1's position: `xs[1] = 5`, `ys[1] = 6`, sum = 11, exits 11.

### Why SoA instead of AoS?

**Array-of-structures (AoS)** from lesson 06 would store each entity as a contiguous record:

```asm
entity_0: dq x, y, vx, vy, ...
entity_1: dq x, y, vx, vy, ...
```

**Structure-of-arrays (SoA)** stores each field contiguously across all entities:

```asm
xs:  dq x0, x1, x2, ...
ys:  dq y0, y1, y2, ...
```

**Advantage:** A system that only touches `xs` and `vxs` (e.g., `xs[i] += vxs[i]`) streams two arrays sequentially, using cache efficiently. With AoS, you'd skip over unused fields (`y`, `vy`, ...) on every iteration, polluting cache.

### Component masks

A **component mask** is a byte where each bit represents a component:

```asm
POS  = 0b0001   ; bit 0
VEL  = 0b0010   ; bit 1
HP   = 0b0100   ; bit 2
```

An entity with position and velocity has mask `0b0011` = 3.

**Drill:** `11-component-mask.asm` ORs `POS` (1) with `VEL` (2), exits 3.

**Drill:** `05-entity-alive.asm` tests byte value 1 with `test al, 1` (bit 0), exits 1 (alive).

**Drill:** `24-from-scratch-ecs-query.asm` counts how many of four masks `1, 3, 1, 2` have bit 0 set. Values 1 and 3 have bit 0 set (count 3 total, since 1 appears twice). Value 2 is `VEL` only (bit 1), so it doesn't count. Exits 3.

### Spawning and despawning

**Spawn:** Allocate the next entity ID by incrementing a counter.

**Drill:** `09-spawn-entity.asm` increments a zero ID counter to 1, exits 1.

**Despawn:** Free an entity ID by pushing it onto a free-list stack for reuse.

**Drill:** `10-despawn-freelist.asm` — the lesson describes "stores 3 at the free-list top and bumps the top, exiting 3." The **solution as shipped** is `mov qword [free_top], 3` and exits 3. No array, no bump. This is a placeholder.

### Entity update loop (checksum example)

A typical per-tick loop: for each alive entity, integrate velocity into position.

```asm
section .data
    xs:  dq 0, 0, 0
    vxs: dq 1, 2, 3
    alive: db 1, 0, 1

section .text
global _start
_start:
    xor rcx, rcx            ; i = 0
.loop:
    cmp rcx, 3
    jge .done
    cmp byte [alive + rcx], 0
    je .next
    mov rax, [vxs + rcx*8]
    add [xs + rcx*8], rax   ; xs[i] += vxs[i]
.next:
    inc rcx
    jmp .loop
.done:
    mov rdi, [xs]           ; xs[0] = 0 + 1 = 1
    add rdi, [xs + 16]      ; xs[2] = 0 + 3 = 3
    mov rax, 60             ; checksum 1 + 3 = 4
    syscall
```

Entity 0 moves `0 + 1 = 1`. Entity 1 is dead (skipped). Entity 2 moves `0 + 3 = 3`. Checksum 4. Exits 4.

**Note:** This listing is not attached to a drill in the current course; it demonstrates the pattern.

## Pathfinding: BFS and A\*

### Manhattan distance (A\* heuristic `h`)

Manhattan distance from `(x1, y1)` to `(x2, y2)`:

```
h = |x2 - x1| + |y2 - y1|
```

**Drill:** `03-astar-h.asm` computes `|(3 - 1)| + |(4 - 2)|` = `2 + 2` = 4, exits 4.

**Note:** Both subtractions in the solution are ordered so the result is positive. If a delta can be negative, test the sign before negating (same rule as lesson 15's mouse delta).

### A\* score `f = g + h`

- **`g`:** Cost already paid from start to this tile.
- **`h`:** Heuristic estimate of remaining cost to goal (Manhattan distance for a 4-neighbor grid).
- **`f`:** Total estimated cost = `g + h`.

A\* expands tiles in order of `f`, using `g` to break ties. Manhattan distance is **admissible** for 4-neighbor movement with unit cost (never overestimates), so the first path A\* finds is optimal.

**Drill:** `13-astar-fscore.asm` computes `f = 3 + 4` = 7, exits 7.

### Breadth-first search (BFS)

BFS explores the grid in **rings** (distance layers). Tiles leave the queue in order of distance from the start, so **the first time the goal is dequeued, the path is shortest**.

**Algorithm:**

1. **Data structures:**
   - FIFO queue (lesson 11 ring buffer): enqueue at `tail`, dequeue at `head`, sized for the tile count.
   - `visited[]`: one byte per tile (0 = unvisited, 1 = visited).
   - `parent[]`: one index per tile (stores the tile that enqueued this one).
   - Solid flags (lesson 16): skip walls.

2. **Loop:**
   ```
   enqueue(start)
   visited[start] = 1
   while queue not empty:
       current = dequeue()
       if current == goal:
           return reconstruct_path(parent, goal)
       for each neighbor in {north, south, east, west}:
           if solid[neighbor] or visited[neighbor]:
               continue
           visited[neighbor] = 1
           parent[neighbor] = current
           enqueue(neighbor)
   return NO_PATH
   ```

3. **Mark visited at enqueue time** (not dequeue time) so each tile is enqueued exactly once.

4. **Path reconstruction:** Walk `parent[]` backward from goal to start, counting steps.

**Drills:**

- `02-bfs-dist.asm` — the lesson describes "runs the full loop on a small map and exits the distance." The **solution** is `mov rdi, 1` (placeholder constant).
- `12-bfs-queue.asm` — the lesson describes "the head/tail FIFO the search runs on." The **solution** is `mov rdi, 5` (placeholder constant).
- `14-path-reconstruct.asm` — the lesson describes "walks `parent[]` from the goal back to the start and counts steps." The **solution** is `mov rdi, 4` (placeholder constant).
- `19-debug-parent-index.asm` — the lesson describes a bug: "the exercise file's BFS is missing the `parent[next] = current` store, so it exits 0 (reconstruction fails)." The **solution (fixed)** is `mov rdi, 2` (placeholder constant). The lesson says the fix adds the missing store.

**Note:** The current drills are placeholders. Future updates will implement full BFS.

### Path step

Move an entity one tile along the reconstructed path per tick.

**Drill:** `06-path-step.asm` — exits 1 (placeholder constant).

### Flow field

A **flow field** runs BFS outward from the goal, writing one distance byte per tile. Every agent can then walk downhill (toward lower distance) without per-agent search.

**Drill:** `22-stretch-flow-field.asm` — exits 4 (placeholder constant).

### Steering: seek

Desired velocity for **seek** steering: `target - position`.

**Drill:** `20-steering-seek.asm` — `10 - 3` = 7, exits 7.

## UI panels: hit testing, focus, layout

### Hit test (point in rectangle)

A cursor `(cx, cy)` is inside rectangle `[x0, y0, x1, y1)` (half-open) when:

```
(x0 <= cx < x1) and (y0 <= cy < y1)
```

Four inequalities, same as AABB overlap (lesson 16).

**Drill:** `04-ui-hit.asm` — the lesson describes "exits 1 for a cursor inside." The **solution** is `mov rdi, 1` (placeholder constant).

### Button press

A **button** is a hit-test result AND a pressed bit (e.g., left mouse button down).

**Drill:** `15-ui-button-press.asm` — exits 1 (placeholder constant).

### Focus cycling

UI focus (which widget is selected) wraps with modulo. To advance focus:

```
focus = (focus + 1) mod widget_count
```

**Drill:** `16-ui-focus.asm` — focus starts at 2, widget count 3:

```asm
inc qword [focus]       ; 2 → 3
mov rax, [focus]
xor rdx, rdx
mov rbx, 3
div rbx                 ; 3 / 3 → quotient 1, remainder 0
mov rdi, rdx            ; focus wraps to 0
```

Exits 0 (first widget).

**Why `inc` then `mod`, not `mod` then `inc`?** If focus is at the last widget (index 2), `(2 + 1) mod 3` = 0 wraps to the first. But `(2 mod 3) + 1` = 3 would point past the last widget (valid indices are 0–2).

### Panel layout: stacking rows

Each row advances the y cursor by `row_height + padding`.

**Drill:** `17-panel-layout.asm` — row height 10, padding 2 → `10 + 2` = 12 per row. Starting from `y = 0`, two rows → `y = 24`, exits 24.

### Panel rendering

A panel draws rows into a framebuffer (lesson 14) at offset `y * stride + x * bytes_per_pixel`.

**Drill:** `07-panel-draw-stub.asm` — exits 3 (placeholder constant).

### Modal depth

A **modal dialog** grabs all input until dismissed. Stack depth tracks how many modals are active.

**Drill:** `23-stretch-ui-modal.asm` — increment depth from 0 to 1, exits 1.

## Guest stats: clamping after arithmetic

A guest's happiness is capped at 100. When adding a bonus, **clamp after the add**:

**Drill:** `18-guest-happiness.asm` — happiness 90, bonus 20:

```asm
mov rax, 90
add rax, 20             ; 110
cmp rax, 100
jle .ok
mov rax, 100            ; clamp to 100
.ok:
```

Exits 100.

**Plausible wrong reading:**

*"Clamping is about keeping the stored stat valid, so clamp the current value first (90 is already ≤ 100), then add the bonus."*

**Why it's wrong:** If you clamp 90 first, nothing changes (90 ≤ 100 passes). Then `add rax, 20` produces 110, which is stored unchecked. The invariant "happiness ≤ 100" is broken after every bonus.

**The correct reading:** Clamp the **result of the arithmetic**, right before it's stored or used. The same rule applies to lesson 18's cash (clamp after subtracting cost, not before).

## Placeholder drills (future expansion)

Several drills are **constants** rather than full implementations:

**Entities:**
- `08-from-scratch-guest-target.asm` — exits 7 (placeholder)
- `21-formation-slot.asm` — exits 2 (placeholder)

**Search:**
- `02-bfs-dist.asm` — exits 1 (placeholder)
- `12-bfs-queue.asm` — exits 5 (placeholder)
- `14-path-reconstruct.asm` — exits 4 (placeholder)
- `19-debug-parent-index.asm` — exits 2 (placeholder fix)
- `06-path-step.asm` — exits 1 (placeholder)
- `22-stretch-flow-field.asm` — exits 4 (placeholder)

**UI:**
- `04-ui-hit.asm` — exits 1 (placeholder)
- `07-panel-draw-stub.asm` — exits 3 (placeholder)
- `15-ui-button-press.asm` — exits 1 (placeholder)

Future course updates will expand these into full implementations.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| SoA and AoS are equivalent | SoA (parallel arrays) streams one field efficiently; AoS (records) keeps one entity's data contiguous |
| Component mask test is `cmp` | Use `test mask, bit` to check a single bit; `cmp` checks the whole byte |
| Manhattan distance needs square root | Manhattan is `\|dx\| + \|dy\|` (no square root); Euclidean distance needs `sqrt(dx² + dy²)` |
| A\* `f = h` | `f = g + h` (cost-so-far + heuristic) |
| BFS marks visited at dequeue | Mark visited at **enqueue** to prevent duplicate enqueues |
| Focus advance is `mod` then `inc` | `inc` then `mod` to wrap correctly: `(focus + 1) mod count` |
| Clamp before arithmetic | Clamp **after** arithmetic (clamp the result, not the operand) |

## Check yourself

1. In the entity-update listing (`xs`, `vxs`, `alive db 1,0,1`), why is the index scaled by 8 for `xs`/`vxs` but not for `alive`?

2. `24-from-scratch-ecs-query.asm` counts masks `1, 3, 1, 2` with `test rax, 1`. Why does 3 count but 2 does not?

3. `16-ui-focus.asm` exits 0 for focus 2 with 3 widgets. Why `inc` then `div` rather than `div` then `inc`?

4. You compute A\* `h` from `(5, 10)` to `(2, 8)`. What is the Manhattan distance? Which coordinate contributes more to `h`?

5. You clamp happiness at 100, but you test `cmp rax, 100` / `jle .ok` **before** adding the +20 bonus. What is the final value if happiness starts at 85?

## Key takeaways

- ECS uses structure-of-arrays (parallel `xs[]`, `ys[]`, etc.) for cache-efficient iteration over one component across all entities.
- Component masks use bit flags; test with `test mask, bit`, not `cmp`.
- BFS explores the grid in distance layers; mark `visited` at enqueue (not dequeue) to prevent duplicate work.
- A\* score `f = g + h` where `g` is cost from start, `h` is Manhattan heuristic; A\* expands tiles in `f` order.
- UI focus wraps with `(focus + 1) mod count`; the `mod` must come after the `inc`.
- Clamp stats **after** arithmetic (clamp the result, not the operands).

## Lookup

- Entity-component systems: [Data-Oriented Design (Fabian Giesen)](https://fgiesen.wordpress.com/2018/02/19/reading-bits-of-a-data-structure-the-cache/)
- BFS and A\*: [Red Blob Games: Introduction to A\*](https://www.redblobgames.com/pathfinding/a-star/introduction.html)
- Manhattan distance admissibility: [Wikipedia: Taxicab geometry](https://en.wikipedia.org/wiki/Taxicab_geometry)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Entities:**
- `01-soa-pos.asm` — entity 1 position sum, exit 11
- `05-entity-alive.asm` — test bit 0, exit 1
- `08-from-scratch-guest-target.asm` — **placeholder: exits 7**
- `09-spawn-entity.asm` — increment ID, exit 1
- `10-despawn-freelist.asm` — **placeholder: exits 3**
- `11-component-mask.asm` — `POS | VEL`, exit 3
- `18-guest-happiness.asm` — clamp 90+20 to 100, exit 100
- `21-formation-slot.asm` — **placeholder: exits 2**
- `24-from-scratch-ecs-query.asm` — count bit 0 in `1,3,1,2`, exit 3

**Pathfinding:**
- `02-bfs-dist.asm` — **placeholder: exits 1**
- `03-astar-h.asm` — Manhattan `(1,2)` to `(3,4)`, exit 4
- `06-path-step.asm` — **placeholder: exits 1**
- `12-bfs-queue.asm` — **placeholder: exits 5**
- `13-astar-fscore.asm` — `f = 3 + 4`, exit 7
- `14-path-reconstruct.asm` — **placeholder: exits 4**
- `19-debug-parent-index.asm` — **placeholder fix: exits 2**
- `20-steering-seek.asm` — `10 - 3`, exit 7
- `22-stretch-flow-field.asm` — **placeholder: exits 4**

**UI:**
- `04-ui-hit.asm` — **placeholder: exits 1**
- `07-panel-draw-stub.asm` — **placeholder: exits 3**
- `15-ui-button-press.asm` — **placeholder: exits 1**
- `16-ui-focus.asm` — `(2+1) mod 3`, exit 0
- `17-panel-layout.asm` — stack 2 rows of 12 each, exit 24
- `23-stretch-ui-modal.asm` — increment depth, exit 1
