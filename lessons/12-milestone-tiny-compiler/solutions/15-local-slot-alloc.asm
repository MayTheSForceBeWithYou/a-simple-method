; Exercise 15: local slot alloc
;
; Allocate 3 locals; next_slot=3; exit 3.
;
; Build: nasm -f elf64 15-local-slot-alloc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    next_slot resq 1
section .text
    global _start
_start:
    mov qword [next_slot],0
    inc qword [next_slot]
    inc qword [next_slot]
    inc qword [next_slot]
    mov rdi,[next_slot]
    mov rax,60
    syscall
