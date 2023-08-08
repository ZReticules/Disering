model tiny
.386
.code
org 100h
includelib c:\libs\main_lib.lib
include c:\libs\console\console.inc
include c:\libs\console\point.inc
include c:\libs\console\color.inc

pzero point <0,0>
ZeroCol EGAColor <0,0>

VERSION M520

EGA_ChgColor proc C far uses ax bx
arg Color:byte, Red:Byte, Green:byte, Blue:byte
    xor ah, ah
    ror Red, 1
    ror Green, 1
    ror Blue, 1
    call RolColors
    rol Red, 1
    rol Green, 1
    rol Blue, 1
    call RolColors
    shr bx, 2
    mov bl, Color
    mov ax, 1000h;
    int 10h
    ret
    RolColors proc
        mov al, Blue
        shrd bx, ax, 1
        mov al, Green
        shrd bx, ax, 1 
        mov al, Red
        shrd bx, ax, 1  
        ret
    endp
endp

Normal_Palette proc C near
    call EGA_ChgColor C, 0000b, 0b, 0b, 0b
    call EGA_ChgColor C, 0001b, 0b, 0b, 10b
    call EGA_ChgColor C, 0010b, 0b, 10b, 0b
    call EGA_ChgColor C, 0010b, 0b, 10b, 0b
    call EGA_ChgColor C, 0011b, 0b, 10b, 10b
    call EGA_ChgColor C, 0100b, 10b, 0b, 0b
    call EGA_ChgColor C, 0101b, 10b, 0b, 10b
    call EGA_ChgColor C, 0110b, 10b, 10b, 0b
    call EGA_ChgColor C, 0111b, 10b, 10b, 10b
    call EGA_ChgColor C, 1000b, 1b, 1b, 1b
    call EGA_ChgColor C, 1001b, 0b, 0b, 11b
    call EGA_ChgColor C, 1010b, 0b, 11b, 0b
    call EGA_ChgColor C, 1010b, 0b, 11b, 0b
    call EGA_ChgColor C, 1011b, 0b, 11b, 11b
    call EGA_ChgColor C, 1100b, 11b, 0b, 0b
    call EGA_ChgColor C, 1101b, 11b, 0b, 11b
    call EGA_ChgColor C, 1110b, 11b, 11b, 0b
    call EGA_ChgColor C, 1111b, 11b, 11b, 11b
    ret
endp

main:
    mov ax, @data
    mov ds, ax
    mov ax, 0012h
    int 10h
    call Normal_Palette
    Call $ method Console:SetCursorPosition C, pzero
    xor bx, bx
    mov ah, 09h
    mov al, 0dbh
    @@:
        mov cx, 80
        int 10h
        call $ method Console:PutChar C, 0Ah
        inc bl
    cmp bl, 16
    jl @B
    mov ah, 4ch
    int 21h

end main