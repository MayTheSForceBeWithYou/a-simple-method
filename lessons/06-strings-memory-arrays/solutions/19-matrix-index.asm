; Exercise 19: matrix index
;
; Row-major 3x3; get (r=1,c=2) from 1..9 matrix -> 6.
;
; Build: nasm -f elf64 19-matrix-index.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    m dq 1,2,3,4,5,6,7,8,9
section .text
    global _start
_start:
    mov rax, 1
    imul rax, 3
    add rax, 2
    mov rdi, [m+rax*8]
    mov rax, 60
    syscall
