; Exercise 24: from scratch write err
;
; FROM SCRATCH: write to fd=-1; expect error (rax<0); exit 1.
;
; Build: nasm -f elf64 24-from-scratch-write-err.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
