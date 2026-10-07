# 10 — Milestone: CLI Text Editor

You've spent nine lessons mastering x86-64 mechanics. This milestone lesson asks you to synthesize that knowledge into a real-world artifact: a command-line text editor. Not a toy—a program that manages a buffer, tracks a cursor, inserts and deletes characters, handles line-based operations, saves and loads files with integrity checks, and flips the terminal into raw mode so every keypress arrives immediately. By the end, you'll have drilled the twenty-four buffer primitives that make an editor work, and you'll understand the acceptance criteria for a complete milestone binary.

## What this lesson asks of you

- Maintain a byte buffer with a length and a cursor index, clamping the cursor to the valid range `[0, len]`.
- Insert a byte by shifting the tail rightward, and delete by shifting the tail leftward—never assume memory moves itself.
- Manage a **gap buffer**: keep free space at the cursor so inserts are cheap, and move the gap by copying bytes when the cursor moves.
- Scan backward from the cursor to find a line start (the byte after the previous `\n`, or 0), and implement kill-line (delete text up to the newline, leaving the newline itself).
- Track a dirty flag (set by edits, cleared by save), store a length-prefixed file image with a magic number, and validate that magic on load.
- Flip a terminal into raw mode with `termios` and `ioctl` so the editor receives keypresses immediately without echo.

## Why a text editor as milestone 1

An editor touches every concept from lessons 00–09:
- **Memory layout** (`.data`, `.bss`, buffers)
- **Arithmetic and flags** (length checks, cursor clamping, gap math)
- **Control flow** (loops for scanning, conditionals for edge cases)
- **Procedures** (insert, delete, move, render as separate routines)
- **Strings and arrays** (byte buffers, null-terminated paths)
- **Bitwise operations** (flag manipulation in `termios`)
- **Syscalls** (`read`, `write`, `open`, `close`, `ioctl`)
- **Macros and multi-file** (factoring the editor into modules)

The milestone is not a single drill—it's a capstone binary you build by composing the patterns from the 24 drills below, applying lesson 09's multi-file build, and meeting six acceptance criteria. The drills isolate each primitive so you can verify it in a 10-line testbench before integrating it into a 500-line editor.

## Buffer, cursor, length

The editor's state starts with three values:

```asm
section .bss
    buf: resb 4096          ; the text bytes
    len: resq 1             ; how many bytes are live
    cur: resq 1             ; cursor index in [0, len]
```

An empty buffer has `len = 0` and `cur = 0`. Appending a byte means writing `buf[len]`, then incrementing `len`. The cursor can sit anywhere in `[0, len]`, including at the end (past the last character). When the cursor is at the end, an insert appends. When the cursor is in the middle, an insert shifts the tail.

### Cursor movement

Moving right increments `cur` if `cur < len`. Moving left decrements `cur` if `cur > 0`. The clamp is **mandatory**—a cursor past `len` or below 0 causes memory corruption.

```asm
; move right
mov rax, [cur]
cmp rax, [len]
jae .done               ; already at end
inc qword [cur]
.done:
```

Use **unsigned** comparisons (`jae`, `jbe`) for indices because they're always nonnegative. A signed compare would misinterpret a corrupted negative index as a valid small number.

**Clamping a out-of-range cursor:** If a bug produces `cur > len`, clamp it:

```asm
mov rax, [cur]
cmp rax, [len]
jbe .ok                 ; cur <= len
mov rax, [len]
mov [cur], rax          ; clamp to len
.ok:
```

This is defensive: if `cur` is 9 and `len` is 3, the clamp sets `cur = 3`. The drill `21-debug-cursor-oob.asm` exits 3 after this clamp.

### Appending a character

```asm
; append 'A' to the end
mov rax, [len]
mov byte [buf + rax], 'A'
inc qword [len]
```

This is `02-insert-char.asm`. It exits 1 (the new length). The cursor is not moved in this drill, so an append-then-move-right pattern would be:

```asm
; append and advance cursor
mov rax, [len]
mov byte [buf + rax], 'A'
inc qword [len]
inc qword [cur]
```

### Deleting at the end (backspace)

If the cursor is at the end, backspace just decrements `len`:

```asm
; backspace when cur == len
cmp qword [cur], 0
je .done                ; can't backspace at start
mov rax, [cur]
cmp rax, [len]
jne .middle
; at end
dec qword [len]
dec qword [cur]
.done:
```

