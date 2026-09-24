; Exercise 11: isolate lowbit
;
; x=0b101100; x&-x -> 0b100 = 4; exit 4.
;
; Build: nasm -f elf64 11-isolate-lowbit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 0b101100
    mov rbx, rax
    neg rbx
    and rax, rbx
    mov rdi, rax
    mov rax,60
    syscall
