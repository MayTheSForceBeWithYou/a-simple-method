; Exercise 23: stretch symbol resolve
;
; STRETCH: symbol table maps name hash to addr 0x20; exit 0x20=32.
;
; Build: nasm -f elf64 23-stretch-symbol-resolve.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    sym resq 1
section .text
    global _start
_start:
    mov qword [sym],32
    mov rdi,[sym]
    mov rax,60
    syscall
