; Exercise 22: is prime lite
;
; Trial divide n=11 by 2..sqrt-ish (2..10). Exit 1 if prime else 0.
;
; Build: nasm -f elf64 22-is-prime-lite.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov r8, 11
    mov rcx, 2
.loop:
    cmp rcx, r8
    jge .prime
    mov rax, r8
    xor rdx, rdx
    div rcx
    cmp rdx, 0
    je .composite
    inc rcx
    jmp .loop
.composite:
    xor rdi, rdi
    jmp .out
.prime:
    mov rdi, 1
.out:
    mov rax, 60
    syscall
