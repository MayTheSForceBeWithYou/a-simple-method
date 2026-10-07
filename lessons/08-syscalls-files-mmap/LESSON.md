# 08 — Syscalls, Files, mmap

You've been calling `write` and `exit` on faith since lesson 00. This lesson reveals the register protocol Linux x86-64 syscalls demand, shows you how to read errors encoded as negative return values, and equips you to call `open`, `read`, `close`, `lseek`, and `mmap` without ever invoking libc. By the end you'll see that a syscall is not a magic word—it's just a register contract you honor.

## What this lesson asks of you

- Place syscall number in `rax`, arguments in `rdi, rsi, rdx, r10, r8, r9`, and interpret the `rax` return.
- Recognize when `rax` encodes `-errno` (values above `0xfffffffffffff000`) and negate to recover the error number.
- Call `open` with path, flags (`O_RDONLY`, `O_WRONLY`, `O_CREAT`, `O_TRUNC`), and mode, receiving a file descriptor.
- Pass that file descriptor to `read`, `write`, `lseek`, or `close`.
- Map anonymous memory with `mmap` and release it with `munmap`.
- Use `r10` for the fourth syscall argument, not `rcx` (which `syscall` clobbers).

## The syscall register protocol

A syscall is a controlled transfer into kernel mode. The CPU instruction `syscall` reads `rax` as an integer index, switches privilege level, and jumps to a kernel-side dispatch table. The kernel reads argument registers, performs the requested operation, writes a return value into `rax`, and returns control to the next instruction after your `syscall`.

**Syscall argument ABI:**

| Register | Role |
|----------|------|
| `rax` | Syscall number (input), return value (output) |
| `rdi` | Argument 1 |
| `rsi` | Argument 2 |
| `rdx` | Argument 3 |
| `r10` | Argument 4 (not `rcx`; `syscall` clobbers `rcx` and `r11`) |
| `r8` | Argument 5 |
| `r9` | Argument 6 |

The instruction clobbers `rcx` (saved `rip`) and `r11` (saved `rflags`). All other registers—including `rdi` through `r9`—remain intact after the syscall returns. If you need the fd again for a second operation, you don't have to reload it.

**Common syscalls:**

| Number | Name | Arg1 (`rdi`) | Arg2 (`rsi`) | Arg3 (`rdx`) | Arg4 (`r10`) | Arg5 (`r8`) | Arg6 (`r9`) |
|-------:|------|--------------|--------------|--------------|--------------|-------------|-------------|
| 0 | `read` | fd | buffer | count | — | — | — |
| 1 | `write` | fd | buffer | count | — | — | — |
| 2 | `open` | path | flags | mode | — | — | — |
| 3 | `close` | fd | — | — | — | — | — |
| 8 | `lseek` | fd | offset | whence | — | — | — |
| 9 | `mmap` | addr | length | prot | flags | fd | offset |
| 11 | `munmap` | addr | length | — | — | — | — |
| 12 | `brk` | addr | — | — | — | — | — |
| 22 | `pipe` | fds | — | — | — | — | — |
| 39 | `getpid` | — | — | — | — | — | — |
| 60 | `exit` | status | — | — | — | — | — |
| 228 | `clock_gettime` | clockid | timespec | — | — | — | — |

## Interpreting syscall returns

Most syscalls return 0 on success and encode failure as a negative value. That negative value is not a valid result—it's `-errno`. The kernel cannot return the error code directly because 0 is often a valid success return (for example, `close` or `munmap` return 0). Instead, Linux x86-64 reserves the top page of address space (addresses `≥ 0xfffffffffffff000`) for error codes. When `rax` falls in that range after a syscall, you negate it to recover the `errno`.

**Detection pattern:**

```asm
syscall
test rax, rax
js .error               ; SF set means negative, which means -errno
; success path: rax holds the real return (fd, bytes read, etc.)
jmp .continue

.error:
neg rax                 ; -errno → errno
; rax now holds 2 (ENOENT), 13 (EACCES), etc.
```

A syscall that returns a file descriptor (like `open`) will return a small nonnegative integer (typically 3 or higher) on success, or a negative value on failure. A syscall like `read` or `write` returns the byte count (which may be less than requested) on success, or negative on failure. A syscall like `close` or `munmap` returns 0 on success.

**Why the signed jump works:** When the high bit of a 64-bit value is set, the number is negative in two's complement. `js` (jump if sign) checks the sign flag, which is set when the result's high bit is 1—exactly the top page condition.

## File descriptors and the open-read-write-close cycle

A **file descriptor** is a small nonnegative integer the kernel hands you as a handle for an open file. You pass that integer to `read`, `write`, `lseek`, and `close`. Three descriptors are pre-opened for every process:

