; Exercise 18: trampoline depth
;
; bump_depth(n) adds n via recursion; n=8 exit 8.
;
; Build: nasm -f elf64 18-trampoline-depth.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 8
    call bump
    mov rdi, rax
    mov rax, 60
    syscall
bump:
    ; TODO: implement bump
