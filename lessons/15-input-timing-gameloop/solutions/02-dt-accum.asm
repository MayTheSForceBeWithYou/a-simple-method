; Exercise 02: dt accum
;
; accum+=dt; if >= step then tick++; exit ticks 2 for accum sim.
;
; Build: nasm -f elf64 02-dt-accum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    mov rax, 0
    add rax, 8
    add rax, 8
    mov rbx, 8
.l:
    cmp rax, rbx
    jl .d
    sub rax, rbx
    inc rdi
    jmp .l
.d:
    mov rax, 60
    syscall
