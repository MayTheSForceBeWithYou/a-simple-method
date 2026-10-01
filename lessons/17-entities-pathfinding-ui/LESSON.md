# Lesson 17 — Entities, Pathfinding, UI

## Learning objectives

1. Read one entity's position from parallel `xs` and `ys` arrays.
2. Test a component bit, spawn by incrementing an id, and push a free id.
3. Add `g` and a Manhattan `h` without pretending a constant is a search.
4. Advance a focus index with `inc` then `mod`, and stack panel rows by `h + pad`.
5. Clamp a guest stat, and count entities whose mask has a bit set.

The search files in this lesson mostly store a constant. Where the solution actually walks data, the listing below matches it. The park tick, track pieces, and save format are lesson 18. No name or asset from a commercial game belongs in this code.

## Structure of arrays

Entity `i` does not sit in one record. `xs[1]` is `[xs+8]`, `ys[1]` is `[ys+8]`. 5 + 6 exits 11.

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

That is `24-from-scratch-ecs-query.asm`. The first spawn increments a zeroed id and exits 1 (`09-spawn-entity.asm`). Despawn stores 3 at the free-list top and exits 3 (`10-despawn-freelist.asm`). It does not push a link. A guest target id of 7 is the constant 7 (`08-from-scratch-guest-target.asm`). A formation slot of 2 is the constant 2 (`21-formation-slot.asm`).

## Search, as far as these files go

Manhattan distance from `(1,2)` to `(3,4)` is `|3-1| + |4-2|` = 4 (`03-astar-h.asm`). Both subtractions in the solution are ordered so the result is positive. A backward delta needs a sign test before you add it. `f = g + h` with 3 and 4 exits 7 (`13-astar-fscore.asm`). Desired velocity `10 - 3` exits 7 (`20-steering-seek.asm`).

`02-bfs-dist.asm` exits 1. `12-bfs-queue.asm` exits 5. `14-path-reconstruct.asm` exits 4. `06-path-step.asm` exits 1. `19-debug-parent-index.asm` exits 2. `22-stretch-flow-field.asm` exits 4. None of them allocate a queue, write a parent index, or step a grid. A real BFS would push the start, mark it visited, and pop until the goal, storing `parent[next] = current`. The exercise file for the parent bug exits 0. The solution replaces that with the constant 2. Do not ship a search that is only the constant when you leave this lesson. The exit the file requires is still that constant.

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

That is `16-ui-focus.asm`. Two stacked rows of height 10 and pad 2 each add 12. From 0 the next y is 24 (`17-panel-layout.asm`). A hit test that exits 1 (`04-ui-hit.asm`) and a button that exits 1 (`15-ui-button-press.asm`) do not compare the cursor to a rectangle. Widget count 3 is the constant 3 (`07-panel-draw-stub.asm`). A modal depth increments from zero and exits 1 (`23-stretch-ui-modal.asm`).

Happiness 90 plus 20 is 110. The clamp at 100 exits 100 (`18-guest-happiness.asm`). Compare after the add. Clamping first would leave 90 plus 20.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Entities: `01-soa-pos.asm`, `05-entity-alive.asm`, `08-from-scratch-guest-target.asm` (constant 7), `09-spawn-entity.asm`, `10-despawn-freelist.asm`, `11-component-mask.asm`, `18-guest-happiness.asm` (exit 100), `21-formation-slot.asm` (constant 2), `24-from-scratch-ecs-query.asm`. Search: `02-bfs-dist.asm` (constant 1), `03-astar-h.asm` (exit 4), `06-path-step.asm` (constant 1), `12-bfs-queue.asm` (constant 5), `13-astar-fscore.asm`, `14-path-reconstruct.asm` (constant 4), `19-debug-parent-index.asm` (constant 2), `20-steering-seek.asm`, `22-stretch-flow-field.asm` (constant 4). UI: `04-ui-hit.asm` (constant 1), `07-panel-draw-stub.asm` (constant 3), `15-ui-button-press.asm` (constant 1), `16-ui-focus.asm`, `17-panel-layout.asm`, `23-stretch-ui-modal.asm`.