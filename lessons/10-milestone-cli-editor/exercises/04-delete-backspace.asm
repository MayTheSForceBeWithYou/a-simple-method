; Exercise 04: delete backspace
;
; len=2; backspace; exit len 1.
;
; Build: nasm -f elf64 04-delete-backspace.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
