; Exercise 13: pack rgba8888
;
; R=255 G=0 B=0 A=255; low byte R=255 exit 255.
;
; Build: nasm -f elf64 13-pack-rgba8888.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax,255
    ; RGBA little-endian R in low
    mov edi,eax
    mov rax,60
    syscall
