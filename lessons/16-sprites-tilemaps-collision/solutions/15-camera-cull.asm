; Exercise 15: camera cull
;
; Sprite x=100 cam=50 view_w=40 -> culled; exit 1.
;
; Build: nasm -f elf64 15-camera-cull.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,100
    sub rax,50
    cmp rax,40
    jl .vis
    mov rdi,1
    jmp .o
.vis:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
