; Exercise 05: save magic
;
; Magic 'PK01' first byte 'P'=80; exit 80.
;
; Build: nasm -f elf64 05-save-magic.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
