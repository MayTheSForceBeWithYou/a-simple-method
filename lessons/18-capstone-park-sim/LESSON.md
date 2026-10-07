# 18 — Capstone: Park Simulation

Lesson 17 gave you entities, pathfinding, and UI. This capstone lesson synthesizes all 18 lessons into one integrated program: a **park simulation** with a tile map, track pieces that connect by direction, guests that walk BFS paths, an economy with income and upkeep (never going negative), and a binary save/load format with magic-number verification. By the end you'll have drilled the primitives that compose into the capstone binary, and you'll understand the six acceptance criteria that define "done."

## What this lesson asks of you

- Clamp every map index to the map bounds **before** it becomes a memory address (`0 <= x < width`, `0 <= y < height`).
- Place at least three track piece types (straight, curve, station) with direction `0..3` (N, E, S, W), and connect pieces by matching their entry/exit directions (`dir[a] == (dir[b] + 2) & 3`).
- Step one agent along a BFS parent walk, one tile per tick (`pos = parent[pos]`), until it reaches the goal.
- Tick cash and upkeep on a single qword that **never goes negative**: subtract upkeep only when `cash >= upkeep`.
- Save and load the map with syscalls `open`/`write`/`read`/`close`, with an 8-byte header (magic `"PK01"` + version dword `1`), rejecting bad magic or wrong version.
- Render the final map to a P6 PPM file (lesson 14) so the sim has visible state.

## Why a park sim as the capstone

The park simulation touches **every lesson**:
- **Lessons 00–02:** Registers, arithmetic, data sections, flags.
- **Lessons 03–05:** Control flow, procedures, recursion.
- **Lesson 06:** Strings, arrays, row-major map indexing.
- **Lesson 07:** Bitwise direction wrapping (`& 3`), connection masks.
- **Lesson 08:** File I/O (`open`, `write`, `read`, `close`) for save/load.
- **Lesson 09:** Multi-file build (`global`/`extern`, Makefile).
- **Lesson 10:** (Editor techniques, less directly used here.)
- **Lesson 11:** Data structures (queues for BFS, stacks for undo).
- **Lesson 12:** (Compiler techniques, less directly used.)
- **Lesson 13:** Fixed-point (if you add smooth camera or entity positions).
- **Lesson 14:** Framebuffer, P6 PPM output for map rendering.
- **Lesson 15:** Game loop, fixed timestep, tick counter.
- **Lesson 16:** Tile map indexing, bounds checking, sprite blitting (if you add guest sprites).
- **Lesson 17:** ECS (guest/ride entities), BFS pathfinding, UI panels (if you add menus).
- **Lesson 18:** Integration—composing all primitives into one running program.

The capstone is **not 24 drills**. It's **one program** that you build by composing the patterns from all 18 lessons, using your own names and design. The drills below isolate the park-specific primitives (map cells, track piece types, agent stepping, cash guarding, save format). You link them into the capstone binary for the milestone.

## Acceptance criteria

The park simulation is **done** when all six criteria hold:

### 1. Multi-file build with no undefined symbols

Use lesson 09's `global`/`extern` to split the program across at least three `.asm` files:
- `main.asm`: owns `_start`, calls the other modules.
- `map.asm`: exposes `map_place`, `map_read`, etc.
- `econ.asm`: exposes `econ_tick`, `econ_add_cash`, etc.
- `save.asm`: exposes `save_game`, `load_game`.

**Makefile:**

```make
park: main.o map.o econ.o save.o
	ld -o park main.o map.o econ.o save.o

%.o: %.asm
	nasm -f elf64 $< -o $@
```

`$@` is the target, `$<` is the first prerequisite. Run `make` and `ld` must succeed with no undefined symbols.

### 2. Place and read back at least three track piece types

- **Straight** (type 1)
- **Curve** (type 2)
- **Station** (type 3)

Each piece has a **direction** `0..3` (N, E, S, W). Placing a station at `(x, y)` writes type 3 to `map[y * width + x]`. Reading that cell back returns 3.

Two adjacent pieces **connect** when one's exit direction is the other's entry:

```
connect = (dir[a] == (dir[b] + 2) & 3)
```

**Example:** Piece A faces east (1), piece B is to the east of A and faces west (3):
- `(3 + 2) & 3` = `5 & 3` = 1
- Matches `dir[a]` = 1, so they connect.

### 3. Agent reaches goal via BFS parent walk