This is `04-delete-backspace.asm` (simplified: it only does the decrement, no cursor move). A full backspace that works in the middle requires a tail shift.

## Inserting and deleting in the middle: tail shifts

When the cursor is not at the end, insertion and deletion must **shift the tail**. Memory does not move itself.

### Insert in the middle

To insert `'B'` at index 1 in `"AC"`, producing `"ABC"`:

1. Shift `buf[1..len)` one byte rightward to `buf[2..len+1)`.
2. Store `'B'` at `buf[1]`.
3. Increment `len`.
4. Increment `cur` (optional, depending on desired cursor behavior).

**Shift loop (reverse order to avoid overwriting):**

```asm
    mov rcx, [len]
.shift:
    cmp rcx, [cur]
    jle .done_shift         ; stop when rcx reaches cur
    mov al, [buf + rcx - 1]
    mov [buf + rcx], al
    dec rcx
    jmp .shift
.done_shift:
    ; now store the new byte at buf[cur]
    mov rax, [cur]
    mov byte [buf + rax], 'B'
    inc qword [len]
    inc qword [cur]
```

The loop starts at `rcx = len` and copies `buf[rcx-1]` to `buf[rcx]`, decrementing until `rcx == cur`. This preserves the tail without overwriting any live data.

**Drill:** `10-insert-middle.asm` starts with `"AC"`, cursor at 1, inserts `'B'`, and exits 66 (the byte value of `'B'`). The final buffer is `"ABC"`.

### Delete in the middle (delete-forward)

To delete the character at the cursor (delete-forward), shift `buf[cur+1..len)` one byte leftward to `buf[cur..len-1)`:

```asm
    mov rcx, [cur]
.shift:
    inc rcx
    cmp rcx, [len]
    jge .done_shift
    mov al, [buf + rcx]
    mov [buf + rcx - 1], al
    jmp .shift
.done_shift:
    dec qword [len]
```

The loop starts at `cur` and copies `buf[rcx]` to `buf[rcx-1]` for all `rcx` from `cur+1` to `len-1`.

**Drill:** `11-delete-forward.asm` starts with `"ABCD"`, cursor at 1, deletes `'B'`, and exits 3 (the new length, `"ACD"`).

## The gap buffer: amortizing tail shifts

Shifting the tail on every insert is expensive if you're typing in the middle of a 10KB file. A **gap buffer** keeps the free space at the cursor, so inserts just consume gap space—no shift unless the gap is empty.

**Structure:**

```asm
section .bss
    buf: resb 4096
    gap_start: resq 1       ; first free byte
    gap_end: resq 1         ; first byte of right-hand text
```

The text is `buf[0..gap_start)` (left half) and `buf[gap_end..capacity)` (right half). Free space is `gap_end - gap_start`.

**Empty buffer:**

```asm
mov qword [gap_start], 0
mov qword [gap_end], 4096
; free space = 4096
```

**Insert at the gap:**

```asm
; store character at gap_start
mov rax, [gap_start]
mov byte [buf + rax], 'X'
inc qword [gap_start]
; free space decreased by 1
```

The cursor is conceptually at `gap_start`. No tail shift—just write and advance the gap start.

**Drill:** `15-gap-insert.asm` starts with `gap_start = 2` and `gap_end = 6` (free space 4). After one insert, `gap_start` becomes 3, and the exit is 3 (the remaining free space). The drill does not actually store the character—it only verifies the arithmetic.

### Moving the gap

When the cursor moves away from the gap, you must **move the gap** by copying bytes:

**Move gap left (cursor moves left):**

```asm
; copy buf[gap_start - 1] to buf[gap_end - 1]
; then dec gap_start, dec gap_end
.move_left:
    mov rax, [gap_start]
    dec rax
    mov al, [buf + rax]
    mov rcx, [gap_end]
    dec rcx
    mov [buf + rcx], al
    mov [gap_start], rax
    mov [gap_end], rcx
```

This moves one byte from the left half to the right half, effectively shifting the gap left by one.

**Drill:** `16-gap-move-left.asm` starts with `gap_start = 3` and `gap_end = 5`. After moving left, `gap_start = 2` and the exit is 2.

**Move gap right (cursor moves right):**

```asm
; copy buf[gap_end] to buf[gap_start]
; then inc gap_start, inc gap_end
.move_right:
    mov rax, [gap_end]
    mov al, [buf + rax]
    mov rcx, [gap_start]
    mov [buf + rcx], al
    inc qword [gap_start]
    inc qword [gap_end]
```

