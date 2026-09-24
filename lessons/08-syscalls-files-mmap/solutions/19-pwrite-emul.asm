; Exercise 19: pwrite emul
;
; Emulate pwrite via lseek+write on /dev/null: open, lseek end, write. Exit 0 on success.
;
; Build: nasm -f elf64 19-pwrite-emul.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/dev/null",0
    m db "x"
section .text
    global _start
_start:
    mov rax,2
    lea rdi,[path]
    mov rsi,1
    syscall
    cmp rax,0
    jl .e
    mov r8,rax
    mov rax,8
    mov rdi,r8
    xor rsi,rsi
    xor rdx,rdx
    syscall
    mov rax,1
    mov rdi,r8
    lea rsi,[m]
    mov rdx,1
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
