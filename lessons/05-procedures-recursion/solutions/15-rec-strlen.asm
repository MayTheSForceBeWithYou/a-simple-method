; Exercise 15: rec strlen
;
; Recursive strlen on "abcd"; exit 4.
;
; Build: nasm -f elf64 15-rec-strlen.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "abcd",0
section .text
    global _start
_start:
    lea rdi, [s]
    call rstrlen
    mov rdi, rax
    mov rax, 60
    syscall
rstrlen:
    cmp byte [rdi], 0
    je .z
    inc rdi
    call rstrlen
    inc rax
    ret
.z:
    xor rax, rax
    ret
