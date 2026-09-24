; Exercise 20: clz loop
;
; Count leading zeros in 16-bit value 0x00F0 -> 8; exit 8.
;
; Build: nasm -f elf64 20-count-leading-zeros-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    movzx rax, word [val]
    xor rdi, rdi
    mov rcx, 16
.l:
    test rax, rax
    jz .pad
    test rax, 0x8000
    jnz .d
    shl rax, 1
    inc rdi
    dec rcx
    jnz .l
    jmp .d
.pad:
    mov rdi, 16
.d:
    mov rax,60
    syscall
section .data
    val dw 0x00F0
