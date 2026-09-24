; Exercise 17: closure sim
;
; Pass context pointer in r12 (callee-saved): ctx dq 10; add_ctx(rdi) returns rdi+[ctx]. Call with 5 -> 15.
;
; Build: nasm -f elf64 17-closure-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    ctx dq 10
section .text
    global _start
_start:
    lea r12, [ctx]
    mov rdi, 5
    call add_ctx
    mov rdi, rax
    mov rax, 60
    syscall
add_ctx:
    push r12
    mov rax, rdi
    add rax, [r12]
    pop r12
    ret
