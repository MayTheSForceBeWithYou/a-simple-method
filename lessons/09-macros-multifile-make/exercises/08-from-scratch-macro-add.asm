; Exercise 08: from scratch macro add
;
; FROM SCRATCH: %macro ADD_IMM reg,imm; use to build 40+2 exit 42.
;
; Build: nasm -f elf64 08-from-scratch-macro-add.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
