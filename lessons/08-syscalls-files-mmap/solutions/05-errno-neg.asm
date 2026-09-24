; Exercise 05: errno neg
;
; On failed open, mov rdi,rax; neg rdi; exit with small errno (clipped and 127).
;
; Build: nasm -f elf64 05-errno-neg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/nope",0
section .text
    global _start
_start:
    mov rax, 2
    lea rdi, [path]
    xor rsi, rsi
    syscall
    mov rdi, rax
    neg rdi
    and rdi, 127
    mov rax, 60
    syscall
