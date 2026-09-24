; Exercise 15: jump table
;
; rax=1. Jump table of 3 cases setting rdi to 10/20/30. Exit 20.
;
; Build: nasm -f elf64 15-jump-table.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    jmp [jt+rax*8]
case0:
    mov rdi, 10
    jmp done
case1:
    mov rdi, 20
    jmp done
case2:
    mov rdi, 30
done:
    mov rax, 60
    syscall

section .rodata
jt:
    dq case0, case1, case2
