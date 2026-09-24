; Exercise 03: macro write
;
; Macro sys_write1 msg,len; print 'M\n'.
;
; Build: nasm -f elf64 03-macro-write.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
%macro sys_write1 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro
section .data
    m db "M",10
section .text
    global _start
_start:
    sys_write1 m, 2
    mov rax,60
    xor rdi,rdi
    syscall
