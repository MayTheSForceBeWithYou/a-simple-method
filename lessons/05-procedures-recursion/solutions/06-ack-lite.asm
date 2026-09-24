; Exercise 06: ack lite
;
; ack(1,1) classic = 3. Implement ack(m,n). Exit 3.
;
; Build: nasm -f elf64 06-ack-lite.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 1
    mov rsi, 1
    call ack
    mov rdi, rax
    mov rax, 60
    syscall
ack:
    cmp rdi, 0
    je .m0
    cmp rsi, 0
    je .n0
    push rdi
    dec rsi
    call ack
    mov rsi, rax
    pop rdi
    dec rdi
    jmp ack
.m0:
    mov rax, rsi
    inc rax
    ret
.n0:
    dec rdi
    mov rsi, 1
    jmp ack
