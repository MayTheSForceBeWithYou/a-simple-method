; Exercise 02: je equal
;
; rax=3,rbx=3. If equal exit 1 else 0.
;
; Build: nasm -f elf64 02-je-equal.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 3
    mov rbx, 3
    cmp rax, rbx
    je .yes
    xor rdi, rdi
    jmp .exit
.yes:
    mov rdi, 1
.exit:
    mov rax, 60
    syscall
