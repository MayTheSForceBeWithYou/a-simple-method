; Exercise 05: blit copy
;
; Copy 4 bytes src->dst; sum exit 10.
;
; Build: nasm -f elf64 05-blit-copy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
