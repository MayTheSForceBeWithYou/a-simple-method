; Exercise 09: cmp sete
;
; rax=5, rbx=5. cmp; sete al; movzx rdi,al; exit 1.
;
; Build: nasm -f elf64 09-cmp-sete.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    mov rbx, 5
    cmp rax, rbx
    sete al
    movzx rdi, al
    mov rax, 60
    syscall
