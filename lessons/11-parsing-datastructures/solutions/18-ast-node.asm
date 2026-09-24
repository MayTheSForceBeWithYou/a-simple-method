; Exercise 18: ast node
;
; AST node kind=1 left=2 right=3; exit kind+left+right=6.
;
; Build: nasm -f elf64 18-ast-node.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    node resq 3
section .text
    global _start
_start:
    mov qword [node],1
    mov qword [node+8],2
    mov qword [node+16],3
    mov rdi,[node]
    add rdi,[node+8]
    add rdi,[node+16]
    mov rax,60
    syscall
