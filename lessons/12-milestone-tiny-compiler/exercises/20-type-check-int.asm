; Exercise 20: type check int
;
; Type tag int=1; expression type int; exit 1.
;
; Build: nasm -f elf64 20-type-check-int.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
