; Exercise 29: from scratch factorial loop
;
; FROM SCRATCH: 6! with a counted loop = 720. Exit 720&255=208.
;
; Build: nasm -f elf64 29-from-scratch-factorial-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    mov rcx, 2
.loop:
    cmp rcx, 6
    jg .done
    imul rax, rcx
    inc rcx
    jmp .loop
.done:
    mov rdi, rax
    and rdi, 255
    mov rax, 60
    syscall