The gap buffer optimization pays off when you type continuously at one spot: all inserts are `O(1)` until the gap runs out. Moving the cursor costs one byte copy per position, so cursor motion is still `O(distance)`, but that's much cheaper than shifting a 10KB tail on every keystroke.

## Lines: scanning and kill-line

A **line** is the text between two newlines (byte value `10`, ASCII `\n`). The **line start** is the index immediately after the previous newline, or 0 if there is none.

### Finding the line start

Scan backward from the cursor:

```asm
; input: rsi = cursor
; output: rcx = line start index
    mov rcx, rsi
.scan:
    test rcx, rcx
    jz .done                ; reached beginning of buffer
    dec rcx
    cmp byte [buf + rcx], 10
    jne .scan
    inc rcx                 ; step past the newline
.done:
    ; rcx is the line start
```

**Example:** In `"ab\ncd"` (bytes `'a', 'b', 10, 'c', 'd'`), cursor at index 4 (the `'d'`):
- `rcx = 4`, `buf[3] = 'c'`, not `10`, continue.
- `rcx = 3`, `buf[2] = 10`, found newline, `inc rcx` → `rcx = 3`.
- Line start is 3 (the `'c'`).

**Drill:** `12-line-start-end.asm` computes the line start for cursor 4 and exits 3. (The filename says "end"; the code computes the start. This is a known naming mismatch.)

### Kill-line

**Kill-line** deletes the text from the cursor to the end of the line, **leaving the newline**. In `"ab\ncd"`, kill from cursor 0 produces `"\ncd"` (length 3).

**Algorithm:**

1. Scan forward from cursor to find the newline (or end of buffer).
2. Copy `buf[newline_index..len)` down to `buf[cursor..cursor + (len - newline_index))`.
3. Update `len`.

**Drill:** `24-from-scratch-kill-line.asm` starts with `"ab\ncd"` (length 5), cursor 0. The newline is at index 2. Copy `buf[2..5)` to `buf[0..3)`, set `len = 3`, exit 3. The buffer is now `"\ncd"`.

The newline is copied, which is why the lesson says "the newline stays." If you wanted to delete the newline too (kill including newline), you'd start the copy at `newline_index + 1`.

## Rendering the buffer

An editor must display the buffer. The simplest rendering is to write the entire buffer to stdout:

```asm
mov rax, 1              ; sys_write
mov rdi, 1              ; stdout
lea rsi, [buf]
mov rdx, [len]
syscall
```

**Drill:** `05-render-line.asm` writes a short string (e.g., `"ed\n"`) and exits 0.

For a full-screen editor, you'd render a **viewport**: a subset of the buffer around the cursor. The drills model this with a fixed-size view:

**Drill:** `13-render-viewport.asm` writes the first 3 bytes of the buffer (e.g., `"L1\n"`) and exits 0. A real editor would compute the starting line based on the cursor position and terminal height.

## Save, load, dirty flag, and magic numbers

An editor must persist its buffer to disk and reload it. To detect corruption or version mismatches, the file format includes a **magic number** and a **length prefix**.

### File format

```
Offset  Size  Field
0       4     Magic: "ED01" (0x4445 0x3130 on little-endian load)
4       4     (padding/reserved, optional)
8       8     Length (qword)
16      N     Buffer contents (N bytes)
```

The magic `"ED01"` is `'E'`, `'D'`, `'0'`, `'1'` (ASCII `69, 68, 48, 49`). On a little-endian load of the first word, the bytes appear as `0x44 0x45` (in memory order), which is `0x4544` as a 16-bit word. Wait—let's check:

- Little-endian stores the **least significant byte first**.
- `"ED"` as bytes: `'E' = 0x45`, `'D' = 0x44`.
- In memory: `[0x45, 0x44, ...]`.
- Load as a word: `word [magic]` reads the first two bytes in little-endian order: `0x4445` (not `0x4544`).

**Drill:** `20-load-validate-magic.asm` checks `cmp word [magic], 0x4445` and exits 1 if it matches. The drill inverts the test (exits 1 on match, 0 on mismatch), which is backwards from a real editor, but it verifies the comparison works.

### Dirty flag

A **dirty flag** tracks unsaved changes. Any edit sets it; a successful save clears it.

```asm
section .bss
    dirty: resb 1

; on insert, delete, or any edit:
mov byte [dirty], 1

; on save:
; ... write file ...
mov byte [dirty], 0
```

