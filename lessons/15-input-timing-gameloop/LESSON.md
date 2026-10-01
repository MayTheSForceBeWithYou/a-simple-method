# Lesson 15 — Input, Timing, Game Loop

## Learning objectives

1. Store a key as a byte, and require both bytes of a chord.
2. Turn a millisecond budget into a step count with `div`, and cap the count.
3. Convert microseconds to milliseconds before dividing by the step.
4. Detect a rising edge, a repeat threshold, and a pause that skips the update.
5. Run input, update, and render as a counted phase, not as a sleep.

`clock_gettime` was lesson 08. This lesson subtracts timestamps you already have and decides how many simulation steps that difference is worth. Sprites and collision are lesson 16. No drill reads `/dev/input`.

## Keys and the pointer

`'W'` compared to `'W'` exits 1 (`01-keymap.asm`). Down then up clears the byte and exits 0 (`09-key-down-up.asm`). A chord is the bitwise `and` of the two key bytes. Both set exits 1 (`10-chord.asm`). A rising edge in `04-edge-trigger.asm` is the pair prev = 0, cur = 1, and it exits 1. It is not a general edge function: both compares are immediates. Repeat fires when the hold count is at least 3, exit 1 (`16-repeat-delay.asm`).

Mouse deltas 5 and -2 become a Manhattan distance of 7 (`11-mouse-delta.asm`). The solution `neg`s the register it loaded with -2. That is correct for this pair and wrong for a positive dy. Test the sign before you negate. An input queue enqueues 9 at the tail and dequeues at the head, exit 9 (`18-input-queue.asm`). A full ring that drops one event exits 1 (`22-stretch-ring-drop.asm`). The file stores the count. It does not test capacity. `07-poll-stub.asm` exits 0 with no event. `06-quit-flag.asm` exits 1. `23-stretch-haptic-stub.asm` exits 2. None of them call `poll` or `read`.

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

That is `03-fixed-step.asm`. `02-dt-accum.asm` adds 8 twice and subtracts a step of 8 whenever the accumulator is at least the step. Two ticks, exit 2. The leftover accumulator is not the exit. Interpolation in percent is `accum * 100 / step`. 8 and 16 exit 50 (`13-interp-alpha.asm`). The prompt also mentions a Q16 alpha. The solution does not build one.

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

That is `12-timestep-spiral.asm`. Without the cap, one long stall runs enough steps to stall again. `05-frame-limit.asm` is the other direction: a frame of 6 against a minimum of 8 exits the pad 2. `20-fixed-hz.asm` exits 60. It does not store 16666667 nanoseconds. `21-sim-real-ratio.asm` exits 50. It does not divide sim time by real time. `14-frame-stats.asm` exits 60. `17-clock-diff.asm` subtracts 60 from 100 and exits 40.

## Units

`19-debug-dt-units.asm` divides 16000 by 16 and masks 255. That treats a microsecond count as if the step were 16 microseconds, and the status is not 1. Convert to milliseconds first. 16000 / 1000 is 16, and 16 / 16 is one step.

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

## The loop

Ten iterations exit 10 (`08-from-scratch-loop-counter.asm`). Two frames of three phases, input then update then render, add 3 twice and exit 6 (`24-from-scratch-loop-phases.asm`). Pause set to 1 skips the increment. The update counter stays 0 (`15-pause-flag.asm`). Draw can still run. The skipped count is the update, not the frame.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Input: `01-keymap.asm`, `04-edge-trigger.asm`, `06-quit-flag.asm`, `07-poll-stub.asm`, `09-key-down-up.asm`, `10-chord.asm`, `11-mouse-delta.asm` (this pair only), `16-repeat-delay.asm`, `18-input-queue.asm`, `22-stretch-ring-drop.asm` (exit 1, no capacity test), `23-stretch-haptic-stub.asm`. Time: `02-dt-accum.asm` (exit 2), `03-fixed-step.asm` (exit 3), `05-frame-limit.asm` (exit 2), `12-timestep-spiral.asm` (exit 3, not 6), `13-interp-alpha.asm` (exit 50), `14-frame-stats.asm`, `17-clock-diff.asm`, `19-debug-dt-units.asm` (exit 1), `20-fixed-hz.asm` (exit 60), `21-sim-real-ratio.asm` (exit 50, no divide). Loop: `08-from-scratch-loop-counter.asm`, `15-pause-flag.asm`, `24-from-scratch-loop-phases.asm`.