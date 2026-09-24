; Exercise 11: strchr
;
; Find index of "l" in "hello" -> 2.
;
; Build: nasm -f elf64 11-strchr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "hello",0
section .text
    global _start
_start:
    lea rdi, [s]
    mov rsi, 'l'
    call strchr_idx
    mov rdi, rax
    mov rax, 60
    syscall
strchr_idx:
    xor rax, rax
.l:
    movzx rcx, byte [rdi+rax]
    test rcx, rcx
    jz .miss
    cmp rcx, rsi
    je .hit
    inc rax
    jmp .l
.miss:
    mov rax, 255
.hit:
    ret
