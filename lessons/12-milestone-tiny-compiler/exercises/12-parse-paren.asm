; Exercise 12: parse paren
;
; (1+2)*3 = 9; exit 9.
;
; Build: nasm -f elf64 12-parse-paren.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
