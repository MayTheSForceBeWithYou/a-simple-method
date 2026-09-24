; Exercise 13: variadic max
;
; max_n(n, ...) n in rdi, n qwords on stack. max of 5,9,2,9 -> wait n=3 values 5,1,9 exit 9.
;
; Build: nasm -f elf64 13-variadic-max.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    push 9
    push 1
    push 5
    mov rdi, 3
    call max_n
    add rsp, 24
    mov rdi, rax
    mov rax, 60
    syscall
max_n:
    mov rax, [rsp+8]
    mov rcx, 1
.l:
    cmp rcx, rdi
    jge .d
    mov rdx, [rsp+8+rcx*8]
    cmp rdx, rax
    cmovg rax, rdx
    inc rcx
    jmp .l
.d:
    ret
