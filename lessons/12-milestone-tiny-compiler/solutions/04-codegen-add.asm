; Exercise 04: codegen add
;
; Fold 2+3 at compile-time; exit 5.
;
; Build: nasm -f elf64 04-codegen-add.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 2
    add rdi, 3
    mov rax, 60
    syscall
