; Exercise 20: weather tick
;
; Rain intensity 0..3 cycle; from 3 -> 0; exit 0.
;
; Build: nasm -f elf64 20-weather-tick.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    rain resq 1
section .text
    global _start
_start:
    mov qword [rain],3
    inc qword [rain]
    and qword [rain],3
    mov rdi,[rain]
    mov rax,60
    syscall
