; Exercise 05: counted loop
;
; Add rcx times: start rdi=0,rcx=5; loop add 3 each time; exit 15.
;
; Build: nasm -f elf64 05-counted-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    mov rcx, 5
.loop:
    cmp rcx, 0
    je .done
    add rdi, 3
    dec rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
