# A Simple Method — Learning Roadmap

Learning assembly language programming from the ground up through exercises.

**Target:** Linux x86-64, NASM syntax, System V AMD64 ABI, Linux syscalls  
**North star:** Build toward a mini park / coaster-builder simulation (RCT-depth *skills*, original code/assets)  
**Course root:** `/home/n8/dev/asm`

---

## Prerequisites

- Comfortable with a Linux shell (cd, ls, editors, pipes). WSL2 is fine.
- Basic programming literacy (variables, loops, functions, arrays) in any language.
- Willingness to read Intel/AMD manuals and man pages when stuck.
- **Not required:** prior assembly, OS course, or C — C helps later for ABI intuition.

## Toolchain

| Tool | Role |
|------|------|
| `nasm` | Assembler (`-f elf64`) |
| `ld` | Linker (static ELF) |
| `make` | Build orchestration |
| `gdb` / `rr` | Debugging (breakpoints, registers, memory) |
| `objdump -d` / `readelf` | Inspect object/ELF |
| Optional later | `gcc` as driver for libc/X11 glue; `strace` for syscalls |

Install (Arch Linux WSL — distro `arch`):

```bash
# From Windows PowerShell/CMD:
#   wsl -d arch -- bash
sudo pacman -Syu --needed nasm binutils make gdb
```

Do **not** use Ubuntu/`apt` for this course machine.

Canonical build for freestanding programs in early lessons:

```bash
nasm -f elf64 foo.asm -o foo.o
ld foo.o -o foo
./foo
```

## How to use `exercises/` vs `solutions/`

1. Read `LESSON.md` end-to-end once; skim again while coding.
2. Copy or edit files under `exercises/` only. Do **not** peek at `solutions/` until you have a failing attempt or a design question.
3. Each exercise file starts with a comment block stating the goal, constraints, and often the build command.
4. Progressive difficulty: early numbers are drills; mid numbers are debug/from-scratch; late numbers are stretch.
5. When stuck >20 minutes: re-read the relevant LESSON section, check registers with `gdb`, then compare *approach* (not line-by-line) with the solution.
6. Solutions are reference implementations — alternate correct ABIs/layouts are fine if documented.

## Recommended order

Strict sequential through **09**, then **10** (editor milestone).  
**11–12** (parsing + tiny compiler) before heavy game work.  
**13–17** feed **18** (capstone). You may lightly sample **13** (fixed-point) earlier if game sketches demand it.

---

## Phase catalog

### 00 — Tools, registers, `mov`, first syscalls
- **Slug:** `00-tools-registers-mov-syscall`
- **Goals:** Install/verify toolchain; know GPR names/sizes; `mov`/`xor`; write/exit syscalls; build/run ELF.
- **Exercise target:** 24–32
- **Status this run:** **FULL** (≥24 drills + solutions)

### 01 — Addressing modes & data sections
- **Slug:** `01-addressing-data`
- **Goals:** `.data`/`.bss`/`.rodata`/`.text`; immediates, direct, register indirect, displacement, SIB-style scaled index; `lea` vs `mov`.
- **Exercise target:** 24–36
- **Status:** **FULL**

### 02 — Arithmetic & flags
- **Slug:** `02-arithmetic-flags`
- **Goals:** `add`/`sub`/`inc`/`dec`/`imul`/`mul`/`idiv`/`div`/`neg`; RFLAGS (ZF/SF/CF/OF); setcc family.
- **Exercise target:** 24–36
- **Status:** **FULL**

### 03 — Control flow
- **Slug:** `03-control-flow`
- **Goals:** `cmp`/`test`; conditional/unconditional jumps; loops; structured if/else/while in asm; jump tables intro.
- **Exercise target:** 24–40
- **Status:** **FULL**

### 04 — Stack & System V AMD64 calling convention
- **Slug:** `04-stack-calling-convention`
- **Goals:** `push`/`pop`; red zone awareness; arg regs `rdi,rsi,rdx,rcx,r8,r9`; stack args; alignment; caller/callee-saved; prologue/epilogue.
- **Exercise target:** 24–36
- **Status:** **FULL**

### 05 — Procedures & Recursion
- **Slug:** `05-procedures-recursion`
- **Goals:** Leaf vs non-leaf; locals on stack; recursion (factorial, Fibonacci, tree walk); mutual recursion.
- **Exercise target:** 24–32
- **Status:** **FULL** (24 exercises)

### 06 — Strings, memory, arrays
- **Slug:** `06-strings-memory-arrays`
- **Goals:** strlen/strcpy/memcmp patterns; array indexing; struct-like layouts; `rep movsb`/`stosb` carefully.
- **Exercise target:** 28–40 (full: 24)
- **Status:** **FULL** (24 exercises)

### 07 — Bit ops, shifts, masks
- **Slug:** `07-bitops-shifts-masks`
- **Goals:** `and`/`or`/`xor`/`not`; `shl`/`shr`/`sar`/`rol`/`ror`; bitfields; flags packing; popcount-by-hand.
- **Exercise target:** 24–32 (full: 24)
- **Status:** **FULL** (24 exercises)

### 08 — Syscalls, files, mmap
- **Slug:** `08-syscalls-files-mmap`
- **Goals:** open/read/write/close/lseek; error handling via negative rax; `mmap`/`munmap`; simple file copy & sparse buffers.
- **Exercise target:** 24–36 (full: 24)
- **Status:** **FULL** (24 exercises)

### 09 — Macros, multi-file, Makefile
- **Slug:** `09-macros-multifile-make`
- **Goals:** `%macro`/`%define`/`%include`; separate asm units + `global`/`extern`; Make dependency graphs.
- **Exercise target:** 20–28 (full: 24)
- **Status:** **FULL** (24 exercises)

