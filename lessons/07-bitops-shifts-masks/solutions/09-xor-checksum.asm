; Exercise 09: xor checksum
;
; XOR-fold bytes 1,2,4,8 -> 15; exit 15.
;
; Build: nasm -f elf64 09-xor-checksum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    b db 1,2,4,8
section .text
    global _start
_start:
    xor eax,eax
    xor al,[b]
    xor al,[b+1]
    xor al,[b+2]
    xor al,[b+3]
    movzx rdi,al
    mov rax,60
    syscall
