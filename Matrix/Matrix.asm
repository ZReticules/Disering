model tiny
.586
.code
includelib c:\libs\main_lib.lib
include c:\libs\heap\heap.inc
include c:\libs\array\array.inc

VERSION M520

LOCALS __

public Matrix_New
public Matrix_GetRangeCount
public Matrix_GetColumnsCount
public Matrix_GetElement
public Matrix_SetElement

matrix_head struc
    db ?                    ;тип блока
    dw ?                    ;сегмент владельца
    dw ?                    ;размер блока
    MatrixType db ?         ;тип элемента матрицы
    MatrixTotalLength dw ?  ;общая длина
    MatrixRangeCount dw ?   ;количество строк
    MatrixColumnCount dw ?  ;количество столбцов
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

Matrix_GetElement proc C far uses ds cx
@@Matrix    equ [esp+8]
@@RangeNum  equ [esp+12]
@@ColumnNum equ [esp+14]
    xor eax, eax
    mov dx, @@RangeNum
    call Matrix_GetRangeCount C, dword ptr @@Matrix
    mul dx
    add ax, @@ColumnNum
    mov dx, @@Matrix[2]
    dec dx
    mov ds, dx
    mov cl, ds:[MatrixType]
    inc dx
    mov ds, dx
    cmp cl, 2
        je __dword
        jnp __byte
        jl __word
        __qword:
            mov edx, ds:[eax*QWORD+4]
            mov eax, ds:[eax*QWORD]
        jmp __return
        __dword:
            mov eax, ds:[eax*DWORD]
        jmp __return
        __word:
            mov ax, ds:[eax*WORD]
        jmp __return
        __byte:
            mov al, ds:[eax*BYTE]
    __return:
    ret
endp

Matrix_SetElement proc C far uses ds ecx
@@Matrix    equ [esp+10]
@@RangeNum  equ [esp+14]
@@ColumnNum equ [esp+16]
@@NewValue  equ [esp+18]
    xor eax, eax
    mov dx, @@RangeNum
    call Matrix_GetRangeCount C, dword ptr @@Matrix
    mul dx
    add ax, @@ColumnNum
    mov dx, @@Matrix[2]
    dec dx
    mov ds, dx
    mov cl, ds:[MatrixType]
    inc dx
    mov ds, dx
    cmp cl, 2
    mov ecx, eax
    mov eax, @@NewValue
    mov edx, @@NewValue+4
    je __dword
    jnp __byte
    jl __word
        __qword:
            mov ds:[ecx*QWORD+4], edx
            mov ds:[ecx*QWORD], eax
        jmp __return
        __dword:
            mov ds:[ecx*DWORD], eax
        jmp __return
        __word:
            mov ds:[ecx*WORD], ax
        jmp __return
        __byte:
            mov ds:[ecx*BYTE], al
    __return:
    ret
endp

end