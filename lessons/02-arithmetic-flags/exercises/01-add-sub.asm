; Exercise 01: add sub
;
; rdi=100; add 20; sub 78; exit (42).
;
; Build: nasm -f elf64 01-add-sub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
