; Exercise 21: sparse fill
;
; Fill every other byte in 8-byte buf with 1; sum=4.
;
; Build: nasm -f elf64 21-sparse-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 8
section .text
    global _start
_start:
    xor rcx, rcx
.l:
    cmp rcx, 8
    jge .sum
    test rcx, 1
    jnz .nz
    mov byte [buf+rcx], 1
.nz:
    inc rcx
    jmp .l
.sum:
    xor rdi, rdi
    xor rcx, rcx
.s:
    cmp rcx, 8
    jge .o
    movzx rax, byte [buf+rcx]
    add rdi, rax
    inc rcx
    jmp .s
.o:
    mov rax, 60
    syscall
