# Lesson 03 — Control Flow

## Learning objectives

1. Use `jmp`, `je/jz`, `jne`, `jl`, `jg`, `jb`, `ja`, and signed/unsigned variants.
2. Implement if/else, while, for patterns.
3. Write counted loops and early exits.
4. Build a simple jump table.
5. Debug off-by-one and inverted conditions.

## Compare then branch

```asm
cmp rax, rbx
je  equal
jg  greater          ; signed
ja  above            ; unsigned
jmp elsewhere
```

`test rdi, rdi` / `jz` is the idiomatic zero check.

## Structured patterns

### if/else

```asm
    cmp rax, 0
    jne .else
    ; then
    jmp .end
.else:
    ; else
.end:
```

### while

```asm
.loop:
    cmp rcx, 0
    jle .done
    ; body
    dec rcx
    jmp .loop
.done:
```

### for i in 0..n-1

```asm
    xor rcx, rcx
.for:
    cmp rcx, n
    jge .endfor
    ; use rcx
    inc rcx
    jmp .for
.endfor:
```

## Jump tables (preview)

```asm
    ; rax in 0..2
    jmp [table+rax*8]
table:
    dq case0, case1, case2
```

## Exercises

30 drills: branches, loops, sums, search, bug hunts, AoC-style counting, jump table.
