; Exercise 25: adc chain
;
; Add two 128-bit values lo/hi: a=(1,0) b=(0xFFFFFFFFFFFFFFFF,0). Use add/adc. Exit with CF after adc (1) via setc.
;
; Build: nasm -f elf64 25-adc-chain.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    mov rdx, 0
    mov rbx, 0xffffffffffffffff
    mov rcx, 0
    add rax, rbx
    adc rdx, rcx
    setc al
    movzx rdi, al
    mov rax, 60
    syscall
