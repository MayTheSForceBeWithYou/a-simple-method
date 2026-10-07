# Lesson 03 — Control Flow

Arithmetic and data movement are computation, but control flow is decision. This lesson teaches you to compare values and branch based on the result, turning linear sequences of instructions into programs that adapt to their inputs. You will use conditional jumps (`je`, `jne`, `jl`, `jg`, `jb`, `ja`) to implement if/else, while loops, for loops, and early exits, and understand the critical distinction between signed and unsigned comparisons. You will also see how jump tables let you dispatch to many cases efficiently, and debug the two most common control-flow bugs: off-by-one loop bounds and inverted conditions.

## What this lesson asks of you

You must be able to use `cmp` or `test` followed by a conditional jump instruction to branch based on register values. You will implement if/else structures, counted loops (for and while), and early loop exits using labels and jumps. You will distinguish signed conditional jumps (`jl`, `jg`, `jle`, `jge`) from unsigned conditional jumps (`jb`, `ja`, `jbe`, `jae`) and choose the correct one for your data type. You will also build a simple jump table to dispatch to different code paths based on an index, which is the foundation for switch statements and function-pointer tables. By the end, you should trace a loop to confirm it runs the correct number of times, and recognize the symptoms of an inverted condition (entering the "then" branch when you meant "else").

## Conditional jumps: branching on flags

A **conditional jump** instruction checks one or more flags in RFLAGS and jumps to a label if the condition is true, or falls through to the next instruction if false. You typically set up the flags with `cmp` or `test`, then immediately jump based on the result.

### Basic conditional jumps

| Instruction | Condition | Typical use |
|-------------|-----------|-------------|
| `je` / `jz` | `ZF=1` | Jump if equal / zero |
| `jne` / `jnz` | `ZF=0` | Jump if not equal / not zero |
| `jl` / `jnge` | Signed `<` | Jump if less (signed) |
| `jg` / `jnle` | Signed `>` | Jump if greater (signed) |
| `jle` / `jng` | Signed `<=` | Jump if less or equal (signed) |
| `jge` / `jnl` | Signed `>=` | Jump if greater or equal (signed) |
| `jb` / `jnae` | Unsigned `<` | Jump if below (unsigned) |
| `ja` / `jnbe` | Unsigned `>` | Jump if above (unsigned) |
| `jbe` / `jna` | Unsigned `<=` | Jump if below or equal (unsigned) |
| `jae` / `jnb` | Unsigned `>=` | Jump if above or equal (unsigned) |

The mnemonics use "less" and "greater" for signed comparisons, and "below" and "above" for unsigned comparisons. This naming helps you remember which to use: if your data is signed integers, use `jl`/`jg`; if your data is unsigned integers or addresses, use `jb`/`ja`.

Here is a basic comparison and branch:

```asm
cmp rax, rbx
je  .equal            ; jump if rax == rbx
jl  .less             ; jump if rax < rbx (signed)
; fall through: rax >= rbx (signed)
```

The `jmp` instruction is an **unconditional jump** — it always jumps, regardless of flags. Use it to skip code or loop back.

### The idiomatic zero check

To check if a register is zero, the idiomatic form is `test reg, reg` followed by `jz`:

```asm
test rdi, rdi
jz   .is_zero
; rdi is nonzero
```

This is equivalent to `cmp rdi, 0` but shorter and faster (because `test rdi, rdi` is `rdi & rdi`, which is zero exactly when `rdi` is zero).

## Structured control flow patterns

Assembly does not have `if`, `while`, or `for` keywords, but you implement them with labels and jumps. The patterns below are idiomatic translations.

### if/else

```asm
    cmp rax, 0
    jge .else          ; if rax < 0 (signed), continue; else jump
    ; then branch: rax is negative
    ; ...
    jmp .end           ; skip else branch
.else:
    ; else branch: rax is non-negative
    ; ...
.end:
```

If you only need an `if` without `else`, omit the `.else` label and jump directly to `.end` when the condition is false:

```asm
    test rdi, rdi
    jz .end            ; skip the body if rdi is zero
    ; if body: rdi is nonzero
    ; ...
.end:
```

### while loop

```asm
.loop:
    cmp rcx, 0         ; check loop condition
    jle .done          ; exit if rcx <= 0
    ; loop body
    ; ...
    dec rcx            ; update loop variable
    jmp .loop          ; repeat
.done:
```

The condition is checked at the top (a "while" loop in C terms). If the condition is false initially, the body never runs.

### for loop (counted iteration)

A counted loop from 0 to n-1:

