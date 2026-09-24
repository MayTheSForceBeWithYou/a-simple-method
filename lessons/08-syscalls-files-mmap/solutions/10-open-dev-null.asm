; Exercise 10: open dev null
;
; open /dev/null O_WRONLY=1; on success close and exit 0.
;
; Build: nasm -f elf64 10-open-dev-null.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/dev/null",0
section .text
    global _start
_start:
    mov rax,2
    lea rdi,[path]
    mov rsi,1
    syscall
    cmp rax,0
    jl .e
    mov rdi,rax
    mov rax,3
    syscall
    xor rdi,rdi
    jmp .o
.e:
    mov rdi,1
.o:
    mov rax,60
    syscall
