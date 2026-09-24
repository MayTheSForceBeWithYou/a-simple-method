; Exercise 03: aabb reject
;
; No overlap -> 0.
;
; Build: nasm -f elf64 03-aabb-reject.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    mov rax, 60
    syscall
