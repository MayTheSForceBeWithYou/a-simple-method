; Exercise 06: clip test
;
; x=5 w=4 -> outside exit 1.
;
; Build: nasm -f elf64 06-clip-test.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    cmp rax, 4
    jl .in
    mov rdi, 1
    jmp .o
.in:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
