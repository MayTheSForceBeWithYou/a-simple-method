; Exercise 15: jump table
;
; rax=1. Jump table of 3 cases setting rdi to 10/20/30. Exit 20.
;
; Build: nasm -f elf64 15-jump-table.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    jmp [jt+rax*8]
case0:
    ; TODO: implement case0
case1:
    ; TODO: implement case1
case2:
    ; TODO: implement case2
done:
    ; TODO: implement done
section .rodata
jt:
    ; TODO: implement jt
