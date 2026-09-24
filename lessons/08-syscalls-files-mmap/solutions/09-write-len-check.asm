; Exercise 09: write len check
;
; write "Z\n"; if rax==2 exit 0 else 1.
;
; Build: nasm -f elf64 09-write-len-check.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    m db "Z",10
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,m
    mov rdx,2
    syscall
    cmp rax,2
    jne .bad
    xor rdi,rdi
    jmp .o
.bad:
    mov rdi,1
.o:
    mov rax,60
    syscall
