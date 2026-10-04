; Exercise 09: write stderr
;
; Write "error\n" to stderr (fd 2), exit 1.
;
; Build: nasm -f elf64 09-write-stderr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
