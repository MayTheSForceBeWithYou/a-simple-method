; Exercise 05: frame limit
;
; If frame_time < min, pad; return pad amount 2.
;
; Build: nasm -f elf64 05-frame-limit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 6
    mov rbx, 8
    cmp rax, rbx
    jge .nopad
    mov rdi, rbx
    sub rdi, rax
    jmp .o
.nopad:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
