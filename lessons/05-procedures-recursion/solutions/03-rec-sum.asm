; Exercise 03: rec sum
;
; sum_to(n)=n+(n-1)+...+1 recursive. sum_to(5)=15.
;
; Build: nasm -f elf64 03-rec-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 5
    call sum_to
    mov rdi, rax
    mov rax, 60
    syscall
sum_to:
    cmp rdi, 0
    jle .z
    push rdi
    dec rdi
    call sum_to
    pop rdi
    add rax, rdi
    ret
.z:
    xor rax, rax
    ret
