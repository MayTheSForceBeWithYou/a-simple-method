; Exercise 25: stretch binsearch
;
; STRETCH: sorted dq 1,3,5,7,9. Binary search for 7; exit index 3.
;
; Build: nasm -f elf64 25-stretch-binsearch.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 1, 3, 5, 7, 9
    n equ 5

section .text
    global _start
_start:
    xor r8, r8
    mov r9, n
    dec r9
    mov r10, 7
.loop:
    cmp r8, r9
    jg .miss
    mov rax, r8
    add rax, r9
    shr rax, 1
    mov rcx, rax
    mov rdx, [arr+rcx*8]
    cmp rdx, r10
    je .found
    jl .go_right
    mov r9, rcx
    dec r9
    jmp .loop
.go_right:
    mov r8, rcx
    inc r8
    jmp .loop
.found:
    mov rdi, rcx
    jmp .out
.miss:
    mov rdi, 255
.out:
    mov rax, 60
    syscall
