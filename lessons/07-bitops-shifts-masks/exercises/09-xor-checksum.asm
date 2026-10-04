; Exercise 09: xor checksum
;
; XOR-fold bytes 1,2,4,8 -> 15; exit 15.
;
; Build: nasm -f elf64 09-xor-checksum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
