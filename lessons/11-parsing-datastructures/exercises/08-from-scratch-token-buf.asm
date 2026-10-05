; Exercise 08: from scratch token buf
;
; FROM SCRATCH: store ascii 'x' as token lexeme len 1; exit 1.
;
; Build: nasm -f elf64 08-from-scratch-token-buf.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
