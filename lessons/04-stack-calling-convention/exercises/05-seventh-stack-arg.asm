; Exercise 05: seventh stack arg
;
; sum7 uses 7th arg on stack. Pass 1..7; exit 28. Remember alignment.
;
; Build: nasm -f elf64 05-seventh-stack-arg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    push 0              ; align: will push one arg
    ; TODO: implement push 0              ; align
sum7:
    ; TODO: implement sum7
