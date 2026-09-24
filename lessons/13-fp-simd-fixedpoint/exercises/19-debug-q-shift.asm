; Exercise 19: debug q shift
;
; BUG: forgot >>16 after Q mul. Fix 2*3 Q mul -> 6.
;
; Build: nasm -f elf64 19-debug-q-shift.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax,2
    shl eax,16
    mov ebx,3
    shl ebx,16
    movsxd rax,eax
    movsxd rbx,ebx
    imul rax,rbx
    ; BUG: missing shifts
    mov rdi,rax
    and rdi,255
    mov rax,60
    syscall