```asm
    xor rcx, rcx       ; rcx = 0 (loop counter)
.for:
    cmp rcx, n         ; compare counter to limit
    jge .endfor        ; exit if rcx >= n
    ; loop body (rcx is the index)
    ; ...
    inc rcx            ; increment counter
    jmp .for           ; repeat
.endfor:
```

This runs exactly `n` times (assuming `n > 0`). If you write `jg` instead of `jge`, the loop runs `n+1` times (an off-by-one error). If you write `jle`, the loop only checks whether the counter has passed the limit and may loop forever if `n` is large.

### Early exit (break)

To exit a loop early, jump directly to the `.done` or `.endfor` label:

```asm
.loop:
    cmp rcx, 0
    jle .done
    ; ...
    test rax, rax      ; check some condition
    jz .done           ; break if rax is zero
    ; ...
    dec rcx
    jmp .loop
.done:
```

### Early continue (skip to next iteration)

To skip the rest of the loop body and start the next iteration, jump back to the top of the loop (after updating the loop variable if necessary):

```asm
.loop:
    cmp rcx, 0
    jle .done
    test rax, rax
    jz .skip           ; skip rest of body if rax is zero
    ; main body
    ; ...
.skip:
    dec rcx
    jmp .loop
.done:
```

## Jump tables: dispatching by index

A **jump table** is an array of addresses. You load an address from the table and jump to it, allowing you to dispatch to different code paths based on an index. This is the low-level mechanism for switch statements with dense cases.

```asm
section .rodata
    jump_table dq .case0, .case1, .case2

section .text
    ; assume rax holds the case index (0, 1, or 2)
    ; bounds check: if rax >= 3, jump to default or error
    cmp rax, 3
    jae .default

    ; dispatch: load address from table and jump
    jmp [jump_table + rax*8]

.case0:
    ; handle case 0
    jmp .end
.case1:
    ; handle case 1
    jmp .end
.case2:
    ; handle case 2
    jmp .end
.default:
    ; handle out-of-range
.end:
```

The key line is `jmp [jump_table + rax*8]`, which loads the quadword at `jump_table + rax*8` (the address of the case) and jumps to it. This is one indirect jump instead of a chain of comparisons and branches, which is faster when you have many cases.

**Bounds check is mandatory** — if `rax` is out of range, you will load a random address and crash or jump into the middle of unrelated code. Always check `rax` against the table size before dispatching.

## Worked example: counting even numbers in a range

Let's write a program that counts how many even numbers exist in the range `[10, 50)` (10 inclusive, 50 exclusive). We will loop from 10 to 49, test each number's low bit, and increment a counter if the bit is clear (even). Here is the source:

```asm
section .text
    global _start
_start:
    xor rax, rax       ; rax = counter (starts at 0)
    mov rcx, 10        ; rcx = loop variable (starts at 10)

.loop:
    cmp rcx, 50        ; compare rcx to upper bound
    jge .done          ; exit if rcx >= 50

    test rcx, 1        ; check low bit (1 means odd, 0 means even)
    jnz .skip          ; if odd (ZF=0), skip increment

    inc rax            ; even: increment counter
.skip:
    inc rcx            ; move to next number
    jmp .loop          ; repeat

.done:
    mov rdi, rax       ; exit with count as status
    mov rax, 60
    syscall
```

Build and run:
```bash
nasm -f elf64 count_even.asm -o count_even.o
ld count_even.o -o count_even
./count_even
echo $?   # should print 20 (there are 20 even numbers in [10,50))
```

Trace the reasoning. We initialize `rax` (the counter) to 0 and `rcx` (the loop variable) to 10. At the top of the loop, we compare `rcx` to 50. If `rcx >= 50`, we exit. Otherwise, we test the low bit of `rcx` with `test rcx, 1`. If the low bit is 1 (odd), ZF is cleared, and `jnz .skip` jumps over the `inc rax` line. If the low bit is 0 (even), ZF is set, `jnz` falls through, and we increment the counter. Then we increment `rcx` and loop.

The loop runs 40 times (from 10 to 49 inclusive). Half of those numbers are even (10, 12, 14, ..., 48), so `rax` ends up at 20. We exit with 20 as the status.

### A plausible wrong reading (and why it fails)

A common mistake is to write `jg .done` instead of `jge .done` at the loop condition. This changes the exit test from `rcx >= 50` to `rcx > 50`. With this change, the loop continues when `rcx == 50`, processes 50 (which is even), increments the counter to 21, then increments `rcx` to 51, compares again, and exits. The result is 21 instead of 20 — an **off-by-one error**.

