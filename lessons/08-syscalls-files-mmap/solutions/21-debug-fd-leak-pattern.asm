; Exercise 21: debug fd pattern
;
; BUG: wrong syscall number for close (used 1). Fix open /dev/zero and close; exit 0.
;
; Build: nasm -f elf64 21-debug-fd-leak-pattern.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/dev/zero",0
section .text
    global _start
_start:
    mov rax,2
    lea rdi,[path]
    xor rsi,rsi
    syscall
    cmp rax,0
    jl .e
    mov rdi,rax
    mov rax,3
    syscall
    xor rdi,rdi
    jmp .o
.e:
    mov rdi,1
.o:
    mov rax,60
    syscall
