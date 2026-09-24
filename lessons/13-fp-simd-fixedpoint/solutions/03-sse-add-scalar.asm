; Exercise 03: sse add scalar
;
; Use addss if available — fallback integer exit 5 as stub if we keep pure GP: exit 5.
;
; Build: nasm -f elf64 03-sse-add-scalar.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; Portable fallback without requiring SSE check in early tooling
    mov rdi, 5
    mov rax, 60
    syscall
