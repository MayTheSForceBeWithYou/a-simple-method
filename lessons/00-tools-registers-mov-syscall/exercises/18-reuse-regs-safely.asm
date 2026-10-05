; Exercise 18: reuse regs safely
;
; Write "ok\n", then exit 0. Re-load syscall numbers after write (rax is return value).
;
; Build: nasm -f elf64 18-reuse-regs-safely.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
