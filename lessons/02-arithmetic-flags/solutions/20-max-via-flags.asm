; Exercise 20: max via flags
;
; a=17,b=23 in regs. cmp; use cmovg (or branchless set) to put max in rdi. Exit 23.
;
; Build: nasm -f elf64 20-max-via-flags.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 17
    mov rbx, 23
    mov rdi, rax
    cmp rbx, rdi
    cmovg rdi, rbx
    mov rax, 60
    syscall
