# 15 — Input, Timing, Game Loop

Lesson 14 gave you pixels. This lesson gives you **time** and **input**: reading keypresses without blocking, measuring elapsed time with `clock_gettime`, banking frame time into an accumulator, running fixed-timestep updates, and pacing the loop with `nanosleep` so the game runs at a steady frame rate. By the end you'll understand the classic fixed-timestep game loop: **input → update(fixed dt) → render → wait**, and you'll see why dividing microseconds by milliseconds crashes (`div` needs matching units and a zero `rdx`).

## What this lesson asks of you

- Store key states as bytes, detect chords (two keys pressed simultaneously), and recognize rising edges (key down this frame, up last frame).
- Convert frame delta-time into a step count by dividing elapsed milliseconds by the step size, and **clamp** the step count to prevent spiral-of-death.
- Convert `timespec` (seconds + nanoseconds) into milliseconds, handling nanosecond borrow when the difference wraps.
- Detect a rising edge for one-shot actions, a repeat threshold for held keys, and a pause flag that skips updates but not rendering.
- Pace the loop to a frame budget: run input → fixed-step updates → render, then sleep the remaining budget with `nanosleep`.

## Why a game loop for the park sim milestone

Lesson 18's park simulation needs:
- **Input:** arrow keys for camera, mouse for UI.
- **Fixed timestep:** The economy ticks in constant 16 ms steps, so the simulation is deterministic and reproducible.
- **Frame pacing:** Cap at 60 FPS so the game doesn't burn CPU.

The drills below isolate each primitive. You'll compose them into a full game loop for the capstone.

## Keys: bytes, chords, and edges

### Key state as a byte

Store each key as a byte: 0 = up, 1 = down.

**Drill:** `01-keymap.asm` compares `key_w` to the constant `'W'` (65) and exits 1 (pressed).

**Drill:** `09-key-down-up.asm` sets a key byte to 1 (down), then 0 (up), exits 0.

### Chord: two keys simultaneously

A **chord** requires both keys to be pressed. Test with bitwise AND:

```asm
mov al, [key_shift]
and al, [key_a]
jz .no_chord
; both keys are down
```

**Drill:** `10-chord.asm` tests two key bytes (both 1), exits 1 (chord detected).

### Rising edge: key just pressed this frame

A **rising edge** (also called a "press" or "one-shot") triggers only on the frame the key transitioned from up to down:

```asm
; rising_edge = (prev == 0 && cur == 1)
cmp byte [prev], 0
jne .no_edge
cmp byte [cur], 1
jne .no_edge
; rising edge detected
```

**Drill:** `04-edge-trigger.asm` tests `prev = 0, cur = 1`, exits 1.

**Note:** This drill hardcodes the comparisons against 0 and 1. A general edge function would load the bytes first.

### Repeat delay

A held key can **repeat** (fire again) after a threshold. Track a hold counter:

```asm
.update:
    cmp byte [key], 1
    jne .not_held
    inc qword [hold_count]
    cmp qword [hold_count], 3
    jl .not_held
    ; fire repeat
    ; reset hold_count or keep incrementing
.not_held:
```

**Drill:** `16-repeat-delay.asm` fires when `hold_count >= 3`, exits 1.

### Mouse delta

Mouse motion is a delta `(dx, dy)` since the last frame. **Manhattan distance** is `|dx| + |dy|`:

```asm
; dx = 5, dy = -2
mov rax, 5
mov rbx, -2
; absolute value of rbx
test rbx, rbx
jns .pos
neg rbx
.pos:
add rax, rbx            ; 5 + 2 = 7
```

**Drill:** `11-mouse-delta.asm` computes `|5| + |-2|` and exits 7.

**Bug:** The solution does `mov rbx, -2` / `neg rbx` unconditionally, which works for this negative value but **fails for positive values** (e.g., `dy = 2` would become −2, giving `5 + (−2) = 3` instead of 7). The fix is to test the sign before negating.

### Input queue

Store incoming input events (keypresses, mouse clicks) in a ring buffer (lesson 11). Enqueue at `tail`, dequeue at `head`.

**Drill:** `18-input-queue.asm` enqueues 9 at the tail, dequeues at the head, exits 9.

**Drill:** `22-stretch-ring-drop.asm` — the lesson describes dropping an event when the ring is full by checking the count before enqueue. The **solution as shipped** stores the constant 1 into `dropped` and exits 1. No capacity test is performed (this is a placeholder).

## Non-blocking input: `poll` then `read`

Lesson 08's `read` blocks until input arrives. A game loop cannot block—the simulation must keep running. Use `poll` (syscall 7) to **check** if fd 0 (stdin) is readable without waiting.

### `struct pollfd`

