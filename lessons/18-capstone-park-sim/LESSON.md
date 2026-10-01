# Lesson 18 — Capstone: Mini Park

## Learning objectives

1. Store a path cell at `y * width + x` and read the byte back, not the index.
2. Clamp a coordinate to `width - 1` before it becomes an index.
3. Rotate a piece direction with `inc` and `and 3`.
4. Add ticket cash and subtract upkeep on the same qword.
5. Recognize a save magic byte and a version of 1. These drills do not write a file.

The roadmap's capstone places track, walks an agent, ticks an economy, and round-trips a map. These 24 files are the cells and the counters that sim is made of. They do not pathfind, and they do not call `open`. Use your own names. Do not copy a commercial park game's text, assets, or data.

## The map

A cell is one byte. Path is 1. Empty is 0. Writing 1 at a fixed offset and reading it back exits 1 (`01-map-cell.asm`). Erase writes 1 and then 0 at the same byte and exits 0 (`10-map-erase.asm`).

Column 2, row 3, width 8 is index 26. The byte stored there is `PATH`, which is 1. The exit is that byte, not 26.

```asm
PATH equ 1
section .bss
    map resb 64
section .text
global _start
_start:
    mov rax, 3
    imul rax, 8             ; row * width
    add rax, 2              ; + column, index 26
    mov byte [map+rax], PATH
    movzx rdi, byte [map+rax]
    mov rax, 60             ; 1
    syscall
```

That is `09-map-place-path.asm`. An x of 99 on a width of 8 is not a column. The exercise file masks 99 with 255 and exits 99. The fix compares against the width and, if `x >= width`, sets `x` to `width - 1`.

```asm
section .text
global _start
_start:
    mov rax, 99
    mov rbx, 8              ; width
    cmp rax, rbx
    jl .ok
    mov rax, rbx
    dec rax                 ; 7
.ok:
    mov rdi, rax
    mov rax, 60
    syscall
```

That is `19-debug-map-bounds.asm`. `jl` keeps an x that is already inside. Do not `and` with 255 and call it a clamp.

## Pieces and agents

A direction lives in `0..3`. Increment, then `and` with 3. From 3 the next value is 0 (`11-track-piece-rotate.asm`).

```asm
section .bss
    dir resq 1
section .text
global _start
_start:
    mov qword [dir], 3
    inc qword [dir]
    and qword [dir], 3
    mov rdi, [dir]          ; 0
    mov rax, 60
    syscall
```

Piece type 3 is the constant 3 (`02-place-track.asm`). Two pieces "connecting" exits the constant 1 (`12-track-connect.asm`). It does not compare directions. Steps remaining 4 is the constant 4 (`13-peep-pathfind-step.asm`). There is no grid walk. One agent step increments x from zero and exits 1 (`04-agent-step.asm`). A ride-open flag exits 1 (`06-ride-open.asm`). A queue length of 7 is stored and exited (`14-ride-queue-len.asm`). An excitement value of 42 is the constant 42 (`22-stretch-coaster-excitement.asm`). A net tick id of 2 is local data (`23-stretch-multiplayer-stub.asm`). It is not a socket.

## Economy and the tick

Cash is a qword in `.bss`, so it starts at 0. Adding 5 exits 5 (`03-econ-tick.asm`). Adding a ticket of 15 exits 15 (`15-econ-ticket.asm`). Upkeep subtracts 3 from 10 and exits 7 (`16-econ-upkeep.asm`). Subtract after you know the qword is not still zero, or the cash goes negative and the exit status is not 7.

A tick loop increments until the counter is 5 and exits 5 (`08-from-scratch-tick.asm`). One integrated tick writes a path byte, increments the agent, increments cash, and exits the cash, which is 1 (`24-from-scratch-sim-integrate.asm`). Happiness 120 compared against 100 exits 100 (`07-peep-happy.asm`). Guests of exactly 100 meet a `>= 100` goal because the reject branch is `jl`, and 100 is not less. Exit 1 (`21-scenario-goal.asm`). Rain 3 incremented and masked with 3 exits 0 (`20-weather-tick.asm`). Same wrap as the piece direction.

## Save

`"PK01"` 's first byte is `'P'`, 80 (`05-save-magic.asm`). A header of magic plus version is described as 8 bytes. `17-save-header.asm` exits 8 and does not store those bytes and does not `write`. Version 1 compared equal exits 1 (`18-load-version-check.asm`). A load that accepts any version is not this check. When you do write the map, lesson 08's `open` / `write` / `close` is the path. This file does not open one.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Map: `01-map-cell.asm`, `09-map-place-path.asm` (exit 1, index 26), `10-map-erase.asm`, `19-debug-map-bounds.asm` (exit 7). Pieces and agents: `02-place-track.asm` (constant 3), `04-agent-step.asm` (exit 1), `06-ride-open.asm`, `11-track-piece-rotate.asm`, `12-track-connect.asm` (constant 1), `13-peep-pathfind-step.asm` (constant 4), `14-ride-queue-len.asm`, `22-stretch-coaster-excitement.asm` (constant 42), `23-stretch-multiplayer-stub.asm`. Economy and time: `03-econ-tick.asm`, `07-peep-happy.asm` (exit 100), `08-from-scratch-tick.asm`, `15-econ-ticket.asm`, `16-econ-upkeep.asm` (exit 7), `20-weather-tick.asm`, `21-scenario-goal.asm`, `24-from-scratch-sim-integrate.asm` (exit 1). Save: `05-save-magic.asm` (exit 80), `17-save-header.asm` (constant 8, no `write`), `18-load-version-check.asm`.