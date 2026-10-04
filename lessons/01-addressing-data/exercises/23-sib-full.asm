; Exercise 23: sib full
;
; base=addr of table, index=2, scale=8, disp=0. table dq 0,0,42,0. Load into rdi.
;
; Build: nasm -f elf64 23-sib-full.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
