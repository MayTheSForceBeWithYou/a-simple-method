; Exercise 05: render line
;
; Print buffer 'ed\n'; exit 0.
;
; Build: nasm -f elf64 05-render-line.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    buf db "ed",10
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,buf
    mov rdx,3
    syscall
    mov rax,60
    xor rdi,rdi
    syscall
