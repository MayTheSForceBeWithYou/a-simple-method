; Exercise 09: clear color
;
; Clear 4 pixels to color 5; exit first.
;
; Build: nasm -f elf64 09-clear-color.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
