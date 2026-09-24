; Exercise 01: emit mov imm
;
; Compiler-ish: 'emit' by writing value 42 to out cell; exit 42.
;
; Build: nasm -f elf64 01-emit-mov-imm.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    outv resq 1
section .text
    global _start
_start:
    mov qword [outv], 42
    mov rdi, [outv]
    mov rax, 60
    syscall
