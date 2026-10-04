; Exercise 21: intern string
;
; Intern table pointer equality: same slot; exit 1.
;
; Build: nasm -f elf64 21-intern-string.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
