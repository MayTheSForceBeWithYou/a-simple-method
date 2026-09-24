; Exercise 03: jne branch
;
; rax=1,rbx=2. jne -> exit 5; if equal would exit 0.
;
; Build: nasm -f elf64 03-jne-branch.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    mov rbx, 2
    cmp rax, rbx
    jne .diff
    xor rdi, rdi
    jmp .exit
.diff:
    mov rdi, 5
.exit:
    mov rax, 60
    syscall
