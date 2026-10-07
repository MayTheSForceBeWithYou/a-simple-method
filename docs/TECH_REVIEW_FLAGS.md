# Technical Review Flags

This file tracks technical doubts raised during the pedagogy rework pass.
Each entry requires verification by a separate technical reviewer.

**Format:**
- **Lesson:** lesson number and file
- **Location:** section or line reference
- **Quoted text:** the questionable claim or listing
- **Doubt:** what specifically needs verification

---

## Lesson 10 — Milestone: CLI Text Editor

1. **`struct termios` size.** The lesson says `struct termios` is 60 bytes. That is glibc's userspace struct. The kernel's `TCGETS`/`TCSETS` ioctl uses the kernel `struct termios` (NCCS = 19), which is 36 bytes. A 60-byte buffer is safe either way, but the stated size may be the wrong struct for a raw syscall.

2. **Insert loop in `solutions/10-insert-middle.asm`** does one extra copy (`buf[cur] = buf[cur-1]`) because it exits on `jl` rather than `jle`, and it stores at the literal `[buf+1]` instead of `[buf+cur]`. The output is correct for this input. Decide whether the solution should model the minimal shift, given that the lesson text says "shifting the tail one byte right".

3. **Signed vs unsigned compares on indices.** `10-insert-middle.asm` uses signed `jl` on indices while the lesson teaches unsigned `jbe` for the cursor clamp. Standardize on unsigned branches for indices?

4. **Exercise starting state.** The TODO stubs (for example `exercises/01-buffer-init.asm`) end at `; TODO` with no `syscall`, so `_start` runs off into whatever bytes follow. Exits with status 127 observed. If intentional, README should explain.

5. **`12-line-start-end.asm`.** The file's name says "end" while the code computes the start. Naming mismatch.

## Lesson 11 — Parsing & Data Structures

1. **"Ring" naming.** `20-queue-ring.asm` is labeled "Ring buffer cap 4" in its own comment but has no wrap or capacity check. The lesson discloses this. Should the file be renamed or the comment changed so that learners do not copy a non-wrapping queue into lesson 17 BFS?

2. **`13-hashmap-put-get.asm`** is called a hashmap but has no hash, probe, or key compare. The lesson says so. Flag for clarity that hashing is not taught here.

3. **`24-from-scratch-vector-push.asm` exercise** segfaulted (status 139) as shipped. Confirm that the exercise file contains no starter code that dereferences something.

4. **Interning by pointer compare (`21-intern-string.asm`).** Comparing pointers is only valid after strings have been interned via content lookup. The drill does not show that content lookup.

## Lesson 12 — Milestone: Tiny Language Compiler

1. **"rel8" is unsigned in the code.** The bytecode table calls the jump operand `rel8`, conventionally meaning signed 8-bit displacement. `19-bytecode-jump.asm` loads it with `movzx`, so a byte like `0xFE` jumps forward 254 rather than back 2. Should the operand be read with `movsx rax, byte [rsi]` for backward jumps?

2. **Keyword boundary.** The grammar says a keyword is "the whole word", but neither the lesson nor `03-parse-let.asm` mentions the trailing-boundary check (`let` vs `letter`). Confirm that it matches the intended grammar.

3. **Grammar vs drills.** The grammar includes `ident` as a factor, `while`, `if_expr`, and `call` with argument lists. The drills `16`/`17`/`18` exit constants or near-constants. Is acceptance criterion 5 ("a call exits its return value") exercised by any drill that actually performs a `call`/`ret`?

4. **`exercises/18-call-codegen.asm` segfaulted** (status 139) as shipped. May contain starter code. Investigate.

5. **ELF header size.** Agree that `Elf64_Ehdr` is 64 bytes. A runnable ELF also needs at least one 56-byte program header, which the lesson does not mention.

## Lesson 13 — Fixed-point Arithmetic

1. **`shr` on signed products.** `01-fixed-mul.asm`, `19-debug-q-shift.asm`, and `15-lerp-fixed.asm` use `shr` after a signed `imul`. For a negative product, rescaling needs `sar`. Should the listings use `sar`?

2. **`shr rax,16` in `11-fixed-div.asm`** is also logical rather than arithmetic, so it has the same negative-value issue after `idiv`.

3. **Folder name vs content.** The folder is `13-fp-simd-fixedpoint`, but the lesson explicitly does no floating point and no SIMD. Lesson 12 says "Floating point is lesson 13" twice, but that promise is not kept.

4. **`13-pack-rgba8888.asm`** exits 255 without packing G, B, or A (disclosed). Lesson 14 then teaches a different pack order (`R<<16 | G<<8 | B`, i.e. XRGB). Which byte order is "RGBA8888" in this course?

