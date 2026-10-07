# 09 — Macros, Multi-file, Make

Every syscall you've written so far spelled out `mov rax, 60` and `mov rdi, STATUS` by hand. This lesson shows you how to collapse that repetition into reusable macros, how to split a program across multiple files that share symbols, and how to automate rebuilds with Make so you only reassemble what changed. By the end you'll see that assembly—even without a standard library—can still be factored into maintainable, composable units.

## What this lesson asks of you

- Replace repeated magic numbers with `%define` constants and collapse repetitive instruction sequences into `%macro` definitions.
- Use `%rep` and `%assign` to generate code at assembly time without runtime loops.
- Mark macro-internal labels with `%%` to avoid name collisions across multiple macro invocations.
- Export a symbol with `global` in one file and reference it with `extern` in another, then link the two objects into one executable.
- Write Makefile pattern rules that rebuild only changed sources, using `.PHONY`, `$@`, `$<`, and `$^`.

## Text substitution with %define and %macro

NASM's preprocessor runs before the assembler proper. It sees `%define`, `%macro`, `%include`, and other directives and transforms the source text before any instruction encoding happens.

### Constants with %define

`%define` is a token-level text replacement. Every occurrence of the defined name is replaced by the tokens on the right-hand side.

```asm
%define SYS_EXIT 60
%define STATUS_OK 0

section .text
global _start
_start:
    mov rax, SYS_EXIT       ; becomes mov rax, 60
    mov rdi, STATUS_OK      ; becomes mov rdi, 0
    syscall
```

This is **not** the same as `equ`. `equ` defines a symbol whose value is computed at assembly time and can be used in expressions. `%define` is pure text substitution—it pastes the right-hand side wherever the name appears, before the assembler sees the line.

### Parameterized text with %macro

A macro is a template for one or more instructions. You declare it with a parameter count, and NASM will refuse to expand it unless the invocation supplies exactly that many arguments.

```asm
%macro exit_with 1          ; one parameter
    mov rax, 60
    mov rdi, %1             ; %1 is replaced by the argument
    syscall
%endmacro

section .text
global _start
_start:
    exit_with 7             ; expands to: mov rax, 60; mov rdi, 7; syscall
```

The macro name `exit_with` is followed by the parameter count `1`. Inside the macro body, `%1` refers to the first argument. If you invoke `exit_with` with zero arguments or two arguments, NASM will error at assembly time.

**Multi-parameter macros:**

```asm
%macro ADD3 3
    mov rdi, %1
    add rdi, %2
    add rdi, %3
%endmacro

; invocation:
ADD3 10, 20, 12             ; rdi = 10 + 20 + 12 = 42
```

Each `%N` is replaced by the corresponding argument text, not evaluated. So `%1` becomes `10`, `%2` becomes `20`, `%3` becomes `12`.

## Assembly-time loops and conditionals

### %rep for code generation

`%rep N` repeats its body `N` times at assembly time. The repetition happens in the NASM preprocessor, so the output object contains `N` copies of the instructions, not a loop at runtime.

```asm
section .text
global _start
_start:
    xor rdi, rdi
%rep 3
    inc rdi                 ; this line appears three times in the output
%endrep
    mov rax, 60
    syscall                 ; rdi = 3
```

The code above is equivalent to writing `inc rdi` three times by hand. The CPU executes three separate `inc` instructions—there's no branch, no jump, no loop counter.

### %assign for preprocessor variables

`%assign` defines or updates a preprocessor integer. You can use it inside `%rep` to track iteration counts or generate numbered labels.

```asm
%assign i 0
%rep 4
    inc rdi
    %assign i i+1
%endrep
; i is now 4, but i is not a register—it's a preprocessor symbol
```

The symbol `i` is not visible to the assembler or the CPU. It exists only during the preprocessing pass. If you want a runtime counter, you need a register.

### %ifdef and %else

`%ifdef SYMBOL` checks whether a symbol is defined at preprocessing time. This is useful for debug switches and conditional compilation.

```asm
%define DEBUG

section .text
global _start
_start:
%ifdef DEBUG
    mov rdi, 1              ; debug exit
%else
    xor rdi, rdi            ; release exit
%endif
    mov rax, 60
    syscall
```

