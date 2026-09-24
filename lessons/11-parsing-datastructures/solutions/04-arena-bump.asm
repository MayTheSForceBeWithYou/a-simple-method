; Exercise 04: arena bump
;
; Bump allocate 16 then 16; offset 32; exit 32&255.
;
; Build: nasm -f elf64 04-arena-bump.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    bump resq 1
section .text
    global _start
_start:
    mov qword [bump], 0
    add qword [bump], 16
    add qword [bump], 16
    mov rdi, [bump]
    and rdi, 255
    mov rax, 60
    syscall
