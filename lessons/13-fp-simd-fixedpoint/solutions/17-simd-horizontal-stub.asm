; Exercise 17: simd horizontal stub
;
; Sum 4 lanes {1,2,3,4}=10 without SSE.
;
; Build: nasm -f elf64 17-simd-horizontal-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    v dd 1,2,3,4
section .text
    global _start
_start:
    mov eax,[v]
    add eax,[v+4]
    add eax,[v+8]
    add eax,[v+12]
    mov edi,eax
    mov rax,60
    syscall
