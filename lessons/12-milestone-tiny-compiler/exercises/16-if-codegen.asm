; Exercise 16: if codegen
;
; if 1 then 7 else 9; exit 7.
;
; Build: nasm -f elf64 16-if-codegen.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
