; Exercise 28: from scratch abi add
;
; FROM SCRATCH: implement and call add3(a,b,c) = a+b+c with ABI regs; exit 42 for 10,20,12.
;
; Build: nasm -f elf64 28-from-scratch-abi-add.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    mov rsi, 20
    mov rdx, 12
    call add3
    mov rdi, rax
    mov rax, 60
    syscall

add3:
    ; TODO: implement add3
