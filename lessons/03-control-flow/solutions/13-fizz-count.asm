; Exercise 13: fizz count
;
; AoC-lite: count numbers 1..20 divisible by 3 (6). Exit 6.
;
; Build: nasm -f elf64 13-fizz-count.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    mov rcx, 1
.loop:
    cmp rcx, 20
    jg .done
    mov rax, rcx
    xor rdx, rdx
    mov rbx, 3
    div rbx
    cmp rdx, 0
    jne .next
    inc rdi
.next:
    inc rcx
    jmp .loop
.done:
    mov rax, 60
    syscall