Lesson 17's BFS runs on the park's path cells (type 1). The search produces a `parent[]` array. Each tick, the agent steps one tile along the parent walk:

```
pos = parent[pos]
```

The agent starts at a source tile (e.g., park entrance) and steps toward the goal (e.g., a ride). When `pos == goal`, the agent has arrived.

The simulation must complete this walk within the tick budget (e.g., 100 ticks). If BFS found a path of length 10, the agent reaches the goal in 10 ticks.

### 4. 100 ticks with cash never negative

Cash is a qword in `.bss` (starts at 0). Each tick:
- **Income:** Add ticket sales, ride fees, etc.
- **Upkeep:** Subtract maintenance costs, **only if** `cash >= upkeep`.

**Critical guard:**

```asm
mov rax, [cash]
cmp rax, [upkeep]
jb .skip_upkeep         ; cash < upkeep, do not subtract
sub rax, [upkeep]
mov [cash], rax
.skip_upkeep:
```

Run 100 ticks. Cash must never be negative (as a signed qword) or wrap to a huge unsigned value. The guard ensures the invariant holds.

### 5. Save/load with magic and version check

**Save format (binary):**
- Offset 0: Magic `"PK01"` (4 bytes)
- Offset 4: Version dword `1` (4 bytes)
- Offset 8: Map bytes (width × height bytes)

**Save:**

```asm
mov rax, 2              ; open
lea rdi, [path]
mov rsi, 577            ; O_WRONLY | O_CREAT | O_TRUNC
mov rdx, 420            ; 0644
syscall
mov rbx, rax            ; fd

mov rax, 1              ; write header (8 bytes)
mov rdi, rbx
lea rsi, [header]
mov rdx, 8
syscall

mov rax, 1              ; write map
mov rdi, rbx
lea rsi, [map]
mov rdx, MAP_SIZE
syscall

mov rax, 3              ; close
syscall
```

**Load:**

Read header, check magic and version:

```asm
mov rax, 0              ; read
mov rdi, fd
lea rsi, [header_buf]
mov rdx, 8
syscall

; check magic
cmp dword [header_buf], 0x314B5050   ; "PK01" little-endian
jne .bad_magic

; check version
cmp dword [header_buf + 4], 1
jne .bad_version
```

The loader must **reject** a file with bad magic or wrong version (exit with error).

### 6. Visible state: P6 PPM map render

After the simulation runs, render the final map to a P6 PPM file (lesson 14):

- Empty cell (0): black `(0, 0, 0)`
- Path (1): green `(0, 255, 0)`
- Straight (2): brown `(139, 69, 19)`
- Curve (3): orange `(255, 165, 0)`
- Station (4): white `(255, 255, 255)`

Open the `.ppm` file in an image viewer. The park is visible. The sim never touches `/dev/fb0`—the file is the output.

## Map: bounds checking and cell types

### Cell storage

The map is a flat byte array, row-major:

```asm
section .bss
    map: resb 64            ; 8×8 map
    width equ 8
    height equ 8
```

Cell at `(x, y)`: `map[y * width + x]`.

**Drill:** `01-map-cell.asm` writes 1 at a fixed offset, reads it back, exits 1.

**Drill:** `09-map-place-path.asm` — column 2, row 3, width 8 → index 26. Stores `PATH` (1), exits 1.

**Drill:** `10-map-erase.asm` — writes 1 then 0 at the same byte, exits 0.

### Bounds clamping

**Critical:** Clamp `x` and `y` to valid ranges **before** indexing the map. An out-of-bounds index causes a segfault or corrupts adjacent memory.

```asm
; clamp x to [0, width)
cmp rax, 0
jge .x_not_negative
xor rax, rax
.x_not_negative:
cmp rax, width
jl .x_ok
mov rax, width
dec rax                 ; width - 1
.x_ok:
```

**Drill:** `19-debug-map-bounds.asm` — `x = 99`, width 8. The fix clamps to 7, exits 7.

**Bug in drill:** The solution only clamps the **upper bound** (`x >= width`). It does not handle negative `x`. A full clamp needs both comparisons:

```asm
; unsigned clamp to [0, width)
cmp rax, width
jb .ok                  ; 0 <= x < width (unsigned)
mov rax, width
dec rax
.ok:
```

For signed clamps, test `jl 0` first.

## Track pieces: types, directions, connections

### Piece types

