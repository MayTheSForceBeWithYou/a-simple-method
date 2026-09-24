; Exercise 04: mmap anon
;
; mmap 4096 anon private RW; store 42; exit 42. SYS_mmap=9.
;
; Build: nasm -f elf64 04-mmap-anon.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 9
    xor rdi, rdi
    mov rsi, 4096
    mov rdx, 3
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall
    cmp rax, 0
    jl .fail
    mov rbx, rax
    mov qword [rbx], 42
    mov rdi, [rbx]
    mov rax, 60
    syscall
.fail:
    mov rax, 60
    mov rdi, 2
    syscall
