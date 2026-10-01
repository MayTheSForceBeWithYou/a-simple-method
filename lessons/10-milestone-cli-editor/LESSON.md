# Lesson 10 — Milestone: CLI Text Editor

## Learning objectives

1. Keep a byte buffer, a length, and a cursor, and refuse a cursor past the length.
2. Insert and delete by sliding bytes, not by hoping the tail moves itself.
3. Represent the cursor as a gap: free space is `gap_end - gap_start`.
4. Find a line start by scanning backward for `10`, and kill the line text up to that newline. The newline stays.
5. Record dirty, a length prefix, and a magic check. Raw tty is a flag in these drills, not `termios`.

The milestone acceptance in the roadmap is a real editor. These 24 drills are the buffer mechanics that editor is built from. They do not open the tty, and they do not call libc. Parsing a language is lesson 11.

## Buffer, cursor, length

The text is bytes in a `resb` buffer. `len` is how many of those bytes are live. `cursor` is an index in `0..len`, not a pointer into the gap yet. An empty buffer exits 0 (`01-buffer-init.asm`). Appending `'A'` at `buf[len]` and incrementing `len` exits 1 (`02-insert-char.asm`). Moving right and then left exits 0 (`03-cursor-move.asm`). Five right moves on an ASCII cursor exit 5 (`17-utf8-ascii-cursor.asm`). This lesson steps one byte. It does not decode UTF-8.

Backspace in `04-delete-backspace.asm` only decrements `len` from 2 to 1. It does not slide the tail and it does not move a cursor. A cursor of 9 with `len` 3 is illegal. Clamp with an unsigned compare (`21-debug-cursor-oob.asm` exits 3).

```asm
section .bss
    cur resq 1
    len resq 1
section .text
global _start
_start:
    mov qword [cur], 9
    mov qword [len], 3
    mov rax, [cur]
    cmp rax, [len]
    jbe .ok
    mov rax, [len]
    mov [cur], rax
.ok:
    mov rdi, [cur]          ; 3
    mov rax, 60
    syscall
```

Inserting at the cursor when the cursor is not `len` means shifting the tail one byte right, then storing. `"AC"` with the cursor at 1 becomes `"ABC"`, and the byte at index 1 is `'B'` = 66 (`10-insert-middle.asm`). Inserting `"X"` into an empty buffer leaves the cursor at 1 (`09-insert-at-cursor.asm`). Delete-forward slides the tail left: `"ABCD"` at cursor 1 becomes length 3 (`11-delete-forward.asm`).

## The gap

A contiguous buffer pays for every insert in the middle. A gap buffer keeps the free bytes at the cursor. `gap_start` is the first free index. `gap_end` is the first byte of the right-hand text. Free space is the difference. An empty capacity of 8 is `0` and `8`.

```asm
section .bss
    gap_s resq 1
    gap_e resq 1
section .text
global _start
_start:
    mov qword [gap_s], 0
    mov qword [gap_e], 8
    mov rdi, [gap_e]
    sub rdi, [gap_s]        ; 8
    mov rax, 60
    syscall
```

That is `08-from-scratch-gap-start.asm`. One insert increments `gap_start` only. From 2 and 6 the free count becomes 3 (`15-gap-insert.asm`). The reference does not store the character. Moving the gap left decrements both indices (`16-gap-move-left.asm` exits `gap_start` = 2). A buffer that actually holds text also copies the byte at `gap_start-1` to `gap_end-1` before those decrements. The drill's exit does not check that copy. Moving right copies `[gap_end]` to `[gap_start]` and increments both. Do not let the indices cross.

## Lines

A line start is the index after the nearest preceding `10`, or 0 if there is none. In `"ab\ncd"` the cursor 4 (the `'d'`) walks back to the newline at 2 and steps forward to 3.

```asm
section .data
    buf db "ab", 10, "cd", 0
section .text
global _start
_start:
    mov rcx, 4
.scan:
    test rcx, rcx
    jz .done
    dec rcx
    cmp byte [buf+rcx], 10
    jne .scan
    inc rcx
.done:
    mov rdi, rcx            ; 3
    mov rax, 60
    syscall
```

`12-line-start-end.asm` is that scan. The name says line end. The solution returns the start. Kill-line from cursor 0 copies from the newline through the end down to index 0, so `"ab\ncd"` becomes `"\ncd"` and the length exits 3 (`24-from-scratch-kill-line.asm`). The newline stays. Rendering writes bytes, it does not draw a cursor: `05-render-line.asm` writes `ed\n` and exits 0, and `13-render-viewport.asm` writes the first three bytes `L1\n` and exits 0.

## Save, load, undo, raw

`dirty` is a byte. An edit sets it. A save clears it (`14-dirty-flag.asm` exits 0). `06-save-stub.asm` exits 0 without a `write`. `07-load-stub.asm` stores `len = 3` and exits 3. A length-prefixed image is 8 bytes of length plus 4 bytes of payload, and `19-save-length-prefix.asm` exits 12 without storing either. Magic `"ED01"` is accepted when the first word is `0x4445` (`'E'` then `'D'` on a little-endian load). `20-load-validate-magic.asm` exits 1.

```asm
section .data
    magic db "ED01"
section .text
global _start
_start:
    cmp word [magic], 0x4445
    jne .bad
    mov rdi, 1              ; 1
    mov rax, 60
    syscall
.bad:
    xor rdi, rdi
    mov rax, 60
    syscall
```

Undo pushes opcodes 1 then 2. One pop leaves 1 at the new top (`22-stretch-undo-stack.asm`). The popped value is 2. The exit is the value still on the stack. A status line that is only the length exits 12 (`18-status-line-len.asm`). `23-stretch-raw-mode-flag.asm` sets a byte and clears it, then exits 0. It does not call `ioctl` or `tcsetattr`. The roadmap allows a thin libc later for the real tty. These drills are not that program.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Buffer: `01-buffer-init.asm`, `02-insert-char.asm`, `03-cursor-move.asm`, `04-delete-backspace.asm`, `09-insert-at-cursor.asm`, `10-insert-middle.asm` (exit 66), `11-delete-forward.asm`, `17-utf8-ascii-cursor.asm`, `21-debug-cursor-oob.asm`. Gap: `08-from-scratch-gap-start.asm`, `15-gap-insert.asm` (exit 3, no stored byte), `16-gap-move-left.asm` (exit 2). Lines: `05-render-line.asm`, `12-line-start-end.asm`, `13-render-viewport.asm`, `24-from-scratch-kill-line.asm`. File and flags: `06-save-stub.asm`, `07-load-stub.asm`, `14-dirty-flag.asm`, `18-status-line-len.asm`, `19-save-length-prefix.asm` (exit 12), `20-load-validate-magic.asm` (exit 1), `22-stretch-undo-stack.asm` (exit 1, the remaining top), `23-stretch-raw-mode-flag.asm`.