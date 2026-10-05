; Exercise 02: mutual even odd
;
; is_even/is_odd mutual recursion. is_even(4)->1; exit 1.
;
; Build: nasm -f elf64 02-mutual-even-odd.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 4
    call is_even
    mov rdi, rax
    mov rax, 60
    syscall
is_even:
    ; TODO: implement is_even
is_odd:
    ; TODO: implement is_odd
