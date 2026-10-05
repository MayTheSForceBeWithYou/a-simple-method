; Exercise 20: clz loop
;
; Count leading zeros in 16-bit value 0x00F0 -> 8; exit 8.
;
; Build: nasm -f elf64 20-count-leading-zeros-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
