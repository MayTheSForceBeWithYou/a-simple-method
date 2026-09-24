; Exercise 16: debug missing pop
;
; BUG HUNT: recursive fact-like leaves stack unbalanced. Fix; fact(3)=6 exit 6.
;
; Build: nasm -f elf64 16-debug-missing-pop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 3
    call fact
    mov rdi, rax
    mov rax, 60
    syscall
fact:
    cmp rdi, 1
    jle .b
    push rdi
    dec rdi
    call fact
    pop rdi
    imul rax, rdi
    ret
.b:
    mov rax, 1
    ret
