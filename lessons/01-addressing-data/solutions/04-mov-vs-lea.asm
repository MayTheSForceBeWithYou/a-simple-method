; Exercise 04: mov vs lea
;
; Label x dq 99. lea rbx,[x] then mov rdi,[rbx]. Exit with 99. Comment which is address vs load.
;
; Build: nasm -f elf64 04-mov-vs-lea.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    x dq 99

section .text
    global _start
_start:
    lea rbx, [x]
    mov rdi, [rbx]
    mov rax, 60
    syscall
