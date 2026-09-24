; Exercise 08: from scratch tick
;
; FROM SCRATCH: sim_tick counter to 5; exit 5.
;
; Build: nasm -f elf64 08-from-scratch-tick.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    tick resq 1
section .text
    global _start
_start:
.l:
    cmp qword [tick], 5
    jge .d
    inc qword [tick]
    jmp .l
.d:
    mov rdi, [tick]
    mov rax, 60
    syscall
