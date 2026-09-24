; Exercise 23: collatz steps
;
; Collatz steps for n=6 until 1: 6->3->10->5->16->8->4->2->1 = 8 steps. Exit 8.
;
; Build: nasm -f elf64 23-collatz-steps.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 6
    xor rdi, rdi
.loop:
    cmp rax, 1
    je .done
    inc rdi
    test rax, 1
    jnz .odd
    shr rax, 1
    jmp .loop
.odd:
    imul rax, 3
    add rax, 1
    jmp .loop
.done:
    mov rax, 60
    syscall
