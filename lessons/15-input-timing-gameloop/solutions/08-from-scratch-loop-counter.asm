; Exercise 08: from scratch loop counter
;
; FROM SCRATCH: 10 frame iterations; exit 10.
;
; Build: nasm -f elf64 08-from-scratch-loop-counter.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
.l:
    cmp rdi, 10
    jge .d
    inc rdi
    jmp .l
.d:
    mov rax, 60
    syscall
