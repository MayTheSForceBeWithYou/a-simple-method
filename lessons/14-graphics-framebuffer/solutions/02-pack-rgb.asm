; Exercise 02: pack rgb
;
; Pack R=1,G=2,B=3 into 0x010203 then &255 exit 3.
;
; Build: nasm -f elf64 02-pack-rgb.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    shl rax, 16
    mov rbx, 2
    shl rbx, 8
    or rax, rbx
    or rax, 3
    movzx rdi, al
    mov rax, 60
    syscall
