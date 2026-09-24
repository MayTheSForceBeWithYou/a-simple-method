; Exercise 21: gray code
;
; Binary to gray: n^(n>>1) for n=7 -> 4; exit 4.
;
; Build: nasm -f elf64 21-gray-code.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 7
    mov rbx, rax
    shr rbx, 1
    xor rax, rbx
    mov rdi, rax
    mov rax,60
    syscall
