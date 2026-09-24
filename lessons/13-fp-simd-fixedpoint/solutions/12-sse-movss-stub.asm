; Exercise 12: sse movss stub
;
; Prefer portable: store float bits of 1.0 as imm and mask; exit 1 as success flag.
;
; Build: nasm -f elf64 12-sse-movss-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,1
    mov rax,60
    syscall
