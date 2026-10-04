; Exercise 03: xor swap
;
; xor-swap rax=1 rbx=2; exit rax (2).
;
; Build: nasm -f elf64 03-xor-swap.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
