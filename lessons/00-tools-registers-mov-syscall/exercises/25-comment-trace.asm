; Exercise 25: comment trace
;
; Exit 9. Every instruction needs an end-of-line comment.
;
; Build: nasm -f elf64 25-comment-trace.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
