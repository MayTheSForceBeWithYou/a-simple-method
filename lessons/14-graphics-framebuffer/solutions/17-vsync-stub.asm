; Exercise 17: vsync stub
;
; Frame ready flag clear; exit 0.
;
; Build: nasm -f elf64 17-vsync-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    ready resb 1
section .text
    global _start
_start:
    mov byte [ready],0
    movzx rdi,byte [ready]
    mov rax,60
    syscall
