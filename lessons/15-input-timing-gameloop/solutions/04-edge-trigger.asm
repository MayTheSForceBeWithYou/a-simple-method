; Exercise 04: edge trigger
;
; prev=0 cur=1 -> rising exit 1.
;
; Build: nasm -f elf64 04-edge-trigger.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax, 0
    mov ebx, 1
    cmp eax, 0
    jne .n
    cmp ebx, 1
    jne .n
    mov rdi, 1
    jmp .o
.n:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
