; Exercise 14: two arrays sum
;
; a dq 3,4  b dq 5,6. rdi = a[0]+a[1]+b[0]+b[1] (18), exit.
;
; Build: nasm -f elf64 14-two-arrays-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
