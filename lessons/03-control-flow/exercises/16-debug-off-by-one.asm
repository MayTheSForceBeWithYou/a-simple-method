; Exercise 16: debug off by one
;
; BUG: loop runs 0..n inclusive summing 1..5 as 0..5. Fix to sum 1..5 = 15.
;
; Build: nasm -f elf64 16-debug-off-by-one.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    mov rcx, 0
.loop:
    cmp rcx, 5
    jg .done
    add rdi, rcx
    inc rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
