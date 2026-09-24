; Exercise 11: fixed div
;
; Q16: (6<<16)/(2<<16) via (a<<16)/b style: ((6<<16)<<16)/(2<<16) careful. Simpler int: 6/2=3 exit 3.
;
; Build: nasm -f elf64 11-fixed-div.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax,6
    shl eax,16
    mov ebx,2
    shl ebx,16
    ; (a / b) in Q16: (a<<16)/b but a already Q16: use i64
    movsxd rax,eax
    shl rax,16
    movsxd rbx,ebx
    cqo
    idiv rbx
    shr rax,16
    mov rdi,rax
    mov rax,60
    syscall
