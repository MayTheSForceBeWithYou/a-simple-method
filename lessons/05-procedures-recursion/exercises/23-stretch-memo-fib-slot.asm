; Exercise 23: stretch memo fib slot
;
; STRETCH: memo[10] slots; fib with memo fill. fib(8)=21; exit 21.
;
; Build: nasm -f elf64 23-stretch-memo-fib-slot.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    memo resq 16
section .text
    global _start
_start:
    ; clear memo to -1
    mov rcx, 16
    lea rdi, [memo]
.cl:
    mov qword [rdi], -1
    add rdi, 8
    loop .cl
    mov rdi, 8
    call fibm
    mov rdi, rax
    mov rax, 60
    syscall
fibm:
    ; TODO: implement fibm
