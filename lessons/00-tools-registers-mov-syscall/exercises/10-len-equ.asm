; Exercise 10: len equ
;
; Define string "equ works\n" with db; length via equ $ - label. Write it; exit 0.
;
; Build: nasm -f elf64 10-len-equ.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
