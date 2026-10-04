; Exercise 24: from scratch vector push
;
; FROM SCRATCH: dynamic array len/cap; push 3 values; exit len 3.
;
; Build: nasm -f elf64 24-from-scratch-vector-push.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    data resq 8
    len resq 1
    cap resq 1
section .text
    global _start
_start:
    mov qword [cap],8
    mov qword [len],0
    call push1
    call push1
    call push1
    mov rdi,[len]
    mov rax,60
    syscall
push1:
    ; TODO: implement push1
