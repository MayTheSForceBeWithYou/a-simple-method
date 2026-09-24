; Exercise 03: open fail
;
; open nonexistent path; if rax<0 exit 1 else 0. Expect 1.
;
; Build: nasm -f elf64 03-open-fail.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/no/such/asm_course_file",0
section .text
    global _start
_start:
    mov rax, 2
    lea rdi, [path]
    xor rsi, rsi
    syscall
    cmp rax, 0
    jl .bad
    xor rdi, rdi
    jmp .out
.bad:
    mov rdi, 1
.out:
    mov rax, 60
    syscall