8 bytes total:
- Offset 0: `fd` (dword, 4 bytes)
- Offset 4: `events` (word, 2 bytes) — what you want to know (e.g., `POLLIN` = 1, readable)
- Offset 6: `revents` (word, 2 bytes) — what the kernel reports

### Poll with timeout 0 (non-blocking)

```asm
section .bss
    pfd: resb 8
    key: resb 1

section .text
global _start
_start:
    mov dword [pfd], 0      ; fd 0 (stdin)
    mov word [pfd + 4], 1   ; POLLIN
    mov rax, 7              ; sys_poll
    lea rdi, [pfd]
    mov rsi, 1              ; 1 struct
    mov rdx, 0              ; timeout 0 ms (return immediately)
    syscall
    test rax, rax
    jz .no_key              ; 0 fds ready
    cmp word [pfd + 6], 0
    je .no_key              ; revents empty

    ; fd 0 is readable, read one byte
    mov rax, 0              ; sys_read
    xor rdi, rdi
    lea rsi, [key]
    mov rdx, 1
    syscall                 ; rax = 1, [key] = the byte

.no_key:
    xor rdi, rdi
    mov rax, 60
    syscall
```

**Drill:** The lesson refers to `07-poll-key.asm` that "returns the byte waiting on stdin, or 0 when no key is waiting." However, the repo contains **`07-poll-stub.asm`**, which only does `xor rdi, rdi` + `exit 0`. No `poll` or `read` is performed. This is a placeholder.

**Canonical mode caveat:** Without raw mode (lesson 10), the terminal buffers input line-by-line. `poll` reports fd 0 as readable only after Enter is pressed. For true per-keypress input, the full editor (lesson 10) or game must flip the terminal to raw mode with `termios` and `ioctl`.

## Fixed timestep: banking and spending frame time

### Delta time (dt) and the accumulator

**Delta time** (dt) is the elapsed time since the last frame. Store it in an **accumulator**. Whenever the accumulator holds at least one simulation **step** (e.g., 16 ms), subtract the step and run one `update`.

**Drill:** `02-dt-accum.asm` adds 8 ms twice (total 16 ms), subtracts a step of 8 ms twice, exits 2 (two steps run). The leftover accumulator (0 here) is used for interpolation, not the exit status.

### Steps from dt

Divide accumulated milliseconds by the step size:

```asm
; dt_accum = 50 ms, step = 16 ms
mov rax, 50
xor rdx, rdx
mov rbx, 16
div rbx                 ; rax = 3, rdx = 2 (remainder)
mov rdi, rax            ; 3 steps
```

**Drill:** `03-fixed-step.asm` computes `50 / 16` → 3, exits 3.

**Critical:** Zero `rdx` before **every** unsigned `div`. See the worked example below.

### Spiral-of-death clamp

If one frame takes 100 ms, a 16 ms step would run 6 updates. Those 6 updates might take another 100 ms, spiraling. **Clamp** the step count to a maximum (e.g., 3):

```asm
mov rax, 100
xor rdx, rdx
mov rbx, 16
div rbx                 ; rax = 6
cmp rax, 3
jbe .ok
mov rax, 3              ; clamp to 3
.ok:
```

**Drill:** `12-timestep-spiral.asm` clamps `100 / 16` → 6 down to 3, exits 3.

### Interpolation alpha

For smooth rendering, interpolate between the previous and current physics state using **alpha** = `accumulator / step` (the fraction of a step remaining).

**Percent:** `(accum * 100) / step`

**Drill:** `13-interp-alpha.asm` computes `(8 * 100) / 16` = 50, exits 50.

The drill also computes the **Q16.16 alpha** `(accum << 16) / step` → `0x8000` (register value), but that doesn't fit in an 8-bit exit status.

## `clock_gettime` and timespec arithmetic

Syscall 228 (`clock_gettime`) with `CLOCK_MONOTONIC` (1) writes 16 bytes to `rsi`:

- Offset 0: `tv_sec` (qword, 8 bytes)
- Offset 8: `tv_nsec` (qword, 8 bytes)

### Converting to milliseconds

```
ms = (sec2 - sec1) * 1000 + (nsec2 - nsec1) / 1000000
```

If `nsec2 < nsec1`, **borrow** one second:
1. Add `1000000000` to the nanosecond difference.
2. Subtract 1 from the seconds difference.

**Drill:** `17-clock-diff.asm` — the lesson describes exiting "the millisecond difference of two real `timespec` stamps" with borrow. The **solution as shipped** is `mov rax, 100` / `sub rax, 60` → 40, exits 40. No `clock_gettime`, no `timespec`, no borrow. This is a placeholder constant.

### Unit conversion before dividing by step

