; Exercise 14: mutual parity count
;
; Count down from 7 using mutual even/odd that returns steps; or: is_even chain returns 1 for 6. Exit 1.
;
; Build: nasm -f elf64 14-mutual-parity-count.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 6
    call is_even
    mov rdi, rax
    mov rax, 60
    syscall
is_even:
    test rdi, rdi
    jz .y
    dec rdi
    jmp is_odd
.y:
    mov rax, 1
    ret
is_odd:
    test rdi, rdi
    jz .n
    dec rdi
    jmp is_even
.n:
    xor rax, rax
    ret
