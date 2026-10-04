; Exercise 22: stretch matrix2 mul
;
; STRETCH: 2x2 identity * (3,4) -> 3; exit 3 (x).
;
; Build: nasm -f elf64 22-stretch-matrix2-mul.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
