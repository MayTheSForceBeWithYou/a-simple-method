; Exercise 01: token kind
;
; Token kinds as equ; exit TK_NUM=1.
;
; Build: nasm -f elf64 01-token-kind.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
