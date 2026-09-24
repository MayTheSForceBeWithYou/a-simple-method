; Exercise 15: gap insert
;
; Gap buffer: gap_s=2 gap_e=6; insert shrinks gap; free space after insert one = 3; exit 3.
;
; Build: nasm -f elf64 15-gap-insert.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    gap_s resq 1
    gap_e resq 1
section .text
    global _start
_start:
    mov qword [gap_s],2
    mov qword [gap_e],6
    ; insert one char at gap_s
    inc qword [gap_s]
    mov rdi,[gap_e]
    sub rdi,[gap_s]
    mov rax,60
    syscall
