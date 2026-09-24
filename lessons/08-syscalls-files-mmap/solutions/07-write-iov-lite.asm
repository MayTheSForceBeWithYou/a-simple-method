; Exercise 07: write iov lite
;
; Two writes simulating writev; print 'A\nB\n'; exit 0.
;
; Build: nasm -f elf64 07-write-iov-lite.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    a db "A",10
    b db "B",10
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,a
    mov rdx,2
    syscall
    mov rax,1
    mov rdi,1
    mov rsi,b
    mov rdx,2
    syscall
    mov rax,60
    xor rdi,rdi
    syscall
