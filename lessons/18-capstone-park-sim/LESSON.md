# Lesson 18 — Capstone: Mini Park

## Learning objectives

1. Clamp every map index to the map bounds before it becomes an address.
2. Place at least three track piece types and connect pieces by matching directions.
3. Step one agent along a BFS parent walk, one tile per tick.
4. Tick cash and upkeep on a single qword that never goes negative.
5. Save and load the map with `open`/`write`/`read`/`close`, checked by magic and version.

The capstone is one program, not 24 drills. The drills below are its cells, counters, and file format; the milestone is the integrated binary in Acceptance criteria. Use your own names. Do not copy a commercial park game's text, assets, or data.

## Acceptance criteria

The park is done when all six hold:

1. `make` builds one binary from at least three `.asm` files, sharing symbols with `global`/`extern` (lesson 09). The link has no undefined symbols.
2. The binary places at least three track piece types — straight, curve, station — and reading back each placed cell returns the type stored.
3. An agent reaches its goal: BFS (lesson 17) runs over the path cells each tick, the agent steps one tile along the parent walk per tick, and the goal tile is reached inside the tick budget.
4. 100 ticks run with cash never negative: upkeep is subtracted only when the qword covers it.
5. The save file starts with magic `"PK01"` and version dword `1`, then the map bytes. The loader accepts that file and rejects a bad magic and a wrong version.
6. The run leaves a `.ppm` file rendering the final map (lesson 14). The sim has visible state.

## One binary from many files

Lesson 09's `global`/`extern` is how the capstone stops being 24 separate `_start`s. `map.asm` exposes `map_place`, `econ.asm` exposes `econ_tick`, `save.asm` exposes `save_game`, and `main.asm` calls them and owns the only `_start`. A `Makefile` assembles each file once and links the objects:

```make
park: main.o map.o econ.o save.o
	ld -o park main.o map.o econ.o save.o

%.o: %.asm
	nasm -f elf64 $< -o $@
```

`$@` is the target, `$<` the first prerequisite. Criterion 1 is the link: one binary, no undefined symbols. The drills stay single-file so each stays hand-traceable; the program is the composition.

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

## Pieces

Three piece types, each one byte in the cell: 1 is straight, 2 is curve, 3 is station. `02-place-track.asm` stores the type byte and exits the type: placing a station exits 3. A direction lives in `0..3`. Increment, then `and` with 3. From 3 the next value is 0 (`11-track-piece-rotate.asm`).

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

Two adjacent pieces connect when one's exit direction is the other's entry: `dir[a] == (dir[b] + 2) & 3`. Piece A faces east (1), piece B sits east of A facing west (3): `(3 + 2) & 3` is 1, so `12-track-connect.asm` exits 1. It compares; the old constant did not. A ride-open flag exits 1 (`06-ride-open.asm`). A queue length of 7 is stored and exited (`14-ride-queue-len.asm`). Excitement is `airtime * 3 + length`: 10 and 12 exit 42 (`22-stretch-coaster-excitement.asm`). A net tick id of 2 is local data (`23-stretch-multiplayer-stub.asm`). It is not a socket.

## Agents walk the BFS

Lesson 17's BFS runs on the park's path cells: queue, visited-at-enqueue, `parent[next] = current`, walls from lesson 16's solid flags. Each tick the agent takes one step along the parent walk: `pos = parent[pos]`. Agent at tile 5 with `parent[5] = 2` moves to 2 and exits 2 (`13-peep-pathfind-step.asm`). One agent step from tile 0 to tile 1 exits 1 (`04-agent-step.asm`). No constant is a search: the parent array is walked, not asserted.

## Economy and the tick

Cash is a qword in `.bss`, so it starts at 0. Adding 5 exits 5 (`03-econ-tick.asm`). Adding a ticket of 15 exits 15 (`15-econ-ticket.asm`). Upkeep subtracts 3 from 10 and exits 7 (`16-econ-upkeep.asm`). Subtract after you know the qword is not still zero, or the cash goes negative and the exit status is not 7 — criterion 4 is this guard, every tick.

