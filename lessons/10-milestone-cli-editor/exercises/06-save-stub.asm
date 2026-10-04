; Exercise 06: save stub
;
; Pretend save ok; exit 0.
;
; Build: nasm -f elf64 06-save-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
