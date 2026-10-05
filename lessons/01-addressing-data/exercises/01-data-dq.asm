; Exercise 01: data dq
;
; Define count dq 41 in .data. Load into rdi, add 1, exit (42).
;
; Build: nasm -f elf64 01-data-dq.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
