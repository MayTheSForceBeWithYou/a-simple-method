; Exercise 14: early break
;
; Sum arr dq 5,5,5,5 until sum>=10; exit sum (10).
;
; Build: nasm -f elf64 14-early-break.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 5, 5, 5, 5

section .text
    global _start
_start:
    xor rdi, rdi
    xor rcx, rcx
.loop:
    cmp rdi, 10
    jge .done
    add rdi, [arr+rcx*8]
    inc rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
