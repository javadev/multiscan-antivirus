
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модуль выводит сообщения об ошибках
;

public  analizErrDir,analizErrDisk,analizErr,int24Entry
public  mesSecNotFound,mesWriteProtect,mesTotalError,ioErr,diskNotReady
public  mesDataErr,mesWrite,mesRead,mesClBad,mesWriteOver,printOver
extrn   printEng:near,who:near,mesBody3:near,varBreak:byte,device:byte
extrn   writeChar:near,varEng:byte,print:near,varKeyOk:byte,color:byte
extrn   print0D0A:near,varRap:byte,countErr:byte
        .model small
        .code
analizErrDir proc
; table |off Error (w)| metod (w)|
        push dx si ds
        push ss
        pop  ds
        push word ptr varRap
        mov countErr,99
        mov varRap,0
        mov color,12
        xor ah,ah
        shl ax,1
        shl ax,1
        lea si,tableErr
        add si,ax
        mov dx,[si]
        cmp byte ptr [si+2],1
        je  outError1
outError:
        call printEng
        mov dl,'.'
        call writeChar
        call print0D0A
        jmp short exitOutErr3
outError1:
        mov al,device
        call setDev
        call printEng
        mov dl,'.'
        call writeChar
        call print0D0A
        mov al,1
        lea dx,mesBody3
        push word ptr varKeyOk
        mov varKeyOk,0
        call who
        pop word ptr varKeyOk
        pushf
        call print0D0A
        popf
        jnc exitOutError
        mov varBreak,1
exitOutErr3:
        mov al,3
        stc
exitOutError:
        pop word ptr varRap
        pop ds si dx
        ret
        endp
setDev proc
        push si ax
        mov si,dx
        cmp varEng,0
        je nextChar
find0:
        lodsb
        or al,al
        jne find0
nextChar:
        lodsb
        or al,al
        je exitDev
        cmp al,':'
        jne nextChar
        pop ax
        push ax
        mov byte ptr [si-2],al
exitDev:
        pop ax si
        ret
        endp
printOver proc
        mov al,0Dh
        call analizErrDir
        ret
        endp
analizErr proc
        push ax bx cx dx di es
        xor bx,bx
        mov ah,59h
        int 21h
        cmp ax,19
        jb analizOk
        cmp al,31
        ja analizBad
        sub al,19
        call analizErrDir
exitAnaliz:
        pop es di dx cx bx ax
        ret
        endp
analizOk:
        clc
        jmp short exitAnaliz
analizBad:
        stc
        jmp short exitAnaliz
int24Entry proc
        push dx ds es
        push ax
        mov ax,@data
        mov ds,ax
        mov es,ax
        pop ax
        test ah,80h
        jnz exit24
        add al,'A'
        mov device,al
exit24:
        mov al,3
        cmp varBreak,1
        je toIret
        mov ax,di
        call analizErrDir
toIret:
        pop es ds dx
        iret
        endp
analizErrDisk proc
        push dx
        mov color,12
        cmp ah,0
        clc
        je noErrDisk
        cmp ah,1
        je noErrDisk1
        cmp ah,2
        je noErrDisk1
        cmp ah,3
        jne nextDiskErr
        xor ax,ax               ; защита записи
        call analizErrDir
        pop dx
        ret
nextDiskErr:
        lea dx,mesSecNotFound
        cmp ah,4
        jne noErrDisk1
        call printEng
        call print0D0A
noErrDisk1:
        stc
noErrDisk:
        pop dx
        ret
        endp
        .data
tableErr        equ $
                dw mesWriteProtect  , 1 ; 0
                dw mesTotalError    , 3 ; 1
                dw diskNotReady     , 1 ; 2
                dw mesTotalError    , 3 ; 3
                dw mesDataErr       , 3 ; 4
                dw mesTotalError    , 3 ; 5
                dw mesTotalError    , 3 ; 6
                dw mesTotalError    , 3 ; 7
                dw mesSecNotFound   , 3 ; 8
                dw mesTotalError    , 3 ; 9
                dw mesWrite         , 3 ; A
                dw mesRead          , 3 ; B
                dw mesTotalError    , 3 ; C
                dw mesWriteOver     , 3 ; D
mesSecNotFound  db ' - сектор не найден',0
                db ' - sector not found',0
                dw 0EE01h,mesSecNotFound
mesWriteProtect db 10,9,9,'  Внимание !!! Диск X: защищен от записи',0
                db 10,9,9,' Attention !!! Disk X: is write protected',0
                db 10,9,9
                dw 0EE01h,mesWriteProtect
mesTotalError   db ' - неизвестная ошибка',0
                db ' - unknown error',0
                dw 0EE01h,mesTotalError
ioErr           db ' - ошибка ввода/вывода',0
                db ' - input/output error',0
                dw 0EE01h,ioErr
diskNotReady    db 10,9,9,9,'  Устройство X: не готово',0
                db 10,9,9,9,'    Device X: not ready',0
                dw 0EE01h,diskNotReady
mesDataErr      db ' - ошибка данных',0
                db ' - data error',0
                dw 0EE01h,mesDataErr
mesWrite        db ' - ошибка записи',0
                db ' - write error',0
                dw 0EE01h,mesWrite
mesRead         db ' - ошибка чтения',0
                db ' - read error',0
                dw 0EE01h,mesRead
mesWriteOver    db ' - недостаточно места на диске',0
                db ' - disk full. Write error',0
                dw 0EE01h,mesWriteOver
mesClBad        db ' - ошибка закрытия файла',10,0
                db ' - file close error',10,0
                dw 0EE01h,mesClBad
end
