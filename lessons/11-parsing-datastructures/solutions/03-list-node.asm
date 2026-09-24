; Exercise 03: list node
;
; Node {dq val, next}; one node val 9; exit 9.
;
; Build: nasm -f elf64 03-list-node.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    node resq 2
section .text
    global _start
_start:
    mov qword [node], 9
    mov qword [node+8], 0
    mov rdi, [node]
    mov rax, 60
    syscall
