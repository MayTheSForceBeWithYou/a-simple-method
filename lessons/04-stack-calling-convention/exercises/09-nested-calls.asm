; Exercise 09: nested calls
;
; double(x)=x*2; add(a,b)=a+b. Compute add(double(10),double(11))=42.
;
; Build: nasm -f elf64 09-nested-calls.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
