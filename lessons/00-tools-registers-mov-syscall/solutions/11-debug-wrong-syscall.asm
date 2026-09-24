; Exercise 11: debug wrong syscall
;
; BUG HUNT: Intends to exit status 3 but uses wrong syscall number. Fix it.
;
; Build: nasm -f elf64 11-debug-wrong-syscall.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 60
    mov rdi, 3
    syscall
