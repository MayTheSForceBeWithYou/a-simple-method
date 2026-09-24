; Exercise 24: nested loops
;
; Count pairs (i,j) with 0<=i<3, 0<=j<4 (12). Exit 12.
;
; Build: nasm -f elf64 24-nested-loops.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    xor r8, r8
.outer:
    cmp r8, 3
    jge .done
    xor r9, r9
.inner:
    cmp r9, 4
    jge .next
    inc rdi
    inc r9
    jmp .inner
.next:
    inc r8
    jmp .outer
.done:
    mov rax, 60
    syscall
