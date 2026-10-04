; Exercise 18: mask range
;
; Make mask of width 5: (1<<5)-1 = 31; exit 31.
;
; Build: nasm -f elf64 18-mask-range.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
