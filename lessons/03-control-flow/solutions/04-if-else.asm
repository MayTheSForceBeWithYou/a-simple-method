; Exercise 04: if else
;
; If rax>10 exit 1 else exit 2. Set rax=11.
;
; Build: nasm -f elf64 04-if-else.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 11
    cmp rax, 10
    jg .then
    mov rdi, 2
    jmp .out
.then:
    mov rdi, 1
.out:
    mov rax, 60
    syscall
