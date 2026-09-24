; Exercise 24: from scratch rec sum array
;
; FROM SCRATCH: rec_sum(arr,n) sums n qwords. {2,3,4} n=3 -> 9.
;
; Build: nasm -f elf64 24-from-scratch-rec-sum-array.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 2,3,4
section .text
    global _start
_start:
    lea rdi, [arr]
    mov rsi, 3
    call rec_sum
    mov rdi, rax
    mov rax, 60
    syscall
rec_sum:
    test rsi, rsi
    jz .z
    mov rax, [rdi]
    push rax
    add rdi, 8
    dec rsi
    call rec_sum
    pop rdx
    add rax, rdx
    ret
.z:
    xor rax, rax
    ret
