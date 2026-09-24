; Exercise 05: entity alive
;
; flags bit0 alive; exit 1.
;
; Build: nasm -f elf64 05-entity-alive.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    flags db 1
section .text
    global _start
_start:
    movzx rdi, byte [flags]
    and rdi, 1
    mov rax, 60
    syscall
