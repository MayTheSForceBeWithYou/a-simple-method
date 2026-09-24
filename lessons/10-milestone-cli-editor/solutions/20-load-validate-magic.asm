; Exercise 20: load validate magic
;
; Magic "ED01"; check first two ED; exit 1 if ok.
;
; Build: nasm -f elf64 20-load-validate-magic.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    magic db "ED01"
section .text
    global _start
_start:
    cmp word [magic], 0x4445
    jne .n
    mov rdi,1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
