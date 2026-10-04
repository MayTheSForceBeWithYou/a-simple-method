; Exercise 08: from scratch close
;
; FROM SCRATCH: open /dev/zero O_RDONLY=0; close fd; exit 0 on success.
;
; Build: nasm -f elf64 08-from-scratch-close.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
