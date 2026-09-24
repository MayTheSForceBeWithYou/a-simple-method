; Exercise 15: clip rect
;
; Clip x to [0,w); x=-1 -> 0; exit 0.
;
; Build: nasm -f elf64 15-clip-rect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,-1
    cmp rax,0
    jge .hi
    xor rax,rax
.hi:
    cmp rax,10
    jl .ok
    mov rax,9
.ok:
    mov rdi,rax
    mov rax,60
    syscall
