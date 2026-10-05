; Exercise 17: while codegen
;
; while i<3 i++; exit i=3.
;
; Build: nasm -f elf64 17-while-codegen.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
