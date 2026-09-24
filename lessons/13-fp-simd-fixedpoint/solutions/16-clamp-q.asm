; Exercise 16: clamp q
;
; Clamp -3 to [0,100]; exit 0.
;
; Build: nasm -f elf64 16-clamp-q.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,-3
    cmp rax,0
    jge .hi
    xor rax,rax
.hi:
    cmp rax,100
    jle .ok
    mov rax,100
.ok:
    mov rdi,rax
    mov rax,60
    syscall
