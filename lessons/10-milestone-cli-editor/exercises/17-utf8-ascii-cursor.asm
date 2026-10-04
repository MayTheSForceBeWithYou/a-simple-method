; Exercise 17: utf8 ascii cursor
;
; ASCII-only: moving right increments cursor by 1; exit 5 after 5 moves.
;
; Build: nasm -f elf64 17-utf8-ascii-cursor.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
