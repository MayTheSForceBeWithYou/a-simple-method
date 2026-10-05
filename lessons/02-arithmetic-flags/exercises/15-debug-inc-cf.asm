; Exercise 15: debug lecture
;
; Educational: compute 0xFF as byte in al, add 1 to al (wraps). Exit with CF materialized: after add, setc al; movzx rdi,al expect 1.
;
; Build: nasm -f elf64 15-debug-inc-cf.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
