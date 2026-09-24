; Exercise 13: munmap
;
; mmap then munmap (11); exit 0 if munmap rax==0.
;
; Build: nasm -f elf64 13-munmap.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,9
    xor rdi,rdi
    mov rsi,4096
    mov rdx,3
    mov r10,0x22
    mov r8,-1
    xor r9,r9
    syscall
    cmp rax,0
    jl .f
    mov rdi,rax
    mov rax,11
    mov rsi,4096
    syscall
    mov rdi,rax
    mov rax,60
    syscall
.f:
    mov rdi,1
    mov rax,60
    syscall
