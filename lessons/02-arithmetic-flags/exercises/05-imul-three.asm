; Exercise 05: imul three
;
; Set rdi=6 then imul rdi,7. Exit 42.
;
; Build: nasm -f elf64 05-imul-three.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
