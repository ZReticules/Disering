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
    FDisc db ?
    FName db 8 dup (0)
    FileType db 3 dup (0)
    DataBlock dw ?
    LogicSize dw ?
ends

FileName db 'img4.ppm', 0
ImgBuf dd 4 dup (?)

ImgWidth dw ?
ImgHeight dw ?

GammaRay label BYTE
    db 15 dup (0)
    db 10 dup (1)
    db 7 dup (2)
    db 5 dup(3)
    j = 4
    i = 4
    rept 3
        rept 3
            db j dup(i)
            i = i+1
        endm
        j = j - 1
    endm
    db 3 dup (13)
    i = 14
    rept 7
        db 2 dup(i)
        i = i+1
    endm
    db 21
    db 2 dup(22)
    db 2 dup(23)
    db 24
    db 2 dup(25)
    db 2 dup(26)
    db 27
    db 2 dup(28)
    db 29
    db 2 dup(30)
    db 31
    db 32
    db 2 dup(33)
    db 34
    db 2 dup(35)
    db 36
    db 37
    db 38
    db 2 dup(39)
    db 40
    db 41
    db 42
    db 3 dup(43)        ;увеличил на 1
    i = 44
    rept 6
        db i
        i=i+1
    endm
    i=49
    rept 23
        db i
        i=i+1
    endm
    i=73
    rept 7
        db i
        i=i+1
    endm
    i=81
    rept 5
        db i
        i=i+1
    endm
    i=87
    rept 5
        db i
        i=i+1
    endm
    irp x, <93, 94, 95, 97, 98, 99, 100, 102, 103, 105, 106, 107, 109, 110, 111, 113, 114>
        db x
    endm
    irp x, <116, 117, 119, 120, 121, 123, 124, 126, 127, 129, 130, 132, 133, 135, 137, 138>
        db x
    endm
    irp x, <140, 141, 143, 145, 146, 148, 149, 151, 153, 154, 156, 158, 159, 161, 163, 165>
        db x
    endm
    db 166
    db 168
    db 170
    db 172
    i=173
    rept 5
        db i
        i=i+2
    endm
    i=182
    rept 8
        db i
        i=i+2
    endm
    i=197
    rept 18
        db i
        i=i+2
    endm
    i=234
    rept 8
        db i
        i=i+2
    endm
    db 251
    db 253
    db 255

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

GetNextVal proc C near uses ecx ebx edx                 ;формула : C(i,j) = B(i mod len(b), j mod len(B))*4+A(i div len (B), j div len(B))
@@MatB equ [esp+14]
@@MatA equ [esp+18]
    mov eax, ebx                                        ;в ebx должны быть координаты: младшая часть - столбец, старшая - строка
    mov edx, ebx                                        ;в eax будет остаток
    shr cx, 1                                           ;в cx должна быть размерность квадратной матрицы, половина - размерность предыдущей
    bsr cx, cx                                          ;получаем степень двойки размерности, на эту степень двойки и делим
    mov bx, 0FFFFh                                      ;маска для получения остатка
    shl bx, cl                                          ;сдвигаем маску
    not bx                                              ;инвертируем
    rol edx, 16                                         ;получаем строки
    shr dx, cl                                          ;сначала строки сдвигаем
    rol edx, 16                                         ;получаем столбцы
    shr dx, cl                                          ;делим столбцы
    push bx
    push bx
    pop ebx                                             ;удваиваем маску
    and eax, ebx                                        ;получаем сразу остаток для двух
    mov ecx, edx                                        ;сохраеняем остаток в edx так как getelement портит edx
    call Matrix_GetElement C, dword ptr @@MatB+4, eax
    mov bx, ax                                          ;получаем элемент предыдущей матрицы, умножаем на 4
    shl bx, 2
    call Matrix_GetElement C, dword ptr @@MatA+4, ecx   ;получаем элемент изначальной матрицы, прибавляем к предыдущей
    add ax, bx
    ret
endp

NextDis proc C far uses ds esi es edi eax edx ebx ecx
@@MatA      equ [esp+32]
@@MatBLink  equ [esp+36]
@@MatCLink  equ [esp+40]
    les di, @@MatBLink                                              ;загрузка указателя на матрицу B (матрица предыдущей итерации)
    mov bx, es:[di][2]                                              ;освобождаем сегмент позапрошлой итерации
    call $ method Heap:FreeBlock C, bx
    lds si, @@MatCLink                                              ;загружаем сегмент прошлой итерации
    movsd                                                           ;теперь прошлая итерация в MatB
    sub di, 4
    sub si, 4
    call $ method Matrix:GetRangeCount C, dword ptr es:[di]         ;получаем размер матрицы предыдущей итерации
    shl ax, 1                                                       ;следующая - в два раза больше
    mov cx, ax                                                      ;соханяем в cx размерность
    call $ method Matrix:New C, BYTE, ax, ax                        ;создаем новую матрицу текущей итерации
    mov ds:[si], eax                                                ;теперь текущая итерация в матрице C
    xor ebx, ebx                                                    ;ebx - двойной счетчик. Внешний цикл идет по столбцам, внутренний - по строкам
    @@:
        rol ebx, 16                                                 ;старшая часть для номера строки
        xor bx, bx
        @@:
            call GetNextVal C, DWORD ptr es:[di], dword ptr @@MatA  ;получаем следующее значение, для чего нужен исходник и предыдущая итерация
            call Matrix_SetElement C, DWORD ptr ds:[si], ebx, ax    ;устанавливаем новый элемент
        inc bx
        cmp bx, cx
        jb @B
        rol ebx, 16
    inc bx
    cmp bx, cx
    jb @2
    ret
