; Exercise 11: read dev zero
;
; open /dev/zero; read 8 bytes; sum should be 0; exit 0.
;
; Build: nasm -f elf64 11-read-dev-zero.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
