; Exercise 10: map erase
;
; Erase cell to EMPTY=0; exit 0.
;
; Build: nasm -f elf64 10-map-erase.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
