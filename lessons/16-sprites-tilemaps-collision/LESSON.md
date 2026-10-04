# Lesson 16 — Sprites, Tilemaps, Collision

## Learning objectives

1. Index a row-major tile map and convert a world coordinate with a shift.
2. Cull a sprite only when it is fully outside the view, and clip a partially visible sprite to the visible width.
3. Test two AABBs for overlap with the four-inequality test on both axes: overlap needs x and y, not x alone.
4. Hash a world position into a spatial-hash cell with shifts, and list the tiles an AABB touches.
5. Advance an animation with `div` and keep the remainder, not the quotient.

The formulas below are the ones the solutions compute. Entities, BFS, and panels are lesson 17.

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

Screen x is world minus camera. 50 − 20 exits 30, and the sprite is drawn: 30 is inside `[0,40)` (`04-sprite-origin.asm`). A sprite is culled only when it is fully outside the view: `sx >= view_w` off the right, or `sx + sw <= 0` off the left. x = 100, width 8, view 40 is past the right edge, so `15-camera-cull.asm` exits 1. Testing only `sx < view_w` is the bug the old prose had: a sprite at x = -8 with width 8 passes that test and still draws nothing.

A partially visible sprite is clipped, not culled. Clamp the x into the view and shrink the width to what remains visible:

```asm
section .text
global _start
_start:
    mov rax, 6              ; sprite x
    mov rbx, 8              ; sprite width
    mov rcx, 10             ; view width
    cmp rax, 0
    jge .right
    add rbx, rax            ; width -= -x (x is negative)
    xor rax, rax            ; x = 0
.right:
    mov rdx, rax
    add rdx, rbx            ; x + width
    cmp rdx, rcx
    jle .done
    mov rbx, rcx
    sub rbx, rax            ; width = view_w - x
.done:
    mov rdi, rbx            ; 4
    mov rax, 60
    syscall
```

That is `07-clip-w.asm`: x = 6, width 8, view 10. The left edge is inside, so only the right clips: `10 - 6 = 4`. The blit then copies 4 bytes per row — `05-blit-copy.asm`'s `rep movsb` over the clipped width, with the color key from lesson 14 skipping transparent pixels. If the width comes out zero or negative, the sprite was fully off-screen: cull it. `11-sprite-layer.asm` builds the draw key `layer * 1000 + y`; layer 0, y 42 exits 42. Draw in key order so nearer layers cover farther ones. `17-flip-flags.asm` ors `HFLIP` (1) with `VFLIP` (2) and exits 3. `21-sprite-batch-count.asm` counts 8 sprite records and exits 8.

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

## Tiles an AABB touches

Collision runs against tiles, not pixels: convert the box to a tile range, then test only those tiles' solid flags. With tile size 8 (`>> 3`) and half-open edges `[x0,x1)`, the touched columns run from `x0 >> 3` to `(x1 - 1) >> 3` — the last inside pixel decides the far edge. The same on y.

```asm
section .text
global _start
_start:
    mov rax, 5
    shr rax, 3              ; first column = 0
    mov rbx, 20
    dec rbx                 ; last inside pixel = 19
    shr rbx, 3              ; last column = 2
    sub rbx, rax
    inc rbx                 ; count = 3
    mov rdi, rbx
    mov rax, 60
    syscall
```

Box x in `[5,20)` touches columns 0, 1, 2: three columns. Forgetting the `dec` reads one column too far whenever the edge lands exactly on a tile boundary. Lesson 17's BFS walks these solid flags; this is how a moving box asks the map what it may hit.

## AABB

Two axis-aligned boxes miss when one is completely on one side of the other. With half-open edges, box A misses box B when `a.x1 <= b.x0` or `b.x1 <= a.x0` or the same test on y. Overlap is the negation: all four miss-tests false. Both axes have to agree — x alone is not enough.

`[0,0,2,2]` and `[1,1,3,3]` overlap on x (0 < 3 and 1 < 2) and on y, so `02-aabb-overlap.asm` compares all four edges and exits 1. `03-aabb-reject.asm` runs the same four compares on boxes that miss and exits 0. `08-from-scratch-point-in-rect.asm` is the degenerate case: point `(2,2)` in `[0,0,5,5]` passes all four compares and exits 1. `19-debug-aabb-y.asm` is the bug the old set had: the exercise file retests x and never reads y. The fix adds the y compares; the comment's boxes are `a.y = 0`, height 2 and `b.y = 1`, height 2, which do overlap on y, so the fixed file exits 1.

Expanding a width of 4 by 1 on each side adds 2 and exits 6 (`12-aabb-minkowski.asm`). That is an expansion, not a Minkowski sum of two boxes. Overlap area of width 2 and height 3 exits 6 (`24-from-scratch-overlap-area.asm`). A time of impact of 3 is the constant 3 (`13-sweep-hit-t.asm`): swept collision stays a stretch stub. An AABB has 2 separating axes. `22-stretch-sat-axes.asm` exits 2 and does not project.

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

Map: `01-tile-index.asm` (exit 23), `05-tile-solid.asm`, `09-tile-at.asm`, `10-world-to-tile.asm` (exit 2), `14-tile-collision-mask.asm`, `20-tile-autotile-mask.asm`, `23-stretch-chunk-coords.asm` (exit 2). Sprite: `04-sprite-origin.asm` (exit 30), `07-clip-w.asm` (exit 4, clipped width), `11-sprite-layer.asm` (exit 42), `15-camera-cull.asm` (exit 1), `16-anim-frame.asm` (exit 2), `17-flip-flags.asm` (exit 3), `21-sprite-batch-count.asm` (exit 8). Collision: `02-aabb-overlap.asm` (exit 1), `03-aabb-reject.asm` (exit 0), `08-from-scratch-point-in-rect.asm` (exit 1), `12-aabb-minkowski.asm` (exit 6), `13-sweep-hit-t.asm` (constant 3), `19-debug-aabb-y.asm` (exit 1), `22-stretch-sat-axes.asm` (constant 2), `24-from-scratch-overlap-area.asm` (exit 6). Hash: `06-hash-cell.asm` (exit 17), `18-spatial-hash-insert.asm`.
