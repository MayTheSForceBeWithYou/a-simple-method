; Exercise 10: put pixel
;
; put_pixel(x,y) with stride 8 bpp1; x=2 y=1 -> offset 10; store 9; exit 9.
;
; Build: nasm -f elf64 10-put-pixel.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
