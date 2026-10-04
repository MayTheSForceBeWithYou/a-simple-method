; Exercise 05: errno neg
;
; On failed open, mov rdi,rax; neg rdi; exit with small errno (clipped and 127).
;
; Build: nasm -f elf64 05-errno-neg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