**Drill:** `14-dirty-flag.asm` sets the flag to 1, performs a mock save (just clearing the flag), and exits 0.

### Saving with length prefix

To save the buffer, open the file with `O_CREAT | O_TRUNC | O_WRONLY`, write the magic and length, write the buffer, close.

```asm
section .data
    path: db "editor.save", 0
    magic: db "ED01"
section .bss
    fd: resq 1
    len: resq 1
    buf: resb 4096

; save
mov rax, 2              ; open
lea rdi, [path]
mov rsi, 577            ; O_WRONLY | O_CREAT | O_TRUNC
mov rdx, 420            ; mode 0644
syscall
mov [fd], rax

; write magic (4 bytes)
mov rax, 1
mov rdi, [fd]
lea rsi, [magic]
mov rdx, 4
syscall

; write length (8 bytes)
mov rax, 1
mov rdi, [fd]
lea rsi, [len]
mov rdx, 8
syscall

; write buffer
mov rax, 1
mov rdi, [fd]
lea rsi, [buf]
mov rdx, [len]
syscall

; close
mov rax, 3
mov rdi, [fd]
syscall
```

**Drill:** `19-save-length-prefix.asm` computes the total byte count (4 magic + 8 length + N content, so 12 + N) but does not actually write. For a buffer of length 0, it exits 12.

### Loading and validating

To load, open the file, read magic and length, validate the magic, read the content, close.

```asm
; load
mov rax, 2              ; open
lea rdi, [path]
xor rsi, rsi            ; O_RDONLY
syscall
mov [fd], rax

; read magic
mov rax, 0              ; sys_read
mov rdi, [fd]
lea rsi, [magic]
mov rdx, 4
syscall

; validate
cmp word [magic], 0x4445
jne .bad_magic

; read length
mov rax, 0
mov rdi, [fd]
lea rsi, [len]
mov rdx, 8
syscall

; read buffer
mov rax, 0
mov rdi, [fd]
lea rsi, [buf]
mov rdx, [len]
syscall

; close
mov rax, 3
mov rdi, [fd]
syscall

.bad_magic:
; exit with error
mov rdi, 1
mov rax, 60
syscall
```

**Drill:** `07-load-stub.asm` mocks loading by setting `len = 3` and exiting 3. `06-save-stub.asm` exits 0 without writing.

## Raw mode: capturing keypresses

A terminal in **canonical mode** (the default) buffers input until Enter is pressed and echoes each character. An editor needs **raw mode**: every keypress arrives immediately, and nothing is echoed.

On Linux, terminal behavior is controlled by a `struct termios`, manipulated with `ioctl` syscall 16.

### struct termios and ioctl

`struct termios` (glibc userspace version) is 60 bytes. The field `c_lflag` (a 32-bit bitmask) sits at offset 12. Two bits matter:

- `ICANON` (0x2): canonical mode (line buffering).
- `ECHO` (0x8): echo input.

To enter raw mode, clear both bits. To restore, set them.

**ioctl constants:**

- `TCGETS` (0x5401): read current termios.
- `TCSETS` (0x5402): write new termios.

**Entering raw mode:**

```asm
section .bss
    tio: resb 60

section .text
global _start
_start:
    ; get current termios
    mov rax, 16             ; sys_ioctl
    xor rdi, rdi            ; fd 0 (stdin)
    mov rsi, 0x5401         ; TCGETS
    lea rdx, [tio]
    syscall

    ; clear ICANON and ECHO
    mov eax, [tio + 12]     ; c_lflag
    and eax, ~0xA           ; ~(ICANON | ECHO) = ~10 = ~0xA
    mov [tio + 12], eax

    ; set new termios
    mov rax, 16
    xor rdi, rdi
    mov rsi, 0x5402         ; TCSETS
    lea rdx, [tio]
    syscall

    ; now in raw mode
    ; ... editor loop ...

    ; (restore termios on exit by setting the bits back)
    xor rdi, rdi
    mov rax, 60
    syscall
```

**Drill:** `23-stretch-raw-mode-flag.asm` sets a byte flag (modeling the `ICANON` bit), clears it (modeling the `and` operation), and exits 0. It does not call `ioctl`—it's a logic drill.

**Important:** A real editor must **restore** the original `termios` on exit. If you forget, the terminal remains in raw mode (no echo, no line editing), and the user must type `reset<Enter>` blindly to recover.

