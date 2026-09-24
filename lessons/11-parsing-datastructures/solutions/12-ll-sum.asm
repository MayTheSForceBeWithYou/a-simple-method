; Exercise 12: ll sum
;
; List 3->4->5; sum=12.
;
; Build: nasm -f elf64 12-ll-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    ; nodes inline: val,next
    n3 dq 5,0
    n2 dq 4,n3
    n1 dq 3,n2
section .text
    global _start
_start:
    lea rsi,[n1]
    xor rdi,rdi
.l:
    test rsi,rsi
    jz .d
    add rdi,[rsi]
    mov rsi,[rsi+8]
    jmp .l
.d:
    mov rax,60
    syscall
