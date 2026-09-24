; Exercise 11: map array proc
;
; apply_inc: for each of 4 qwords, +=1 via procedure. Sum after = 14 for {1,2,3,4}->15? 2+3+4+5=14. Exit 14.
;
; Build: nasm -f elf64 11-map-array-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 1,2,3,4
section .text
    global _start
_start:
    lea rdi, [arr]
    mov rsi, 4
    call map_inc
    mov rdi, [arr]
    add rdi, [arr+8]
    add rdi, [arr+16]
    add rdi, [arr+24]
    mov rax, 60
    syscall
map_inc:
    xor rcx, rcx
.l:
    cmp rcx, rsi
    jge .d
    inc qword [rdi+rcx*8]
    inc rcx
    jmp .l
.d:
    ret