| Descriptor | Name | Use |
|-----------:|------|-----|
| 0 | stdin | Standard input (keyboard, redirected file, or pipe) |
| 1 | stdout | Standard output (terminal, redirected file, or pipe) |
| 2 | stderr | Standard error (usually the terminal, unbuffered) |

### Opening a file

Syscall 2 (`open`) takes a null-terminated path string, an integer of bitwise-ORed flags, and a permission mode (used only when creating a new file).

**Common flags:**

| Flag | Value | Meaning |
|------|------:|---------|
| `O_RDONLY` | 0 | Open for reading |
| `O_WRONLY` | 1 | Open for writing |
| `O_RDWR` | 2 | Open for reading and writing |
| `O_CREAT` | 64 | Create the file if it doesn't exist |
| `O_TRUNC` | 512 | Truncate file to zero length if it exists |
| `O_APPEND` | 1024 | Append mode (writes always go to end) |

To open an existing file for reading:

```asm
section .data
    path: db "/tmp/data.txt", 0

section .text
global _start
_start:
    mov rax, 2              ; sys_open
    lea rdi, [path]
    xor rsi, rsi            ; O_RDONLY = 0
    xor rdx, rdx            ; mode unused when not creating
    syscall
    test rax, rax
    js .open_failed
    ; rax now holds the file descriptor (e.g. 3)
```

To create a new file (or truncate an existing one) for writing:

```asm
    mov rax, 2
    lea rdi, [path]
    mov rsi, 64 | 1 | 512   ; O_CREAT | O_WRONLY | O_TRUNC = 577
    mov rdx, 420            ; 0644 octal = rw-r--r--
    syscall
```

The mode `420` is `0644` octal: owner can read/write, group and others can read. The kernel applies your process's umask, so the final permissions may be more restrictive.

### Reading and writing

Once you have a descriptor, `read` (syscall 0) and `write` (syscall 1) transfer bytes:

```asm
    mov rdi, rax            ; fd from open
    mov rax, 0              ; sys_read
    lea rsi, [buffer]       ; destination
    mov rdx, 256            ; count
    syscall
    ; rax = number of bytes read, or 0 at EOF, or negative on error
```

`read` may return fewer bytes than you requested (short read), especially when reading from a pipe or terminal. A return of 0 means end-of-file. A negative return is an error.

`write` is symmetric:

```asm
    mov rdi, fd
    mov rax, 1              ; sys_write
    lea rsi, [data]
    mov rdx, 12
    syscall
    ; rax = bytes written, or negative on error
```

### Seeking

Syscall 8 (`lseek`) moves the file offset:

| `rdx` (whence) | Value | Meaning |
|----------------|------:|---------|
| `SEEK_SET` | 0 | Set offset to `rsi` |
| `SEEK_CUR` | 1 | Add `rsi` to current offset |
| `SEEK_END` | 2 | Set offset to end of file + `rsi` |

```asm
    mov rax, 8              ; sys_lseek
    mov rdi, fd
    xor rsi, rsi            ; offset 0
    xor rdx, rdx            ; SEEK_SET
    syscall
    ; rax = new file offset
```

### Closing

Syscall 3 (`close`) releases the descriptor:

```asm
    mov rax, 3
    mov rdi, fd
    syscall
    ; rax = 0 on success, negative on error
```

After close, the descriptor is invalid. The kernel reuses low-numbered descriptors first, so the next `open` will likely return 3 again if that was the first file you opened.

## Anonymous memory mapping

Syscall 9 (`mmap`) asks the kernel for virtual memory. The most common use in freestanding programs is **anonymous mapping**: memory not backed by any file.

**Arguments for anonymous mmap:**

- `rdi`: address hint (usually 0, let kernel choose)
- `rsi`: length in bytes (must be multiple of page size, typically 4096)
- `rdx`: protection flags (`PROT_READ` = 1, `PROT_WRITE` = 2, combine to 3)
- `r10`: mapping flags (`MAP_PRIVATE` = 2, `MAP_ANONYMOUS` = 32, combine to `0x22`)
- `r8`: file descriptor (must be -1 for anonymous)
- `r9`: offset (must be 0 for anonymous)

```asm
    mov rax, 9              ; sys_mmap
    xor rdi, rdi            ; let kernel pick address
    mov rsi, 4096           ; one page
    mov rdx, 3              ; PROT_READ | PROT_WRITE
    mov r10, 0x22           ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    xor r9, r9
    syscall
    ; rax = base address of new mapping, or negative on error
```

You can now read and write through the pointer in `rax`. The memory is initialized to zero.

To release the mapping:

```asm
    mov rdi, rax            ; address returned by mmap
    mov rax, 11             ; sys_munmap
    mov rsi, 4096           ; same length
    syscall
    ; rax = 0 on success
```

