; Exercise 07: while double
;
; rax=1; while rax<100 rax*=2; exit with final rax clamped: put rax in rdi then and 255; 128&255=128.
;
; Build: nasm -f elf64 07-while-double.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
.loop:
    cmp rax, 100
    jge .done
    imul rax, 2
    jmp .loop
.done:
    mov rdi, rax
    and rdi, 255
    mov rax, 60
    syscall
