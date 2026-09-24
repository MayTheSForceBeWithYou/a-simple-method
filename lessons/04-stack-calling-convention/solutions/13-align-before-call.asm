; Exercise 13: align before call
;
; Show correct alignment: at _start rsp is 8-mod-16 typically after argv setup — for freestanding ld entry, push a dummy then call a function that returns rsp&0xf via and — exit 0 if aligned after call entry check inside callee: mov rax,rsp; and rax,15; should be 8 at entry.
;
; Build: nasm -f elf64 13-align-before-call.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; make sure we call with aligned stack: rsp % 16 == 0 before call
    mov rax, rsp
    and rax, 15
    cmp rax, 0
    je .aligned
    push rax               ; adjust by 8 if needed
.aligned:
    call check
    mov rdi, rax
    mov rax, 60
    syscall

check:
    mov rax, rsp
    and rax, 15            ; expect 8 at function entry
    cmp rax, 8
    je .ok
    mov rax, 1
    ret
.ok:
    xor rax, rax
    ret
