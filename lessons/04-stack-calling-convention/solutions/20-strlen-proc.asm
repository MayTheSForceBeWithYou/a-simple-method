; Exercise 20: strlen proc
;
; strlen(rdi)->rax. 'assembly' len 8; exit 8.
;
; Build: nasm -f elf64 20-strlen-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "assembly", 0

section .text
    global _start
_start:
    lea rdi, [s]
    call strlen
    mov rdi, rax
    mov rax, 60
    syscall

strlen:
    mov rax, rdi
.loop:
    cmp byte [rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    sub rax, rdi
    ret
