; Exercise 11: max in array
;
; arr dq 3,9,2,7. Max in rdi (9).
;
; Build: nasm -f elf64 11-max-in-array.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
