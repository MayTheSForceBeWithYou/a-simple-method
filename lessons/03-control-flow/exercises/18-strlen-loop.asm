; Exercise 18: strlen loop
;
; Cstring 'hello',0. Count length 5 into rdi.
;
; Build: nasm -f elf64 18-strlen-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
