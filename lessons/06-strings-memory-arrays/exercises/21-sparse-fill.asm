; Exercise 21: sparse fill
;
; Fill every other byte in 8-byte buf with 1; sum=4.
;
; Build: nasm -f elf64 21-sparse-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