If you remove the `%define DEBUG` line, the `%else` branch is kept. The CPU sees only one of the two paths—the other is discarded before assembly.

## Macro-local labels with %%

A label starting with `%%` is **macro-local**. NASM generates a unique name for it on every macro expansion, so you can safely use the same label name in multiple invocations without collision.

Without `%%`, a macro containing a label would break if invoked twice in the same function:

```asm
%macro TWICE 0
.again:                     ; BAD: second invocation redefines .again
    inc rdi
%endmacro

_start:
    TWICE                   ; expands .again
    TWICE                   ; ERROR: .again already defined
```

With `%%`, each invocation gets a unique label:

```asm
%macro TWICE 0
%%again:
    inc rdi
%endmacro

_start:
    TWICE                   ; expands to ..@1.again (or similar)
    TWICE                   ; expands to ..@2.again
```

**Example: absolute value macro**

```asm
%macro ABS 1
    cmp %1, 0
    jge %%ok                ; unique label for this expansion
    neg %1
%%ok:
%endmacro

section .text
global _start
_start:
    mov rdi, -9
    ABS rdi                 ; rdi = 9
    mov rax, 60
    syscall
```

The `%%ok` label is rewritten to something like `..@3.ok` internally, so multiple `ABS` invocations don't collide.

## %include for shared headers

`%include "file.inc"` inserts the contents of `file.inc` at that line. Header files typically contain `%define` constants, `%macro` definitions, and structure definitions.

**Header guard idiom:**

```asm
; regs.inc
%ifndef REGS_INC
%define REGS_INC

%define SYS_EXIT 60
%define SYS_WRITE 1

%endif
```

If two files both `%include "regs.inc"`, the second inclusion sees `REGS_INC` already defined and skips the body, preventing duplicate definitions.

## Splitting across multiple files

When a program grows, you want to split it into logical units: one file for the entry point, another for helper routines, another for data structures. To share symbols across files, you must **export** them from the defining file and **import** them in the using file.

### Exporting with global

`global symbol` marks a symbol (label or function) as visible to other object files.

```asm
; helper.asm
section .text
global helper_add           ; export this function

helper_add:
    add rdi, rsi
    mov rax, rdi
    ret
```

### Importing with extern

`extern symbol` tells NASM that the symbol is defined in another object file. NASM emits a relocation for it; the linker resolves it.

```asm
; main.asm
extern helper_add           ; import the function

section .text
global _start
_start:
    mov rdi, 20
    mov rsi, 22
    call helper_add         ; rax = 42
    mov rdi, rax
    mov rax, 60
    syscall
```

### Linking multiple objects

Assemble each file separately, then link all objects together:

```bash
nasm -f elf64 main.asm -o main.o
nasm -f elf64 helper.asm -o helper.o
ld main.o helper.o -o prog
./prog; echo $?             # 42
```

The linker combines the `.text`, `.data`, and `.rodata` sections from both objects, resolves `extern` references, and produces a single executable. The entry point is `_start`, which the linker knows to look for by default.

**What if extern has no definition?** The linker will error with "undefined reference to `symbol`" at link time, not at assemble time or runtime. This is not a silent null—it's a build failure.

## default rel for position-independent code

By default, NASM encodes a bare `[symbol]` as an absolute address (32-bit displacement in the opcode). On modern x86-64, you almost always want **RIP-relative** addressing for data symbols, which is position-independent and avoids relocation overhead.

`default rel` at the top of the file tells NASM to interpret all `[symbol]` references as RIP-relative by default.

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
    lea rsi, [msg]          ; RIP-relative: lea rsi, [rel msg]
    mov rdx, n
    syscall
    xor rdi, rdi
    mov rax, 60
    syscall
```

Without `default rel`, NASM 2.15+ will warn about absolute addresses. With it, the code is position-independent and can be linked as a PIE (position-independent executable) without warnings.

## Make: rebuilding only what changed

A Makefile automates the build: it declares dependencies (which sources produce which objects, which objects link into which binary) and recipes (the shell commands to run). Make compares file timestamps and rebuilds only what's out of date.

### Basic structure

```makefile
# target: prerequisites
# <tab>recipe
```

The recipe line **must** start with a hard tab, not spaces. Make will error on spaces.

### Pattern rules

A pattern rule describes how to build any `.o` from a `.asm`:

```makefile
%.o: %.asm
	nasm -f elf64 $< -o $@
