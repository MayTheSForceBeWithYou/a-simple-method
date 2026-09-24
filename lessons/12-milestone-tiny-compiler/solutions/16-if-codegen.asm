; Exercise 16: if codegen
;
; if 1 then 7 else 9; exit 7.
;
; Build: nasm -f elf64 16-if-codegen.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,1
    test rax,rax
    jz .e
    mov rdi,7
    jmp .o
.e:
    mov rdi,9
.o:
    mov rax,60
    syscall
