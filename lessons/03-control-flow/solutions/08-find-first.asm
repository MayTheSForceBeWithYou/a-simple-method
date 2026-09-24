; Exercise 08: find first
;
; arr db 3,1,4,1,5. Find first index of 4 (2). Exit index.
;
; Build: nasm -f elf64 08-find-first.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr db 3, 1, 4, 1, 5
    n equ 5

section .text
    global _start
_start:
    xor rcx, rcx
.loop:
    cmp rcx, n
    jge .missing
    movzx rax, byte [arr+rcx]
    cmp rax, 4
    je .found
    inc rcx
    jmp .loop
.found:
    mov rdi, rcx
    jmp .exit
.missing:
    mov rdi, 255
.exit:
    mov rax, 60
    syscall
