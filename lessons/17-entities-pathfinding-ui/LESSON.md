# Lesson 17 — Entities, Pathfinding, UI

## Learning objectives

1. Read one entity's position from parallel `xs` and `ys` arrays.
2. Test a component bit, spawn by incrementing an id, and push a free id.
3. Compute `f = g + h` from a path cost `g` and a Manhattan-distance heuristic `h`, and state what each term means for a grid search.
4. Advance a focus index with `inc` then `mod`, and stack panel rows by `h + pad`.
5. Clamp a guest stat, and count entities whose mask has a bit set.

The search files in this lesson mostly store a constant. Where the solution actually walks data, the listing below matches it. The park tick, track pieces, and save format are lesson 18. No name or asset from a commercial game belongs in this code.

## Structure of arrays

Entity `i` does not sit in one record. `xs[1]` is `[xs+8]`, `ys[1]` is `[ys+8]`. 5 + 6 exits 11. (The AoS alternative from lesson 06 would keep one entity's fields adjacent at `ents+i*16`; the parallel arrays win when a system touches one field across every entity.)

```asm
section .data
    xs dq 0, 5, 0
    ys dq 0, 6, 0
section .text
global _start
_start:
    mov rdi, [xs+8]
    add rdi, [ys+8]        ; 11
    mov rax, 60
    syscall
```

That is `01-soa-pos.asm`. Alive is bit 0 of a flags byte. The byte 1 masked with 1 exits 1 (`05-entity-alive.asm`). `POS` is 1 and `VEL` is 2. Oring them exits 3 (`11-component-mask.asm`). A query counts how many of four masks have bit 0 set. The bytes `1, 3, 1, 2` yield 3. The value 2 is `VEL` only and does not count.

```asm
section .data
    masks db 1, 3, 1, 2
section .text
global _start
_start:
    xor rdi, rdi
    xor rcx, rcx
.next:
    cmp rcx, 4
    jge .done
    movzx rax, byte [masks+rcx]
    test rax, 1
    jz .skip
    inc rdi
.skip:
    inc rcx
    jmp .next
.done:
    mov rax, 60             ; rdi == 3
    syscall
```

That is `24-from-scratch-ecs-query.asm`. The first spawn increments a zeroed id and exits 1 (`09-spawn-entity.asm`). Despawn pushes the freed id onto a free-list stack: it stores 3 at the free-list top and bumps the top, exiting 3 (`10-despawn-freelist.asm`). It does not thread a next-pointer through the freed slot. (File behavior UNVERIFIED.) A guest target id of 7 is the constant 7 (`08-from-scratch-guest-target.asm`). A formation slot of 2 is the constant 2 (`21-formation-slot.asm`).

A table is only half of an entity system; the other half is the loop that runs every tick: for `i` in `0..n-1`, if the entity is alive, integrate it. That is the loop lesson 18's park tick will call once per frame, and it is why the fields sit in parallel arrays — one system streams one field straight through.

```asm
section .data
    xs    dq 0, 0, 0
    vxs   dq 1, 2, 3
    alive db 1, 0, 1
section .text
global _start
_start:
    xor rcx, rcx                 ; i = 0
.loop:
    cmp rcx, 3
    jge .done
    cmp byte [alive+rcx], 0
    je .next
    mov rax, [vxs+rcx*8]
    add [xs+rcx*8], rax         ; xs[i] += vxs[i]
.next:
    inc rcx
    jmp .loop
.done:
    mov rdi, [xs]               ; 1
    add rdi, [xs+16]            ; + 3 = 4
    mov rax, 60
    syscall
```

Entity 0 moves `0+1`, entity 1 is dead and skipped, entity 2 moves `0+3`; the exit is the checksum 4. Skipping the dead entity is the whole point of the alive bit from `05-entity-alive.asm`. (Hand-traced; not assembled — UNVERIFIED. The rewrite must attach this listing to a drill file and reflect it in the Exercises list.)

## Pathfinding on the grid

Manhattan distance from `(1,2)` to `(3,4)` is `|3-1| + |4-2|` = 4 (`03-astar-h.asm`). Both subtractions in the solution are ordered so the result is positive; a delta that can be negative needs a sign test before you negate it — the same rule as lesson 15's mouse delta. `f = g + h` with 3 and 4 exits 7 (`13-astar-fscore.asm`). Here `g` is the cost already paid from the start to this tile and `h` is the Manhattan estimate of what remains to the goal; A* expands tiles in order of `f`. Seek steering aims an entity at a target: desired velocity is `target - pos`, so `10 - 3` exits 7 (`20-steering-seek.asm`).

Breadth-first search explores the grid in rings: tiles leave the queue in order of distance from the start, so the first time the goal is dequeued the path is a shortest one. It needs three things you already own: a FIFO queue (lesson 11's ring idea — enqueue at `tail`, dequeue at `head`, sized for the map), a `visited` byte per tile, and lesson 16's solid flags to skip walls. The loop: enqueue the start tile and mark it visited; dequeue the head; for each of the four neighbors, skip it if solid or already visited, otherwise mark it visited, store `parent[neighbor] = current`, and enqueue it; stop when the dequeued tile is the goal or the queue is empty — empty means the goal is unreachable. Marking visited at enqueue time, not dequeue time, is what keeps every tile enqueued exactly once. Walking `parent[]` backward from the goal to the start and counting steps is the reconstructed path (`14-path-reconstruct.asm`); moving an entity one tile along that walk per tick is a path step (`06-path-step.asm`). A flow field is the same BFS run outward from the goal, writing one distance byte per tile, so every agent can walk downhill with no per-agent search (`22-stretch-flow-field.asm`). `02-bfs-queue.asm` is the head/tail FIFO the search runs on, and `02-bfs-dist.asm` runs the full loop on a small map and exits the distance. The exit status only reports the answer — it is not the implementation. `19-debug-parent-index.asm` is the bug hunt: the exercise file's BFS is missing the `parent[next] = current` store (it exits 0 because the reconstruction walk never terminates); the fix is the missing store, which makes it exit 2 — not a hardcoded constant.

(Exit numbers above are the lesson's own claims, carried over; UNVERIFIED. The rewrite must make the drill files actually implement what this prose promises.)

Every search drill must allocate the structure its name promises and compute its answer by walking the grid; the exit status only reports the result. `12-bfs-queue.asm` keeps a head/tail FIFO of tile indices; `14-path-reconstruct.asm` walks `parent[]` from the goal back to the start; `22-stretch-flow-field.asm` writes one BFS distance byte per tile outward from the goal. Do not ship a search that is only the constant when you leave this lesson — and the drills must not ask you to either.

## Panels

Focus starts at 2. One tab increments, then divides by 3. The exit is the remainder, 0.

```asm
section .bss
    focus resq 1
section .text
global _start
_start:
    mov qword [focus], 2
    inc qword [focus]
    mov rax, [focus]
    xor rdx, rdx
    mov rbx, 3
    div rbx
    mov rdi, rdx            ; 0
    mov rax, 60
    syscall
```

That is `16-ui-focus.asm`. Each stacked row advances the cursor by `h + pad` = 12; starting from 0, two rows leave the next y at 24 (`17-panel-layout.asm`). A hit test is four compares: the cursor is inside exactly when `x0 <= cx < x1` and `y0 <= cy < y1` — the half-open convention from lesson 14's clip rect — and `04-ui-hit.asm` exits 1 for a cursor inside. A button is that test plus a pressed bit (`15-ui-button-press.asm`). A panel draws its rows into a `.bss` pixel buffer with lesson 14's `y * stride + x * bytes_per_pixel` offset (`07-panel-draw-stub.asm`). A modal dialog grabs input until dismissed; the depth counter tracks how many modals are stacked, incrementing from zero to 1 (`23-stretch-ui-modal.asm`).

Happiness 90 plus 20 is 110. The clamp at 100 exits 100 (`18-guest-happiness.asm`). Clamp after the add: clamping the 90 first would leave 90, and the +20 would put it right back at 110.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Entities: `01-soa-pos.asm`, `05-entity-alive.asm`, `08-from-scratch-guest-target.asm` (constant 7), `09-spawn-entity.asm`, `10-despawn-freelist.asm`, `11-component-mask.asm`, `18-guest-happiness.asm` (exit 100), `21-formation-slot.asm` (constant 2), `24-from-scratch-ecs-query.asm`. Search: `02-bfs-dist.asm` (constant 1), `03-astar-h.asm` (exit 4), `06-path-step.asm` (constant 1), `12-bfs-queue.asm` (constant 5), `13-astar-fscore.asm`, `14-path-reconstruct.asm` (constant 4), `19-debug-parent-index.asm` (constant 2), `20-steering-seek.asm`, `22-stretch-flow-field.asm` (constant 4). UI: `04-ui-hit.asm` (constant 1), `07-panel-draw-stub.asm` (constant 3), `15-ui-button-press.asm` (constant 1), `16-ui-focus.asm`, `17-panel-layout.asm`, `23-stretch-ui-modal.asm`.