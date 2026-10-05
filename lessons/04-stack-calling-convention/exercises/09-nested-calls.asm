; Exercise 09: nested calls
;
; double(x)=x*2; add(a,b)=a+b. Compute add(double(10),double(11))=42.
;
; Build: nasm -f elf64 09-nested-calls.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    call double
    push rax
    mov rdi, 11
    call double
    mov rsi, rax
    pop rdi
    call add2
    mov rdi, rax
    mov rax, 60
    syscall

double:
    ; TODO: implement double
add2:
    ; TODO: implement add2
