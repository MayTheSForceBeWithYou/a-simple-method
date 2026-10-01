# Lesson 08 — Syscalls, Files, mmap

## Learning objectives

1. Call `read`, `write`, `open`, `close`, and `lseek` with the Linux argument registers.
2. Treat a negative `rax` as `-errno`, not as a file descriptor.
3. Map an anonymous page with `mmap` and release it with `munmap`.
4. Query `brk`, `getpid`, `clock_gettime`, and `pipe` without inventing a libc wrapper.
5. Keep the fourth syscall argument in `r10`. `syscall` clobbers `rcx` and `r11`.

Lesson 00 used `write` and `exit`. This lesson is every other raw call the drills actually make. Macros and `Makefile` rules are lesson 09. Do not wrap these numbers in libc.

## The register contract

`rax` is the syscall number. Arguments are `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9`. The return is `rax`. A return above `0xfffffffffffff000` is a failure: `neg rax` is the errno. `0` is success for `close`, `munmap`, `clock_gettime`, and `pipe`. `open` returns a small nonnegative fd.

| `rax` | Call | Arguments you need here |
|------:|------|-------------------------|
| 0 | `read` | fd, buffer, count |
| 1 | `write` | fd, buffer, count |
| 2 | `open` | path, flags, mode |
| 3 | `close` | fd |
| 8 | `lseek` | fd, offset, whence |
| 9 | `mmap` | addr, length, prot, flags in `r10`, fd, offset |
| 11 | `munmap` | addr, length |
| 12 | `brk` | 0 to query the current break |
| 22 | `pipe` | pointer to two ints |
| 39 | `getpid` | none |
| 60 | `exit` | status |
| 228 | `clock_gettime` | clock id, `timespec` pointer |

`O_RDONLY` is 0. `O_WRONLY` is 1. `SEEK_SET` is 0, `SEEK_CUR` is 1, `SEEK_END` is 2. `PROT_READ|PROT_WRITE` is 3. `MAP_PRIVATE|MAP_ANONYMOUS` is `0x22`.

## A missing path is `-ENOENT`

`open` of a path that is not there returns a negative value. It is not a branch you skip. `/no/such/asm_course_file` exits 1 in `03-open-fail.asm` because the test is only `rax < 0`. `05-errno-neg.asm` negates and keeps seven bits. `/nope` is errno 2 (`ENOENT`).

```asm
section .data
    path db "/nope", 0
section .text
global _start
_start:
    mov rax, 2
    lea rdi, [path]
    xor rsi, rsi            ; O_RDONLY
    xor rdx, rdx
    syscall
    neg rax                 ; -errno -> errno
    and rax, 127
    mov rdi, rax            ; 2
    mov rax, 60
    syscall
```

Opening `"/"` with `O_WRONLY` fails on this machine and `18-error-eacces-sim.asm` exits 1. The prompt says "often". The solution's exit on a failure is 1, not the errno. `24-from-scratch-write-err.asm` writes to fd `-1` and exits 1 because `rax < 0`. A successful `write` of two bytes (`"Z\n"`, `"io\n"`, or `"A\n"` then `"B\n"`) exits 0: `01-write-only.asm`, `07-write-iov-lite.asm`, `09-write-len-check.asm`. Those are two `write` calls, not `writev`. `17-dup-concept.asm` writes `"d\n"` to fd 1 and exits 0. It does not call `dup`.

`read` of one byte from fd 0 exits that byte when `rax == 1`, and exits 0 when the read is short (`02-read-stdin-one.asm`). With no pipe on stdin the exit is 0.

## `open`, `read`, `close`, `lseek`

`/dev/zero` opens with flag 0. `close` is syscall 3, not 1. `21-debug-fd-leak-pattern.asm` puts 1 in `rax` and therefore `write`s when it meant to close. The fix exits 0 (`08-from-scratch-close.asm` is the same shape). `10-open-dev-null.asm` opens `/dev/null` with flag 1, closes, and exits 0.

