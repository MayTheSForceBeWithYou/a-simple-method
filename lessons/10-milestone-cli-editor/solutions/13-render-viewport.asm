; Exercise 13: render viewport
;
; Render first line only of "L1\nL2\n"; write "L1\n"; exit 0.
;
; Build: nasm -f elf64 13-render-viewport.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    buf db "L1",10,"L2",10
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,buf
    mov rdx,3
    syscall
    xor rdi,rdi
    mov rax,60
    syscall
