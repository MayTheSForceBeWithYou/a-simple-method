; Exercise 21: abi quiz exit
;
; Without printing: set rdi=1,rsi=2,rdx=3,rcx=4,r8=5,r9=6 then call identity6 that returns arg4 (rcx) in rax — but rcx is caller-saved and call clobber? Actually call doesn't clobber rcx itself; callee could. identity6: mov rax,rcx; ret. Exit 4.
;
; Build: nasm -f elf64 21-abi-quiz-exit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
