; Exercise 09: count evens
;
; arr db 1,2,3,4,5,6. Count evens (3). test al,1 / jz.
;
; Build: nasm -f elf64 09-count-evens.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr db 1, 2, 3, 4, 5, 6
    n equ 6

section .text
    global _start
_start:
    xor rdi, rdi
    xor rcx, rcx
.loop:
    cmp rcx, n
    jge .done
    movzx rax, byte [arr+rcx]
    test rax, 1
    jnz .odd
    inc rdi
.odd:
    inc rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
