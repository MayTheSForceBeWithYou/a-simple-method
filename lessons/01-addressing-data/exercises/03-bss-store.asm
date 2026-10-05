; Exercise 03: bss store
;
; resb 1 in .bss. Store 7 into it, load into rdi, exit.
;
; Build: nasm -f elf64 03-bss-store.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
