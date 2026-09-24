; Exercise 15: rd expect
;
; Expect char "(" present; exit 1.
;
; Build: nasm -f elf64 15-rd-expect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "(1)",0
section .text
    global _start
_start:
    cmp byte [s],'('
    jne .n
    mov rdi,1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
