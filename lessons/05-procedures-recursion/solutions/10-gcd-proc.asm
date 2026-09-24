; Exercise 10: gcd proc
;
; gcd(rdi,rsi) Euclid recursive. gcd(48,18)=6; exit 6.
;
; Build: nasm -f elf64 10-gcd-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 48
    mov rsi, 18
    call gcd
    mov rdi, rax
    mov rax, 60
    syscall
gcd:
    cmp rsi, 0
    je .base
    mov rax, rdi
    xor rdx, rdx
    div rsi
    mov rdi, rsi
    mov rsi, rdx
    call gcd
    ret
.base:
    mov rax, rdi
    ret