## Worked example: how far does the tail shift in insert-middle?

**Task:** Starting with buffer `"AC"` (length 2), cursor at 1, insert `'B'` to produce `"ABC"`. What does the shift loop do?

**Shift loop from `10-insert-middle.asm`:**

```asm
mov rcx, [len]          ; rcx = 2
.shift:
    cmp rcx, [cur]      ; compare rcx to 1
    jl .put
    mov al, [buf + rcx - 1]
    mov [buf + rcx], al
    dec rcx
    jmp .shift
.put:
    mov byte [buf + 1], 'B'
    inc qword [len]
```

**Trace:**

| Iteration | `rcx` | `cmp rcx, [cur]` (1) | Action | Buffer after |
|-----------|------:|----------------------|--------|--------------|
| 1 | 2 | 2 ≥ 1, continue | `buf[2] = buf[1]` (`'C'`) | `A C C` |
| 2 | 1 | 1 ≥ 1, continue | `buf[1] = buf[0]` (`'A'`) | `A A C` |
| 3 | 0 | 0 < 1, exit to `.put` | — | `A A C` |
| — | — | — | `buf[1] = 'B'` | `A B C` |

**Plausible wrong reading:**

*"The loop moves every byte from the cursor to the end one place right, so it runs once, for the `'C'`, and stops."*

**Why it's wrong:** The exit test is `jl` (jump if less), so the loop continues while `rcx >= cur`. The loop stops only when `rcx < cur`, which happens when `rcx = 0`. The second iteration copies `buf[0]` to `buf[1]`, overwriting the `'C'` that was just moved. This is wasted work, but harmless because `.put` immediately overwrites `buf[1]` with `'B'`.

**The correct reading:** The loop performs **two** copies, not one. To avoid the wasted copy, change `jl` to `jle` (or `jbe` for unsigned indices), so the loop stops when `rcx == cur`. Also note that `.put` stores at the literal `[buf + 1]`, not `[buf + cur]`, so the drill only works because `cur` happens to be 1. A real editor would compute `buf + cur` and also increment `cur` after the insert.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| `len` is the capacity | `len` is the number of live bytes; capacity is the allocated buffer size |
| The cursor is a pointer | The cursor is an **index** (offset from `buf`), not a pointer |
| Insert moves the tail automatically | You must explicitly shift `buf[cur..len)` rightward before storing the new byte |
| Gap buffer eliminates all shifts | Gap buffer eliminates shifts for inserts **at the gap**; moving the cursor still copies bytes |
| Kill-line deletes the newline | Kill-line deletes **up to** the newline; the newline remains |
| Raw mode is on by default | Terminals start in canonical mode (line-buffered, echoed); you must `ioctl` to enter raw mode |
| `struct termios` is always 60 bytes | glibc's userspace `struct termios` is 60 bytes; the kernel's may differ (consult docs for your libc) |

## Check yourself

1. In `24-from-scratch-kill-line.asm`, the buffer is `"ab\ncd"` (length 5), cursor 0. The newline is at index 2. After kill-line, what is in `buf[0]`, `buf[1]`, `buf[2]`, and what is the new length?

2. `22-stretch-undo-stack.asm` pushes opcodes 1 and 2, then pops one entry (`dec qword [usp]`). The code then does `dec rcx` before reading `[ustk + rcx*8]`. Why is the extra `dec` needed?

3. `21-debug-cursor-oob.asm` clamps an out-of-range cursor using `jbe` (unsigned compare). If a bug made `cur` equal to `0xffffffffffffffff` (−1 as a signed value), would the clamp catch it? Would a signed `jle` catch it?

4. You have a gap buffer with `gap_start = 5` and `gap_end = 8`. How many bytes of free space remain? After one insert (no gap move), what are the new values?

5. The termios field `c_lflag` is at offset 12 and holds `0x0000082F` before clearing `ICANON` (0x2) and `ECHO` (0x8). What is the value after `and eax, ~0xA`?

## Key takeaways

- An editor is a byte buffer with a length, a cursor index in `[0, len]`, and insert/delete operations that shift the tail.
- Inserting in the middle requires copying `buf[cur..len)` one byte rightward in reverse order to avoid overwriting data.
- A gap buffer keeps free space at the cursor, making inserts `O(1)` until the gap runs out; moving the cursor copies bytes to move the gap.
- Line operations scan for newline (`10`) characters; kill-line deletes text up to the newline but leaves the newline itself.
- A save file includes a magic number (`"ED01"`) and a length prefix to detect corruption and version mismatches.
- Raw mode (entered via `ioctl` with `TCGETS`/`TCSETS` and clearing `ICANON` and `ECHO` in `c_lflag`) delivers keypresses immediately without echo.

