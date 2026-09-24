; Exercise 20: count char
;
; Count 's' in 'mississippi' -> 4.
;
; Build: nasm -f elf64 20-count-char.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "mississippi",0
section .text
    global _start
_start:
    lea rsi, [s]
    xor rdi, rdi
.l:
    movzx rax, byte [rsi]
    test rax, rax
    jz .d
    cmp al, 's'
    jne .n
    inc rdi
.n:
    inc rsi
    jmp .l
.d:
    mov rax, 60
    syscall
