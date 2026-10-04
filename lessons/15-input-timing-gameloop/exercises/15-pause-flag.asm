; Exercise 15: pause flag
;
; Paused skips update; updates=0; exit 0.
;
; Build: nasm -f elf64 15-pause-flag.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
