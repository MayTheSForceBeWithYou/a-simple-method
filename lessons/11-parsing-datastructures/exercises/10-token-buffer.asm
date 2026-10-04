; Exercise 10: token buffer
;
; Lexeme copy "let" into tok; len=3 exit 3.
;
; Build: nasm -f elf64 10-token-buffer.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