A tick loop increments until the counter is 5 and exits 5 (`08-from-scratch-tick.asm`). One integrated tick writes a path byte, steps the agent along the parent walk, ticks cash, and exits the cash, which is 1 (`24-from-scratch-sim-integrate.asm`). Happiness 120 compared against 100 exits 100 (`07-peep-happy.asm`). Guests of exactly 100 meet a `>= 100` goal because the reject branch is `jl`, and 100 is not less. Exit 1 (`21-scenario-goal.asm`). Rain 3 incremented and masked with 3 exits 0 (`20-weather-tick.asm`). Same wrap as the piece direction.

## Save and load

The save format is an 8-byte header — magic `"PK01"` (4 bytes) then version dword `1` (4 bytes) — followed by the map bytes. Writing it is lesson 08's create pattern: `open` with `O_WRONLY|O_CREAT|O_TRUNC` = 577 and mode `0644` = 420, `write` the header, `write` the map, `close`.

```asm
section .data
    path db "park.sav", 0
    hdr  db "PK01"
    ver  dd 1                 ; header is 8 bytes total
section .bss
    map resb 64
section .text
global _start
_start:
    mov rax, 2               ; open
    lea rdi, [path]
    mov rsi, 577             ; O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 420             ; 0644
    syscall
    mov rbx, rax             ; fd
    mov rax, 1               ; write
    mov rdi, rbx
    lea rsi, [hdr]           ; "PK01" + version dword
    mov rdx, 8
    syscall                  ; rax = 8
    mov rax, 1               ; write
    mov rdi, rbx
    lea rsi, [map]
    mov rdx, 64
    syscall
    mov rax, 3               ; close
    syscall
    xor rdi, rdi
    mov rax, 60
    syscall
```

`17-save-header.asm` is the first `write`: it exits the byte count, 8. The magic's first byte is `'P'`, 80 (`05-save-magic.asm`). Loading reads the header back and checks both fields: version 1 compared equal exits 1, and any other version is rejected (`18-load-version-check.asm`). A load that accepts any version is not this check.

## Visible state

After the run, the map is rendered to a P6 file (lesson 14): each cell byte becomes one RGB triple — empty is black, path is green, straight is brown, curve is orange, station is white — written with the same `open`/`write`/`close` as the save. Criterion 6 is that file: open it in a viewer and the park is there. The sim never touches `/dev/fb0`; the file is the screen.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`. The integrated binary in Acceptance criteria composes these drills' patterns across files (lesson 09).

Map: `01-map-cell.asm` (exit 1), `09-map-place-path.asm` (exit 1, index 26), `10-map-erase.asm` (exit 0), `19-debug-map-bounds.asm` (exit 7). Pieces and agents: `02-place-track.asm` (exit 3, the type), `04-agent-step.asm` (exit 1), `06-ride-open.asm` (exit 1), `11-track-piece-rotate.asm` (exit 0), `12-track-connect.asm` (exit 1), `13-peep-pathfind-step.asm` (exit 2), `14-ride-queue-len.asm` (exit 7), `22-stretch-coaster-excitement.asm` (exit 42), `23-stretch-multiplayer-stub.asm` (no socket). Economy and time: `03-econ-tick.asm` (exit 5), `07-peep-happy.asm` (exit 100), `08-from-scratch-tick.asm` (exit 5), `15-econ-ticket.asm` (exit 15), `16-econ-upkeep.asm` (exit 7), `20-weather-tick.asm` (exit 0), `21-scenario-goal.asm` (exit 1), `24-from-scratch-sim-integrate.asm` (exit 1). Save: `05-save-magic.asm` (exit 80), `17-save-header.asm` (exit 8), `18-load-version-check.asm` (exit 1).