### 10 — Milestone: CLI text editor
- **Slug:** `10-milestone-cli-editor`
- **Goals:** Gap/rope or contiguous buffer; cursor; raw tty (`tcsetattr` via libc *or* ioctl); load/save; basic insert/delete/redraw.
- **Exercise target:** 20–30 scaffold drills + one integrated binary (full: 24)
- **Acceptance criteria:**
  - Open a path, edit, save, quit without corrupting file on normal paths.
  - Arrow keys or h/j/k/l move cursor; insert printable ASCII; backspace deletes.
  - Buffer ≥64 KiB supported; redraw is correct after edits.
  - Majority of editor logic in asm (thin C/libc OK for termios only).
- **Status:** **FULL** (24 exercises)

### 11 — Parsing & data structures in asm
- **Slug:** `11-parsing-datastructures`
- **Goals:** Token buffers; linked lists/hash maps/arena allocators in asm; recursive descent skeleton.
- **Exercise target:** 24–32 (full: 24)
- **Status:** **FULL** (24 exercises)

### 12 — Milestone: Tiny Language Compiler
- **Slug:** `12-milestone-tiny-compiler`
- **Goals:** Lexer → AST or bytecode → emit NASM or raw machine code for a tiny language (ints, lets, if, while, funcs).
- **Exercise target:** 20–28 + integrated compiler (full: 24)
- **Acceptance criteria:**
  - Compiles ≥10 sample programs in the tiny language to runnable ELF (via generated asm + nasm/ld, or direct emit).
  - Supports integers, arithmetic, locals, `if`, `while`, and at least one form of procedure.
  - Clear error messages on lex/parse failure (stderr).
  - Compiler itself predominantly asm (hosted helpers OK).
- **Status:** **FULL** (24 exercises)

### 13 — Fixed-point arithmetic
- **Slug:** `13-fp-simd-fixedpoint`
- **Goals:** fixed-point arithmetic (Q16.16); Q16.16 (or similar) fixed-point; why RCT-era engines favored integer/fixed-point.
- **Exercise target:** 24–32 (full: 24)
- **Status:** **FULL** (24 exercises)

### 14 — Graphics path
- **Slug:** `14-graphics-framebuffer`
- **Goals:** P6 PPM image file output via taught syscalls (open/write/close); pixel plots, clear, blit; keep *game logic* in asm.
- **Exercise target:** 20–28 (full: 24)
- **Status:** **FULL** (24 exercises)

### 15 — Input, Timing, Game Loop
- **Slug:** `15-input-timing-gameloop`
- **Goals:** Keyboard/mouse events; `clock_gettime`; fixed timestep vs variable; frame pacing.
- **Exercise target:** 20–28 (full: 24)
- **Status:** **FULL** (24 exercises)

### 16 — Sprites, Tilemaps, Collision
- **Slug:** `16-sprites-tilemaps-collision`
- **Goals:** Tile indexing; sprite blit with clipping; AABB collision; spatial hash intro.
- **Exercise target:** 24–32 (full: 24)
- **Status:** **FULL** (24 exercises)

### 17 — Entities, pathfinding, UI panels (RCT-flavored)
- **Slug:** `17-entities-pathfinding-ui`
- **Goals:** Entity component tables (SoA/AoS); BFS/A* on grids; panel/hit-test UI; guest/path metaphors without RCT IP.
- **Exercise target:** 24–32 (full: 24)
- **Status:** **FULL** (24 exercises)

### 18 — Capstone: Mini Park
- **Slug:** `18-capstone-park-sim`
- **Goals:** Integrate map edit, simple ride track pieces, peep agents, economy tick, save/load — almost entirely asm.
- **Exercise target:** milestone checklist + supporting drills (full: 24)
- **Acceptance criteria:**
  - Place/remove path and at least 3 track piece types on a grid map.
  - ≥1 autonomous agent type pathfinds on paths.
  - Simulation ticks with visible state change; save/load round-trips map.
  - Documented build; no copyrighted assets or reverse-engineered RCT code.
- **Status:** **FULL** (24 exercises)

---

## How RCT-depth skills map (without RCT IP)

Chris Sawyer’s RCT work exemplifies:

| Skill | Where you train it |
|-------|--------------------|
| Extreme performance awareness | 02, 07, 13, 16 |
| Custom engines & tight data layout | 06, 11, 16, 17, 18 |
| Integer/fixed-point world sims | 13, 17, 18 |
| Direct hardware/OS talking | 00, 08, 14, 15 |
| Large asm codebases (modules, macros) | 05, 09, 10, 12, 18 |
| Tools that emit machine code | 12 |

We pursue **those engineering muscles**, with original exercises and a park-builder *theme* — never copied assets, names, or disassembly.

## Exercise count summary (targets)

| Lessons | Per-lesson target | Current |
|---------|-------------------|----------|
| 00–04 | 24–40 full | Full ≥24 each |
| 05–18 | 20–40 | **Full 24 each** (expanded) |

## Pedagogy stance

PhD CS + education: precise vocabulary (ABI, RFLAGS, SIB, red zone), authentic difficulty, learn-by-doing. Borrow *shapes* from Project Euler-lite, Advent of Code loops, CSAPP bomblab/buflab spirit, and nand2tetris “build the stack” — mapped cleanly onto NASM/Linux.

## Next fill pass

05–18 now have 24 drills each. Optional next: deepen milestones 10/12/18 with multi-file integrated binaries, add 25–40 stretch drills, and richer graphics/sys backends.
