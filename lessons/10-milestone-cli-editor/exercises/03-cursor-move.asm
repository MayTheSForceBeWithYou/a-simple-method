; Exercise 03: cursor move
;
; cursor dq; move right then left; exit cursor 0.
;
; Build: nasm -f elf64 03-cursor-move.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
