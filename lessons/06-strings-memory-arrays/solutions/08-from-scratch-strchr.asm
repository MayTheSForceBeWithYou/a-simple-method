; Exercise 08: from scratch strchr
;
; FROM SCRATCH: strchr for 'c' in 'abcd'; return index 2.
;
; Build: nasm -f elf64 08-from-scratch-strchr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "abcd",0
section .text
    global _start
_start:
    lea rdi, [s]
    mov rsi, 'c'
    call strchr_idx
    mov rdi, rax
    mov rax, 60
    syscall
strchr_idx:
    xor rax, rax
.l:
    movzx rcx, byte [rdi+rax]
    cmp rcx, 0
    je .miss
    cmp rcx, rsi
    je .hit
    inc rax
    jmp .l
.miss:
    mov rax, 255
.hit:
    ret
