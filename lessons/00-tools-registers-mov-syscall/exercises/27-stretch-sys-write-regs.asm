; Exercise 27: stretch sys write regs
;
; Print "syscall\n" using only rax,rdi,rsi,rdx for the write setup. Exit 0.
;
; Build: nasm -f elf64 27-stretch-sys-write-regs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
