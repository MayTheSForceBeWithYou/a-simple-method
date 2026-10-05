; Exercise 28: from scratch echo lit
;
; FROM SCRATCH: Print "nasm+ld\n" and exit 0. Empty body on purpose.
;
; Build: nasm -f elf64 28-from-scratch-echo-lit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
