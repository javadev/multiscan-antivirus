
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Изначально этот модуль добавлял/удалял вакцуну. Кое-чего было добавлено
;

public  checkVak,delIt,mesDelV,mesAnti,mesVacOk,mesOver,mesWhoO,mesOverOk
public  checkExtV,mesAnti
extrn   writeF:near,setPos:near,writeHead:near,formDI_CX:near
extrn   myTitle:word,typeFile:byte,color:byte,buf:near,changeOpen:near
extrn   setTime:near,readF:near,getPage:near
extrn   setPos1:near,print0D0A1:near,who:near,date:word,time:word
extrn   posHiAll:word,posLoAll:word,varVakcine:byte,printEng:near
extrn   pathMs:near,closeFile:near,writeChar:near,fname:near,path:near
extrn   handleW:word,varKeyOk:byte,erase:byte,segRec:word,lenRec:word
extrn   baseSeg:word,baseIP:word,subLenAX:near,posHi:word,posLo:word
extrn   calcSum:near,scanChSum:near,virFoundF:byte
        .model small
        .code

checkVak proc
        push ax cx dx si es
        push ss
        pop  es
        cmp virFoundF,0
        jne exitVac1
        cmp varVakcine,1
        je  vacOK
        cmp varVakcine,3
        je  vacOKP
        cmp varVakcine,2
        je  vacBack
        clc
exitVac:
        pushf
        cmp varKeyOk,2
        je noCheckMs
        call checkMs
noCheckMs:
        popf
        pop es si dx cx ax
        ret
        endp
vacOKP:
        mov byte ptr cs:setForXor,31h
vacOK:
        call doReadVak
        jc exitVac1
        call checkAntiO
        jne setVak
        mov color,2
        lea dx,mesAnti
        call printEng
        lea dx,mesVacOk
        call printEng
        call print0D0A1
exitVac1:
        clc             ; уже защищен
        jmp short exitVac
setVak:
        call checkExtV
        jne exitVac1
        cmp typeFile,0
        je  checkCom
        call protEXE
        jmp short exitVac1
checkCom:
        call protCOM
        jmp short exitVac1
vacBack:
        call doReadVak
        jc exitVac1
        call checkAntiB
        jne exitVac1    ; не был защищен
        push ax cx dx si
        lea dx,delIt
        call who
        jc  endBack
        call changeOpen
        jc  endBack
        mov si,baseIP
        push ds
        cmp typeFile,1
        mov ds,baseSeg
        je backEXE
        mov ax,word ptr [si+setLoBytes-vacBegin]
        mov ss:myTitle,ax
        mov al,byte ptr [si+setHiByte-vacBegin]
        mov byte ptr ss:myTitle+2,al
exitBack:
        pop ds
        mov ax,offset lenVac
        call subLenAX
        jc endBack
        lea dx,mesDelV
        call printEng
        call print0D0A1
        stc
        jmp short endBackStc
endBack:
        clc
endBackStc:
        pop si dx cx ax
        jmp exitVac

backEXE proc
        mov ax,word ptr [si+setSS10-vacBegin]
        sub ax,10h
        mov ss:[myTitle+0Eh],ax
        mov ax,word ptr [si+setSP-vacBegin]
        mov ss:[myTitle+10h],ax
        mov ax,word ptr [si+setCS10-vacBegin]
        sub ax,10h
        mov ss:[myTitle+16h],ax
        mov ax,word ptr [si+setIP-vacBegin]
        mov ss:[myTitle+14h],ax
        jmp exitBack
        endp
doReadVak proc
        push ax cx dx ds
        mov cx,posHi
        mov dx,posLo
        add dx,baseIP
        adc cx,0
        mov ax,4200h
        int 21h
        mov dx,baseIP
        mov ds,baseSeg
        mov cx,offset lenVac
        call readF
        pop ds dx cx ax
        ret
        endp
cmpName proc
nextName:
        lodsb
        mov cl,al
        or si,si
        jcxz endScN
        push di
        rep cmpsb
        pop di
        pushf
        add si,cx
        popf
        jne nextName
endScN:
        ret
        endp
checkExtV proc
        push ax cx si di
        call formDI_CX
        push si
        lea si,firstLet
        call cmpName
        pop si
        je badExN
        lea di,[si-4]
        lea si,lastLet
        call cmpName
normalEXT:
        pop di si cx ax
        ret
        endp
