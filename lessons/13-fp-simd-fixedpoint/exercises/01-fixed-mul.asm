; Exercise 01: fixed mul
;
; Q16.16: 2.0 * 3.0 -> 6.0; represent 2<<16 etc; result>>16 exit 6.
;
; Build: nasm -f elf64 01-fixed-mul.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
