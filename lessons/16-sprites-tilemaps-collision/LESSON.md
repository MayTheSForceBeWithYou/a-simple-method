# Lesson 16 — Sprites, Tilemaps, Collision

## Learning objectives

1. Index a row-major tile map and convert a world coordinate with a shift.
2. Reject a sprite whose screen x is not inside the view.
3. Separate two AABBs on x or on y, and not on x alone.
4. Build a spatial-hash cell from `>> 3` and a nibble shift.
5. Advance an animation with `div` and keep the remainder, not the quotient.

Several files in this set store the answer as an immediate. The formulas below are the ones the solutions actually compute. Entities, BFS, and panels are lesson 17.

## Tile index

`index = y * map_w + x`. y = 2, width = 10, x = 3 exits 23.

```asm
section .text
global _start
_start:
    mov rax, 2
    imul rax, 10
    add rax, 3
    mov rdi, rax            ; 23
    mov rax, 60
    syscall
```

That is `01-tile-index.asm`. A map stored as bytes, width 4, cell (1,1) is index 5, and the byte there is 5 (`09-tile-at.asm`). World x = 20 with tile size 8 is `shr` by 3, exit 2 (`10-world-to-tile.asm`). Do not `div` by 8 when the size is a power of two. A chunk index is `tile >> 4`. Tile 40 exits 2 (`23-stretch-chunk-coords.asm`). Solid flags live in a byte table: id 2 exits 1 (`05-tile-solid.asm`). Collision bits: value 3 with bit 0 masked exits 1 (`14-tile-collision-mask.asm`). Neighbors N = 1 and E = 4 or to 5 (`20-tile-autotile-mask.asm`).

## Screen space

Screen x is world minus camera. 50 − 20 exits 30 (`04-sprite-origin.asm`). A sprite is culled when that screen x is not strictly less than the view width. 100 − 50 = 50, and 50 is not `< 40`, so `15-camera-cull.asm` exits 1. `07-clip-w.asm` exits 2. It does not clip a width. `11-sprite-layer.asm` exits 2. The prompt's `layer * 1000 + y` is not computed. `17-flip-flags.asm` ors `HFLIP` (1) with `VFLIP` (2) and exits 3. A batch count of 8 is the immediate 8 (`21-sprite-batch-count.asm`).

Animation frame is `(t / ticks) mod n`. 10 / 4 is 2, and `2 mod 3` is 2. The exit is `rdx` after the second `div`, not `rax`.

```asm
section .text
global _start
_start:
    mov rax, 10
    xor rdx, rdx
    mov rbx, 4
    div rbx                 ; rax = 2
    xor rdx, rdx
    mov rbx, 3
    div rbx
    mov rdi, rdx            ; 2
    mov rax, 60
    syscall
```

That is `16-anim-frame.asm`. Zero `rdx` before each unsigned `div`.

## AABB

Two axis-aligned boxes miss when one is completely on one side of the other. With edges as coordinates, box A `[x0,y0,x1,y1]` misses B when `a.x0 >= b.x1` or `b.x0 >= a.x1` or the same test on y. Both axes have to overlap.

`[0,0,2,2]` and `[1,1,3,3]` overlap. `02-aabb-overlap.asm` exits 1 by storing that constant. It does not compare. `03-aabb-reject.asm` exits 0 the same way. `08-from-scratch-point-in-rect.asm` exits 1 for the comment's point `(2,2)` in `[0,0,5,5]`, again as a constant. `19-debug-aabb-y.asm` in the exercise file exits 0 without reading y. The solution exits 1. The comment's boxes are `a.y = 0`, height 2 and `b.y = 1`, height 2, which do overlap on y. A fix that only retests x is still the bug.

Expanding a width of 4 by 1 on each side adds 2 and exits 6 (`12-aabb-minkowski.asm`). That is not a Minkowski sum of two boxes. Overlap area of width 2 and height 3 exits 6 (`24-from-scratch-overlap-area.asm`). A time of impact of 3 is the constant 3 (`13-sweep-hit-t.asm`). An AABB has 2 separating axes. `22-stretch-sat-axes.asm` exits 2 and does not project.

## Spatial hash

Cell size 8 is a shift by 3. The y cell is shifted left by 4, which is a 16-wide row of cells, then added to the x cell. x = 10, y = 10: both cells are 1, and `1 + (1<<4)` is 17. The exit masks with 255, which leaves 17.

```asm
section .text
global _start
_start:
    mov rax, 10
    shr rax, 3              ; cell x
    mov rbx, 10
    shr rbx, 3
    shl rbx, 4              ; cell y * 16
    add rax, rbx
    and rax, 255
    mov rdi, rax            ; 17
    mov rax, 60
    syscall
```

That is `06-hash-cell.asm`. Inserting into a bucket in `18-spatial-hash-insert.asm` increments a counter and exits 1. There is no list of entity ids in the cell.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Map: `01-tile-index.asm`, `05-tile-solid.asm`, `09-tile-at.asm`, `10-world-to-tile.asm`, `14-tile-collision-mask.asm`, `20-tile-autotile-mask.asm`, `23-stretch-chunk-coords.asm`. Sprite: `04-sprite-origin.asm`, `07-clip-w.asm` (constant 2), `11-sprite-layer.asm` (constant 2), `15-camera-cull.asm` (exit 1), `16-anim-frame.asm`, `17-flip-flags.asm`, `21-sprite-batch-count.asm` (constant 8). Collision: `02-aabb-overlap.asm` (constant 1), `03-aabb-reject.asm` (constant 0), `08-from-scratch-point-in-rect.asm` (constant 1), `12-aabb-minkowski.asm`, `13-sweep-hit-t.asm` (constant 3), `19-debug-aabb-y.asm` (exit 1), `22-stretch-sat-axes.asm` (constant 2), `24-from-scratch-overlap-area.asm`. Hash: `06-hash-cell.asm` (exit 17), `18-spatial-hash-insert.asm`.