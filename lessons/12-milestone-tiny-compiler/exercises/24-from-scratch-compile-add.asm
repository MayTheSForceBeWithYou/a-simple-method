; Exercise 24: from scratch compile add
;
; FROM SCRATCH: compile-time eval of 40+2; exit 42.
;
; Build: nasm -f elf64 24-from-scratch-compile-add.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
