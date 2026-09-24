; Exercise 16: bss resq
;
; resq 4. Store 1,2,3,4 into consecutive qwords; sum into rdi (10); exit.
;
; Build: nasm -f elf64 16-bss-resq.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    arr resq 4

section .text
    global _start
_start:
    mov qword [arr], 1
    mov qword [arr+8], 2
    mov qword [arr+16], 3
    mov qword [arr+24], 4
    mov rdi, [arr]
    add rdi, [arr+8]
    add rdi, [arr+16]
    add rdi, [arr+24]
    mov rax, 60
    syscall
