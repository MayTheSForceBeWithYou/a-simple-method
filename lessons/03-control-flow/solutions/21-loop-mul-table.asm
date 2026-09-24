; Exercise 21: loop mul table
;
; Compute 7*8 via repeated addition loop. Exit 56.
;
; Build: nasm -f elf64 21-loop-mul-table.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    mov rcx, 8
.loop:
    cmp rcx, 0
    je .done
    add rdi, 7
    dec rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
