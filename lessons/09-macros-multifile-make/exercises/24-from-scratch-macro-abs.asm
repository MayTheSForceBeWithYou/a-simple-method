; Exercise 24: from scratch macro abs
;
; FROM SCRATCH: %macro ABS 1 for register; ABS rax with -9 -> 9 exit 9.
;
; Build: nasm -f elf64 24-from-scratch-macro-abs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
