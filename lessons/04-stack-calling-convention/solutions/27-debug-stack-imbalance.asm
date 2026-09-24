; Exercise 27: debug stack imbalance
;
; BUG: extra push without pop before ret corrupts return. Fix; exit 2.
;
; Build: nasm -f elf64 27-debug-stack-imbalance.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    call two
    mov rdi, rax
    mov rax, 60
    syscall

two:
    mov rax, 2
    ret
