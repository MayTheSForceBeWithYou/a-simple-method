; Exercise 22: many pushes balance
;
; Push 1,2,3; call sum_top3 that reads [rsp+8],[rsp+16],[rsp+24] after call (retaddr at [rsp]). Exit 6.
;
; Build: nasm -f elf64 22-many-pushes-balance.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    push 1
    push 2
    push 3
    call sum_top3
    add rsp, 24
    mov rdi, rax
    mov rax, 60
    syscall

sum_top3:
    ; TODO: implement sum_top3
