; Exercise 22: stretch itoa
;
; STRETCH: itoa 123 into buffer; write then exit 0. Also set len cell=3 and exit 3 instead if no write needed.
;
; Build: nasm -f elf64 22-stretch-itoa.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 16
    len resq 1
section .text
    global _start
_start:
    mov rdi, 123
    lea rsi, [buf]
    call itoa
    mov rdi, rax
    mov rax, 60
    syscall
itoa:
    ; returns length
    mov rax, rdi
    mov rbx, 10
    lea rcx, [rsi+15]
    mov byte [rcx], 0
    xor r8, r8
    test rax, rax
    jnz .loop
    dec rcx
    mov byte [rcx], '0'
    mov rax, 1
    mov rdi, rsi
    mov byte [rdi], '0'
    mov byte [rdi+1], 0
    ret
.loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    inc r8
    test rax, rax
    jnz .loop
    ; copy to rsi front
    mov rdx, r8
    mov rdi, rsi
.cpy:
    mov al, [rcx]
    mov [rdi], al
    inc rcx
    inc rdi
    dec rdx
    jnz .cpy
    mov byte [rdi], 0
    mov rax, r8
    ret
