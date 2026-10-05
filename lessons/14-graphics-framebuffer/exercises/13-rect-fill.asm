; Exercise 13: rect fill
;
; Fill 2x2 rect with 3; sum=12.
;
; Build: nasm -f elf64 13-rect-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
