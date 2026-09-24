; Exercise 08: from scratch close
;
; FROM SCRATCH: open /dev/zero O_RDONLY=0; close fd; exit 0 on success.
;
; Build: nasm -f elf64 08-from-scratch-close.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/dev/zero",0
section .text
    global _start
_start:
    mov rax, 2
    lea rdi, [path]
    xor rsi, rsi
    syscall
    cmp rax, 0
    jl .e
    mov rdi, rax
    mov rax, 3
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
.e:
    mov rax, 60
    mov rdi, 1
    syscall