**Critical:** The step size is in milliseconds. If you have **nanoseconds** from a `timespec` difference, divide by `1000000` first. If you have **microseconds**, divide by `1000` first. **Never** divide raw nanoseconds or microseconds by a millisecond step—the units don't match.

**Drill:** `19-debug-dt-units.asm` demonstrates this bug: it divides a microsecond count (16000 µs) by a 16 ms step as if the units matched. The fix converts µs → ms first, then divides by the step:

```asm
mov rax, 16000          ; µs
xor rdx, rdx
mov rbx, 1000           ; µs → ms
div rbx                 ; rax = 16 ms
xor rdx, rdx            ; CRITICAL: zero rdx again
mov rbx, 16
div rbx                 ; rax = 1 step
```

The second `xor rdx, rdx` is **not redundant**—see the worked example below.

## Frame pacing: sleeping the budget remainder

A **60 Hz** frame budget is `1000000000 / 60` = 16666667 nanoseconds (≈ 16.67 ms).

**Drill:** `20-fixed-hz.asm` — the lesson describes storing that constant. The **solution as shipped** only does `mov rdi, 60` and exits 60. No storage, no nanoseconds. Placeholder constant.

After `input → update → render`, call `clock_gettime` again, compute elapsed nanoseconds, and sleep the remainder with `nanosleep` (syscall 35), passing a `timespec` with the pad.

**Drill:** `05-frame-limit.asm` computes `budget - elapsed` → pad = 2, exits 2. The lesson says "that pad becomes the `nanosleep` argument," but the drill does not call `nanosleep`. Placeholder math.

### The full game loop

**Drill:** `24-from-scratch-loop-phases.asm` — the lesson describes input → update → render → pace, driven by `clock_gettime`, `poll`/`read`, and `nanosleep`. The **solution as shipped** adds 3 to `rdi` twice and exits 6. No syscalls, no loop phases. Placeholder constant.

A real game loop (for the milestone):

```asm
.frame_loop:
    ; 1. Input: poll + read
    ; ...
    ; 2. Bank dt into accumulator
    ; rax = milliseconds since last frame
    add qword [accum], rax
    ; 3. Fixed-step updates
    xor rcx, rcx
.update_loop:
    cmp qword [accum], 16
    jl .render
    cmp rcx, 3              ; clamp
    jge .render
    sub qword [accum], 16
    ; call update_physics
    inc rcx
    jmp .update_loop
.render:
    ; call render_frame
    ; 4. Pace: sleep budget remainder
    ; ...
    jmp .frame_loop
```

## Pause flag

A **pause** flag skips `update` steps but **not** render or pacing:

**Drill:** `15-pause-flag.asm` — pause set to 1 skips `inc qword [updates]` but not `inc qword [frames]`. The drill exits 0 (the update counter). A paused game should still render and sleep, so a frame counter would still advance.

## Worked example: why `19-debug-dt-units.asm` needs the second `xor rdx, rdx`

**Task:** Convert 16000 µs to milliseconds, then divide by a 16 ms step to get step count.

**Code (fixed):**

```asm
mov rax, 16000
xor rdx, rdx
mov rbx, 1000
div rbx                 ; 16000 µs → 16 ms
xor rdx, rdx            ; CRITICAL
mov rbx, 16
div rbx                 ; 16 ms / 16 ms step = 1
```

**Plausible wrong reading:**

*"The second `xor rdx, rdx` is redundant. The first one already zeroed `rdx`, and nothing in between writes to it."*

**Why it's wrong:** `div rbx` **writes to `rdx`**. The unsigned `div` divides the 128-bit value `rdx:rax` by `rbx`, putting the **quotient** in `rax` and the **remainder** in `rdx`. Here, `16000 / 1000` has remainder 0, so the second `xor` happens to change nothing for this input. But for `16500 µs`:
- First `div`: `16500 / 1000` → quotient 16, **remainder 500** (in `rdx`).
- Without the second `xor`, the next `div` divides `(500 · 2⁶⁴ + 16) / 16`—a value far too large for 64 bits, causing a **divide error** (SIGFPE, exit status 136).

**The correct reading:** Every unsigned `div` needs `rdx` cleared **right before it**, regardless of what came earlier, because the previous `div` reuses `rdx` for its remainder. The lesson's rule is: **Zero `rdx` before every unsigned `div`.**

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| A chord is one key then another | A chord is **both keys simultaneously** (AND, not sequence) |
| Rising edge is `cur == 1` | Rising edge is `prev == 0 AND cur == 1` (transition, not just state) |
| `poll` blocks until a key | With timeout 0, `poll` returns **immediately** (non-blocking check) |
| `div` only reads `rax` | `div` divides `rdx:rax` (128 bits) and writes **both** `rax` (quotient) and `rdx` (remainder) |
| One `xor rdx, rdx` is enough for multiple `div`s | Each `div` writes `rdx`, so zero it **before every `div`** |
| Nanoseconds and milliseconds are interchangeable | **Convert units** (`ns / 1000000` or `µs / 1000`) before dividing by a millisecond step |
| Variable timestep is deterministic | Fixed timestep (constant dt per `update`) is deterministic; variable dt depends on frame rate |
| Pause stops everything | Pause skips **update** only; render and frame pacing still run |

