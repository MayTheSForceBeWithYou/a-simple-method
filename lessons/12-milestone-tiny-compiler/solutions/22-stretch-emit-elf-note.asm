; Exercise 22: stretch emit elf note
;
; STRETCH: document emitting ELF; exit header size stub 64.
;
; Build: nasm -f elf64 22-stretch-emit-elf-note.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,64
    mov rax,60
    syscall
