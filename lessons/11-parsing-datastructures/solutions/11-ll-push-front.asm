; Exercise 11: ll push front
;
; Push two nodes; head val=2; exit 2.
;
; Build: nasm -f elf64 11-ll-push-front.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    n1 resq 2
    n2 resq 2
    head resq 1
section .text
    global _start
_start:
    mov qword [n1],1
    mov qword [n1+8],0
    mov qword [head],n1
    mov qword [n2],2
    mov rax,[head]
    mov [n2+8],rax
    mov qword [head],n2
    mov rax,[head]
    mov rdi,[rax]
    mov rax,60
    syscall
