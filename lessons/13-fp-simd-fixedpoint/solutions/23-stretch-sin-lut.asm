; Exercise 23: stretch sin lut
;
; STRETCH: LUT[0]=0 LUT[1]=1; index 1 exit 1.
;
; Build: nasm -f elf64 23-stretch-sin-lut.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    lut dq 0,1,0
section .text
    global _start
_start:
    mov rdi,[lut+8]
    mov rax,60
    syscall
