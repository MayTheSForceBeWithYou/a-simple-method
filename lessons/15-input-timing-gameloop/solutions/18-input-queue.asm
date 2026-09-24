; Exercise 18: input queue
;
; Enqueue event 9; dequeue; exit 9.
;
; Build: nasm -f elf64 18-input-queue.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    q resq 4
    h resq 1
    t resq 1
section .text
    global _start
_start:
    mov rcx,[t]
    mov qword [q+rcx*8],9
    inc qword [t]
    mov rcx,[h]
    mov rdi,[q+rcx*8]
    inc qword [h]
    mov rax,60
    syscall
