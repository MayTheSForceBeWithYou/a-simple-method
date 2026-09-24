; Exercise 24: from scratch ecs query
;
; FROM SCRATCH: count entities with mask POS; 3 of 4; exit 3.
;
; Build: nasm -f elf64 24-from-scratch-ecs-query.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    masks db 1,3,1,2
section .text
    global _start
_start:
    xor rdi,rdi
    xor rcx,rcx
.l:
    cmp rcx,4
    jge .d
    movzx rax,byte [masks+rcx]
    test rax,1
    jz .n
    inc rdi
.n:
    inc rcx
    jmp .l
.d:
    mov rax,60
    syscall
