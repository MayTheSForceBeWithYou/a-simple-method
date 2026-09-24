; Exercise 27: stretch dot product
;
; STRETCH: u dq 2,3,4  v dq 5,6,7. rdi=2*5+3*6+4*7 (56). imul allowed.
;
; Build: nasm -f elf64 27-stretch-dot-product.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    u dq 2, 3, 4
    v dq 5, 6, 7

section .text
    global _start
_start:
    mov rax, [u]
    imul rax, [v]
    mov rdi, rax
    mov rax, [u+8]
    imul rax, [v+8]
    add rdi, rax
    mov rax, [u+16]
    imul rax, [v+16]
    add rdi, rax
    mov rax, 60
    syscall