| Type | Value | Meaning |
|------|------:|---------|
| Empty | 0 | No structure |
| Path | 1 | Walkable path for guests |
| Straight | 2 | Straight track segment |
| Curve | 3 | Curved track segment |
| Station | 4 | Ride station (guests board here) |

**Drill:** `02-place-track.asm` — the lesson describes "stores the type byte and exits the type: placing a station exits 3." The **solution** is `mov rdi, 3` (placeholder constant). No store is performed.

### Directions

Directions wrap with `& 3`:

| Value | Direction |
|------:|-----------|
| 0 | North |
| 1 | East |
| 2 | South |
| 3 | West |

**Rotate clockwise:** `(dir + 1) & 3`

**Drill:** `11-track-piece-rotate.asm` — direction 3 (west), increment and wrap: `(3 + 1) & 3` = 0 (north), exits 0.

### Connection rule

Two adjacent pieces connect when one's **exit direction** is the other's **entry direction**:

```
connect = (dir[a] == (dir[b] + 2) & 3)
```

Adding 2 rotates by 180° (opposite direction).

**Drill:** `12-track-connect.asm` — the lesson describes "Piece A faces east (1), piece B faces west (3): `(3 + 2) & 3` = 1, exits 1. It compares; the old constant did not." The **solution** is `mov rdi, 1` (placeholder constant). No comparison is performed.

## Agents: BFS parent walk

Lesson 17's BFS produces a `parent[]` array. Each tick, the agent moves one tile closer to the goal:

```asm
mov rax, [agent_pos]
mov rbx, [parent + rax*8]
mov [agent_pos], rbx
```

**Drill:** `13-peep-pathfind-step.asm` — the lesson describes "Agent at tile 5 with `parent[5] = 2` moves to 2 and exits 2. The parent array is walked, not asserted." The **solution** stores constant 4 in `steps` and exits **4** (mismatch). No parent array is walked.

**Drill:** `04-agent-step.asm` — one step from tile 0 to tile 1, exits 1 (placeholder).

## Economy: cash, upkeep, guarding against negative

### Cash initialization

Cash is a qword in `.bss`, starts at 0.

**Drill:** `03-econ-tick.asm` — add 5 to cash, exits 5.

**Drill:** `15-econ-ticket.asm` — add ticket sale 15, exits 15.

### Upkeep: the guard

Each tick, subtract upkeep **only if** `cash >= upkeep`. Otherwise, skip the subtraction.

**Drill:** `16-econ-upkeep.asm` — cash 10, upkeep 3 → `10 - 3` = 7, exits 7. However, the **solution has no guard**:

```asm
mov qword [cash], 10
sub qword [cash], 3     ; unconditional subtraction
```

If cash were 2, this would produce `-1` (`0xFFFFFFFFFFFFFFFF`), violating criterion 4.

**Correct guard:**

```asm
mov rax, [cash]
cmp rax, [upkeep]
jb .skip_upkeep         ; unsigned: cash < upkeep
sub rax, [upkeep]
mov [cash], rax
.skip_upkeep:
```

The lesson's phrase "Subtract after you know the qword is not still zero" is **insufficient**. Cash of 1 is "not zero," but subtracting upkeep of 3 still goes negative. The test must be `cash >= upkeep`.

### Worked example: does `16-econ-upkeep.asm` enforce "cash never negative"?

**Task:** The drill should demonstrate criterion 4's guard: upkeep is subtracted only when cash covers it.

**Code (as shipped):**

```asm
section .bss
    cash: resq 1

section .text
global _start
_start:
    mov qword [cash], 10
    sub qword [cash], 3
    mov rdi, [cash]
    mov rax, 60
    syscall
```

**Plausible wrong reading:**

*"This drill enforces the guard: upkeep is subtracted only when cash covers it, and the exit of 7 proves it worked."*

**Why it's wrong:** There is **no comparison** anywhere in the file. `sub` runs unconditionally. If cash were 2, `sub qword [cash], 3` would leave `0xFFFFFFFFFFFFFFFF` (−1 as a signed qword), the exit status would be 255 (low byte), and the run would continue with a corrupted balance. An exit of 7 shows only that 10 − 3 = 7, not that a guard exists.

**The correct reading:** The guard is a **compare-and-branch before the subtraction**. Compare cash (unsigned) against upkeep. If less, skip the subtraction. That block, run every tick for 100 ticks, is what criterion 4 requires.

