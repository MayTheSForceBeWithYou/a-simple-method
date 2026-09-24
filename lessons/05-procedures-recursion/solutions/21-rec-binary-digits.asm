; Exercise 21: rec binary digits
;
; Count bits set via recursion clearing lowbit. popcount(0b1101)=3; exit 3.
;
; Build: nasm -f elf64 21-rec-binary-digits.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 0b1101
    call poprec
    mov rdi, rax
    mov rax, 60
    syscall
poprec:
    test rdi, rdi
    jz .z
    mov rax, rdi
    dec rax
    and rdi, rax
    call poprec
    inc rax
    ret
.z:
    xor rax, rax
    ret
