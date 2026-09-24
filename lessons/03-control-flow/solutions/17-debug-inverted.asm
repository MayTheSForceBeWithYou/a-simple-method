; Exercise 17: debug inverted
;
; BUG: jl used where jg needed. rax=5 should take 'big' path exit 2.
;
; Build: nasm -f elf64 17-debug-inverted.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    cmp rax, 3
    jg .big
    mov rdi, 1
    jmp .out
.big:
    mov rdi, 2
.out:
    mov rax, 60
    syscall
