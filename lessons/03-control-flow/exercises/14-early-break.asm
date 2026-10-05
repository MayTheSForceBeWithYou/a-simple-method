; Exercise 14: early break
;
; Sum arr dq 5,5,5,5 until sum>=10; exit sum (10).
;
; Build: nasm -f elf64 14-early-break.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
