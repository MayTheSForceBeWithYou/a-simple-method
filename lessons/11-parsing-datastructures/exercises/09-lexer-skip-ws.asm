; Exercise 09: lexer skip ws
;
; Skip spaces before digit in "  7"; exit value 7.
;
; Build: nasm -f elf64 09-lexer-skip-ws.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
