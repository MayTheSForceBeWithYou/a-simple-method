; Exercise 14: brk query
;
; SYS_brk(0)=12 with rdi=0 returns current brk; exit 0 if rax>0.
;
; Build: nasm -f elf64 14-brk-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,12
    xor rdi,rdi
    syscall
    test rax,rax
    jz .z
    xor rdi,rdi
    jmp .o
.z:
    mov rdi,1
.o:
    mov rax,60
    syscall
