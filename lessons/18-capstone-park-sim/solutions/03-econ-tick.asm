; Exercise 03: econ tick
;
; cash+=5; exit cash 5.
;
; Build: nasm -f elf64 03-econ-tick.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    cash resq 1
section .text
    global _start
_start:
    add qword [cash], 5
    mov rdi, [cash]
    mov rax, 60
    syscall
