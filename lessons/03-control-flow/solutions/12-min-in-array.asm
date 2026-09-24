; Exercise 12: min in array
;
; Same array; min 2.
;
; Build: nasm -f elf64 12-min-in-array.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 3, 9, 2, 7
    n equ 4

section .text
    global _start
_start:
    mov rdi, [arr]
    mov rcx, 1
.loop:
    cmp rcx, n
    jge .done
    mov rax, [arr+rcx*8]
    cmp rax, rdi
    jge .cont
    mov rdi, rax
.cont:
    inc rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
