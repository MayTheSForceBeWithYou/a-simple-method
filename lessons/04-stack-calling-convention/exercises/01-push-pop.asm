; Exercise 01: push pop
;
; push 3; push 4; pop rax; pop rdi; add rdi,rax; exit 7.
;
; Build: nasm -f elf64 01-push-pop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
