; Exercise 29: from scratch factorial loop
;
; FROM SCRATCH: 6! with a counted loop = 720. Exit 720&255=208.
;
; Build: nasm -f elf64 29-from-scratch-factorial-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
