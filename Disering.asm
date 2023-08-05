model small
.586
.stack 100h
.data
includelib c:\libs\main_lib.lib
includelib c:\disering\dislib.lib
include c:\disering\Matrix\Matrix.inc
include c:\libs\heap\heap.inc
include c:\libs\array\array.inc
include c:\libs\pstring\pstring.inc
include c:\libs\console\console.inc

VERSION M520

LOCALS __

MatA matrix <>
MatB matrix <>
MatC matrix <>

PString_New PStr1
TAB db 1, 09h
PString_New NL, ' '

ImgFCBTable struc
    Disc db ?
    Name db 8 dup (0)
    FileType db 3 dup (0)
    DataBlock dw ?
    LogicSize dw ?
ends

FileName db 'image.ppm', 0

.code

PrintMatrix proc C far uses ecx eax bx
@@Matrix equ [esp+14]
    call Matrix_GetColumnsCount C, DWORD ptr @@Matrix
    mov bx, ax
    xor ecx, ecx
    @@:
        rol ecx, 16
        xor cx, cx
        @@:
            rol ecx, 16
            call Matrix_GetElement C, DWORD ptr @@Matrix+4, ecx
            rol ecx, 16
            call $ method PString:Int32Str C, ds offset PStr1, eax
            call $ Method PString:Write C, ds offset PStr1
            call $ Method Console:PutChar C, 09h
        inc cx
        cmp cx, bx
        jb @B
        call $ Method Console:PutChar C, 0Ah
        call $ Method Console:PutChar C, 0Dh
        rol ecx, 16
    inc cx
    cmp cx, bx
    jb @0
    ret
endp

GetNextVal proc C near uses ecx ebx edx
@@MatB equ [esp+14]
@@MatA equ [esp+18]
    mov eax, ebx
    mov edx, ebx
    shr cx, 1
    bsr cx, cx
    mov bx, 0FFFFh
    shl bx, cl
    rol edx, 16
    shr dx, cl
    rol edx, 16
    shr dx, cl
    not bx
    push bx
    push bx
    pop ebx
    and eax, ebx
    mov ecx, edx
    call Matrix_GetElement C, dword ptr @@MatB+4, eax
    mov bx, ax
    shl bx, 2
    call Matrix_GetElement C, dword ptr @@MatA+4, ecx
    add ax, bx
    ret
endp

NextDis proc C far uses ds esi es edi eax edx ebx ecx
@@MatA      equ [esp+32]
@@MatBLink  equ [esp+36]
@@MatCLink  equ [esp+40]
    les di, @@MatBLink                                              ;загружаем указатель на матрицу позапрошлой итерации
    mov bx, es:[di][2]                                              ;освобождаем память, занятую старой матрицей
    call $ method Heap:FreeBlock C, bx
    lds si, @@MatCLink                                              ;загружаем указатель на матрицу прошлой итерации
    movsd                                                           ;теперь прошлая итерация в MatB
    sub di, 4
    sub si, 4
    call $ method Matrix:GetRangeCount C, dword ptr es:[di]         ;получаем размерность матрицы предыдущей итерации
    shl ax, 1                                                       ;новая матрица размерностью в 2 раза больше
    mov cx, ax                                                      ;сохраняем эту размерность в cx
    call $ method Matrix:New C, BYTE, ax, ax                        ;выделяем новую память для матрицы текущей итерации
    mov ds:[si], eax                                                ;загружаем эту память по указателю, теперь текущая итерация в MatC
    xor ebx, ebx                                                    ;ebx - двойной счетчик. Старшая часть - строки, младшая - столбцы
    @@:
        rol ebx, 16                                                 ;поэтому перебор идет сперва по столбцу, потом по строке
        xor bx, bx
        @@:
            call GetNextVal C, DWORD ptr es:[di], dword ptr @@MatA
            call Matrix_SetElement C, DWORD ptr ds:[si], ebx, ax
        inc bx
        cmp bx, cx
        jb @B
        rol ebx, 16
    inc bx
    cmp bx, cx
    jb @2
    ret
endp

main proc
    mov ax, @data
    mov ds, ax
    xor eax, eax
    mov al, 85
    int 10h
    call $ method Heap:Init C, END_PROG
    call $ method Matrix:New C, BYTE, 2, 2
    mov MatA, eax
    call $ method Matrix:SetElement C, MatA, 0, 0, 0
    call $ method Matrix:SetElement C, MatA, 0, 1, 2
    call $ method Matrix:SetElement C, MatA, 1, 0, 3
    call $ method Matrix:SetElement C, MatA, 1, 1, 1
    call $ method Matrix:New C, BYTE, 2, 2
    mov MatB, eax
    call $ method Matrix:New C, BYTE, 2, 2
    mov MatC, eax
    push ds
    les di, MatC
    lds si, MatA
    movsd
    pop ds
    call NextDis C, MatA, ds offset MatB, ds offset MatC
    call NextDis C, MatA, ds offset MatB, ds offset MatC
    call NextDis C, MatA, ds offset MatB, ds offset MatC
    call PrintMatrix C, MatC
    mov ah, 4ch
    int 21h
endp
.fardata END_PROG
end main