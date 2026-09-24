; Exercise 10: nested if
;
; rax=7. If rax>0 and rax<10 exit 1 else 0.
;
; Build: nasm -f elf64 10-nested-if.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 7
    cmp rax, 0
    jle .no
    cmp rax, 10
    jge .no
    mov rdi, 1
    jmp .out
.no:
    xor rdi, rdi
.out:
    mov rax, 60
    syscall
