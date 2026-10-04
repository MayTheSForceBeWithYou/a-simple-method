; Exercise 13: munmap
;
; mmap then munmap (11); exit 0 if munmap rax==0.
;
; Build: nasm -f elf64 13-munmap.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