### Other economy drills

**Drill:** `07-peep-happy.asm` — happiness 120, clamp to 100, exits 100 (same clamp-after-arithmetic rule as lesson 17).

**Drill:** `21-scenario-goal.asm` — guest count 100, goal `>= 100`, exits 1 (goal met).

## Simulation tick loop

A tick loop runs a fixed number of iterations (e.g., 100):

**Drill:** `08-from-scratch-tick.asm` — increment counter until 5, exits 5.

**Drill:** `24-from-scratch-sim-integrate.asm` — the lesson describes "writes a path byte, steps the agent along the parent walk, ticks cash, and exits the cash, which is 1." The **solution** does `inc qword [peep_x]` and exits 1 (placeholder).

### Other tick drills

**Drill:** `20-weather-tick.asm` — rain counter 3, increment and wrap with `& 3` → 0, exits 0.

**Drill:** `06-ride-open.asm` — ride open flag, exits 1.

**Drill:** `14-ride-queue-len.asm` — queue length 7, exits 7.

**Drill:** `22-stretch-coaster-excitement.asm` — excitement = `airtime * 3 + length`: `10 * 3 + 12` = 42, exits 42.

**Drill:** `23-stretch-multiplayer-stub.asm` — net tick ID 2 (placeholder, not a socket).

## Save and load: binary format with magic and version

### Save format

**8-byte header:**
- Offset 0: Magic `"PK01"` (4 bytes, ASCII)
- Offset 4: Version `1` (dword, 4 bytes)

**Map data:** width × height bytes (one byte per cell).

**Drill:** `05-save-magic.asm` — magic's first byte is `'P'` (80), exits 80.

**Drill:** `17-save-header.asm` — the lesson describes "the first `write`: it exits the byte count, 8." The **solution** is `mov rdi, 8` (placeholder). No `write` is performed.

**Drill:** `18-load-version-check.asm` — the lesson describes "version 1 compared equal exits 1, and any other version is rejected." The **solution** checks `ver dq 1` (a **qword**, not a dword as the format specifies) with `cmp qword`. Against a real 8-byte header at offset 4, a qword compare would read 4 bytes past the header into the map. The drill does not read from a file.

### Full save sequence

```asm
section .data
    path: db "park.sav", 0
    header: db "PK01"
            dd 1            ; version dword

section .bss
    map: resb 64

section .text
global _start
_start:
    ; open
    mov rax, 2
    lea rdi, [path]
    mov rsi, 577            ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 420            ; 0644
    syscall
    mov rbx, rax            ; fd

    ; write header
    mov rax, 1
    mov rdi, rbx
    lea rsi, [header]
    mov rdx, 8
    syscall

    ; write map
    mov rax, 1
    mov rdi, rbx
    lea rsi, [map]
    mov rdx, 64
    syscall

    ; close
    mov rax, 3
    mov rdi, rbx
    syscall

    xor rdi, rdi
    mov rax, 60
    syscall
```

### Load sequence

Read header, validate magic and version, read map:

```asm
; open
mov rax, 2
lea rdi, [path]
xor rsi, rsi            ; O_RDONLY
syscall
mov rbx, rax            ; fd

; read header
mov rax, 0
mov rdi, rbx
lea rsi, [header_buf]
mov rdx, 8
syscall

; check magic (little-endian)
mov eax, [header_buf]
cmp eax, 0x314B5050     ; "PK01" reversed
jne .bad_magic

; check version
mov eax, [header_buf + 4]
cmp eax, 1
jne .bad_version

; read map
mov rax, 0
mov rdi, rbx
lea rsi, [map]
mov rdx, 64
syscall

; close
mov rax, 3
syscall
```

## Visible output: P6 PPM rendering

After the simulation, render the map to a P6 file (lesson 14):

**Header:** `"P6\n<width> <height>\n255\n"`

**Body:** 3 bytes per pixel (R, G, B), row-major.

**Color mapping:**

| Cell type | Color | RGB |
|-----------|-------|-----|
| Empty (0) | Black | `(0, 0, 0)` |
| Path (1) | Green | `(0, 255, 0)` |
| Straight (2) | Brown | `(139, 69, 19)` |
| Curve (3) | Orange | `(255, 165, 0)` |
| Station (4) | White | `(255, 255, 255)` |

