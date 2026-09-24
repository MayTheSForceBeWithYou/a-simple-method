; Exercise 13: align before call
;
; Show correct alignment: at _start rsp is 8-mod-16 typically after argv setup — for freestanding ld entry, push a dummy then call a function that returns rsp&0xf via and — exit 0 if aligned after call entry check inside callee: mov rax,rsp; and rax,15; should be 8 at entry.
;
; Build: nasm -f elf64 13-align-before-call.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
