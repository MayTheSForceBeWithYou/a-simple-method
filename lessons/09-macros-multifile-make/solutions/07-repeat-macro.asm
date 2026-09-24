; Exercise 07: repeat macro
;
; %rep 3 increment; exit 3.
;
; Build: nasm -f elf64 07-repeat-macro.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
%rep 3
    inc rdi
%endrep
    mov rax, 60
    syscall
