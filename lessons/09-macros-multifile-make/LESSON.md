# Lesson 09 — Macros, Multi-file, Make

## Learning objectives

1. Paste constants with `%define` and parameterized text with `%macro`.
2. Repeat and number at assembly time with `%rep` and `%assign`.
3. Keep macro-local labels on `%%`, and branch with `%ifdef`.
4. Share a symbol across files with `global` and `extern`, then link two objects.
5. Name Make targets so `.PHONY`, `$@`, `$<`, and `$^` rebuild only what changed.

Lesson 08 wrote syscall numbers by hand. This lesson shows how those numbers — and later the editor — stop being copy-paste. The editor buffer is lesson 10. Nothing here calls libc.

## Text substitution

`%define` pastes tokens where the name is used. It is not a register and not `equ`. `%macro` takes a parameter count. `%1` is the first argument, as text. The count on the definition must match the invocation or NASM stops. `21-debug-macro-arity.asm` invokes `EXIT_STATUS` with no argument. The fix is `EXIT_STATUS 4`.

```asm
%macro exit_with 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro
section .text
global _start
_start:
    exit_with 7             ; pastes mov rdi, 7
```

That is `02-macro-exit.asm`. `%define SYS_EXIT 60` exits 0 in `01-define-const.asm`. `%define VERSION 3` exits 3 in `16-include-path-sim.asm`. The prompt says an include path. The solution never `%include`s a file. `%include "regs.inc"` would insert that file at the line. A header guard is `%ifndef ANSWER` / `%define ANSWER 42` / `%endif`, and the exit is 42 (`04-include-guard-sim.asm`).

`ADD_IMM rdi, 2` after `mov rdi, 40` exits 42 (`08-from-scratch-macro-add.asm`). `ADD3 10, 20, 12` exits 42 (`20-macro-with-params.asm`). A zero-argument `SYSCALL0` is only the `syscall` instruction (`10-macro-syscall.asm` prints `K\n` and exits 0). `sys_write1 m, 2` prints `M\n` (`03-macro-write.asm`). `%define SYS_WRITE 1` and `SYS_EXIT 60` print `U\n` and exit 0 (`22-stretch-units-header.asm`). `17-macro-stringize.asm` does not stringify. It stores `"Q\n"` and exits 0.

## Assembly-time loops

`%rep` duplicates the body in the output. It is not a runtime `jmp`. `%assign` updates a preprocessor integer. The `i` in `11-assign-macro.asm` is never loaded into a register. Four `inc rdi` still exit 4.

```asm
section .text
global _start
_start:
    xor rdi, rdi
%rep 3
    inc rdi
%endrep
    mov rax, 60
    syscall                 ; 3
```

That is `07-repeat-macro.asm`. `%ifdef DEBUG` keeps `mov rdi, 1` and drops the `%else` (`13-ifdef-debug.asm` exits 1). `PUSH_CALLEE` pushes `rbx` then `r12`. The matching pops are `r12` then `rbx`, otherwise you restore the wrong register (`09-macro-pushregs.asm` exits 5).

## Local labels inside a macro

A plain `.ok` and a `%%ok` are not the same thing. A dot-label binds to the previous non-local label. Two expansions in one function collide. `%%ok` is rewritten to a unique name on every expansion. `12-strstr-macro-label.asm` never branches: `TWICE` is two `inc rdi`, exit 2. The local label shows up in `24-from-scratch-macro-abs.asm`.

```asm
%macro ABS 1
    cmp %1, 0
    jge %%ok
    neg %1
%%ok:
%endmacro
section .text
global _start
_start:
    mov rdi, -9
    ABS rdi
    mov rax, 60             ; rdi == 9
    syscall
```

## Two objects

`global helper_add` marks a symbol for other objects. `extern helper_add` tells NASM the definition is elsewhere. A single file that both calls and defines the helper does not need `extern` (`06-extern-sim-onefile.asm` exits 5, `14-multifile-sim-globals.asm` returns 20+22 = 42, `19-extern-declare.asm` exits 9). The comment in `05-makefile-note.asm` shows two sources passed to one `nasm` invocation. NASM assembles one file per run.

Assemble each unit, then link:

`nasm -f elf64 a.asm -o a.o && nasm -f elf64 b.asm -o b.o && ld a.o b.o -o /tmp/p`

`a.asm` has `extern helper_add` and `_start`. `b.asm` has `global helper_add`. An `extern` with no definition is a link error, not a runtime zero.

`default rel` makes a bare `[msg]` RIP-relative, which is the warning NASM 3 emits when you leave the default absolute. `18-default-rel-macro.asm` prints `hi\n` and exits 0.

```asm
default rel
section .data
    msg db "hi", 10
    n equ $ - msg
section .text
global _start
_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg]
    mov rdx, n
    syscall
    xor rdi, rdi            ; 0
    mov rax, 60
    syscall
```

## Make

The asm drills do not run Make. `05-makefile-note.asm` and `15-makefile-phony-doc.asm` exit 0. `23-stretch-make-dependency.asm` exits 3, which is the object count written as an immediate, not a graph that Make walked.

| Token | Meaning |
|-------|---------|
| `.PHONY: all clean` | run the recipe even if a file of that name exists |
| `$@` | the target being built |
| `$<` | the first prerequisite |
| `$^` | every prerequisite, in order |

A pattern rule is `%.o: %.asm` with a recipe line that starts with a tab: `nasm -f elf64 $< -o $@`. The link line is `prog: a.o b.o` and then tab `ld $^ -o $@`. A space instead of the tab is a syntax error. `all` depends on `prog`, so `make` with no arguments builds the link.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Macros: `01-define-const.asm`, `02-macro-exit.asm`, `03-macro-write.asm`, `04-include-guard-sim.asm`, `07-repeat-macro.asm`, `08-from-scratch-macro-add.asm`, `09-macro-pushregs.asm`, `10-macro-syscall.asm`, `11-assign-macro.asm` (exit 4; `i` is not loaded), `12-strstr-macro-label.asm` (no `%%` label), `13-ifdef-debug.asm`, `16-include-path-sim.asm` (no `%include`), `17-macro-stringize.asm` (no stringify), `18-default-rel-macro.asm`, `20-macro-with-params.asm`, `21-debug-macro-arity.asm`, `22-stretch-units-header.asm`, `24-from-scratch-macro-abs.asm`. Units and Make: `05-makefile-note.asm`, `06-extern-sim-onefile.asm`, `14-multifile-sim-globals.asm`, `15-makefile-phony-doc.asm`, `19-extern-declare.asm`, `23-stretch-make-dependency.asm` (exit 3).