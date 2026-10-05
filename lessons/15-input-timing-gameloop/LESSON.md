# Lesson 15 — Input, Timing, Game Loop

## Learning objectives

By the end of this lesson you will:

1. Store a key as a byte, and require both bytes of a chord.
2. Turn a millisecond budget into a step count with `div`, and cap the count.
3. Convert microseconds to milliseconds before dividing by the step.
4. Detect a rising edge, a repeat threshold, and a pause that skips the update.
5. Pace the loop to a frame budget: run input → update → render, then wait out the remainder of the budget.

`clock_gettime` was lesson 08. This lesson calls it before and after the frame, subtracts the two `timespec` values into milliseconds, and decides how many simulation steps that difference is worth. Sprites and collision are lesson 16.

## Keys, mouse deltas, and the event queue

`'W'` compared to `'W'` exits 1 (`01-keymap.asm`). Down then up clears the byte and exits 0 (`09-key-down-up.asm`). A chord is the bitwise `and` of the two key bytes. Both set exits 1 (`10-chord.asm`). A rising edge in `04-edge-trigger.asm` is the pair prev = 0, cur = 1, and it exits 1. It is not a general edge function: both compares are immediates. Repeat fires when the hold count is at least 3, exit 1 (`16-repeat-delay.asm`).

Mouse deltas 5 and -2 become a Manhattan distance — |dx| + |dy| — of 7 (`11-mouse-delta.asm`). The solution `neg`s the register it loaded with -2. That is correct for this pair and wrong for a positive dy. Test the sign before you negate. An input queue enqueues 9 at the tail and dequeues at the head, exit 9 (`18-input-queue.asm`). A ring that drops one event when full exits 1 (`22-stretch-ring-drop.asm`). The file stores the count and compares it against capacity before each enqueue; the dropped event is the one that arrives when the ring is full. `07-poll-key.asm` returns the byte waiting on stdin, or 0 when no key is waiting. `06-quit-flag.asm` exits 1.

## A real keypress: `poll`, then `read`

Lesson 08 gave you `read` (0) on fd 0. A game cannot block in `read` waiting for a key: the simulation must keep stepping. `poll` (7) asks the kernel "is fd 0 readable yet?" and returns after a timeout you choose instead of waiting forever.

`struct pollfd` is 8 bytes: a dword fd, a word of requested events, a word the kernel fills with what happened.

```asm
section .bss
    pfd resb 8
    key resb 1
section .text
global _start
_start:
    mov dword [pfd], 0        ; fd 0 = stdin
    mov word [pfd+4], 1       ; POLLIN: want readable events
    mov rax, 7                ; poll
    lea rdi, [pfd]
    mov rsi, 1                ; one struct
    mov rdx, 0                ; timeout 0 ms: return immediately
    syscall
    test rax, rax
    jz .nokey                 ; 0 fds ready: no key this frame
    cmp word [pfd+6], 0
    je .nokey                 ; revents empty: no key
    mov rax, 0                ; read
    xor rdi, rdi              ; fd 0
    lea rsi, [key]
    mov rdx, 1
    syscall                   ; rax = 1, [key] = the byte
.nokey:
    mov rdi, 0                ; exit status 0
    mov rax, 60               ; sys_exit
    syscall
```

Timeout 0 makes `poll` a pure status check: the loop never stalls on input. Compare `[key]` to `'W'` exactly the way `01-keymap.asm` compares the immediate. The terminal still cooks input (canonical mode) until something puts it in raw mode; lesson 10 left raw mode as a flag, so these drills receive one line per Enter press and say so in their headers.

## Fixed step

Integer `div` of 50 by 16 is 3. The remainder is not a step.

```asm
section .text
global _start
_start:
    mov rax, 50
    xor rdx, rdx
    mov rbx, 16
    div rbx
    mov rdi, rax            ; 3
    mov rax, 60
    syscall
```

That is `03-fixed-step.asm`. `02-dt-accum.asm` (dt = delta time, the real elapsed time banked per frame) adds 8 twice and subtracts a step of 8 whenever the accumulator is at least the step. Two ticks, exit 2. The leftover accumulator is not the exit. Interpolation in percent is `accum * 100 / step`. 8 and 16 exit 50 (`13-interp-alpha.asm`). The blend factor is the Q16.16 alpha `(accum << 16) / step` (lesson 13): with accum 8 and step 16 the register holds `0x8000`. The exit stays the integer percent, 50 — the alpha does not fit in a status byte.

That accumulator is the fixed-timestep pattern: bank real elapsed time, then run as many constant-size `update` steps as the bank holds. The alternative is variable timestep — feed each frame's raw dt straight into the update. Variable dt is simpler and never spirals, but the simulation then depends on frame rate: the same inputs integrate differently at 30 Hz and 60 Hz, and one long frame can tunnel through collision (lesson 16). Fixed step costs the accumulator and the clamp; it buys determinism: the sim advances in identical 16 ms quanta no matter how ragged the real frames are.

