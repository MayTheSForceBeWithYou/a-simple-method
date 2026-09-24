; Exercise 24: from scratch ntz
;
; FROM SCRATCH: number of trailing zeros in 0b1011000 = 3; exit 3.
;
; Build: nasm -f elf64 24-from-scratch-ntz.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 0b1011000
    xor rdi, rdi
.l:
    test rax, 1
    jnz .d
    shr rax, 1
    inc rdi
    jmp .l
.d:
    mov rax,60
    syscall