```

- `$<` is the first prerequisite (`%.asm`).
- `$@` is the target (`%.o`).

### Linking rule

```makefile
prog: main.o helper.o
	ld $^ -o $@
```

- `$^` is all prerequisites (`main.o helper.o`).
- `$@` is the target (`prog`).

### Phony targets

`.PHONY` declares targets that are not files:

```makefile
.PHONY: all clean

all: prog

clean:
	rm -f *.o prog
```

If a file named `clean` exists, `make clean` would see it as up-to-date and do nothing. `.PHONY` tells Make to always run the recipe.

### Complete example

```makefile
.PHONY: all clean

all: prog

prog: main.o helper.o
	ld $^ -o $@

%.o: %.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f *.o prog
```

Run `make` to build `prog`. Run `make clean` to remove build artifacts. If `main.asm` changes, Make recompiles `main.o` and relinks `prog`. If `helper.asm` is unchanged, `helper.o` is not rebuilt.

## Worked example: two-file addition program with macro

**Task:** Write a program split into `main.asm` and `add.asm`. `main.asm` defines `_start`, which calls a function `add_two_numbers` exported from `add.asm`. The function adds `rdi` and `rsi`, returns the result in `rax`. Use a macro `EXIT` to wrap the syscall. Exit with the sum of 20 and 22.

**Step-by-step reasoning:**

1. **Macro for exit:** Define `EXIT` with one parameter (status), which moves the status to `rdi` and calls syscall 60.
2. **main.asm:**
   - Include the macro (or define it inline).
   - `extern add_two_numbers` to import the function.
   - `_start`: load `rdi = 20`, `rsi = 22`, call `add_two_numbers`, `EXIT rax`.
3. **add.asm:**
   - `global add_two_numbers` to export it.
   - `add_two_numbers`: add `rdi, rsi`, move result to `rax`, `ret`.
4. **Build:** `nasm -f elf64 main.asm -o main.o && nasm -f elf64 add.asm -o add.o && ld main.o add.o -o prog`

**main.asm:**

```asm
%macro EXIT 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro

extern add_two_numbers

section .text
global _start
_start:
    mov rdi, 20
    mov rsi, 22
    call add_two_numbers    ; rax = 42
    EXIT rax
```

**add.asm:**

```asm
section .text
global add_two_numbers

add_two_numbers:
    mov rax, rdi
    add rax, rsi
    ret
