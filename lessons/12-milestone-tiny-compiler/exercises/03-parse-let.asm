; Exercise 03: parse let
;
; Recognize keyword first letter 'l' of let; exit 1.
;
; Build: nasm -f elf64 03-parse-let.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
