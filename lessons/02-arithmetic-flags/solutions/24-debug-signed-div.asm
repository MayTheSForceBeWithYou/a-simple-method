; Exercise 24: debug signed div
;
; BUG: used xor rdx,rdx before idiv of negative. Fix with cqo. (-20)/3 quot -6.
;
; Build: nasm -f elf64 24-debug-signed-div.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -20
    cqo
    mov rbx, 3
    idiv rbx
    mov rdi, rax
    add rdi, 6
    ; exit 0 if quot was -6
    mov rax, 60
    syscall
