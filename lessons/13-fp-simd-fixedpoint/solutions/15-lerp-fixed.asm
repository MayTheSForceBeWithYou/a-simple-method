; Exercise 15: lerp fixed
;
; lerp(0,10,0.5) ~5 with Q16 t=1<<15; exit 5.
;
; Build: nasm -f elf64 15-lerp-fixed.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax,0
    mov ebx,10
    shl ebx,16
    mov ecx,1
    shl ecx,15
    ; a + (b-a)*t >>16 ; a=0
    movsxd rax,ebx
    movsxd rcx,ecx
    imul rax,rcx
    shr rax,16
    shr rax,16
    mov rdi,rax
    mov rax,60
    syscall