## Lookup

- `ioctl` and `termios`: [man ioctl_tty(2)](https://man7.org/linux/man-pages/man2/ioctl_tty.2.html), [man termios(3)](https://man7.org/linux/man-pages/man3/termios.3.html)
- Gap buffer algorithm: [Wikipedia: Gap buffer](https://en.wikipedia.org/wiki/Gap_buffer), [Emacs source `src/insdel.c`](https://github.com/emacs-mirror/emacs/blob/master/src/insdel.c)
- ANSI escape codes (for cursor positioning, not covered in these drills): [ANSI escape code - Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code)

## Acceptance criteria

The milestone binary is complete when it satisfies all six criteria:

1. **Open, edit, quit:** Opens a text file (or starts empty), displays it, accepts keypresses, and quits on a defined key (e.g., `Ctrl+Q`) without losing the buffer.
2. **Cursor discipline:** The cursor never leaves `[0, len]`. Every move and edit applies the clamp from `21-debug-cursor-oob.asm`.
3. **Kill-line semantics:** Kill-line removes text from the cursor to the end of the line but leaves the newline, per `24-from-scratch-kill-line.asm`.
4. **Save/load integrity:** Save writes a length-prefixed image with magic `"ED01"`. Loading a file with a bad magic is rejected with an error message.
5. **Dirty flag:** Any edit sets the dirty flag; only a successful save clears it. Quitting with unsaved changes warns the user.
6. **Viewport rendering:** The editor renders the buffer with `write` syscalls, one screenful at a time. No libc, no `mmap` of the tty. Use lesson 09's multi-file build to factor rendering, buffer ops, and I/O into separate modules.

Raw mode (from the `termios` section) is what makes criterion 1's "accepts keypresses" work—without it, the editor would wait for Enter after every command.

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Buffer basics:**
- `01-buffer-init.asm` — empty buffer, exit 0
- `02-insert-char.asm` — append `'A'`, exit 1
- `03-cursor-move.asm` — move right then left, exit 0
- `04-delete-backspace.asm` — backspace at end (dec `len` from 2 to 1)
- `09-insert-at-cursor.asm` — insert `'X'` in empty buffer, cursor becomes 1
- `10-insert-middle.asm` — insert `'B'` into `"AC"`, exit 66 (`'B'`)
- `11-delete-forward.asm` — delete from `"ABCD"`, length becomes 3
- `17-utf8-ascii-cursor.asm` — five byte steps, exit 5 (no UTF-8 decoding)
- `21-debug-cursor-oob.asm` — clamp `cur = 9` with `len = 3`, exit 3

**Gap buffer:**
- `08-from-scratch-gap-start.asm` — empty gap, `gap_end - gap_start` = 8, exit 8
- `15-gap-insert.asm` — one insert, `gap_start` 2→3, free space 4→3, exit 3 (does not store byte)
- `16-gap-move-left.asm` — move gap left, `gap_start` 3→2, exit 2

**Line operations:**
- `05-render-line.asm` — write `"ed\n"`, exit 0
- `12-line-start-end.asm` — find line start from cursor 4 in `"ab\ncd"`, exit 3 (filename says "end"; code computes start)
- `13-render-viewport.asm` — write first 3 bytes `"L1\n"`, exit 0
- `24-from-scratch-kill-line.asm` — kill from 0 in `"ab\ncd"`, new length 3, exit 3

**File and state:**
- `06-save-stub.asm` — exit 0 (no write)
- `07-load-stub.asm` — set `len = 3`, exit 3
- `14-dirty-flag.asm` — set dirty, mock save (clear dirty), exit 0
- `18-status-line-len.asm` — length-only status, exit 12
- `19-save-length-prefix.asm` — compute 4 (magic) + 8 (length) + 0 (content) = 12, exit 12
- `20-load-validate-magic.asm` — check `word [magic] == 0x4445`, exit 1 if match (inverted test)
- `22-stretch-undo-stack.asm` — push 1, push 2, pop, exit 1 (remaining top)
- `23-stretch-raw-mode-flag.asm` — set byte, clear byte, exit 0 (models `ICANON` bit, no `ioctl`)
