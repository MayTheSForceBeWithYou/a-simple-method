; Exercise 01: buffer init
;
; resb 64 buffer; store length 0 in len dq; exit len.
;
; Build: nasm -f elf64 01-buffer-init.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
