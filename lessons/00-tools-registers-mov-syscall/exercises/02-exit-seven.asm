; Exercise 02: exit seven
;
; Exit with status 7.
;
; Build: nasm -f elf64 02-exit-seven.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
