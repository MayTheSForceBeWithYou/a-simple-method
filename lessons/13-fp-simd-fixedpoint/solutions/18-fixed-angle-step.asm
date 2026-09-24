; Exercise 18: fixed angle step
;
; Angle += delta; wrap 360; 350+20 -> 10; exit 10.
;
; Build: nasm -f elf64 18-fixed-angle-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,350
    add rax,20
.w:
    cmp rax,360
    jl .d
    sub rax,360
    jmp .w
.d:
    mov rdi,rax
    mov rax,60
    syscall
