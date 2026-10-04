; Exercise 14: codegen add regs
;
; v1=10 v2=32; add into v1; exit 42.
;
; Build: nasm -f elf64 14-codegen-add-regs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