5. **The lerp formula.** The lesson's lerp is described from 0, so `a + (b-a)·t` reduces to `b·t`. Nonzero `a` is not verified in any drill.

## Lesson 14 — Graphics Framebuffer

1. **`16-pitch-bytes.asm` exit mismatch.** The lesson says the file aligns 20 up to 16 and exits **32**. The solution only does `mov rdi,5` / `imul rdi,4` and exits **20**. The lesson's listing (`add rax,15` / `and rax,~15`) is correct math. File needs update.

2. **`23-stretch-ppm-header-len.asm` exit mismatch.** The lesson says it builds the 11-byte header for a 4×2 image, `write`s it, and exits **11**. The solution defines only `h db "P6",10`, makes no syscalls besides exit, and exits **3**.

3. **`04-plot-stub.asm` description.** The lesson says it "plots through the offset math: `y * pitch + x * 4`". The solution stores byte 7 at `[fb]` (offset 0) with `mov byte` and reads it back. There is no offset math and no dword. Exit matches, but description does not.

4. **"P6 ... all from lessons 00 and 08."** Cannot verify from lessons 10–18 alone that `open` (2) and `close` (3) were taught in lesson 08.

5. **Close in P6 listing.** `mov rax, 3` / `syscall` relies on `rdi` still holding the fd from the second `write`. Correct (`syscall` preserves `rdi`), but no explicit `mov rdi, rbx` before `close` would be clearer.

6. **`02-pack-rgb.asm` vs `13-pack-rgba8888.asm` (lesson 13).** The packing conventions differ between lessons.

7. **Placeholder drills.** Many drills in L14 are `mov rdi, N` constants. Prose must not claim they perform real operations. Describe accurately as placeholders.

## Lesson 15 — Input, Timing, Game Loop

1. **`07-poll-key.asm` does not exist.** The prose refers to `07-poll-key.asm`. The repo has `07-poll-stub.asm`, whose solution is `xor rdi,rdi` + exit. There is no `poll` and no `read`. **Fix: Update prose to reference `07-poll-stub.asm`.**

2. **`17-clock-diff.asm` description.** Described as exiting "the millisecond difference of two real `timespec` stamps", with nanosecond borrow. The solution is `mov rax,100` / `sub rax,60` and exits **40**. There is no `clock_gettime`, no `timespec`, and no borrow. **Exit mismatch: prose says one thing, code exits 40 as a constant.**

3. **`24-from-scratch-loop-phases.asm` description.** Described as input → update → render → pace, driven by `clock_gettime`, `poll`/`read`, and `nanosleep`. The solution adds 3 to `rdi` twice and exits 6. Placeholder.

4. **`20-fixed-hz.asm`.** Said to "store the 60 Hz frame budget — 16666667 ns". The solution only does `mov rdi,60`. Nothing is stored. Placeholder.

5. **`21-sim-real-ratio.asm`.** The prose says it "divides sim ms by real ms, times 100". The exercise list says "no divide". The solution is `mov rax,50`. Placeholder.

6. **`22-stretch-ring-drop.asm`.** The prose says "the file stores the count and compares it against capacity before each enqueue". The exercise list says "no capacity test". The solution stores the constant 1 into `dropped`. Placeholder.

7. **`13-interp-alpha.asm`.** Described as also computing the Q16.16 alpha (`0x8000` in a register). The solution computes only the percent (`8*100/16`). Partial implementation.

8. **`05-frame-limit.asm`.** The prose says its pad "is now the `nanosleep` argument". The solution makes no `nanosleep` call. Placeholder.

9. **Units in `19` explanation.** The prose says "A `timespec` difference is nanoseconds ... Convert first — nanoseconds divided by 1000000", but the listing and the drill convert **microseconds** with `/1000`. Both conversions are correct for their own units, but the paragraph mixes them.

10. **Canonical mode remark.** "These drills receive one line per Enter press" is stated but not noted in file headers. In canonical mode, `poll` reports fd 0 readable only after a full line.

11. **Placeholder drills.** Many drills in L15 are `mov rdi, N` constants. Prose must accurately describe them as placeholders, not real implementations.

## Lesson 16 — Sprites, Tilemaps, Collision

1. **`07-clip-w.asm` exit mismatch.** The lesson prints a full clip listing (x = 6, width 8, view 10) and says the file exits **4**. The solution is `mov rdi, 2` and exits **2**. The lesson's listing is correct (would exit 4).

2. **`11-sprite-layer.asm` exit mismatch.** The lesson says the file builds `layer * 1000 + y` with layer 0, y 42, and exits **42**. The solution is `mov rdi,2` and exits **2**.