badExN:
        or si,si
        jmp normalEXT

checkMs proc
        push ax bx cx dx si di
        lea di,fname
        lea si,msName
        call cmpName
        stc
        jne endChMs0
        mov handleW,bx
        lea dx,pathMs
        mov ax,3D40h
        int 21h
endChMs0:
        jc  endChMs
        xchg ax,bx
        mov ax,5700h
        int 21h
        mov ax,date     ; ax текущего
        cmp dx,ax
        ja overIt
        stc
        jmp short closeChMs
overIt:
        mov time,cx
        mov date,dx
        lea dx,mesOver
        call printEng
        lea dx,mesWhoO
        call who
        jc  closeChMs
        call rewriteF
        mov al,1
        jc  closeChMs2
        lea dx,mesOverOk
        call printEng
        call print0D0A1
        xor al,al
closeChMs2:
        mov erase,al
closeChMs:
        pushf
        mov ah,3Eh
        int 21h
        popf
        jc endChMs
        call writeRec
endChMs:
        pop di si dx cx bx ax
        ret
        endp

writePoint proc
        push dx
        mov dl,'.'
        call writeChar
        pop dx
        ret
        endp
rewriteF proc
        push bx
        mov bx,handleW
        call changeOpen
        mov handleW,bx
        pop bx
        jc  closeChMs1

moreRW:
        push ds
        mov ds,baseSeg
        xor dx,dx
        mov cx,60000
        call readF
        pop ds
        jc  closeChMs1

        call writePoint
        push bx
        mov bx,handleW
        mov cx,ax
        push ds
        mov ds,baseSeg
        call writeF
        pop ds bx
        jc closeChMs1

        call writePoint
        cmp ax,60000
        je moreRW

        push bx
        mov bx,handleW
        xor cx,cx
        call writeF
        call setTime
        pop bx
closeChMs1:
        ret
        endp
writeRec proc
        cmp segRec,0
        je noWRE
        push ax cx dx si di
        call formDI_CX
        lea di,[si-4]
        mov ax,'ER'
        stosw
        mov ax,'C'
        stosw
        lea dx,path
        xor cx,cx
        mov ah,3Ch
        int 21h
        jc badMake
        xchg ax,bx
        mov cx,lenRec
        push ds
        mov ds,segRec
        xor dx,dx
        call writeF
        pop ds
        call setTime
        mov ah,3Eh
        int 21h
badMake:
        pop di si dx cx ax
noWRE:
        ret
        endp
checkAntiO proc
        push si
        lea si,addVak
        call checkAnti
        pop si
        je sigFound
checkAntiB:
        push si
        lea si,stdVak
        call checkAnti
        pop si
sigFound:
        ret
        endp
checkAnti proc
        push di es
        mov di,baseIP
        add di,offset offsetEntry
        mov es,baseSeg
        call scanChSum
        pop es di
        ret
        endp
protEXE proc
        call checkOVR
        jne exitBad
        call writetitExe
        jc exitBad
        call writeTail
exitBad:
        ret
        endp
protCOM proc
        call writeJump
        jc smallFile
        call writeTail
smallFile:
        ret
        endp
checkOVR proc
        push ax cx dx
        mov dx,posHiAll
        mov ax,posLoAll
        mov cx,200h
        div cx
        or dx,dx
        je noIncAx
        inc ax
noIncAx:
        cmp ax,ds:myTitle+4
        pop dx cx ax
        ret
        endp
writeJump proc
        push ax dx
        mov ax,posLoAll
        sub ax,3
        cmp ax,offset lenVac
        jb  badSize
        cmp ax,offset 0FE00h-lenVac
        ja  badSize
        push ax
        mov ax,myTitle
        mov word ptr cs:setLoBytes,ax
        mov al,byte ptr ds:myTitle+2
        mov byte ptr cs:setHiByte,al
        mov byte ptr cs:keyForRest,offset restoreCom-exitProg
        mov byte ptr cs:keyForCom,0
        pop ax
        mov byte ptr ds:myTitle,0E9h
        mov ds:[myTitle+1],ax
        add ax,offset lenVac+3
        mov cs:lenFileLo1,ax
        mov cs:lenFileHi1,0
        clc
        jmp short exitSize
badSize:
        stc
exitSize:
        pop dx ax
        ret
        endp
