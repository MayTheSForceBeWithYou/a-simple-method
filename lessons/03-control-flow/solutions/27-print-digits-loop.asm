; Exercise 27: print digits loop
;
; Print "01234\n" using a loop that stores digits into a buffer then one write. Exit 0.
;
; Build: nasm -f elf64 27-print-digits-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .bss
    buf resb 6

section .text
    global _start
_start:
    xor rcx, rcx
.loop:
    cmp rcx, 5
    jge .write
    mov rax, rcx
    add rax, '0'
    mov [buf+rcx], al
    inc rcx
    jmp .loop
.write:
    mov byte [buf+5], 10
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 6
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
