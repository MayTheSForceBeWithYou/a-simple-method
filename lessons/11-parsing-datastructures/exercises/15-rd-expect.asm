; Exercise 15: rd expect
;
; Expect char "(" present; exit 1.
;
; Build: nasm -f elf64 15-rd-expect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
