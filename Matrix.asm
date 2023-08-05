model tiny
.386
.code
includelib c:\libs\main_lib.lib
include c:\libs\pstring\pstring.inc
include c:\libs\heap\heap.inc
include c:\libs\array\array.inc

matrix_head struc
    db ?                    ;block type
    dw ?                    ;сегмент владельца
    dw ?                    ;block size
    MatrixType db ?         ;тип элемента матрицы
    MatrixTotalLength dw ?  ;общая длина
    MatrixRangeCount dw ?   ;количество строк
    MatrixColumnCount dw ?  ;количество столбцов
ends

matrix struc 
    dd ?
ends

Matrix_New proc C far uses dx ds
@@MatrixType    equ [esp+8]
@@MatrixRangeCount equ [esp+10]
@@MatrixColumnCount equ [esp+12]
    mov ax, @@MatrixRangeCount
    mov dx, @@MatrixColumnCount
    mul dx
    call Array_New C, word ptr @@MatrixType+2, ax
    rol eax, 16
    lea dx, [eax-1]
    mov ds, dx
    rol eax, 16
    mov dx, @@MatrixRangeCount
    mov ds:[MatrixRangeCount], dx
    mov dx, @@MatrixColumnCount
    mov ds:[MatrixColumnCount], dx
    ret
endp

Matrix_GetRangeCount proc C far uses ds
@@Matrix equ [esp+6]
    mov ax, @@Matrix[2]
    dec ax
    mov ds, ax
    mov ax, ds:[MatrixRangeCount]
    ret
endp

Matrix_GetColumnsCount proc C far uses ds
@@Matrix equ [esp+6]
    mov ax, @@Matrix[2]
    dec ax
    mov ds, ax
    mov ax, ds:[MatrixColumnCount]
    ret
endp

Matrix_GetElement proc C far uses ds dx
@@Matrix    equ [esp+8]
@@RangeNum  equ [esp+10]
@@ColumnNum equ [esp+12]
    mov dx, @@RangeNum
    call Matrix_GetRangeCount C, @@Matrix
    
    ret
endp

Pstring_New PStr1
TAB db 1, 9h
NL db 1, 0

Mat1 matrix <>

main:
    mov ax, @data
    mov ds, ax
    call $ method Heap:Init C, END_PROG
    call Matrix_New C, WORD, 4, 4
    mov Mat1, eax
    xor eax, eax
    call $ method Array:GetLength C, Mat1
    call $ method PString:Int32Str C, ds offset PStr1, eax
    call $ method PString:Write C, ds offset PStr1
    call $ method PString:Write C, ds offset TAB
    call Matrix_GetColumnsCount C, Mat1
    call $ method PString:Int32Str C, ds offset PStr1, eax
    call $ method PString:Write C, ds offset PStr1
    mov ah, 4ch
    int 21h
.fardata END_PROG
end main