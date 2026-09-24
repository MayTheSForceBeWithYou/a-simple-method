; Exercise 23: stretch ui modal
;
; STRETCH: modal stack depth 1; exit 1.
;
; Build: nasm -f elf64 23-stretch-ui-modal.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    modal_depth resq 1
section .text
    global _start
_start:
    inc qword [modal_depth]
    mov rdi,[modal_depth]
    mov rax,60
    syscall
