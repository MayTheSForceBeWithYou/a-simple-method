; Exercise 20: write from bss
;
; Fill 4-byte bss with 'Z',0x0A,'Z',0x0A. Write 4 bytes. Exit 0.
;
; Build: nasm -f elf64 20-write-from-bss.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
