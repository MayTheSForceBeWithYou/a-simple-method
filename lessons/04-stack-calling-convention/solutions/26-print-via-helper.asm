; Exercise 26: print via helper
;
; Helper write_str(rsi, rdx=len). Print "abi\n"; exit 0.
;
; Build: nasm -f elf64 26-print-via-helper.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "abi", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    lea rsi, [msg]
    mov rdx, msg_len
    call write_str
    mov rax, 60
    xor rdi, rdi
    syscall

write_str:
    mov rax, 1
    mov rdi, 1
    syscall
    ret