writetitExe proc
        push ax cx dx si
        mov si,offset myTitle+0Eh
        lodsw
        add ax,10h
        mov word ptr cs:setSS10,ax
        lodsw
        mov word ptr cs:setSP,ax
        lodsw
        lodsw
        mov word ptr cs:setIP,ax
        lodsw
        add ax,10h
        mov word ptr cs:setCS10,ax
        mov ax,posLoAll
        mov dx,posHiAll
        or dx,dx
        jnz longFile
        cmp ax,1000
        jb  exitEXEbad
longFile:
        mov cx,10h
        div cx
        lea si,myTitle
        sub ax,[si+8]
        sbb dx,0
        mov [si+14h],dx
        mov [si+16h],ax
        mov [si+0Eh],ax
        mov word ptr [si+10h],offset lenVac+640
        mov ax,posLoAll
        mov dx,posHiAll
        add ax,offset lenVac
        adc dx,0
        cmp varVakcine,3
        jne noAdd6
        add ax,6
noAdd6:
        mov cs:lenFileLo1,ax
        mov cs:lenFileHi1,dx
        mov cx,200h
        div cx
        inc ax
        mov [myTitle+4],ax
        mov [myTitle+2],dx
        mov byte ptr cs:keyForRest,offset restoreEXE-exitProg
        mov byte ptr cs:keyForCom,offset exitForEXE-beginCOM
        clc
exitEXEbad:
        pop si dx cx ax
        ret
        endp
writeTail proc
        push ax cx dx si di es
        call changeOpen
        jc protect1
        push cs
        pop  es
        lea si,myTitle
        lea di,vacTitle
        mov cx,12
        rep movsw
        xor al,al
moreInc:
        inc ax
        inc byte ptr cs:setKeyMes
        jz moreInc
        mov cx,offset begVac1-mesTurbo
decodMess:
        sub es:[di],al
        inc di
        loop decodMess
        mov al,2
        call setPos
        mov cx,date
        mov dx,time
        mov word ptr cs:setDat,cx
        mov word ptr cs:setTim,dx
        lea dx,vacBegin
        mov cx,offset lenVac
        push ds
        push cs
        pop  ds
        call writeF
        pop  ds
        jc protect
        call writeHead
protect1:
        jc protect
        cmp varVakcine,3
        jne noCalcS
        call readCalcSum
        mov al,2
        call setPos
        lea dx,buf
        mov cx,6
        call writeF
noCalcS:
        call setTime
        jc protect
        mov color,10
        lea dx,mesVacOk
        call printEng
        call print0D0A1
        clc
protect:
        pop es di si dx cx ax
        ret
        endp
readCalcSum proc
        push ax cx dx si
        push ds
        mov al,0
        call setPos
        xor dx,dx
        mov ds,baseSeg
        mov cx,0FF00h
        call readF
        xchg cx,ax
        xor si,si
        call calcSum
        pop ds
        mov word ptr buf,'AV'
        mov word ptr buf+2,ax
        mov word ptr buf+4,dx
        pop si dx cx ax
        ret
        endp

vacBegin: ;*************************************
        call begVac1
begVac:

realTit equ $-begVac
vacTitle db 24 dup (36)

mesWho  equ $-begVac

mesTurbo db ' (c) MultiScan. Внимание !!! Эту программу изменил вирус.',13,10
         db 'Определите дальнейшие действия :',13,10
         db ' C - вылечить файл;',13,10
         db ' N - не производить лечение;',13,10
         db ' Q - немедленный выход из программы.',13,10,0

mesWho1  equ $-begVac
         db 'Перезапустить компьютер (Да-Enter / Нет-ESC) ?',13,10,0

offsetEntry equ $-vacBegin

begVac1:
        pop si
        mov es,ds:2Ch
        push cx ds
        push cs
        pop ds
        lea dx,[buf1+18+si]
        mov ah,1Ah
        int 21h
setForXor       equ byte ptr $
        xor ax,ax
        mov di,1
        cld
findName:
        dec di
        scasw
        jne findName
        push es
        pop ds
        lea dx,[di+2]
        mov ax,3D00h
        int 21h
        jc  exitProg
        xchg ax,bx
        mov ah,45h
        int 21h
        jc  noDupHand
        push ax
        mov ah,3Eh
        int 21h
        pop bx
noDupHand:
        push dx ds
        push cs cs
        pop  es ds
        lea dx,[buf1+si]
        mov cx,24
        mov ah,3Fh
        int 21h