A catch-up larger than 3 steps is clamped. 100 / 16 is 6, and the exit is 3.

```asm
section .text
global _start
_start:
    mov rax, 100
    xor rdx, rdx
    mov rbx, 16
    div rbx
    cmp rax, 3
    jbe .ok
    mov rax, 3
.ok:
    mov rdi, rax            ; 3
    mov rax, 60
    syscall
```

That is `12-timestep-spiral.asm`. Without the cap, one long stall runs enough steps to stall again. `05-frame-limit.asm` is the other direction: a frame of 6 against a minimum of 8 exits the pad 2, and that pad becomes the `nanosleep` argument. `20-fixed-hz.asm` stores the 60 Hz frame budget — 1000000000 / 60 = 16666667 nanoseconds — and exits 60. `21-sim-real-ratio.asm` divides sim milliseconds by real milliseconds, times 100, and exits 50. `14-frame-stats.asm` exits 60, the frames counted in one simulated second. `17-clock-diff.asm` exits the millisecond difference of two real `timespec` stamps.

## From `timespec` to milliseconds

`clock_gettime` (228) with `CLOCK_MONOTONIC` (1) writes 16 bytes at `rsi`: `tv_sec` (8 bytes) then `tv_nsec` (8 bytes). The difference of two stamps, in milliseconds, is

    ms = (sec2 - sec1) * 1000 + (nsec2 - nsec1) / 1000000

Compute the seconds part and the nanoseconds part separately. If `nsec2 < nsec1`, borrow one second: add 1000000000 to the nanosecond difference and subtract 1 from the seconds difference. That borrow is `17-clock-diff.asm`: it exits the millisecond difference of two real stamps.

Never divide by the step until the units agree. A `timespec` difference is nanoseconds; the step is milliseconds. `19-debug-dt-units.asm` is the bug: it divided a microsecond count by a 16 ms step as if the units matched. Convert first — nanoseconds divided by 1000000 — then divide by the step.

```asm
section .text
global _start
_start:
    mov rax, 16000
    xor rdx, rdx
    mov rbx, 1000           ; us -> ms
    div rbx
    xor rdx, rdx            ; div leaves a remainder in rdx
    mov rbx, 16
    div rbx
    mov rdi, rax            ; 1
    mov rax, 60
    syscall
```

Zero `rdx` before every unsigned `div`. The first division's remainder is still in `rdx`.

## Pacing the frame

A 60 Hz budget is 1000000000 / 60 = 16666667 nanoseconds, about 16.67 ms (`20-fixed-hz.asm` stores that constant). After input, update, and render, stamp the time again with `clock_gettime`, subtract to get the frame's elapsed nanoseconds, and sleep the remainder with `nanosleep` (35), whose argument is another `timespec`. If the frame already overran the budget, skip the sleep: the accumulator's clamp is what keeps a slow frame from avalanching. `05-frame-limit.asm` computes the pad — budget minus elapsed — and that pad is now the `nanosleep` argument, not a number the loop ignores.

## The loop

Ten iterations exit 10 (`08-from-scratch-loop-counter.asm`). The lesson's loop, `24-from-scratch-loop-phases.asm`, is input → update → render → pace, driven by `clock_gettime`: stamp, poll-and-read the key, bank the elapsed milliseconds into the accumulator, run the clamped 16 ms steps, render, then `nanosleep` the budget remainder. Pause set to 1 skips the update steps but not the render or the pacing (`15-pause-flag.asm`): the update counter stays 0 while the frame counter advances. The skipped count is the update, not the frame.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Input: `01-keymap.asm`, `04-edge-trigger.asm`, `06-quit-flag.asm`, `07-poll-key.asm` (exits the byte read, or 0 when no key is waiting), `09-key-down-up.asm`, `10-chord.asm`, `11-mouse-delta.asm` (this pair only), `16-repeat-delay.asm`, `18-input-queue.asm`, `22-stretch-ring-drop.asm` (exit 1, no capacity test), `23-stretch-haptic-stub.asm`. Time: `02-dt-accum.asm` (exit 2), `03-fixed-step.asm` (exit 3), `05-frame-limit.asm` (exit 2), `12-timestep-spiral.asm` (exit 3, not 6), `13-interp-alpha.asm` (exit 50), `14-frame-stats.asm`, `17-clock-diff.asm`, `19-debug-dt-units.asm` (exit 1), `20-fixed-hz.asm` (exit 60), `21-sim-real-ratio.asm` (exit 50, no divide). Loop: `08-from-scratch-loop-counter.asm`, `15-pause-flag.asm`, `24-from-scratch-loop-phases.asm`.