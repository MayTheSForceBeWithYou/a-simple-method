; Exercise 23: stretch raw mode flag
;
; STRETCH: raw_mode byte set/clear; exit 0 after restore.
;
; Build: nasm -f elf64 23-stretch-raw-mode-flag.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    raw resb 1
section .text
    global _start
_start:
    mov byte [raw],1
    mov byte [raw],0
    movzx rdi, byte [raw]
    mov rax,60
    syscall
