; Exercise 18: call codegen
;
; Compile call: function returns 11; exit 11.
;
; Build: nasm -f elf64 18-call-codegen.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    call f
    mov rdi,rax
    mov rax,60
    syscall
f:
    mov rax,11
    ret
