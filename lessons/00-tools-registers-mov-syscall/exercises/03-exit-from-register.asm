; Exercise 03: exit from register
;
; Put 42 in rbx, copy to rdi, exit with that status. Immediate only allowed when loading rbx.
;
; Build: nasm -f elf64 03-exit-from-register.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
