; Exercise 18: max3 proc
;
; max3(a,b,c). Call max3(3,9,7); exit 9.
;
; Build: nasm -f elf64 18-max3-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 3
    mov rsi, 9
    mov rdx, 7
    call max3
    mov rdi, rax
    mov rax, 60
    syscall

max3:
    ; TODO: implement max3
