; Exercise 07: simd lane sum stub
;
; Sum 4 bytes as if SIMD lanes; exit 10.
;
; Build: nasm -f elf64 07-simd-lane-sum-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    v db 1,2,3,4
section .text
    global _start
_start:
    xor rdi, rdi
    movzx rax, byte [v]
    add rdi, rax
    movzx rax, byte [v+1]
    add rdi, rax
    movzx rax, byte [v+2]
    add rdi, rax
    movzx rax, byte [v+3]
    add rdi, rax
    mov rax, 60
    syscall
