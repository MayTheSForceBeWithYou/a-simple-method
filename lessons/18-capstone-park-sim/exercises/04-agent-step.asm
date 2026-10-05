; Exercise 04: agent step
;
; agent x++; exit x.
;
; Build: nasm -f elf64 04-agent-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