`11-read-dev-zero.asm` reads 8 bytes and exits 0. The reference does not add those bytes. They are zeros because the device is `/dev/zero`, which is why a sum would also be 0.

`06-lseek-concept.asm` is not the syscall. It adds 10 and exits 10. The real call is number 8: `rdi` fd, `rsi` offset, `rdx` whence, `rax` the resulting offset. `19-pwrite-emul.asm` opens `/dev/null` write-only, seeks with offset 0 and whence 0 (`SEEK_SET`, not `SEEK_END`), writes one byte, closes, and exits 0. There is no `pwrite` in that file.

```asm
section .data
    path db "/dev/null", 0
section .text
global _start
_start:
    mov rax, 2
    lea rdi, [path]
    mov rsi, 1              ; O_WRONLY
    syscall
    mov rdi, rax            ; fd
    mov rax, 8
    xor rsi, rsi            ; offset 0
    xor rdx, rdx            ; SEEK_SET
    syscall
    mov rdi, rax            ; 0
    mov rax, 60
    syscall
```

## Anonymous `mmap`

`mmap` with a null hint asks the kernel for a page. Length 4096, prot 3, flags `0x22`, fd `-1`, offset 0. The address comes back in `rax`. A store through that pointer is ordinary memory. `04-mmap-anon.asm` stores the qword 42 and exits 42.

```asm
section .text
global _start
_start:
    mov rax, 9
    xor rdi, rdi            ; let the kernel pick the address
    mov rsi, 4096
    mov rdx, 3              ; PROT_READ|PROT_WRITE
    mov r10, 0x22           ; MAP_PRIVATE|MAP_ANONYMOUS, not rcx
    mov r8, -1
    xor r9, r9
    syscall
    mov byte [rax], 42
    movzx rdi, byte [rax]   ; 42
    mov rax, 60
    syscall
```

`12-mmap-write-read.asm` stores the byte 99 at offset 100 and exits 99. `20-mmap-pagesize-fill.asm` fills 16 bytes with 1 and exits 16. `22-stretch-file-copy-mem.asm` maps one page and copies `1,2,3,4` from `.data`. The prompt says two regions and a file. The solution sums those four bytes and exits 10. `13-munmap.asm` passes the address and 4096 to syscall 11 and exits 0 when `rax` is 0. Unmap the same length you mapped. `14-brk-stub.asm` calls `brk` with `rdi = 0` and exits 0 when the break is nonzero. That query is not an allocator.

## Calls that are not files

`getpid` (39) has no arguments. `15-getpid.asm` exits `pid & 0x7f`. That status changes from run to run, so this lesson does not claim a number for it. `clock_gettime` (228) with `CLOCK_MONOTONIC` (1) writes two qwords at `rsi` and returns 0 (`16-clock-gettime-stub.asm`). How you turn that into a frame delay is lesson 15. `pipe` (22) writes two fds at `rdi` and returns 0 (`23-stretch-pipe-syscalls.asm`). The solution exits that 0 and does not read either end.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Descriptors: `01-write-only.asm`, `02-read-stdin-one.asm`, `03-open-fail.asm`, `05-errno-neg.asm` (exit 2), `07-write-iov-lite.asm`, `08-from-scratch-close.asm`, `09-write-len-check.asm`, `10-open-dev-null.asm`, `11-read-dev-zero.asm`, `17-dup-concept.asm` (no `dup`), `18-error-eacces-sim.asm` (exit 1), `21-debug-fd-leak-pattern.asm`, `24-from-scratch-write-err.asm`. Offsets: `06-lseek-concept.asm` (add 10, not syscall 8), `19-pwrite-emul.asm` (`SEEK_SET`). Memory: `04-mmap-anon.asm`, `12-mmap-write-read.asm`, `13-munmap.asm`, `14-brk-stub.asm`, `20-mmap-pagesize-fill.asm`, `22-stretch-file-copy-mem.asm` (one map, checksum 10). Other: `15-getpid.asm` (status is `pid & 0x7f`, not a fixed value), `16-clock-gettime-stub.asm`, `23-stretch-pipe-syscalls.asm`.