close:
        mov ah,3Eh
        int 21h
        mov di,dx
        push si
        rep cmpsb
        pop si
        pop ds dx
keyForRest equ $+1
        jne restoreCOM
exitProg:
        pop ds cx
        mov dx,80h
        mov ah,1Ah
        int 21h
        push ds
        pop es
keyForCom equ $+1
        jmp short $+2
beginCom:
        mov di,100h
        push di
setLoBytes equ $+1
        mov ax,1234h
        stosw
setHiByte  equ $+1
        mov al,12h
        stosb
        xor ax,ax
        mov bx,ax
        mov dx,ax
        mov si,ax
        mov di,ax
        ret

exitForEXE:
        mov ax,es
setSS10 equ $+1
        add ax,1234h
        mov ss,ax
setSP   equ $+1
        mov sp,1234h
        mov ax,es
setCS10 equ $+1
        add ax,1234h
        push ax
setIP   equ $+1
        mov ax,1234h
        push ax
        retf

restoreCOM:
        call shortFile
        jc close1
        mov dx,100h
save:
        mov ah,40h
        int 21h
setTim  equ $+1
        mov cx,1234h
setDat  equ $+1
        mov dx,1234h
        mov ax,5701h
        int 21h

close1:
        pushf
        mov ah,3Eh
        int 21h
        popf
        jc exitProg

        mov ax,offset mesWho1
        call who1
        jc exitProg
        db 0EAh
        dw 0,0FFFFh

restoreEXE:
        call shortFile
        jc close1
        mov cx,24
        mov dx,si
        jmp short save

shortFile:
        mov ax,offset mesWho
        call who1
        jc writeErr
        xor cx,cx
        mov ax,4301h
        int 21h
        jc writeErr
        mov ax,3DC1h
        int 21h
        xchg ax,bx
lenFileLo1 equ word ptr $+1
        mov dx,1234h
lenFileHi1 equ word ptr $+1
        mov cx,1234h
        mov ax,4200h
        push dx
        int 21h
        xor cx,cx
        mov ah,40h
        int 21h
        xor dx,dx
        mov ax,4200h
        int 21h
        pop cx
writeErr:
        push cs
        pop ds
        ret

outMes:
        push si
        add si,ax
nextCout:
        lods byte ptr cs:[si]
setKeyMes equ $+1
        add al,0
        or al,al
        je endMes
        mov ah,0Eh
        int 10h
        jmp nextCout
endMes:
        pop si
        ret

who1:
        call outMes
readKey:
        xor ax,ax
        int 16h
        and al,0DFh
        cmp al,'C'
        je  clCar
        cmp al,'N'
        je  stCar
        cmp al,0Dh
        je  clCar
        cmp ah,1
        je  stCar
        cmp al,'Q'
        jne readKey
        mov ax,4C01h
        int 21h
stCar:
        stc
clCar:
        ret
lenVac          equ $-vacBegin
buf1            equ $-begVac
        .data
firstLet        db 7,'COMMAND',3,'DRW',4,'AIDS',4,'MSAV',4,'TBAV'
                db 4,'F-PR',4,'SCAN',4,'DRSO',4,'WIN.',0
lastLet         db 3,'COM',3,'EXE',0
msName          db 9,'MSCAN.EXE',9,'MSCAN.COM',0
delIt           db 1,10,' снять защиту',0
                db 1,10,' delete vaccine',0
                dw 0EE01h,delIt
mesDelV         db ' освобожден от вакцины ... ',0
                db ' free of vaccine.',0
                dw 0EE01h,mesDelV
mesAnti         db ' был',0
                db ' was',0
                dw 0EE01h,mesAnti
mesVacOk        db ' защищен вакциной ... ',0
                db ' protected with vaccine.',0
                dw 0EE01h,mesVacOk
mesOver         db ' ',12,'эта версия устарела.',0
                db ' ',12,'it version to old.',0
                dw 0EE01h,mesOver
mesWhoO         db ' Обновить',0
                db ' Overwrite',0
                dw 0EE01h,mesWhoO
mesOverOk       db ' Обновлен.',0
                db ' Rewrited.',0
                dw 0EE01h,mesOverOk
addvak          dw 20h,0E0EDh,0EF5Ah
stdvak          dw 20h,0E2EDh,0EF58h
end