**Why anonymous mmap?** Lesson 18's save file will use `mmap` with a real file descriptor to map the save data directly into memory, avoiding a separate `read` call. Anonymous mappings are useful when you need scratch space larger than the stack, or when you want to control alignment and page boundaries.

## The fourth argument goes in r10, not rcx

The user-space calling convention (lesson 04) uses `rcx` for the fourth argument. But the `syscall` instruction clobbers `rcx` (stores the return address there) and `r11` (stores `rflags`). To avoid losing the fourth argument, the syscall ABI places it in `r10` instead.

```asm
    mov rax, 9              ; mmap
    xor rdi, rdi
    mov rsi, 4096
    mov rdx, 3
    mov r10, 0x22           ; fourth argument, not rcx
    mov r8, -1
    xor r9, r9
    syscall
```

If you accidentally use `rcx`, the kernel will see garbage (the saved `rip`) and the syscall will fail with `EINVAL` or produce unexpected behavior.

## Other syscalls in the drills

- **`brk` (12):** Adjusts the program break (end of the data segment). Called with `rdi = 0` to query the current break, or with a new address to move it. Returns the current (or new) break in `rax`.
- **`pipe` (22):** Creates a unidirectional pipe (kernel buffer). Takes a pointer to two dwords in `rdi`, writes the read-end fd first, then the write-end fd. Returns 0 on success.
- **`getpid` (39):** Returns the process ID in `rax`. Takes no arguments.
- **`clock_gettime` (228):** Reads a monotonic or real-time clock. `rdi` is the clock ID (`CLOCK_MONOTONIC` = 1, `CLOCK_REALTIME` = 0), `rsi` is a pointer to a `timespec` struct (two qwords: seconds and nanoseconds). Returns 0 on success. Lesson 15 uses this for frame timing.

## Worked example: opening a missing file and recovering the error

**Task:** Open `/no/such/file` for reading. If it fails, exit with the errno as the status. If it succeeds, exit 0.

**Step-by-step reasoning:**

1. **Syscall 2 (`open`):** path in `rdi`, flags in `rsi`, mode in `rdx`.
2. **Flags:** We want `O_RDONLY` = 0.
3. **Mode:** Unused when not creating, so 0.
4. **Check return:** `open` returns a nonnegative fd on success, or negative on failure.
5. **Distinguish failure:** Use `test rax, rax` then `js` (jump if sign).
6. **Recover errno:** `neg rax` converts `-errno` to `errno`.
7. **Exit with errno:** Move `rax` to `rdi` and call `exit`.

```asm
section .data
    path: db "/no/such/file", 0

section .text
global _start
_start:
    mov rax, 2              ; sys_open
    lea rdi, [path]
    xor rsi, rsi            ; O_RDONLY
    xor rdx, rdx
    syscall

    test rax, rax
    js .failed              ; negative means -errno

    ; Success path: rax holds fd
    mov rdi, rax            ; (hypothetical: use fd here)
    xor rdi, rdi            ; exit 0
    mov rax, 60
    syscall

.failed:
    neg rax                 ; -errno → errno
    mov rdi, rax            ; exit with errno (2 for ENOENT)
    mov rax, 60
    syscall
```

**Expected output:** Exit status 2 (`ENOENT` = "No such file or directory").

**Plausible wrong reading and why it fails:**

*"The `test rax, rax` could be `cmp rax, 0`, so maybe I should use `jl` (jump if less than) instead of `js`."*

**Why it's wrong:** `jl` checks the signed-less-than condition using `SF ≠ OF`. For a syscall return, `rax` will be in the range `0xfffffffffffff000` to `0xffffffffffffffff` (negative in two's complement), which sets `SF` but not `OF` (no subtraction overflow occurred in the `test`). However, `js` directly checks `SF`, which is set by the high bit. Both work here, but `js` is clearer: it directly tests "is the value negative?" without involving overflow logic. More importantly, `test rax, rax` is preferred over `cmp rax, 0` because it's one byte shorter and conveys intent (test for zero/negative) rather than comparison.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| `rcx` holds the fourth syscall argument | `r10` holds the fourth argument; `syscall` clobbers `rcx` and `r11` |
| A syscall failure returns an error code in `rax` | Failure returns `-errno` (a negative value); you must negate to get the error code |
| `open` returns 0 on success | `open` returns the file descriptor (≥ 0, typically ≥ 3) on success, negative on failure |
| `close` returns the fd on success | `close` returns 0 on success, negative on error |
| `read` always reads the requested count | `read` may return fewer bytes (short read), 0 at EOF, or negative on error |
| `mmap` returns null on failure | `mmap` returns a negative value (`-errno`) on failure; null (0) is a valid address hint input |
| You can `write` to any fd | fd must be valid (returned by `open` or pre-opened 0/1/2) and opened with write permission |