Open `output.ppm` in an image viewer. The park is visible. Criterion 6 is met.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| Clamp after indexing | Clamp `x` and `y` **before** computing `map[y * width + x]` |
| Direction is `0..4` | Direction is `0..3` (four cardinal directions); wrap with `& 3` |
| Connection is adjacency | Connection requires **direction match**: `dir[a] == (dir[b] + 2) & 3` |
| Upkeep subtracts unconditionally | Subtract **only if** `cash >= upkeep`; otherwise skip (criterion 4 guard) |
| Version is a qword | Save format defines version as a **dword** (4 bytes), not qword |
| The sim runs in `/dev/fb0` | The sim outputs a P6 PPM **file**; no device access |

## Check yourself

1. `11-track-piece-rotate.asm` computes `(3 + 1) & 3`. Why is `& 3` a correct wrap here, and when would it not be?

2. The connection rule is `dir[a] == (dir[b] + 2) & 3`. With A facing north (0), what must B face to connect, and what does the formula give?

3. `19-debug-map-bounds.asm` uses `jl` to keep `x` when `x < width`. What does it do with `x = -1`, and is that safe as a map index?

4. You have cash = 5 and upkeep = 10. Without the guard, what value is in `cash` after `sub qword [cash], 10`? What is the low-byte exit status?

5. You write the save header with two consecutive `.data` items: `hdr db "PK01"` and `ver dd 1`. Are they contiguous in memory, or could NASM insert padding?

## Key takeaways

- Multi-file build: split the program across modules with `global`/`extern`, link with `ld`, check for undefined symbols.
- Clamp map indices **before** indexing: `0 <= x < width`, `0 <= y < height`.
- Track pieces have types (empty, path, straight, curve, station) and directions (0..3, wrap with `& 3`); connect with `dir[a] == (dir[b] + 2) & 3`.
- Agents step along BFS `parent[]` array: `pos = parent[pos]` each tick until `pos == goal`.
- Economy: subtract upkeep **only if** `cash >= upkeep` (unsigned compare before subtraction).
- Save format: 8-byte header (magic `"PK01"` + version dword `1`) + map bytes; loader validates magic and version.
- Render map to P6 PPM for visible output (criterion 6).

## Lookup

- Multi-file builds: lesson 09 (Macros, Multi-file, Make)
- BFS pathfinding: lesson 17 (Entities, Pathfinding, UI)
- File I/O: lesson 08 (Syscalls, Files, mmap)
- P6 PPM format: lesson 14 (Graphics: Framebuffer & PPM Output)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Map:**
- `01-map-cell.asm` — write 1, read back, exit 1
- `09-map-place-path.asm` — place at index 26, exit 1
- `10-map-erase.asm` — write 1 then 0, exit 0
- `19-debug-map-bounds.asm` — clamp 99 to 7, exit 7 (only upper bound)

**Track and agents:**
- `02-place-track.asm` — **placeholder: exits 3 (no store)**
- `04-agent-step.asm` — **placeholder: exits 1**
- `06-ride-open.asm` — ride flag, exit 1
- `11-track-piece-rotate.asm` — `(3+1) & 3`, exit 0
- `12-track-connect.asm` — **placeholder: exits 1 (no comparison)**
- `13-peep-pathfind-step.asm` — **placeholder: exits 4 (mismatch, lesson says 2)**
- `14-ride-queue-len.asm` — queue 7, exit 7
- `22-stretch-coaster-excitement.asm` — `10*3+12`, exit 42
- `23-stretch-multiplayer-stub.asm` — net ID 2 (no socket)

**Economy and time:**
- `03-econ-tick.asm` — add 5, exit 5
- `07-peep-happy.asm` — clamp 120 to 100, exit 100
- `08-from-scratch-tick.asm` — tick to 5, exit 5
- `15-econ-ticket.asm` — add 15, exit 15
- `16-econ-upkeep.asm` — `10 - 3` = 7, exit 7 (no guard)
- `20-weather-tick.asm` — `(3+1) & 3`, exit 0
- `21-scenario-goal.asm` — 100 guests >= 100, exit 1
- `24-from-scratch-sim-integrate.asm` — **placeholder: exits 1**

**Save/load:**
- `05-save-magic.asm` — first byte `'P'` = 80, exit 80
- `17-save-header.asm` — **placeholder: exits 8 (no write)**
- `18-load-version-check.asm` — **placeholder: exits 1 (qword not dword, no file read)**
