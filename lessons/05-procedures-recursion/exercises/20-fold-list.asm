; Exercise 20: fold list
;
; Null-terminated qword list (0 sentinel): 3,4,5,0. fold add via proc; exit 12.
;
; Build: nasm -f elf64 20-fold-list.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    lst dq 3,4,5,0
section .text
    global _start
_start:
    lea rdi, [lst]
    call fold_add
    mov rdi, rax
    mov rax, 60
    syscall
fold_add:
    ; TODO: implement fold_add
