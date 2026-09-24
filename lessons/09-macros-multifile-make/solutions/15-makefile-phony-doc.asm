; Exercise 15: makefile phony doc
;
; Documents Make .PHONY; program exits 0. Read comment about naming targets.
;
; Build: nasm -f elf64 15-makefile-phony-doc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
; Example Makefile (not assembled):
; .PHONY: all clean
; all: prog
; prog: a.o b.o
;\tld $^ -o $@
; %.o: %.asm
;\tnasm -f elf64 $< -o $@
section .text
    global _start
_start:
    xor rdi,rdi
    mov rax,60
    syscall
