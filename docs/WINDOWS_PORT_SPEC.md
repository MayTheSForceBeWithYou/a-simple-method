# Windows Port Technical Specification

**Target:** Port "A Simple Method" x86-64 assembly course from Linux (NASM, System V ABI, Linux syscalls) to Windows 11 (MASM/ml64.exe, Microsoft x64 ABI, Win32 API)

**Phase 1 Deliverable:** This specification document + smoke test + CI workflow  
**Date:** October 2026  
**Status:** Phase 1 — Specification and Toolchain Verification

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Syntax: NASM to MASM](#syntax-nasm-to-masm)
3. [ABI: System V to Microsoft x64](#abi-system-v-to-microsoft-x64)
4. [Syscalls to Win32 API](#syscalls-to-win32-api)
5. [Binary Format: ELF to PE/COFF](#binary-format-elf-to-pecoff)
6. [Exit Code Semantics](#exit-code-semantics)
7. [Lesson-by-Lesson Mapping](#lesson-by-lesson-mapping)
8. [Build and Test Harness](#build-and-test-harness)
9. [CI Design](#ci-design)
10. [Phase 2 Work Split](#phase-2-work-split)

---

## Executive Summary

This specification defines the technical mapping for porting 19 lessons (00-18) containing approximately 950+ exercise and solution files from Linux x86-64 assembly (NASM syntax, System V ABI, Linux syscalls) to Windows 11 (MASM syntax, Microsoft x64 ABI, Win32 API).

**Core principles:**
- **Real port, not emulation:** Use native Win32 API calls, not WSL or POSIX wrappers
- **No CRT unless necessary:** Link directly with kernel32.lib using `/ENTRY:main /SUBSYSTEM:CONSOLE`
- **Preserve pedagogical intent:** Every drill must teach the same concepts with Windows-native mechanisms
- **Maintain test discipline:** All solutions must pass automated tests; exercises must fail until completed

**Toolchain:** Visual Studio 2022+ (or 2026 if available) x64 Native Tools Command Prompt
- `ml64.exe` — Microsoft Macro Assembler for x64
- `link.exe` — Microsoft linker
- `kernel32.lib` — Win32 API import library

---

## Syntax: NASM to MASM

### Overview

NASM and MASM are both x86-64 assemblers but use different directives, syntax conventions, and macro systems. MASM is more structured (PROC/ENDP) and requires explicit size specifiers more often.

### Directives

| NASM | MASM | Notes |
|------|------|-------|
| `section .text` | `.code` | Executable code section |
| `section .data` | `.data` | Initialized read-write data |
| `section .rodata` | `.const` | Read-only data (not `.data`) |
| `section .bss` | `.data?` | Uninitialized data (zeroed at load) |
| `global _start` | `PUBLIC main` | Export symbol (but see PROC) |
| `extern symbol` | `EXTERN symbol:PROC` or `EXTRN` | Import function |
| `extern var` | `EXTERN var:QWORD` | Import data (specify size) |
| `INCLUDELIB` | `INCLUDELIB kernel32.lib` | Link library (MASM-specific) |

**Critical:** MASM requires you to declare the type of external symbols (`:PROC`, `:QWORD`, `:BYTE`, etc.).

### Procedures

NASM uses labels; MASM uses `PROC`/`ENDP`:

**NASM:**
```nasm
section .text
    global _start
_start:
    mov rax, 60
    xor rdi, rdi
    syscall
```

**MASM:**
```asm
.code
main PROC
    mov rcx, 0
    call ExitProcess
main ENDP
END
```

**Notes:**
- `main PROC` implicitly makes `main` public when used with `/ENTRY:main`
- The `END` directive is required at the end of the file (optionally `END main` to specify entry point, though `/ENTRY` is clearer)
- MASM has no `syscall` instruction usage in the same way — you call Win32 API functions

### Data Declarations

| NASM | MASM | Size |
|------|------|------|
| `db value` | `BYTE value` or `db value` | 1 byte |
| `dw value` | `WORD value` or `dw value` | 2 bytes |
| `dd value` | `DWORD value` or `dd value` | 4 bytes |
| `dq value` | `QWORD value` or `dq value` | 8 bytes |
| `times N db 0` | `BYTE N DUP(0)` | Repeat N times |
| `resb N` | `.data?` + `BYTE N DUP(?)` | Reserve N bytes |
| `resq N` | `.data?` + `QWORD N DUP(?)` | Reserve N quadwords |

**String example:**

NASM: `msg db "Hello", 10, 0`  
MASM: `msg BYTE "Hello", 10, 0` or `msg db "Hello", 10, 0`

### Constants and Symbols

| NASM | MASM | Notes |
|------|------|-------|
| `name equ value` | `name EQU value` or `name = value` | Numeric constant |
| `%define NAME val` | `NAME TEXTEQU <val>` | Text substitution macro |
| `$ - label` | `$ - label` or `SIZEOF name` | Current position / size |

**Length computation:**

NASM: `msg_len equ $ - msg`  
MASM: `msg_len EQU $ - msg` or `msg_len EQU SIZEOF msg`

**Note:** MASM's `=` allows reassignment; `EQU` does not. Use `EQU` for true constants.

### Operands and Size Specifiers

MASM requires explicit size specifiers more often, especially for memory operands with ambiguous sizes:

| NASM | MASM | Notes |
|------|------|-------|
| `mov rax, [addr]` | `mov rax, [addr]` or `mov rax, QWORD PTR [addr]` | Load 8 bytes |
| `mov al, [addr]` | `mov al, BYTE PTR [addr]` | MASM may require `PTR` |
| `mov [addr], 42` | `mov QWORD PTR [addr], 42` | **Required** when size ambiguous |
| `lea rsi, [msg]` | `lea rsi, msg` or `lea rsi, [msg]` | Brackets optional |
| `mov rsi, msg` | `lea rsi, msg` or `mov rsi, OFFSET msg` | MASM: use `OFFSET` for address |

**Critical difference:** NASM distinguishes `mov rsi, msg` (load address) from `mov rsi, [msg]` (load contents). MASM treats `mov rsi, msg` as moving the *contents* by default. Use `OFFSET msg` or `lea` for addresses.

### Local Labels

NASM uses `.label` for local labels (scoped to the previous non-local label). MASM has two mechanisms:

1. **`@@` anonymous labels:**
   ```asm
   @@:
       jmp @B   ; jump backward to nearest @@
       jmp @F   ; jump forward to nearest @@
   ```

2. **PROC-scoped labels:**
   ```asm
   myFunc PROC
       jmp short local_label
   local_label:
       ret
   myFunc ENDP
   ```

Labels inside a PROC are local to that PROC and don't conflict with same-named labels in other PROCs.

### Macros

NASM uses `%macro` / `%endmacro`; MASM uses `MACRO` / `ENDM`:

**NASM:**
```nasm
%macro exit_with 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro
```

**MASM:**
```asm
exit_with MACRO code
    mov rcx, code
    call ExitProcess
ENDM
```

**Differences:**
- MASM uses parameter names, not `%1, %2`
- MASM macros can use `LOCAL` to generate unique labels
- NASM `%if` / `%ifdef` map to MASM `IF` / `IFDEF` (but these are often avoided in simple code)

### RIP-Relative Addressing

**NASM:** `mov rax, [rel symbol]` — explicit `rel` keyword for RIP-relative  
**MASM (64-bit):** `mov rax, [symbol]` — **RIP-relative is the default** in 64-bit mode

To force absolute addressing in MASM (rare): use segment prefix or `IMAGEREL`.

**Important:** In 64-bit MASM, you almost never need to specify RIP-relative; it's automatic. The NASM `[rel x]` pattern maps to MASM `[x]`.

### Case Sensitivity

- **NASM:** Case-sensitive by default
- **MASM:** Case-**in**sensitive by default for instructions and directives; use `/Cx` flag or `OPTION CASEMAP` to change behavior

**Recommendation:** Use lowercase consistently for portability, and uppercase for constants (matching Win32 API convention).

### Calling API Functions

In NASM (Linux syscalls), you set registers and invoke `syscall`. In MASM (Windows), you call imported functions:

**NASM (Linux):**
```nasm
mov rax, 1          ; sys_write
mov rdi, 1          ; stdout
mov rsi, msg
mov rdx, msg_len
syscall
```

**MASM (Windows):**
```asm
EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC

; Get stdout handle
mov rcx, -11        ; STD_OUTPUT_HANDLE
call GetStdHandle
; rax now holds stdout HANDLE

; Write to console
mov rcx, rax        ; console handle
lea rdx, msg        ; buffer
mov r8, msg_len     ; chars to write
lea r9, charsWritten
mov QWORD PTR [rsp+32], 0  ; reserved parameter (in shadow space)
call WriteConsoleA
```

**Import library linkage:**

To call Win32 APIs, link with `kernel32.lib`. The linker resolves `call FunctionName` to an indirect call through the Import Address Table (IAT). The actual call site becomes `call [__imp_FunctionName]` after linking, but you write `call FunctionName` in source.

**No `INVOKE` in ml64:** MASM's `INVOKE` directive does not exist in 64-bit ml64. You must manually set up registers and call.

### Notable Gotchas

1. **No 32-bit `INVOKE`:** ml64 drops the convenient `INVOKE` syntax from 32-bit MASM. All calls are manual.
2. **Size specifiers required:** `mov [addr], 0` is ambiguous; use `mov QWORD PTR [addr], 0`.
3. **`OFFSET` for addresses:** `mov rsi, msg` loads contents in MASM; use `lea rsi, msg` or `mov rsi, OFFSET msg`.
4. **Shadow space must be allocated:** Caller must reserve 32 bytes on stack before any call (see ABI section).
5. **`OPTION` directives:** MASM has many options (e.g., `OPTION PROLOGUE:NONE`) that NASM lacks. For simple standalone code, you typically don't need them.

---

## ABI: System V to Microsoft x64

### Register Usage

| Purpose | System V (Linux) | Microsoft x64 (Windows) | Notes |
|---------|------------------|-------------------------|-------|
| **Integer args 1-6** | RDI, RSI, RDX, RCX, R8, R9 | RCX, RDX, R8, R9 | Win only has 4 register args |
| **Integer arg 7+** | Stack (pushed right-to-left) | Stack (pushed right-to-left, but after shadow space) | |
| **Return value** | RAX | RAX | Same |
| **Caller-saved (volatile)** | RAX, RCX, RDX, RSI, RDI, R8-R11 | RAX, RCX, RDX, R8-R11 | **RSI, RDI nonvolatile on Windows!** |
| **Callee-saved (nonvolatile)** | RBX, RBP, R12-R15 | RBX, RBP, RDI, RSI, R12-R15 | Windows adds RDI, RSI |
| **Float args 1-4** | XMM0-XMM7 | XMM0-XMM3 | Win only has 4 float args |
| **Float return** | XMM0 | XMM0 | Same |
| **Float volatile** | XMM0-XMM15 | XMM0-XMM5 | |
| **Float nonvolatile** | None | XMM6-XMM15 | Must preserve upper 128 bits |
| **Stack pointer** | RSP | RSP | Must be 16-byte aligned before `call` |

### Critical Differences

1. **Argument order changed:** First arg is RCX (not RDI), second is RDX (not RSI)
2. **Only 4 register args (not 6):** Fifth arg starts on stack
3. **RSI and RDI are nonvolatile on Windows:** Must save/restore them if you modify them
4. **XMM6-XMM15 are nonvolatile on Windows:** Must save lower 128 bits if modified

### Shadow Space (Home Space)

The Microsoft x64 ABI requires the **caller** to allocate 32 bytes (4 × 8 bytes) of "shadow space" on the stack before every call, even if the callee has fewer than 4 arguments. This space is reserved for the callee to spill RCX, RDX, R8, R9 if needed (though modern callees rarely do this).

**Example:**

```asm
main PROC
    sub rsp, 32         ; allocate shadow space (4 × 8 bytes)
    mov rcx, 0
    call ExitProcess
    ; ExitProcess never returns, but if it did:
    ; add rsp, 32
    ; ret
main ENDP
```

**Rule:** Before every `call`, RSP must point to at least 32 bytes of free space (in addition to any actual stack arguments).

**Note:** Even leaf functions (functions that make no calls) don't need shadow space *for themselves*, but if they call anyone, they must allocate it.

### Stack Alignment

At the point of a `call` instruction, RSP must be **16-byte aligned**. The `call` itself pushes an 8-byte return address, so inside the function, RSP is 8 bytes off alignment. To restore 16-byte alignment, the function must subtract an odd multiple of 8 from RSP.

**Common pattern for non-leaf functions:**

```asm
myFunc PROC
    sub rsp, 40         ; 32 (shadow space) + 8 = 40 (multiple of 16)
                        ; After this, RSP is 16-byte aligned again
    call OtherFunc
    add rsp, 40
    ret
myFunc ENDP
```

**Why 40?** We need 32 for shadow space, plus an additional 8 to maintain 16-byte alignment (since `call` pushed 8 bytes).

### Stack Parameters (5th and Beyond)

Fifth and subsequent parameters go on the stack **above** the shadow space:

```asm
; Call with 6 arguments: (a, b, c, d, e, f)
; a → RCX, b → RDX, c → R8, d → R9, e → [rsp+32], f → [rsp+40]

sub rsp, 48         ; 32 shadow + 16 for args 5-6 (must be 16-aligned)
mov rcx, a
mov rdx, b
mov r8, c
mov r9, d
mov QWORD PTR [rsp+32], e
mov QWORD PTR [rsp+40], f
call SixArgFunc
add rsp, 48
```

**Note:** The stack must remain 16-byte aligned before the `call`, so allocate in multiples of 16 (32 + N*8, where N is even).

### Prolog and Epilog

Simple leaf functions need no prologue/epilogue. Non-leaf functions must:

1. Allocate stack space (shadow + locals + alignment padding)
2. Save any nonvolatile registers used (RBX, RBP, RDI, RSI, R12-R15, XMM6-XMM15 lower 128 bits)
3. Restore them and deallocate stack in the epilogue

**Example with nonvolatiles:**

```asm
myFunc PROC
    push rbx            ; save nonvolatile
    push rsi
    sub rsp, 40         ; 32 shadow + 8 for alignment
    
    ; ... function body ...
    
    add rsp, 40
    pop rsi
    pop rbx
    ret
myFunc ENDP
```

### PROC FRAME and Unwind Info

For exception handling and debugging, Windows expects **unwind information** for non-leaf functions. This is specified with `PROC FRAME` and directives like `.PUSHREG`, `.ALLOCSTACK`, `.SETFRAME`, `.ENDPROLOG`.

**When required:**
- Non-leaf functions (functions that call other functions)
- Any function that might be unwound during exception handling
- Any function you want to debug step-by-step

**When not required:**
- Leaf functions (no calls, no stack frame)
- Simple code that never throws exceptions and doesn't need debugging

**Example with FRAME:**

```asm
myFunc PROC FRAME
    push rbx
    .PUSHREG rbx
    push rsi
    .PUSHREG rsi
    sub rsp, 40
    .ALLOCSTACK 40
    .ENDPROLOG
    
    ; function body
    
    add rsp, 40
    pop rsi
    pop rbx
    ret
myFunc ENDP
```

**For this course:** Most drills are simple enough to avoid FRAME. But lesson 10+ (milestone editor, compiler, game) may need it for multi-file projects with proper error handling.

### Return Values

- **Integer/pointer:** RAX (same as System V)
- **Floating-point:** XMM0 (same as System V)
- **Structures ≤ 8 bytes:** RAX
- **Structures > 8 bytes:** Caller allocates space and passes pointer in RCX; function returns pointer in RAX

---

## Syscalls to Win32 API

### Overview

Linux programs request kernel services via the `syscall` instruction with a number in RAX. Windows programs call imported functions from kernel32.dll, user32.dll, etc. The mapping is **conceptual**, not one-to-one: one Linux syscall may require multiple Win32 calls or vice versa.

### Error Handling: Negative errno vs. BOOL + GetLastError

**Linux:**
- Most syscalls return negative values (-ERRNO) on error, or ≥0 on success
- Check with `test rax, rax; js error`

**Windows:**
- Many functions return BOOL (0 = failure, nonzero = success) or INVALID_HANDLE_VALUE (-1)
- On failure, call `GetLastError()` to retrieve error code
- Some functions (like GetStdHandle) return NULL or INVALID_HANDLE_VALUE on failure

**Error checking pattern (Windows):**

```asm
call CreateFileA
cmp rax, -1         ; INVALID_HANDLE_VALUE
je error_handler

; Or for BOOL functions:
call WriteFile
test rax, rax
jz error_handler    ; 0 = FALSE
```

### Core Syscall Mappings

#### Exit

| Linux | Windows |
|-------|---------|
| `sys_exit` (rax=60), arg: rdi = status | `ExitProcess(status)`, arg: rcx = UINT exitCode |

**NASM (Linux):**
```nasm
mov rax, 60
mov rdi, 0
syscall
```

**MASM (Windows):**
```asm
EXTERN ExitProcess:PROC
mov rcx, 0
call ExitProcess
```

**Exit code semantics:** Linux uses low 8 bits (0-255); Windows uses full 32-bit UINT (0-4294967295). Portable tests should check only low 8 bits.

#### Write to stdout/stderr

| Linux | Windows |
|-------|---------|
| `sys_write` (rax=1), args: rdi=fd, rsi=buf, rdx=count | `GetStdHandle(STD_OUTPUT_HANDLE)` → `WriteFile(handle, buf, count, &written, NULL)` or `WriteConsoleA` |

**NASM (Linux):**
```nasm
mov rax, 1
mov rdi, 1          ; stdout
lea rsi, [msg]
mov rdx, msg_len
syscall
```

**MASM (Windows):**
```asm
EXTERN GetStdHandle:PROC
EXTERN WriteFile:PROC

.data?
written QWORD ?

.code
; Get stdout
mov rcx, -11        ; STD_OUTPUT_HANDLE = -11
call GetStdHandle
mov rbx, rax        ; save handle

; Write
mov rcx, rbx        ; hFile
lea rdx, msg        ; lpBuffer
mov r8, msg_len     ; nNumberOfBytesToWrite
lea r9, written     ; lpNumberOfBytesWritten
mov QWORD PTR [rsp+32], 0  ; lpOverlapped (NULL)
call WriteFile
```

**Simpler alternative for console-only:** `WriteConsoleA(handle, buffer, chars, &written, NULL)`

**File descriptors vs. HANDLEs:**
- Linux: 0=stdin, 1=stdout, 2=stderr (small integers)
- Windows: Use `GetStdHandle(STD_INPUT_HANDLE=-10, STD_OUTPUT_HANDLE=-11, STD_ERROR_HANDLE=-12)` to get HANDLE values

#### Read from stdin

| Linux | Windows |
|-------|---------|
| `sys_read` (rax=0), args: rdi=fd, rsi=buf, rdx=count | `GetStdHandle(STD_INPUT_HANDLE)` → `ReadFile(handle, buf, count, &read, NULL)` or `ReadConsoleA` |

**Windows (ReadFile):**
```asm
EXTERN GetStdHandle:PROC
EXTERN ReadFile:PROC

.data?
bytesRead QWORD ?

.code
mov rcx, -10        ; STD_INPUT_HANDLE
call GetStdHandle

mov rcx, rax        ; hFile
lea rdx, buffer
mov r8, bufsize
lea r9, bytesRead
mov QWORD PTR [rsp+32], 0
call ReadFile
```

#### File Operations

| Linux | Windows | Notes |
|-------|---------|-------|
| `open(path, flags, mode)` (rax=2) | `CreateFileA(path, access, share, NULL, disposition, attrs, NULL)` | Returns HANDLE, not fd |
| `close(fd)` (rax=3) | `CloseHandle(handle)` | Takes HANDLE |
| `lseek(fd, offset, whence)` (rax=8) | `SetFilePointerEx(handle, offset, &newpos, whence)` | 64-bit offset |
| `read(fd, buf, count)` (rax=0) | `ReadFile(handle, buf, count, &read, NULL)` | |
| `write(fd, buf, count)` (rax=1) | `WriteFile(handle, buf, count, &written, NULL)` | |

**CreateFileA mapping:**

Linux `open` flags → Windows `dwDesiredAccess` + `dwCreationDisposition`:

| Linux Flag | Windows Equivalent |
|------------|--------------------|
| `O_RDONLY` (0) | `dwDesiredAccess = GENERIC_READ` (0x80000000) |
| `O_WRONLY` (1) | `dwDesiredAccess = GENERIC_WRITE` (0x40000000) |
| `O_RDWR` (2) | `GENERIC_READ \| GENERIC_WRITE` |
| `O_CREAT` (64) | `dwCreationDisposition = CREATE_ALWAYS` or `OPEN_ALWAYS` |
| `O_TRUNC` (512) | `dwCreationDisposition = CREATE_ALWAYS` (truncates) |
| `O_APPEND` (1024) | Set file pointer to end after open |

**Example: open file for writing (create or truncate):**

```asm
EXTERN CreateFileA:PROC

.data
path BYTE "output.txt", 0

.code
sub rsp, 56         ; shadow space + alignment
lea rcx, path       ; lpFileName
mov rdx, 40000000h  ; dwDesiredAccess = GENERIC_WRITE
mov r8, 0           ; dwShareMode = 0 (exclusive)
mov r9, 0           ; lpSecurityAttributes = NULL
mov QWORD PTR [rsp+32], 2   ; dwCreationDisposition = CREATE_ALWAYS
mov QWORD PTR [rsp+40], 80h ; dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
mov QWORD PTR [rsp+48], 0   ; hTemplateFile = NULL
call CreateFileA
add rsp, 56
; rax = HANDLE or INVALID_HANDLE_VALUE (-1)
```

#### Memory Allocation

| Linux | Windows | Notes |
|-------|---------|-------|
| `mmap(NULL, len, prot, flags, -1, 0)` (rax=9) | `VirtualAlloc(NULL, len, MEM_COMMIT\|MEM_RESERVE, PAGE_READWRITE)` | Anonymous memory |
| `munmap(addr, len)` (rax=11) | `VirtualFree(addr, 0, MEM_RELEASE)` | |
| `brk(addr)` (rax=12) | No direct equivalent; use `HeapAlloc/HeapFree` or `VirtualAlloc` | Linux `brk` is legacy |

**VirtualAlloc example:**

```asm
EXTERN VirtualAlloc:PROC

; Allocate 4096 bytes RW
sub rsp, 32
mov rcx, 0          ; lpAddress = NULL (let system choose)
mov rdx, 4096       ; dwSize
mov r8, 3000h       ; flAllocationType = MEM_COMMIT | MEM_RESERVE
mov r9, 4           ; flProtect = PAGE_READWRITE
call VirtualAlloc
add rsp, 32
; rax = base address or NULL on failure
```

**Protection flags:**

| Linux `PROT_*` | Windows `PAGE_*` |
|----------------|------------------|
| `PROT_READ` (1) | `PAGE_READONLY` (2) |
| `PROT_WRITE` (2) | `PAGE_READWRITE` (4) |
| `PROT_EXEC` (4) | `PAGE_EXECUTE_READ` (0x20) |
| `PROT_READ\|PROT_WRITE` | `PAGE_READWRITE` (4) |

#### Terminal Control (Raw Mode)

| Linux | Windows | Notes |
|-------|---------|-------|
| `ioctl(0, TCGETS, &termios)` (rax=16) | `GetConsoleMode(stdin_handle, &mode)` | |
| `ioctl(0, TCSETS, &termios)` | `SetConsoleMode(stdin_handle, mode)` | |

**Raw mode implementation:**

Linux: Clear `ICANON` and `ECHO` bits in `termios.c_lflag`

Windows: Clear `ENABLE_LINE_INPUT` and `ENABLE_ECHO_INPUT` in console mode:

```asm
EXTERN GetConsoleMode:PROC
EXTERN SetConsoleMode:PROC

.data?
mode DWORD ?

.code
; Get current mode
sub rsp, 32
mov rcx, stdin_handle
lea rdx, mode
call GetConsoleMode

; Clear ENABLE_LINE_INPUT (2) and ENABLE_ECHO_INPUT (4)
mov eax, mode
and eax, NOT (2 OR 4)   ; Clear bits
mov mode, eax

; Set new mode
mov rcx, stdin_handle
mov edx, mode
call SetConsoleMode
add rsp, 32
```

**Reading keypresses:**

Linux raw mode: `read(0, buf, 1)` returns each key immediately

Windows: `ReadConsoleInputA` for full input events (key down/up, mouse), or `ReadFile` after disabling line input

#### Timing

| Linux | Windows | Notes |
|-------|---------|-------|
| `clock_gettime(CLOCK_MONOTONIC, &ts)` (rax=228) | `QueryPerformanceCounter(&count)` + `QueryPerformanceFrequency(&freq)` | High-resolution timer |
| `nanosleep(&req, &rem)` (rax=35) | `Sleep(milliseconds)` | Windows Sleep is millisecond granularity |

**QueryPerformanceCounter example:**

```asm
EXTERN QueryPerformanceCounter:PROC
EXTERN QueryPerformanceFrequency:PROC

.data?
start_count QWORD ?
frequency QWORD ?

.code
sub rsp, 32
lea rcx, frequency
call QueryPerformanceFrequency

lea rcx, start_count
call QueryPerformanceCounter
add rsp, 32

; Compute elapsed milliseconds later:
; elapsed_ms = (current_count - start_count) * 1000 / frequency
```

**Sleep:**

```asm
EXTERN Sleep:PROC
mov rcx, 16         ; milliseconds
call Sleep
```

#### Process Arguments

| Linux | Windows | Notes |
|-------|---------|-------|
| Args on stack at entry | `GetCommandLineA()` → string | Returns full command line as single string |
| Parse `/proc/self/cmdline` | `CommandLineToArgvW()` (user32.lib) | Parses into argv array |

**Simple approach:** Call `GetCommandLineA` for the raw string.

#### Polling / Waiting

| Linux | Windows | Notes |
|-------|---------|-------|
| `poll(fds, nfds, timeout)` (rax=7) | `WaitForSingleObject(handle, timeout_ms)` | Single handle |
| | `WaitForMultipleObjects(count, handles, waitAll, timeout_ms)` | Multiple handles |

**Console input waiting:**

```asm
EXTERN WaitForSingleObject:PROC

; Wait for stdin input
mov rcx, stdin_handle
mov rdx, 100        ; timeout in milliseconds (INFINITE = -1)
call WaitForSingleObject
; rax = 0 (WAIT_OBJECT_0) if signaled, 0x102 (WAIT_TIMEOUT) if timeout
```

#### Process Management

| Linux | Windows | Notes |
|-------|---------|-------|
| `fork()` (rax=57) | **No direct equivalent** | Windows uses `CreateProcess` + parent-child IPC |
| `exec*()` (rax=59) | `CreateProcessA(...)` | Creates new process |
| `wait4()` (rax=61) | `WaitForSingleObject(process_handle, ...)` | |
| `getpid()` (rax=39) | `GetCurrentProcessId()` | Returns DWORD |
| Signals (rax=13, etc.) | **No POSIX signals** | Use structured exception handling or events |

**Fork/exec has no Windows equivalent:** Lessons teaching `fork()` and `exec()` must be redesigned. See lesson mapping table.

#### Pipe

| Linux | Windows | Notes |
|-------|---------|-------|
| `pipe(fds[2])` (rax=22) | `CreatePipe(&read, &write, NULL, size)` | |

```asm
EXTERN CreatePipe:PROC

.data?
read_handle QWORD ?
write_handle QWORD ?

.code
sub rsp, 32
lea rcx, read_handle
lea rdx, write_handle
mov r8, 0           ; security attrs
mov r9, 0           ; default size
call CreatePipe
add rsp, 32
```

### Comprehensive Syscall Table

This table lists every Linux syscall actually used in lessons 00-18 and its Windows equivalent:

| Syscall | Number | Used In | Windows Replacement | Notes |
|---------|--------|---------|---------------------|-------|
| `exit` | 60 | 00, all | `ExitProcess(code)` | RCX=code |
| `write` | 1 | 00, 03, 08, 10, 14 | `GetStdHandle` + `WriteFile` or `WriteConsoleA` | Handle-based |
| `read` | 0 | 08, 10 | `GetStdHandle` + `ReadFile` or `ReadConsoleA` | Handle-based |
| `open` | 2 | 08, 10 | `CreateFileA` | 7 arguments |
| `close` | 3 | 08, 10 | `CloseHandle` | Takes HANDLE |
| `lseek` | 8 | 08 | `SetFilePointerEx` | 64-bit offset |
| `mmap` | 9 | 08 | `VirtualAlloc` | Different flags |
| `munmap` | 11 | 08 | `VirtualFree` | Takes addr, 0, MEM_RELEASE |
| `brk` | 12 | 08 | `HeapAlloc` or `VirtualAlloc` | No direct `brk` |
| `ioctl` | 16 | 10 | `GetConsoleMode`, `SetConsoleMode` | Console-specific |
| `pipe` | 22 | 08 | `CreatePipe` | Returns two HANDLEs |
| `dup` / `dup2` | 32, 33 | 08 | `DuplicateHandle` | |
| `getpid` | 39 | 08 | `GetCurrentProcessId` | Returns DWORD |
| `fork` | 57 | *none directly* | **No equivalent** | See lesson mapping |
| `execve` | 59 | *none directly* | `CreateProcessA` | Different model |
| `wait4` | 61 | *none directly* | `WaitForSingleObject` | Process handle |
| `clock_gettime` | 228 | 15 | `QueryPerformanceCounter` + `QueryPerformanceFrequency` | High-res timer |
| `nanosleep` | 35 | 15 | `Sleep(milliseconds)` | Millisecond granularity |
| `poll` | 7 | 15 | `WaitForSingleObject` / `WaitForMultipleObjects` | |

**Items with no Windows equivalent:**
- Raw `syscall` instruction itself (lesson 00 teaches the mechanism, but Windows doesn't use it)
- `fork()` (no copy-on-write process cloning)
- POSIX signals (no `signal`, `sigaction`, `kill`)
- `brk()` (legacy; replaced by heap allocators)

---

## Binary Format: ELF to PE/COFF

### Overview

Linux executables use **ELF** (Executable and Linkable Format). Windows uses **PE** (Portable Executable) based on **COFF** (Common Object File Format).

### Sections

| ELF Section | PE/COFF Section | Notes |
|-------------|-----------------|-------|
| `.text` | `.text` | Executable code |
| `.data` | `.data` | Initialized read-write data |
| `.rodata` | `.rdata` or `.text` | Read-only data (often merged) |
| `.bss` | `.bss` (rare) or `.data` | Uninitialized data; PE may not emit separate .bss |

**PE section naming:** By convention, sections start with a dot (`.text`, `.data`), but MASM assembler output sections are controlled by directives (`.code`, `.data`, `.const`, `.data?`).

**ml64 output sections:**
- `.code` → `.text` section (executable, read-only)
- `.data` → `.data` section (read-write)
- `.const` → `.rdata` section (read-only data)
- `.data?` → uninitialized space in `.data` section

### Relocations and RIP-Relative Addressing

**ELF (Linux):**
- Can be position-independent (PIE) or absolute
- Uses `R_X86_64_PC32` (RIP-relative) or `R_X86_64_64` (absolute 64-bit) relocations
- NASM `[rel symbol]` generates RIP-relative

**PE/COFF (Windows):**
- x64 binaries are always position-independent by default (kernel relocates at load)
- Uses `IMAGE_REL_AMD64_REL32` (RIP-relative) relocations
- ml64 generates RIP-relative addressing **automatically** for `[symbol]` in 64-bit mode

**Key point:** Windows x64 requires RIP-relative addressing for most data accesses. MASM does this by default; you don't specify `rel`.

### Imports and Exports

**ELF:**
- Uses dynamic symbol table (`.dynsym`) and PLT/GOT for shared libraries
- Static linking embeds code directly

**PE:**
- Uses **Import Address Table (IAT)** for imported functions
- `EXTERN FunctionName:PROC` + `call FunctionName` generates `call qword ptr [__imp_FunctionName]` (indirect call through IAT)
- Exports defined with `PUBLIC` or `EXPORT` (for DLLs)

**INCLUDELIB directive:** Tells the linker to search a library:

```asm
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
```

Alternatively, pass libraries on the link command line: `link /OUT:prog.exe prog.obj kernel32.lib`

### Entry Point

**ELF (Linux):**
- Default entry is `_start`
- Linker looks for `_start` symbol

**PE (Windows):**
- Default entry depends on subsystem and linker settings
- `/ENTRY:main` specifies entry point
- Must also set `/SUBSYSTEM:CONSOLE` for console apps

**Link command example:**

```
link /OUT:hello.exe /ENTRY:main /SUBSYSTEM:CONSOLE hello.obj kernel32.lib
```

### Address Space

**Linux:**
- PIE binaries load at random address (ASLR)
- Stack starts near 0x7fffffffffff

**Windows:**
- `/LARGEADDRESSAWARE:NO` limits executable to low 2 GB (0-0x7FFFFFFF)
- `/LARGEADDRESSAWARE:YES` (default for x64) allows full address space
- Stack starts near 0x00000000001FFFFF and grows down (but full 64-bit space available)

**For this course:** Use default LARGEADDRESSAWARE (full 64-bit space). No special considerations needed unless we teach address space layout explicitly.

### Debug Info

**ELF:**
- DWARF debug info embedded in `.debug_*` sections
- `nasm -g` generates DWARF

**PE:**
- PDB (Program Database) or COFF debug info
- `ml64 /Zi` generates debug info
- `link /DEBUG` creates PDB file

---

## Exit Code Semantics

### Linux (8-bit status)

Linux `exit(status)` uses a 32-bit argument, but the shell retrieves only the **low 8 bits** via `waitpid()`. Exit codes are 0-255.

**Example:** `exit(300)` becomes 300 & 0xFF = 44 in the shell.

### Windows (32-bit code)

Windows `ExitProcess(exitCode)` takes a UINT (32-bit) and returns the full value to the parent via `GetExitCodeProcess()`. PowerShell and cmd.exe expose this as `$LASTEXITCODE` and `%ERRORLEVEL%`.

**Example:** `ExitProcess(300)` returns 300.

### Test Harness Comparison Strategy

To maintain compatibility with existing Linux exit-code tests:

1. **Solutions use the same numeric exit codes** (e.g., exit with 7)
2. **Harness checks low 8 bits only** when comparing expected vs. actual

**PowerShell example:**

```powershell
$exitCode = $LASTEXITCODE -band 0xFF
if ($exitCode -ne $expected) {
    Write-Error "Expected $expected, got $exitCode"
}
```

This ensures that a test expecting exit code 7 on Linux (which uses only 8 bits) also passes on Windows if the program exits with 7 (or 7 + 256*N, though we won't do that).

**Note:** If a drill explicitly tests large values (e.g., "exit 256 and observe it wraps to 0 on Linux"), the Windows version must document that Windows does NOT wrap. We'll flag such drills in the lesson mapping.

---

## Lesson-by-Lesson Mapping

This table analyzes each lesson (00-18) and categorizes it:

- **Ports directly:** Concepts and syntax map cleanly; syscalls have Win32 equivalents
- **Needs rework:** Core concept holds, but major changes required (different API shape, significant boilerplate)
- **No Windows equivalent:** Linux-specific mechanism with no direct analog; requires replacement concept

| Lesson | Slug | Status | Notes | Replacement Concept |
|--------|------|--------|-------|---------------------|
| **00** | tools-registers-mov-syscall | **Needs rework** | NASM→MASM syntax; `syscall`→function calls; `_start`→`main PROC`; hello world and exit map cleanly but syntax is all different | Teach MASM directives, Win32 calls, `main` entry, no `syscall` instruction |
| **01** | addressing-data | **Ports directly** | `.data`/`.bss`/`.rodata`→`.data`/`.data?`/`.const`; addressing modes unchanged; `lea` and SIB identical; RIP-relative is default | Minor syntax (OFFSET for addresses) |
| **02** | arithmetic-flags | **Ports directly** | Arithmetic instructions identical; RFLAGS unchanged; `setcc` same | None |
| **03** | control-flow | **Ports directly** | Jumps, loops, conditionals identical | None |
| **04** | stack-calling-convention | **Needs rework** | System V→MS x64 ABI: RDI/RSI/RDX/RCX→RCX/RDX/R8/R9; 6 reg args→4; add shadow space; RSI/RDI nonvolatile | Teach MS x64 ABI, shadow space, 4 register args, stack alignment |
| **05** | procedures-recursion | **Needs rework** | Recursion identical, but ABI affects arg passing and prologue/epilogue; must teach `PROC`/`ENDP` | Same as 04; show PROC syntax |
| **06** | strings-memory-arrays | **Ports directly** | `rep movsb`/`stosb` unchanged; memory operations identical | None |
| **07** | bitops-shifts-masks | **Ports directly** | Bit operations identical | None |
| **08** | syscalls-files-mmap | **Needs rework** | Core file I/O and memory allocation work, but API is entirely different: `open`→`CreateFileA`, `mmap`→`VirtualAlloc`, etc.; error handling changes from negative errno to BOOL+GetLastError | Teach Win32 file API and VirtualAlloc; brk stub becomes HeapAlloc demo; pipe maps to CreatePipe |
| **09** | macros-multifile-make | **Needs rework** | `%macro`→`MACRO`; multi-file linking works; Makefile→build.ps1 or MSBuild | Teach MASM macros, EXTERN/PUBLIC, PowerShell build script (or batch) |
| **10** | milestone-cli-editor | **Needs rework** | Buffer/cursor/gap-buffer logic identical; file I/O maps to Win32; **raw mode is the big change**: `ioctl TCGETS/TCSETS`→`GetConsoleMode/SetConsoleMode`; reading keypresses: `ReadConsoleInput` or `ReadFile` with line-input disabled | Teach Windows console modes; replace termios with console API; rest of editor logic unchanged |
| **11** | parsing-datastructures | **Ports directly** | Parsing, linked lists, hash maps, arena allocators are pure algorithm; no syscalls except memory (VirtualAlloc) | None (or see 08 for memory) |
| **12** | milestone-tiny-compiler | **Ports directly** (mostly) | Lexer, parser, codegen are pure algorithm; if compiler emits ELF directly, teach PE instead (or emit MASM source) | Emitting MASM source is simplest; advanced students can emit PE |
| **13** | fp-simd-fixedpoint | **Ports directly** | Fixed-point math and SSE instructions identical | None |
| **14** | graphics-framebuffer | **Ports directly** | PPM file output uses `CreateFileA`+`WriteFile`; pixel math identical | Already covers file I/O from 08 |
| **15** | input-timing-gameloop | **Needs rework** | Timing: `clock_gettime`→`QueryPerformanceCounter`; sleep: `nanosleep`→`Sleep`; input: console input API or polling; **poll() not applicable** | Teach `QueryPerformanceCounter` + `Sleep`; console input API for keypresses; no `poll` on HANDLEs (use WaitForSingleObject if needed) |
| **16** | sprites-tilemaps-collision | **Ports directly** | Pure algorithm (AABB, spatial hash, tile indexing) | None |
| **17** | entities-pathfinding-ui | **Ports directly** | ECS, pathfinding (BFS, A*), UI hit-testing are pure algorithm | None |
| **18** | capstone-park-sim | **Needs rework** | Integration of 00-17; file I/O and timing use Win32; the game loop and simulation logic are identical; save/load uses Win32 file API | Combines all Win32 concepts from 04, 08, 10, 15 |

### Lessons with No Direct Windows Equivalent (and Replacements)

| Concept | Lessons | Issue | Replacement |
|---------|---------|-------|-------------|
| **Raw `syscall` instruction** | 00 | Windows doesn't use syscall; kernel services are via API calls | Teach calling Win32 API functions; show that `syscall` is a Linux mechanism, not x86-64 in general |
| **termios / ioctl TCGETS/TCSETS** | 10 | No POSIX termios on Windows | `GetConsoleMode` / `SetConsoleMode` with `ENABLE_LINE_INPUT`, `ENABLE_ECHO_INPUT` bits |
| **poll()** | 15 | Linux-specific polling syscall | `WaitForSingleObject` / `WaitForMultipleObjects` on console handles (or skip if lesson only uses timing) |
| **fork()** | *none* (not in 00-18) | No fork in lessons | N/A (if it were taught, replace with CreateProcess + IPC) |
| **execve()** | *none* | Not taught | N/A |
| **brk()** | 08 (stub only) | Legacy syscall; Windows has no equivalent | `HeapAlloc` from process heap, or `VirtualAlloc` |
| **Signals** | *none* | POSIX signals (SIGINT, SIGTERM) not used in 00-18 | N/A (if taught, replace with structured exceptions or events) |
| **ANSI escape codes** | *implied in some drills?* | Work in Windows 10+ with ENABLE_VIRTUAL_TERMINAL_PROCESSING, but less reliable | Document enabling VT mode or use SetConsoleCursorPosition API |

**Summary:**
- **Syscall instruction itself** (lesson 00) is taught as "Linux mechanism"; Windows version explains why we call functions instead
- **termios** (lesson 10) maps to Windows console mode flags
- **poll** (lesson 15) maps to WaitForSingleObject if needed (though most of lesson 15 is timing, which ports fine)
- **brk** (lesson 08 stub) becomes a HeapAlloc example or VirtualAlloc
- No fork/exec/signals in the course, so no replacement needed

---

## Build and Test Harness

### Harness Design

Create a **PowerShell script** `test.ps1` (and/or `build.ps1`) that:

1. **Assembles** all `.asm` files with `ml64.exe`
2. **Links** with `link.exe /ENTRY:main /SUBSYSTEM:CONSOLE kernel32.lib`
3. **Runs** each solution binary
4. **Checks** exit code (low 8 bits) and stdout against expected values
5. **Reports** pass/fail for each test

**Test metadata:** Store expected exit codes and stdout in:
- Inline comments (e.g., `; Expected exit: 42`)
- Separate `.expected` files (e.g., `01-exit-zero.expected` contains `exit=0`)
- JSON or TOML manifest

**Recommendation:** Use inline comments for simplicity:

```asm
; Expected exit: 7
; Expected stdout: "Hello\n"
```

The harness parses these comments.

### Build Process

**For a single drill:**

```powershell
# Assemble
ml64 /c /Zi 01-exit-zero.asm
# /c = compile only, /Zi = debug info

# Link
link /OUT:01-exit-zero.exe /ENTRY:main /SUBSYSTEM:CONSOLE /DEBUG 01-exit-zero.obj kernel32.lib

# Run
.\01-exit-zero.exe
$exitCode = $LASTEXITCODE -band 0xFF
```

**For all solutions in a lesson:**

```powershell
$lessons = Get-ChildItem -Directory lessons\*

foreach ($lesson in $lessons) {
    $solutions = Get-ChildItem "$($lesson.FullName)\solutions\*.asm"
    foreach ($sol in $solutions) {
        # Assemble and link (as above)
        # Run and check
    }
}
```

### Checking Expected Values

**Exit code:**

```powershell
$expected = 42
$actual = $LASTEXITCODE -band 0xFF
if ($actual -ne $expected) {
    Write-Error "FAIL: Expected $expected, got $actual"
} else {
    Write-Host "PASS"
}
```

**Stdout:**

Redirect stdout to a file, compare:

```powershell
.\01-hello.exe > actual.txt
$expected = "Hello, world`n"
$actual = Get-Content actual.txt -Raw
if ($actual -ne $expected) {
    Write-Error "FAIL: stdout mismatch"
}
```

**Note:** Windows line endings (`\r\n`) vs. Linux (`\n`) may cause issues. Normalize newlines or accept either.

### Exercise Scaffolds Must Fail

**Requirement:** Untouched exercise files must NOT pass tests. They contain skeleton code or TODOs.

**Approach:**

1. Exercise files exit with a special "not implemented" code (e.g., 255 or 99) by default
2. Harness knows to expect failure for exercises
3. OR: Harness only tests solutions, not exercises

**Preferred:** Test only solutions; exercises are for students to complete. The CI pipeline runs solutions only.

### File Naming and Artifacts

- **Source:** `.asm` extension (was `.asm` on Linux too)
- **Object:** `.obj` (generated by ml64)
- **Executable:** `.exe`
- **Artifacts:** Do NOT commit `.obj` or `.exe` files

**`.gitignore` additions:**

```gitignore
# Windows build artifacts
*.obj
*.exe
*.ilk
*.pdb
*.res
```

### Finding ml64 and link

**Problem:** ml64.exe and link.exe are only in PATH when running from the "x64 Native Tools Command Prompt for VS".

**Solutions:**

1. **Require running from VS command prompt:** Document that users must run from the x64 Native Tools Command Prompt.

2. **Auto-detect with vswhere:** Use `vswhere.exe` to find Visual Studio installation, then call `VsDevCmd.bat`:

```powershell
# Find vswhere
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    throw "vswhere.exe not found; install Visual Studio with C++ tools"
}

# Find VS installation
$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath

# Source VsDevCmd.bat to set environment
$vcvars = "$vsPath\Common7\Tools\VsDevCmd.bat"
cmd /c "`"$vcvars`" && set" | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        Set-Item "env:\$($matches[1])" $matches[2]
    }
}

# Now ml64 and link are in PATH
```

**Recommendation:** Document both approaches; prefer running from VS command prompt for simplicity.

### Test Harness Structure

**`test.ps1`:**

```powershell
# Usage: .\test.ps1 [lesson-number]
param([string]$Lesson = "*")

$ErrorActionPreference = "Stop"

function Test-Solution {
    param($AsmFile)
    
    $name = [System.IO.Path]::GetFileNameWithoutExtension($AsmFile)
    $dir = Split-Path $AsmFile
    
    # Parse expected values from comments
    $expectedExit = (Select-String "Expected exit:\s*(\d+)" $AsmFile).Matches[0].Groups[1].Value
    $expectedStdout = (Select-String "Expected stdout:\s*(.+)" $AsmFile).Matches[0].Groups[1].Value
    
    # Assemble
    ml64 /c /nologo /Zi $AsmFile /Fo:"$dir\$name.obj" | Out-Null
    
    # Link
    link /nologo /OUT:"$dir\$name.exe" /ENTRY:main /SUBSYSTEM:CONSOLE /DEBUG "$dir\$name.obj" kernel32.lib | Out-Null
    
    # Run
    $stdout = & "$dir\$name.exe" 2>&1
    $exit = $LASTEXITCODE -band 0xFF
    
    # Check
    $pass = $true
    if ($expectedExit -and ($exit -ne [int]$expectedExit)) {
        Write-Host "FAIL: $name (exit $exit, expected $expectedExit)" -ForegroundColor Red
        $pass = $false
    }
    if ($expectedStdout -and ($stdout -ne $expectedStdout)) {
        Write-Host "FAIL: $name (stdout mismatch)" -ForegroundColor Red
        $pass = $false
    }
    
    if ($pass) {
        Write-Host "PASS: $name" -ForegroundColor Green
    }
    
    # Clean up
    Remove-Item "$dir\$name.obj", "$dir\$name.exe", "$dir\$name.pdb" -ErrorAction SilentlyContinue
}

# Find and test all solutions
Get-ChildItem "lessons\$Lesson-*\solutions\*.asm" | ForEach-Object {
    Test-Solution $_.FullName
}
```

**Note:** This is a simplified example. Production harness should handle errors, report summary, support timeout, etc.

---

## CI Design

### GitHub Actions Workflow

Create `.github/workflows/windows.yml` to run on `windows-latest`:

```yaml
name: Windows Port CI

on:
  push:
    branches: [windows-port, 'cursor/*-9de4']
  pull_request:
    branches: [windows-port]

jobs:
  build-and-test:
    runs-on: windows-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Set up MSVC
      uses: ilammy/msvc-dev-cmd@v1
      with:
        arch: x64
    
    - name: Verify ml64 and link
      run: |
        ml64 /?
        link /?
    
    - name: Build smoke test
      run: |
        cd tools\windows\smoke
        ml64 /c /nologo hello.asm
        link /nologo /OUT:hello.exe /ENTRY:main /SUBSYSTEM:CONSOLE hello.obj kernel32.lib
    
    - name: Run smoke test
      run: |
        cd tools\windows\smoke
        .\hello.exe
        echo "Exit code: $LASTEXITCODE"
    
    - name: Check smoke test output
      shell: pwsh
      run: |
        cd tools\windows\smoke
        $output = .\hello.exe
        $exit = $LASTEXITCODE
        if ($output -notmatch "Hello") {
          throw "Smoke test failed: wrong output"
        }
        if ($exit -ne 42) {
          throw "Smoke test failed: exit code $exit, expected 42"
        }
        Write-Host "Smoke test passed!"
    
    # Future: run full test harness
    # - name: Run test harness
    #   run: .\test.ps1
```

**Key points:**

- **`windows-latest`:** Currently Windows Server 2022 with Visual Studio 2022 (not 2026, which doesn't exist yet as of October 2024/2026 in this scenario)
- **`ilammy/msvc-dev-cmd@v1`:** Action that sets up MSVC environment variables (ml64, link in PATH)
- **Smoke test:** Minimal hello/exit program to prove toolchain works

### Visual Studio Version on windows-latest

As of late 2024, **`windows-latest` uses Windows Server 2022 with Visual Studio 2022**. Visual Studio 2026 does not exist yet (as of real-world October 2024).

**For this spec:** Assume VS 2022 on windows-latest. All ml64/link features used in this course are stable and present in VS 2019+, so version differences are minimal.

**If ml64 differences matter:**

- **ml64 version:** Part of MSVC toolset; major updates are rare for asm syntax
- **Known quirks:** None that affect this course (PROC/ENDP, EXTERN, OFFSET have been stable for years)

**Action:** Document that the course targets **VS 2019 or later**. Students using older versions (VS 2017-) may encounter issues.

---

## Phase 2 Work Split

Phase 2 involves porting all code (solutions, exercises, listings, prose) across 19 lessons. The work is split into three parallel branches, each merging into `windows-port`.

### Proposed Split

**Partition principle:** Minimize file conflicts; group by artifact type.

| Person | Responsibility | Files | Branch Name | Estimated Scope |
|--------|---------------|-------|-------------|-----------------|
| **Bruce** | Toolchain, harness, CI, all `solutions/` (00-18) | `test.ps1`, `build.ps1`, `.github/workflows/windows.yml`, `lessons/*/solutions/*.asm`, `docs/WINDOWS_PORT_SPEC.md` (this file) | `cursor/bruce-solutions-9de4` | ~475 solution files; hardest are 10-18 (milestones, advanced syscalls) |
| **Jack Gable** | In-lesson listings, worked examples, `exercises/` scaffolds | All code blocks in `LESSON.md` files (inline listings), `lessons/*/exercises/*.asm` | `cursor/jack-exercises-9de4` | ~475 exercise scaffolds + inline code in 19 LESSON.md files |
| **Monk** | Prose, pedagogical content, LESSON.md text | `lessons/*/LESSON.md` (all prose sections, tables, explanations), `docs/LEARNING_ROADMAP.md` updates | `cursor/monk-prose-9de4` | 19 LESSON.md files; rewriting syscall explanations, ABI sections, tool output examples |

### File Globs per Person

**Bruce (solutions + toolchain):**
```
lessons/*/solutions/*.asm
test.ps1
build.ps1
tools/windows/**
.github/workflows/windows.yml
.gitignore
docs/WINDOWS_PORT_SPEC.md
```

**Jack Gable (exercises + listings):**
```
lessons/*/exercises/*.asm
# Note: LESSON.md *code blocks* only (not prose); coordinate with Monk to avoid conflicts
# Jack extracts code blocks from Linux lessons, converts to MASM, updates them in place
# Monk rewrites prose around those code blocks
```

**Monk (prose):**
```
lessons/*/LESSON.md
docs/LEARNING_ROADMAP.md
docs/AUTHORING.md (if Windows-specific authoring rules needed)
```

**Conflict resolution:**

- **`LESSON.md` files:** Both Jack and Monk edit these. Strategy:
  - **Jack:** Edits only code blocks (fenced code sections) and inline code references
  - **Monk:** Edits prose, section structure, tables, explanations (leaves code blocks alone after Jack has updated them)
  - **Coordination:** Jack finishes code blocks first, commits; Monk pulls and updates prose around them
  - **Alternative:** Monk does first pass on prose (changing terminology, rewriting syscall sections), Jack then updates code blocks

**Branch strategy:**

1. Bruce creates `cursor/bruce-solutions-9de4` off `windows-port`, ports all solutions + toolchain
2. Jack creates `cursor/jack-exercises-9de4` off `windows-port`, ports all exercises + in-lesson code
3. Monk creates `cursor/monk-prose-9de4` off `windows-port`, rewrites LESSON.md prose

Each opens a PR into `windows-port`. PRs are reviewed and merged sequentially or in parallel with merge coordination.

**Merge order (recommended):**

1. **Bruce's toolchain + harness first:** Establishes test infrastructure
2. **Jack's exercises + code** next: Provides working code examples
3. **Monk's prose** last: Finalizes explanations around working code

Alternatively, all three work in parallel and merge simultaneously (requires careful conflict resolution).

### Hardest Lessons (Bruce's Domain)

**10-18** are the hardest solutions (milestone projects + advanced topics):

- **Lesson 10 (CLI editor):** termios → console mode, raw input, ioctl → GetConsoleMode/SetConsoleMode
- **Lesson 12 (tiny compiler):** ELF emission → PE or MASM source generation
- **Lesson 15 (timing + input):** clock_gettime → QueryPerformanceCounter, poll → WaitForSingleObject
- **Lesson 18 (capstone park sim):** Integration of all Win32 APIs

**Bruce** will tackle these solutions first, documenting patterns for Jack and Monk to follow.

### Coordination Points

**Weekly sync:** Ensure code-to-prose consistency, especially for:

- Lesson 00 (first impression)
- Lesson 04 (ABI change is most visible here)
- Lesson 08 (syscall → Win32 API transition)
- Lesson 10 (milestone 1: termios → console API)

**Shared glossary:** Maintain a list of term mappings (e.g., "file descriptor" → "HANDLE", "syscall" → "Win32 API function") for consistency.

---

## Appendix A: Smoke Test Code

Located in `tools/windows/smoke/hello.asm`:

```asm
; Smoke test for Windows MASM toolchain
; Prints "Hello from Windows x64!" to stdout and exits with code 42

EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN ExitProcess:PROC

.data
msg BYTE "Hello from Windows x64!", 13, 10, 0
msg_len EQU $ - msg - 1  ; exclude null terminator

.data?
written DWORD ?

.code
main PROC
    sub rsp, 40         ; shadow space (32) + align (8)
    
    ; Get stdout handle
    mov rcx, -11        ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov rbx, rax        ; save handle
    
    ; Write message
    mov rcx, rbx        ; console handle
    lea rdx, msg
    mov r8d, msg_len    ; character count
    lea r9, written
    mov QWORD PTR [rsp+32], 0  ; reserved
    call WriteConsoleA
    
    ; Exit with code 42
    mov rcx, 42
    call ExitProcess
main ENDP
END
```

**Build command:**

```batch
ml64 /c /nologo hello.asm
link /nologo /OUT:hello.exe /ENTRY:main /SUBSYSTEM:CONSOLE hello.obj kernel32.lib
```

**Expected output:**

```
Hello from Windows x64!
```

**Expected exit code:** 42

---

## Appendix B: Glossary of Term Mappings

| Linux / System V | Windows / MS x64 | Notes |
|------------------|------------------|-------|
| syscall | Win32 API function call | No `syscall` instruction |
| file descriptor (fd) | HANDLE | Opaque pointer, not small integer |
| stdin/stdout/stderr (0/1/2) | GetStdHandle(STD_INPUT_HANDLE=-10, etc.) | Must call GetStdHandle |
| errno (negative return) | GetLastError() | Separate function call |
| `_start` | `main` | Entry point name |
| `section .text` | `.code` | MASM directive |
| `section .data` | `.data` | MASM directive |
| `section .bss` | `.data?` | Uninitialized data |
| `section .rodata` | `.const` | Read-only data |
| `global symbol` | `PUBLIC symbol` or `PROC` | Export |
| `extern symbol` | `EXTERN symbol:PROC` | Import (with type) |
| `equ` | `EQU` or `=` | Constant |
| `%macro` | `MACRO` | Macro definition |
| `[rel addr]` | `[addr]` | RIP-relative (default in 64-bit MASM) |
| RDI (arg 1) | RCX | First integer argument |
| RSI (arg 2) | RDX | Second integer argument |
| RDX (arg 3) | R8 | Third integer argument |
| RCX (arg 4) | R9 | Fourth integer argument |
| R8 (arg 5) | stack | Fifth integer argument |
| R9 (arg 6) | stack | Sixth integer argument |
| Caller-saved: RDI, RSI | Nonvolatile: RDI, RSI | **Opposite** on Windows! |

---

## Appendix C: References

- **Microsoft x64 ABI:** https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions
- **MASM for x64:** https://learn.microsoft.com/en-us/cpp/assembler/masm/masm-for-x64-ml64-exe
- **Win32 API (Kernel32):** https://learn.microsoft.com/en-us/windows/win32/api/
- **Intel/AMD64 Architecture Reference:** Same as Linux (x86-64 instructions are platform-independent)
- **PE Format:** https://learn.microsoft.com/en-us/windows/win32/debug/pe-format

---

## Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-10-20 | 1.0 | Cursor Agent (Phase 1) | Initial specification |

---

**End of Specification**