The distinction between `jge` (jump if greater or equal) and `jg` (jump if strictly greater) is one instruction, but it changes the loop bounds by one iteration. When you write a loop like `for (i = start; i < end; i++)` in C, the assembly translation is `cmp i, end` followed by `jge .done` (exit if `i >= end`). If you use `jg`, you are writing `i <= end`, which includes the endpoint. Off-by-one errors are the most common loop bug in assembly; always trace the boundary values (`rcx = 49` and `rcx = 50`) to confirm your condition is correct.

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| `jl` vs `jb` | `jl` (jump if less) is for signed comparison; `jb` (jump if below) is for unsigned. For example, `-1` is less than `0` in signed arithmetic, but greater than `0` in unsigned (because `-1` as unsigned is `0xFFFFFFFFFFFFFFFF`, the maximum value). Use `jl`/`jg` for signed data, `jb`/`ja` for unsigned data. |
| `je` vs `jz` | They are synonyms — both check `ZF=1` and jump if true. `je` reads as "jump if equal" (after `cmp`); `jz` reads as "jump if zero" (after `test`). Use whichever is clearer in context. |
| `jge` vs `jg` | `jge` includes equality (`>=`); `jg` does not (`>`). The difference is one case at the boundary, but it shifts loop bounds by one. For `for (i = 0; i < n; i++)`, use `jge .done` after `cmp i, n`. For `while (i <= n)`, use `jg .done`. |
| `cmp a, b` then `jl` vs `jg` | After `cmp a, b`, `jl` jumps if `a < b`, and `jg` jumps if `a > b`. The operands to `cmp` matter — reversing them inverts the comparison. `cmp a, b; jl` is `a < b`, but `cmp b, a; jl` is `b < a` (equivalent to `a > b`). |
| `test rax, rax` vs `cmp rax, 0` | Both set ZF if `rax` is zero, but `test` is shorter and faster. `test` also clears CF and OF, which can be useful. Prefer `test` for zero checks. |
| Jump table vs chain of `cmp`/`je` | A jump table dispatches in one indirect jump; a chain of comparisons takes O(n) comparisons. For dense cases (0, 1, 2, ...), use a jump table. For sparse cases or non-integer keys, use comparisons. |
| Forgetting the bounds check in a jump table | If the index is out of range, `jmp [table + rax*8]` loads a garbage address and crashes. Always check `cmp rax, table_size` and jump to a default case if out of range. |

## Check yourself

1. Write the assembly for `if (x > 10) { ... } else { ... }` where `x` is in `rax` and the comparison is signed. Which jump instruction do you use after `cmp rax, 10`, and to which label?
2. You write a loop `for (i = 0; i < 100; i++)` using `rcx` as the counter. What is the correct condition after `cmp rcx, 100` — `jge .done`, `jg .done`, `jle .done`, or `jl .done`? How many times does the loop run if you use each?
3. Trace the worked example above with `rcx` starting at 48 instead of 10. How many iterations does the loop run, and what is the final value of `rax`?
4. After `test rdi, 1`, what does `jz` check? If `rdi` is 5, does `jz` jump or fall through?
5. A jump table has 4 entries (indices 0–3). You receive an index in `rax`. Write the bounds check and the dispatch line.

## Key takeaways

- Conditional jumps check flags set by `cmp` or `test` and branch if the condition is true; use signed jumps (`jl`, `jg`) for signed data and unsigned jumps (`jb`, `ja`) for unsigned data.
- Structured patterns (if/else, while, for) are implemented with labels and jumps — check the condition, jump to skip or exit, and jump back to loop.
- The idiomatic zero check is `test reg, reg` followed by `jz` (jump if zero) or `jnz` (jump if nonzero) — shorter than `cmp reg, 0`.
- Off-by-one errors come from using `jg` instead of `jge` (or vice versa) at loop boundaries; always trace the boundary cases to confirm the loop runs the correct number of times.
- Jump tables dispatch by loading an address from an array and jumping to it; they are faster than chains of comparisons for dense cases, but require a bounds check to prevent crashes.
- Inverted conditions (using `jge` when you meant `jl`) cause the opposite branch to execute; the symptom is entering the "then" branch when the condition is false.

## Lookup

- **Conditional jump instructions:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2, Appendix B (Jcc — conditional jumps)
- **FLAGS semantics:** Volume 1, Chapter 3.4 (RFLAGS register)
- **NASM label syntax:** NASM manual, Chapter 3.1 (labels, local labels with `.` prefix)
- **Control flow patterns:** Any x86-64 assembly textbook or reference (if/else, while, for idioms)

## Exercises

30 drills: branches, loops, sums, search, bug hunts, AoC-style counting, jump table.
