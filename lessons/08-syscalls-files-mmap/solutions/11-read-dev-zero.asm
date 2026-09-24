; Exercise 11: read dev zero
;
; open /dev/zero; read 8 bytes; sum should be 0; exit 0.
;
; Build: nasm -f elf64 11-read-dev-zero.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/dev/zero",0
section .bss
    buf resb 8
section .text
    global _start
_start:
    mov rax,2
    lea rdi,[path]
    xor rsi,rsi
    syscall
    cmp rax,0
    jl .e
    mov r8,rax
    mov rax,0
    mov rdi,r8
    lea rsi,[buf]
    mov rdx,8
    syscall
    mov rax,3
    mov rdi,r8
    syscall
    xor rdi,rdi
    jmp .o
.e:
    mov rdi,1
.o:
    mov rax,60
    syscall