## Check yourself

1. `02-dt-accum.asm` adds 8 twice, then loops `cmp rax, rbx` / `jl .done` / `sub rax, rbx` / `inc rdi`. What is in `rax` at exit, and why is that not the status?

2. `15-pause-flag.asm` exits 0. Which counter does the pause protect, and what should still advance on a paused frame?

3. `11-mouse-delta.asm` does `mov rbx, -2` / `neg rbx` unconditionally. Give a `dy` for which this code computes the wrong Manhattan distance, and state the fix.

4. You have two `timespec` stamps: `(sec1=100, nsec1=900000000)` and `(sec2=101, nsec2=100000000)`. Compute the millisecond difference. Does nanosecond borrow occur?

5. You `div rbx` to compute `16000 / 1000`, getting quotient 16 and remainder 0 in `rdx`. You forget to zero `rdx` before the next `div`. What does the CPU see as the dividend?

## Key takeaways

- Store key states as bytes; chords test both keys simultaneously (AND); rising edges test transition from 0 to 1.
- `poll` with timeout 0 is a non-blocking check for readable fds; follow with `read` if `revents` is set.
- Fixed timestep: bank delta-time into an accumulator, run constant-size `update` steps while `accum >= step`, clamp step count to prevent spiral.
- Convert `timespec` (seconds + nanoseconds) to milliseconds: `(sec * 1000) + (nsec / 1000000)`; handle borrow if `nsec2 < nsec1`.
- **Zero `rdx` before every unsigned `div`**; `div` writes the remainder to `rdx`, so previous `div`s corrupt the next dividend.
- Match units before dividing: convert nanoseconds or microseconds to milliseconds before dividing by a millisecond step.
- Pause skips `update` but not render or pacing; frame counter advances, update counter doesn't.

## Lookup

- `poll(2)`: [man poll(2)](https://man7.org/linux/man-pages/man2/poll.2.html)
- `clock_gettime(2)`: [man clock_gettime(2)](https://man7.org/linux/man-pages/man2/clock_gettime.2.html)
- `nanosleep(2)`: [man nanosleep(2)](https://man7.org/linux/man-pages/man2/nanosleep.2.html)
- Fixed timestep: [Gaffer On Games: Fix Your Timestep!](https://gafferongames.com/post/fix_your_timestep/)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Input:**
- `01-keymap.asm` — compare key to `'W'`, exit 1
- `04-edge-trigger.asm` — `prev=0, cur=1`, exit 1
- `06-quit-flag.asm` — exit 1
- `07-poll-stub.asm` — **placeholder: exits 0 (no poll/read)**
- `09-key-down-up.asm` — set 1 then 0, exit 0
- `10-chord.asm` — both keys down, exit 1
- `11-mouse-delta.asm` — `|5| + |-2|` = 7, exit 7 (bug: fails for positive dy)
- `16-repeat-delay.asm` — `hold_count >= 3`, exit 1
- `18-input-queue.asm` — enqueue 9, dequeue, exit 9
- `22-stretch-ring-drop.asm` — **placeholder: exits 1 (no capacity test)**
- `23-stretch-haptic-stub.asm` — placeholder

**Time:**
- `02-dt-accum.asm` — add 8 twice, 2 steps, exit 2
- `03-fixed-step.asm` — `50 / 16` = 3, exit 3
- `05-frame-limit.asm` — budget pad = 2, exit 2
- `12-timestep-spiral.asm` — clamp 6 to 3, exit 3
- `13-interp-alpha.asm` — `(8*100)/16` = 50, exit 50
- `14-frame-stats.asm` — exit 60
- `17-clock-diff.asm` — **placeholder: exits 40 (no timespec)**
- `19-debug-dt-units.asm` — fix: convert µs→ms first, exit 1
- `20-fixed-hz.asm` — **placeholder: exits 60 (no 16666667 ns)**
- `21-sim-real-ratio.asm` — **placeholder: exits 50 (no divide)**

**Loop:**
- `08-from-scratch-loop-counter.asm` — 10 iterations, exit 10
- `15-pause-flag.asm` — pause skips update, exit 0
- `24-from-scratch-loop-phases.asm` — **placeholder: exits 6 (no game loop)**
