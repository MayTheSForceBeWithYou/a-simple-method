; Exercise 13: setb unsigned
;
; rax=1, rbx=2. cmp; setb al; exit 1 (below unsigned).
;
; Build: nasm -f elf64 13-setb-unsigned.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    mov rbx, 2
    cmp rax, rbx
    setb al
    movzx rdi, al
    mov rax, 60
    syscall