3. **AABB drills are constants.** The lesson says `02-aabb-overlap.asm` "compares all four edges", that `03-aabb-reject.asm` "runs the same four compares", that `08-from-scratch-point-in-rect.asm` "passes all four compares", and that `19-debug-aabb-y.asm` "retests x and never reads y". In fact, the solutions are `mov rdi,N` constants. None compares anything. Placeholder drills.

4. **`15-camera-cull.asm`.** Implements only the one-sided test that the lesson calls a bug (no left-edge check, no sprite width), and it uses a camera of 50 that the prose does not mention.

5. **Clip listing on fully off-left sprite.** For x = -10 and width 8, `add rbx, rax` makes the width -2. The prose says to cull when width is zero or negative, but the listing itself does not test for that. Fine as written, as long as the cull is described as a separate step.

6. **Placeholder drills.** Many drills in L16 are `mov rdi, N` constants. Prose must accurately describe them as placeholders.

## Lesson 17 — Entities, Pathfinding, UI

1. **Search drills are constants.** `02-bfs-dist.asm` (`mov rdi,1`), `12-bfs-queue.asm` (`mov rdi,5`), `14-path-reconstruct.asm` (`mov rdi,4`), and `19-debug-parent-index.asm` (`mov rdi,2`) contain no queue, `visited`, or `parent[]`. The prose claims they run full loops. Placeholder drills.

2. **`02-bfs-queue.asm` does not exist.** The prose refers to `02-bfs-queue.asm` as "the head/tail FIFO". **Fix: Likely typo for `12-bfs-queue.asm`.**

3. **`10-despawn-freelist.asm`.** The prose says it "stores 3 at the free-list top and bumps the top". The solution does `mov qword [free_top],3` and exits it. There is no array and no bump. Placeholder.

4. **UI drills are constants.** `04-ui-hit.asm`, `07-panel-draw-stub.asm`, and `15-ui-button-press.asm` are `mov rdi,N`. The prose describes four compares, drawing into a pixel buffer, and a pressed bit. Placeholders.

5. **Entity-update listing** (xs/vxs/alive, checksum 4) is marked UNVERIFIED and is not attached to any drill.

6. **BFS admissibility.** "First time the goal is dequeued the path is a shortest one" is correct for unweighted 4-neighbor grid. The lesson then says A* "expands tiles in order of `f`", but gives no admissibility condition. Manhattan distance is admissible for 4-neighbor movement with unit cost.

7. **Editorial notes.** The lesson contains notes addressed to a rewriter ("The rewrite must attach this listing to a drill file ...", "The rewrite must make the drill files actually implement what this prose promises"). **Fix: Remove editorial notes from learner text.**

8. **Placeholder drills.** Many drills in L17 are `mov rdi, N` constants. Prose must accurately describe them as placeholders.

## Lesson 18 — Capstone: Mini Park

1. **`13-peep-pathfind-step.asm` exit mismatch.** The lesson says agent at tile 5 with `parent[5] = 2` moves to 2 and exits **2**. The solution stores the constant 4 in `steps` and exits **4**.

2. **`12-track-connect.asm`.** The lesson says "It compares; the old constant did not". The solution is `mov rdi,1`. Still a constant.

3. **`02-place-track.asm`** is `mov rdi, 3`. The lesson says it "stores the type byte and exits the type". Nothing is stored. Placeholder.

4. **`17-save-header.asm`** is `mov rdi,8`. The lesson says it "is the first `write`: it exits the byte count, 8". No `write` is performed. Placeholder.

5. **`18-load-version-check.asm`** checks `ver dq 1` (a qword) with `cmp qword`. The save format defines the version as a **dword**. Compared against a real 8-byte header, a qword compare at offset 4 would read 4 bytes past the header. Does not read a header from file.

6. **`24-from-scratch-sim-integrate.asm`.** Said to "step the agent along the parent walk". The solution does `inc qword [peep_x]`. There is no parent walk. Placeholder.

7. **`16-econ-upkeep.asm`** has no guard. The lesson's phrase "Subtract after you know the qword is not still zero" is insufficient. The test must be against the upkeep amount, not zero.

8. **Save listing contiguity.** The save listing writes 8 bytes starting at `hdr` and relies on `ver dd 1` being placed immediately after `hdr db "PK01"` in `.data`. Implicit assumption about NASM layout. An explicit `hdr db "PK01" / dd 1` with `HLEN equ $ - hdr` would be more robust.

9. **`19-debug-map-bounds.asm`** clamps only the upper bound. Objective 1 says "clamp every map index to the map bounds", and that includes negatives. Uses signed `jl`, so -1 passes as "less than width" and becomes `[map-1]`.

10. **Placeholder drills.** Many drills in L18 are `mov rdi, N` constants. Prose must accurately describe them as placeholders.
