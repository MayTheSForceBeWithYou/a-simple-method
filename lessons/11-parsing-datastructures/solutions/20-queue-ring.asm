; Exercise 20: queue ring
;
; Ring buffer cap 4; enqueue 7,8; dequeue; exit 7.
;
; Build: nasm -f elf64 20-queue-ring.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    q resq 4
    head resq 1
    tail resq 1
section .text
    global _start
_start:
    mov qword [head],0
    mov qword [tail],0
    mov rcx,[tail]
    mov qword [q+rcx*8],7
    inc qword [tail]
    mov rcx,[tail]
    mov qword [q+rcx*8],8
    inc qword [tail]
    mov rcx,[head]
    mov rdi,[q+rcx*8]
    inc qword [head]
    mov rax,60
    syscall
