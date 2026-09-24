; Exercise 13: interp alpha
;
; alpha = accum/step with accum=8 step=16 -> 0.5 as Q16 0x8000>>15 =1? Use alpha in 0..100 =50; exit 50.
;
; Build: nasm -f elf64 13-interp-alpha.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,8
    imul rax,100
    xor rdx,rdx
    mov rbx,16
    div rbx
    mov rdi,rax
    mov rax,60
    syscall