```

**Expected output:** Exit status 42.

**Plausible wrong reading and why it fails:**

*"I can put `extern add_two_numbers` in `add.asm` too, so both files know about the function."*

**Why it's wrong:** `extern` means "this symbol is defined elsewhere, resolve it at link time." If you put `extern add_two_numbers` in `add.asm`, you're telling the assembler that `add_two_numbers` is external to `add.asm`. But `add.asm` is the file that **defines** it with `global`. The definition and the `extern` declaration are mutually exclusive: you either define a symbol (`global`) or reference it (`extern`), not both. If you mistakenly mark it `extern` in the file that defines it, the linker will fail with "undefined reference."

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| `%define` is the same as `equ` | `%define` is text substitution; `equ` defines a numeric constant symbol |
| A macro parameter `%1` is evaluated as an expression | `%1` is replaced by the exact text of the argument, then assembled as an instruction |
| `%rep 3` generates a runtime loop | `%rep 3` duplicates the body three times in the source; the CPU sees three straight-line instructions |
| Macro labels can use `.label` | `.label` binds to the previous non-local label; use `%%label` for macro-local labels |
| `extern` declares a symbol for export | `extern` **imports** a symbol; `global` exports it |
| You can link two NASM invocations that list multiple source files | NASM assembles one file per invocation; you pass multiple `.o` files to `ld`, not multiple `.asm` to `nasm` |
| Make recipes can use spaces for indentation | Make recipes **must** start with a hard tab; spaces cause syntax errors |

## Check yourself

1. You define `%macro ABS 1` with a `cmp` and `neg` inside. You invoke `ABS` twice in the same function. If the label inside is `.done`, what happens at assembly time? How do you fix it?

2. You have `main.asm` with `extern helper` and `call helper`, and `helper.asm` with a function `helper:` but no `global helper`. What error do you get, and at which stage (assemble or link)?

3. Your Makefile has `prog: main.o helper.o` with the recipe `ld $< -o $@`. You run `make` and the linker complains about undefined references. What does `$<` expand to, and what should you use instead?

4. You write `%define SYS_EXIT 60` and later `mov rax, SYS_EXIT + 1`. Does NASM compute `61`, or does it error?

5. You have `%rep 5` with `inc rdi` inside. After the `%endrep`, how many `inc rdi` instructions are in the assembled object? How many times does `rdi` increment at runtime?

## Key takeaways

- `%define` pastes text; `%macro` pastes parameterized instruction sequences; both happen at assembly time, before encoding.
- `%rep` and `%assign` generate code at assembly time; they are not runtime loops.
- Macro labels must use `%%` to avoid collisions across multiple invocations.
- `global` exports a symbol for other files to reference with `extern`; link multiple `.o` files with `ld`.
- Makefiles use pattern rules (`%.o: %.asm`) and automatic variables (`$@`, `$<`, `$^`) to rebuild only changed files.
- Recipes must start with a hard tab, not spaces.

## Lookup

- NASM macro documentation: [NASM Manual Chapter 4 (Preprocessor)](https://www.nasm.us/xdoc/2.16.01/html/nasmdoc4.html)
- `global` and `extern`: [NASM Manual Section 7.4](https://www.nasm.us/xdoc/2.16.01/html/nasmdoc7.html#section-7.4)
- `default rel`: [NASM Manual Section 12.1.3](https://www.nasm.us/xdoc/2.16.01/html/nasmdoc12.html#section-12.1.3)
- Make: [GNU Make Manual](https://www.gnu.org/software/make/manual/make.html), especially [Automatic Variables](https://www.gnu.org/software/make/manual/make.html#Automatic-Variables)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Macros:**
- `01-define-const.asm` — `%define SYS_EXIT 60`, exit 0
- `02-macro-exit.asm` — `exit_with 7` macro, exit 7
- `03-macro-write.asm` — macro writes `M\n`, exit 0
- `04-include-guard-sim.asm` — `%ifndef` / `%define` guard, exit 42
- `07-repeat-macro.asm` — `%rep 3` with `inc rdi`, exit 3
- `08-from-scratch-macro-add.asm` — `ADD_IMM rdi, 2` after `mov rdi, 40`, exit 42
- `09-macro-pushregs.asm` — push `rbx`, `r12`; pop in reverse order, exit 5
- `10-macro-syscall.asm` — zero-argument `SYSCALL0`, print `K\n`, exit 0
- `11-assign-macro.asm` — `%assign i` in `%rep 4`, four `inc rdi`, exit 4 (`i` is not loaded into a register)
- `12-strstr-macro-label.asm` — `TWICE` macro with two `inc rdi`, no `%%` label, exit 2
- `13-ifdef-debug.asm` — `%ifdef DEBUG` keeps `mov rdi, 1`, exit 1
- `16-include-path-sim.asm` — `%define VERSION 3`, no `%include` call, exit 3
- `17-macro-stringize.asm` — stores string `"Q\n"`, exit 0 (no stringification)
- `18-default-rel-macro.asm` — `default rel`, print `hi\n`, exit 0
- `20-macro-with-params.asm` — `ADD3 10, 20, 12`, exit 42
- `21-debug-macro-arity.asm` — fix: `EXIT_STATUS 4` (supply missing argument)
- `22-stretch-units-header.asm` — `%define SYS_WRITE 1` and `SYS_EXIT 60`, print `U\n`, exit 0
- `24-from-scratch-macro-abs.asm` — `ABS` macro with `%%ok` label, exit 9

**Multi-file and Make:**
- `05-makefile-note.asm` — comment mentions multi-file; solution is one file, exit 0
- `06-extern-sim-onefile.asm` — single file with `extern` simulation, exit 5
- `14-multifile-sim-globals.asm` — single-file simulation of `global`, return 42
- `15-makefile-phony-doc.asm` — comment about `.PHONY`, exit 0
- `19-extern-declare.asm` — single file, exit 9
- `23-stretch-make-dependency.asm` — exit 3 (object count as immediate, not Make graph)
