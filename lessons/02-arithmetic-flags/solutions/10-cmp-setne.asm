; Exercise 10: cmp setne
;
; rax=5, rbx=6. setne -> exit 1.
;
; Build: nasm -f elf64 10-cmp-setne.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    mov rbx, 6
    cmp rax, rbx
    setne al
    movzx rdi, al
    mov rax, 60
    syscall
