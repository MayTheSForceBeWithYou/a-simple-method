; Exercise 02: macro exit
;
; %macro exit_with 1 ... %endmacro; exit 7.
;
; Build: nasm -f elf64 02-macro-exit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
