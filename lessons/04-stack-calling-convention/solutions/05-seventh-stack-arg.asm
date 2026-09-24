; Exercise 05: seventh stack arg
;
; sum7 uses 7th arg on stack. Pass 1..7; exit 28. Remember alignment.
;
; Build: nasm -f elf64 05-seventh-stack-arg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    push 0              ; align: will push one arg
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8, 5
    mov r9, 6
    push 7
    call sum7
    add rsp, 16
    mov rdi, rax
    mov rax, 60
    syscall

sum7:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rsp+8]
    ret
