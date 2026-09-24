; Exercise 23: stretch ascii validate
;
; STRETCH: validate all bytes <128 in "OK\n"; exit 1 if valid.
;
; Build: nasm -f elf64 23-stretch-utf8-ascii-validate.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "OK",10,0
section .text
    global _start
_start:
    lea rsi, [s]
.l:
    movzx rax, byte [rsi]
    test rax, rax
    jz .ok
    test rax, 0x80
    jnz .bad
    inc rsi
    jmp .l
.ok:
    mov rdi, 1
    jmp .o
.bad:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