## Check yourself

1. After `syscall`, you have `rax = 0xfffffffffffffffb` (−5 in two's complement). Is this a valid return, or an error? If it's an error, what is the errno?
   
2. You call `open` with `O_WRONLY | O_CREAT | O_TRUNC` and mode 420. Does this create the file if it's missing? Does it empty the file if it exists? What are the final permission bits?

3. You `mmap` 8192 bytes with `PROT_READ | PROT_WRITE` and `MAP_PRIVATE | MAP_ANONYMOUS`, fd −1, offset 0. What value should go in `r10`? Can you write to the returned address?

4. Your `read` call requested 512 bytes but returned 100. Is this an error, or can this happen in normal operation? What does return value 0 mean?

5. You accidentally put the `mmap` flags (0x22) in `rcx` instead of `r10`. What will the kernel see in `r10` after `syscall` executes?

## Key takeaways

- Syscalls follow a strict register contract: number in `rax`, arguments in `rdi, rsi, rdx, r10, r8, r9`, return in `rax`.
- `syscall` clobbers `rcx` and `r11`, so the fourth argument goes in `r10`.
- A return value `≥ 0xfffffffffffff000` (negative in two's complement) encodes `-errno`; negate to recover the error code.
- `open` returns a file descriptor (nonnegative) on success or negative on failure.
- `read` and `write` may transfer fewer bytes than requested (short reads/writes are not errors).
- `mmap` with `MAP_ANONYMOUS` allocates zeroed memory; `munmap` releases it with the same length.

## Lookup

- Linux x86-64 syscall table and ABI: [man syscall(2)](https://man7.org/linux/man-pages/man2/syscall.2.html), [arch/x86/entry/entry_64.S](https://github.com/torvalds/linux/blob/master/arch/x86/entry/entry_64.S)
- Individual syscalls: [man 2 open](https://man7.org/linux/man-pages/man2/open.2.html), [man 2 read](https://man7.org/linux/man-pages/man2/read.2.html), [man 2 mmap](https://man7.org/linux/man-pages/man2/mmap.2.html)
- Error codes: [man errno(3)](https://man7.org/linux/man-pages/man3/errno.3.html), `/usr/include/asm-generic/errno-base.h`
- `syscall` instruction: [Intel SDM Vol. 2B SYSCALL](https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-2b-manual.html)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**File operations:**
- `01-write-only.asm` — two writes to stdout, exit 0
- `02-read-stdin-one.asm` — read one byte from stdin, exit that byte or 0 at EOF
- `03-open-fail.asm` — open missing file, exit 1 on failure
- `05-errno-neg.asm` — open `/nope`, exit errno 2 (`ENOENT`)
- `08-from-scratch-close.asm` — open and close `/dev/zero`, exit 0
- `10-open-dev-null.asm` — open `/dev/null` write-only, close, exit 0
- `11-read-dev-zero.asm` — read 8 bytes from `/dev/zero`, exit 0 (do not sum)
- `09-write-len-check.asm` — write and check byte count, exit 0
- `07-write-iov-lite.asm` — two separate `write` calls (not `writev`), exit 0
- `17-dup-concept.asm` — write to fd 1, exit 0 (no `dup` call)
- `21-debug-fd-leak-pattern.asm` — fix: change `mov rax, 1` to `mov rax, 3` for close
- `24-from-scratch-write-err.asm` — write to fd −1, exit 1 on error

**Error handling:**
- `18-error-eacces-sim.asm` — open `/` with `O_WRONLY`, exit 1 on `EACCES`

**Seeking:**
- `06-lseek-concept.asm` — arithmetic offset, not syscall 8, exit 10
- `19-pwrite-emul.asm` — open `/dev/null`, `lseek` to 0 (`SEEK_SET`), write, close, exit 0

**Memory mapping:**
- `04-mmap-anon.asm` — map one page, store 42, exit 42
- `12-mmap-write-read.asm` — map, store 99 at offset 100, exit 99
- `13-munmap.asm` — map then unmap, exit 0
- `14-brk-stub.asm` — call `brk(0)`, exit 0 if nonzero
- `20-mmap-pagesize-fill.asm` — map, fill 16 bytes with 1, exit 16
- `22-stretch-file-copy-mem.asm` — map one page, copy four bytes from `.data`, sum them, exit 10

**Other syscalls:**
- `15-getpid.asm` — call `getpid`, exit `pid & 0x7f` (status varies)
- `16-clock-gettime-stub.asm` — call `clock_gettime`, exit 0
- `23-stretch-pipe-syscalls.asm` — call `pipe`, exit 0 (do not read/write)
