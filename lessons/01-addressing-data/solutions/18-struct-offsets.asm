; Exercise 18: struct offsets
;
; Simulate struct {dq a; dq b; db c;}: set a=1,b=2,c=3. Exit a+b+c=6 using explicit offsets 0,8,16.
;
; Build: nasm -f elf64 18-struct-offsets.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    s resb 17

section .text
    global _start
_start:
    mov qword [s], 1
    mov qword [s+8], 2
    mov byte [s+16], 3
    mov rdi, [s]
    add rdi, [s+8]
    movzx rax, byte [s+16]
    add rdi, rax
    mov rax, 60
    syscall
