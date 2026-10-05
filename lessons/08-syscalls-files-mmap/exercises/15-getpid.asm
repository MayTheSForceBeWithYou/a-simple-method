; Exercise 15: getpid
;
; SYS_getpid=39; exit pid&0x7f (nonzero usually).
;
; Build: nasm -f elf64 15-getpid.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