endp

Pixel_GetNext proc C near uses ax cx dx bx ds
@@PpmHandle     equ [esp+12]
@@ImgBufLink    equ [esp+14]
    lds dx, @@ImgBufLink                        ;указатель на буфер-приемник
    mov bx, @@PpmHandle                         ;дескриптор изображения
    mov cx, 3                                   ;по 3 байта на пиксель
    mov ah, 3Fh
    int 21h
    ret
endp

Gamma_Correction proc C near uses si ds ecx
@@Pixel equ [esp+10]
    mov si, seg GammaRay
    mov ds, si
    mov cx, 3
    @@:
        movzx si, byte ptr @@Pixel[ecx-1]
        mov al, ds:GammaRay[si]
        shl eax, 8
    loop @B
    ret
endp

Pixel_FromRgb proc C near uses cx ebx edx
@@Matrix        equ [esp+12]                            ;преобразование пикселя из ргб в EGA
@@Pixel         equ [esp+16]
    call Matrix_GetElement C, dword ptr @@Matrix+4, ebx ;в ebx должны быть уже округленные координаты
    mov dx, ax                                          ;в dx сохраняем элемент
    call Gamma_Correction C, dword ptr @@Pixel          ;производим гамма-коррекцию
    mov ebx, eax
    ; mov ebx, @@Pixel                                        ;в ebx пиксели, начиная со второго байта(bh)
    ; shl ebx, 8
    call Matrix_GetColumnsCount C, dword ptr @@Matrix   ;получаем размерность матрицы для сдвига
    xchg dx, ax                                         ;возвращаем обратно в ax элемент
    bsr cx, dx                                          ;длина матрицы нужна для сдвига значения пикселя
    sub cx, 4                                           ;вычитаем максимальную степень размерности
    neg cx                                              ;инвертируем, получая положительное значение
    shl cx, 1                                           ;умножаем на 2
    shl ax, 8                                           ;сдвигаем ax на 8 -  в al должен быть результирующий цвет
    mov edx, ebx                                        ;считаем яркость
    ;shl edx, 8
    mov ch, dh                                          ;здесь мы находим самый яркий и самый тусклый байты, складываем
    rol edx, 16
    cmp dh, dl
    jae @F
        xchg dh, dl
    @@:
    cmp dh, ch
    jae @F
        xchg dh, ch
    @@:
    cmp dl, ch
    jbe @F
        xchg dl, ch
    @@:
    mov ch, 3
    add dl, dh
    setc dh
    shr dx, 1
    add dl, ch
    setc dh
    shr dx, 1
    shr dx, cl
    cmp dl, ah
        seta al
    @@:
        shr bh, cl
        cmp bh, ah
        seta bl
        shl al, 1
        add al, bl
        shr ebx, 8
    dec ch
    jnz @B
    ret
endp

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

main proc
    mov ax, @data
    mov ds, ax
    ; mov al, 85
    ; int 10h
    mov ax, 0012h
    int 10h
    ;call Normal_Palette
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
    call NextDis StdCall, MatA, ds offset MatB, ds offset MatC
    call NextDis
    call NextDis
    ;call NextDis
    lea sp, [esp+12]
    mov dx, offset FileName
    mov ax, 3D00h
    int 21h
    mov bx, ax
    xor cx, cx
    mov dx, 3
    mov ax, 4200h
    int 21h
    mov cx, 16
    lea dx, ImgBuf
    mov ah, 3Fh
    int 21h
    mov eax, ImgBuf
    mov di, 1
    mov byte ptr PStr1[0], 0
    mov dx, 3+3+3
    @@:
        mov byte ptr PStr1[di], al
        inc di
        inc dx
        inc byte ptr PStr1[0]
        shr eax, 8
    cmp al, 20h
    jne @B
    call $ method PString:Int32Val C, ds offset PStr1
    mov ImgWidth, ax
    mov eax, ImgBuf[1*DWORD]
    mov di, 1
    mov byte ptr PStr1[0], 0
    @@:
        mov byte ptr PStr1[di], al
        inc di
        inc dx
        inc byte ptr PStr1[0]
        shr eax, 8
    cmp al, 0Ah
    jne @B
    call $ method PString:Int32Val C, ds offset PStr1
    mov ImgHeight, ax
    xor cx, cx
    mov ax, 4200h
    int 21h
    mov ImgBuf[3], 0
    ; call Pixel_GetNext C, bx, ds offset ImgBuf
    ; mov eax, ImgBuf
    ; xor bh, bh
    ; mov dx, 5
    ; xor cx, cx
    ; mov al, 1111b
    ; mov ah, 0Ch
    ; int 10h
    mov si, bx                                      ;дескриптор файла
    mov bx, 0FFFFh
    call $ method Matrix:GetColumnsCount C, MatC
    bsr cx, ax
    shl bx, cl
    mov di, bx
    not di 
    xor dx, dx                                         ;dx строки, cx столбцы
    @@:
        xor cx, cx
        @@:
            call Pixel_GetNext C, si, ds offset ImgBuf
            mov bx, cx
            and bx, di
            shl ebx, 16
            mov bx, dx
            and bx, di
            call Pixel_FromRgb C, MatC, ImgBuf
            mov ah, 0Ch
            xor bh, bh
            int 10h
        inc cx
        cmp cx, ImgWidth
        jb @B
    inc dx
    cmp dx, ImgHeight
    jb @11
    mov ah, 4ch
    int 21h
endp
.fardata END_PROG
end main