; Exercise 24: overwrite data
;
; msg db 'x',10. Change first byte to 'Y' in place, write 2 bytes, exit 0.
;
; Build: nasm -f elf64 24-overwrite-data.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
