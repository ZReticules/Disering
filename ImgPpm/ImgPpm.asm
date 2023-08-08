model tiny
.586
.code
org 100h

ImgPpm struc
    Handle dw ?
ends

ImgPpm_FromFile proc C far 

main:
    mov ax, cs
    mov ds, ax
    mov ah, 4ch
    int 21h

end main