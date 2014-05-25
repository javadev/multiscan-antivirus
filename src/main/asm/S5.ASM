
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модуль подключает MSB файлы и проверяет время/дату создания файлов.
;

public  setPadeg,checkSt,formDI_CX,formDI_CX1,print0D0A1,checkTD,outTSR
public  mesBadD,mesBadT,mesSetD,mesOkD,mesOkT,setFont,readMsb
public  decod,mesErrMsb,mesLoadMs,printPath,insertMsb,printPathF,moveName
public  printPathFI,printPSp,mesBadVer,mesWasLoad,mesNoMemMSB,mesNoGr100MSB
extrn   printEng:near,writeDec:near,delString:near,who:near,print0D:near
extrn   print0D0A:near,print:near,closeFile:near,changeOpen:near,setTime:near
extrn   padeg:byte,longFlo:word,longFhi:word
extrn   path:byte,color:byte,fname:byte,mesSt:near,mesBody2:near
extrn   mesBody3:near,varMesOk:byte,checkShow:byte,writeChar:near
extrn   time:word,date:word,varEng:byte,beep1:near,beep2:near
extrn   dateCount:word,curDatCount:word,font8:near,font14:near,font16:near
extrn   varFN:byte,openFnt:near,baseSeg:word,readF:near,openMsb:near
extrn   iniSigOff:word,iniSigSeg:word,seekF:near,varKeySt:byte
extrn   listCall:near,listVar:near,delToEnd:near,tabMsb:word,countNam:byte
extrn   fileSigCount:word,virsigCount:word,msbPosLo:word,msbPosHi:word
extrn   repName:near,erase:byte,closeF:near
        .model small
        .code
insertMsb proc
        push ax bx cx si di ds es
        mov ds,baseSeg
        mov ax,[si+2]
        mov cl,4
        shr ax,cl
        add ax,12h
        call scanMsb
        jc noMem
        mov es,ax
        mov cx,[si+2]
        mov si,10h
        mov di,110h
        push si
        rep movsb
        pop si
        mov di,offset iniSigOff
        call setupInDi
        mov ss:iniSigSeg,es
        call fillProc
        clc
noMem:
        pop es ds di si cx bx ax
        ret
        endp
setupInDi proc
        lodsw
        xchg ax,ss:[di]
        mov di,[si]
        stosw
        mov ax,ss:iniSigSeg
        stosw
        lodsw
        ret
        endp
scanMsb proc
        push bx si
        xchg bx,ax
        lea si,tabMsb
        lods word ptr ss:[si]
        xchg cx,ax
        jcxz allocNow
nextMsbS:
        lods word ptr ss:[si]
        push cx si di es
        mov es,ax
        mov si,10h
        mov di,110h
        mov cx,20h
        rep cmpsb
        pop es di si cx
        loopne nextMsbS
        jne allocNow
        lea dx,mesWasLoad
printMes1:
        push ss
        pop  ds
	call print0D0A
	call printPathMes
        stc
        jmp short allErr
allocNow:
        mov ah,48h
        int 21h
        lea dx,mesNoMemMSB
        jc printMes1
        cmp si,offset tabMsb+100
        cmc
        lea dx,mesNoGr100MSB
        jc printMes1
        inc ss:tabMsb
        mov ss:[si],ax
allErr:
        pop si bx
        ret
        endp
printPathMes proc
	push dx
	call print0D
        mov color,10
	lea dx,path
	call printPath
	pop dx
        call printEng
	ret
	endp
fillProc proc
        push ax cx si di ds
        lea ax,listCall
        xor di,di
        mov cx,20
fillCall:
        push ax
        mov al,9Ah
        stosb
        pop ax
        stosw
        push ax
        mov ax,cs
        stosw
        mov al,0C3h
        stosb
        pop ax
        add ax,4
        loop fillCall
        mov di,80h
        push ss
        pop  ds
        lea si,listVar
        mov cx,64
        rep movsw
        pop ds di si cx ax
        ret
        endp
getCount proc
        push ax si ds
        mov ds,baseSeg
        sub word ptr ds:10h,100h
        mov si,20h
        xor dx,dx
find0:
        lodsb
        cmp si,ds:10h
        ja endCount
        or al,al
        jne find0
        inc dx
        jmp find0
endCount:
        pop ds si ax
        ret
        endp
readMsb proc
        push ax bx cx dx
        xor ax,ax
nextOpen:
        mov msbPosHi,0
        mov msbPosLo,0
        call openMsb
        jc notFoundMs
        xchg bx,ax
readNextM:
        call readMs
        jc closeMs

        call installMs
        jc readNextM

        call insertMsb
        jc closeMs	;readNextM

        inc fileSigCount
        lea dx,mesLoadMs
        call printPathMes
        call getCount
        add virsigCount,dx
	mov dx,virsigCount
        call writeDec
        jmp readNextM

closeMS:
        call print0D0A
        call closeFile
        mov al,1
        jmp nextOpen
notFoundMs:
        pop dx cx bx ax
        ret
        endp
readMs proc
        push ax dx ds
        mov cx,msbPosHi
        mov dx,msbPosLo
        call seekF
        mov ds,baseSeg
        xor dx,dx
        mov cx,60000
        call readF
        jc readErr
        xchg cx,ax
        cmp cx,20
readErr:
        pop ds dx ax
        ret
        endp
installMs proc
        push cx dx si ds es
        push ss
        pop  es
        mov ds,baseSeg
        xor si,si
        call scanMark
        pushf
        add ss:msbPosLo,cx
        adc ss:msbPosHi,0
        popf
        jne endDecUBad
        call convertC

        call decod
        jc writeMes
        cmp 2 ptr ds:6,'21'
        je endDecU
        push ss
        pop  ds
        lea dx,mesBadVer
        jmp short printMesErr
writeMes:
endDecUBad:
        lea dx,mesErrMsb
printMesErr:
        push ss
        pop  ds
        call beep1
        call printPathMes
;endDecUBad:
        stc
endDecU:
        pop es ds si dx cx
        ret
        endp
scanMark proc
        push ax si
findB:
        lodsb
        cmp al,'B'
        loopne findB
        jne badDecod    ; bad
        push cx si
        dec si
        lea di,strBeg1
        mov cx,offset lenBegS1
        rep cmpsb
        pop si cx
        jne findB
        lea dx,[si+5]
findE:
        lodsb
        cmp al,'E'
        loopne findE
        jne badDecod    ; bad
        push cx si
        dec si
        lea di,strEnd1
        mov cx,offset lenEndS1
        rep cmpsb
        pop si cx
        jne findE
badDecod:
        mov cx,si
        pop si ax
        ret
        endp
convertC proc
        push ax bx cx dx si di
        sub cx,dx
        mov si,dx
        mov dx,cx
        xor di,di
        mov bx,7
        cmp word ptr [si+2],'lw'
        je decMain
        mov bx,3
decMain:
        mov al,[si]
        cmp al,' '
        ja decIt
        inc si
        loop decMain
        jmp short endDec
decIt:
        push cx
        mov ah,[si+bx]   ;si+3
        sub ah,33
        cmp bl,7
        je shKeyOne
        shl ah,1
shKeyOne:
        shl ah,1
        mov cx,bx        ;3
makeCell:
        lodsb
        sub al,33
        cmp bl,7
        je shiftOne
        shl al,1
shiftOne:
        shl al,1
        jc badDecod0
        cmp bl,7
        je addOne
        shl ah,1
        rcr al,1
addOne:
        shl ah,1
        rcr al,1
        mov [di],al
        inc di
        loop makeCell
        inc si
        pop cx
        cmp cx,bx        ;3
        jbe endDec
        sub cx,bx        ;3
        jmp decMain
badDecod0:
        pop cx
endDec:
        pop di si dx cx bx ax
        ret
        endp
decod proc
        push ax cx dx si
        xor si,si
        mov ax,[si]
        cmp ax,'KV'
        jne goBeep
        mov ax,[si+2]
        xchg cx,ax
        mov ax,[si+4]
        mov dx,ax
        mov si,10h
        xor ah,ah
decAll:
        xor ah,[si]
        xor [si],al
        inc si
        loop decAll
        cmp dh,ah
        je noBeep
goBeep:
        stc
noBeep:
        pop si dx cx ax
        ret
        endp
readFont proc
        push ax bx cx dx es
        call openFnt
        jc noReadFnt
        xchg ax,bx
        mov es,baseSeg
        xor dx,dx
        push ds
        push es
        pop ds
        mov cx,10000
        call readF
        pop ds
        call closeF
noReadFnt:
        pop es dx cx bx ax
noReadFn:
        ret
        endp
setFont proc
        call readFont
        jnc setFNow
        cmp varFN,0
        je noSetFn
setFNow:
        push ax bx cx dx bp es
        mov ah,12h
        mov bx,0FF10h
        int 10h
        cmp bx,0FF10h
        je noEga
        mov ax,1130h
        mov bx,200h
        int 10h
        lea bp,font14
        xor bl,bl
        xchg bh,cl
        cmp bh,14
        jb set8
        ja set16
setFnt:
        mov es,baseSeg
        cmp word ptr es:2600h,'NF'
        jne oldSetup
        mov bp,2048
        mov cx,100h
        xor dx,dx
        cmp bh,14
        jb setBp8
        ja setBp16
        jmp short setNow
setBp8:
        xor bp,bp
        jmp short setNow
setBp16:
        mov bp,2048+3584
        jmp short setNow
oldSetup:
        mov ax,fontSeg
        mov es,ax
        mov cx,80h
        mov dx,80h
setNow:
        mov ax,1100h
        int 10h
noEga:
        pop es bp dx cx bx ax
noSetFn:
        ret
        endp
set8:
        lea bp,font8
        jmp setFnt
set16:
        lea bp,font16
        jmp setFnt
setPadeg proc
        push ax bx dx
        mov ax,dx
        mov bx,10
        xor dx,dx
        div bx
        cmp dl,2
        je gangePad
        cmp dl,3
        je gangePad
        cmp dl,4
        je gangePad
gangePad1:
        mov word ptr padeg,' .'
exitPadeg:
        pop dx bx ax
        ret
        endp
gangePad:
        xor dx,dx
        div bx
        cmp dl,1
        je  gangePad1
        mov word ptr padeg,'.а'
        jmp short exitPadeg
checkSt proc
        cmp varKeySt,1
        je noCheckSt
        push ax bx dx di es
        mov ax,1220h
        int 2Fh                     ; DOS Internal services
        mov ax,1216h
        mov bl,es:[di]
        int 2Fh                     ; DOS Internal services
        cmc
        jnc steOk
        mov ax,es:[di+11h]          ; sizeLo (real)
        mov bx,es:[di+13h]          ; sizeHi (real)
        cmp ax,24
        ja checkIt
        or bx,bx
        je steOk
checkIt:
        sub ax,longFlo
        je  steOk
        call checkRP
        je  steOk
        call outTSR
steOk:
        pop es di dx bx ax
noCheckSt:
        ret
        endp
checkRP proc
        push ax cx si di es
        push ds
        pop  es
        lea si,repName
        call formDI_CX1
        lea si,fname
nextRP:
        lodsb
        or al,al
        je endCheckRP
        or al,20h
        scasb
        je nextRP
endCheckRP:
        pop es di si cx ax
        ret
        endp
outTSR proc
        push ax dx
        call printPathF
        lea dx,mesSt
        call printEng
        xchg dx,ax
        call writeDec
        call setPadeg
        lea dx,mesBody2
        call printEng
        lea dx,mesBody3
        call beep2
        call who
        pushf
        call delString
        popf
        pop dx ax
        ret
        endp
moveName proc
        push ax cx dx si es
        push ss
        pop  es
        call formDI_CX
        lea si,fname
        mov cx,7
        rep movsw
        pop es si dx cx ax
        ret
        endp
printPathFI proc
        mov countNam,0
        endp
printPathF proc
        cmp erase,0
        je no0D0A
        call print0D0A
no0D0A:
        push cx dx
        call print0D
        mov color,3
        xor ch,ch
        mov cl,countNam
        jcxz noOutStr
nextPrint:
        mov dl,'-'
        call writeChar
        mov dl,'>'
        call writeChar
        loop nextPrint
noOutStr:
        inc countNam
        lea dx,path
        call printPath
        call printPSp
        pop dx cx
        ret
        endp
printPSp proc
        push cx dx si di
        mov si,dx
        call formDI_CX1
        sub cx,13
        jae noOutSp
        neg cx
        mov dl,' '
nextSP:
        call writeChar
        loop nextSP
noOutSp:
        pop di si dx cx
        ret
        endp
printPath proc
        push ax cx dx si di es
        mov si,dx
        mov di,si
        push ds
        pop  es
        mov cx,-1
        xor ax,ax
        repne scasb
        not cx
        cmp cx,30h
        jbe nextSym
        push cx
        mov dl,[si]
        call writeChar
        mov dl,[si+1]
        call writeChar
        mov dl,'.'
        call writeChar
        call writeChar
        call writeChar
        pop cx
        sub cx,30h
        add si,cx
findSla:
        lodsb
        cmp al,'\'
        je slFound
        cmp al,'/'
        je slFound
        or al,al
        jne findSla
slFound:
        dec si
nextSym:
        lodsb
        or al,al
        je endWrite
        mov dl,al
        call writeChar
        jmp nextSym
endWrite:
        call delToEnd
        pop es di si dx cx ax
        ret
        endp
formDI_CX proc
        lea si,path
        endp
formDI_CX1 proc
        push ax
        mov di,si
        xor cx,cx
cicFind1:
        lodsb
        cmp al,':'
        je storePtr
        cmp al,'\'
        jne noStorePtr
storePtr:
        cmp 1 ptr [si],0
        je noClearCX
        xor cx,cx
noClearCX:
        mov di,si
        jmp short cicFind1
noStorePtr:
        inc cx
        or al,al
        jne cicFind1
        pop ax
        ret
        endp
print0D0A1 proc
        cmp ss:varMesOk,1
        je  exitPrint
        call print0D0A
exitPrint:
        ret
        endp
checkCell proc
        push ax
        shr ax,cl
        and al,bh
        cmp al,bl
        pop ax
        ret
        endp
checkDate proc
        push ax bx cx
        mov ax,date
        mov cl,9
        mov bx,7F00h+99
        call checkCell
        ja badDate
        mov cl,5
        mov bx,0F0Ch
        call checkCell
        ja badDate
        xor cl,cl
        mov bx,1F1Fh
        call checkCell
badDate:
        pop cx bx ax
        ret
        endp
checkTime proc
        push ax bx cx
        mov ax,time
        mov cl,11
        mov bx,1F17h
        call checkCell
        ja badTime
        mov cl,5
        mov bx,3F00h+59
        call checkCell
        ja badTime
        xor cl,cl
        mov bx,1F00h+29
        call checkCell
badTime:
        pop cx bx ax
        ret
        endp
outW proc
        aam
        or ax,3030h
        mov dl,ah
        call writeChar
        mov dl,al
        call writeChar
        mov dl,dh
        call writeChar
        ret
        endp
outMes proc
        mov cl,3
        push ax
        shr ax,cl
        and ax,3Ch
        cmp ax,12*4
        jbe dataOk
        xor ax,ax
dataOk:
        add dx,ax
        call print
        mov dl,' '
        call writeChar
        pop ax
        ret
        endp
outDate proc
        push ax cx dx
        call printEng
        mov ax,date
        mov dh,' '
        cmp varEng,0
        je outRd
        mov cl,9
        push ax
        shr ax,cl
        add ax,1980
        xchg ax,dx
        call writeDec
        xchg ax,dx
        mov dl,dh
        call writeChar
        pop ax
        lea dx,motEng
        call outMes
        and ax,1Fh
        mov dh,' '
        call outW
endOdate:
        mov dl,' '
        call writeChar
outTime:
        mov ax,time
        mov dh,':'
        mov cl,11
        push ax
        shr ax,cl
        call outW
        pop ax
        mov cl,5
        push ax
        shr ax,cl
        and ax,3Fh
        call outW
        pop ax
        shl ax,1
        and ax,3Fh
        mov dh,' '
        call outW
        pop dx cx ax
        ret
        endp
outRd proc
        push ax
        and ax,1Fh
        call outW
        pop ax
        lea dx,motRus
        call outMes
        mov cl,9
        shr ax,cl
        add ax,1980
        xchg ax,dx
        call writeDec
        jmp endOdate
        endp
checkTD proc
        push dx
        call checkDate
        jbe dataNorm
        call printPathF
        lea dx,mesBadD
        call outDate
        call beep1
        inc dateCount   ;st
        lea dx,mesSetD
        call who
        jc dataNorm
        call changeOpen
        jc timeNorm
        mov date,15 shl 9 + 1 shl 5 + 1
        call setTime
        jc timeNorm
        inc curDatCount ;st
        lea dx,mesOkD
        call printEng
dataNorm:
        call checkTime
        jbe timeNorm0
        call printPathF
        lea dx,mesBadT
        call outDate
        call beep1
        inc dateCount   ;st
        lea dx,mesSetD
        call who
        jc timeNorm0
        call changeOpen
        jc timeNorm
        mov time,12 shl 11
        call setTime
        jc timeNorm
        inc curDatCount ;st
        lea dx,mesOkT
        call printEng
timeNorm0:
        clc
timeNorm:
        pop dx
        ret
        endp
fontSeg segment byte public
fontSeg ends
        .data
mesBadD         db 1,12,' - странная дата создания ',0
                db 1,12,' - strange creation date ',0
                dw 0EE01h,mesBadD
mesBadT         db 1,12,' - странное время создания ',0
                db 1,12,' - strange creation time ',0
                dw 0EE01h,mesBadT
mesSetD         db 1,12,'Исправить',0
                db 1,12,'Change',0
                dw 0EE01h,mesSetD
mesOkD          db 1,11,' ИСПРАВЛЕНА на ',1,10,'1.1.1995',10,0
                db 1,11,' CHANGED - ',1,10,'1/1/1995',10,0
                dw 0EE01h,mesOkD
mesOkT          db 1,11,' ИСПРАВЛЕНО на'
newT            db 1,10,' 12:00:00',10,0
                db 1,11,' CHANGED -'
                dw 0FF01h,newT
                db 0
                dw 0EE01h,mesOkT
motEng          db '???',0,'Jan',0,'Feb',0,'Mar',0,'Apr',0,'May',0,'Jun',0
                db 'Jul',0,'Aug',0,'Sep',0,'Okt',0,'Nov',0,'Dec',0
motRus          db '???',0,'янв',0,'фев',0,'мар',0,'апр',0,'май',0,'июн',0
                db 'июл',0,'авг',0,'сен',0,'окт',0,'ноя',0,'дек',0
mesWasLoad      db ' - антивирусная база была загружена !',10,0
                db ' - antivirus was included !',10,0
                dw 0EE01h,mesWasLoad
mesErrMsb       db ' - антивирусная база повреждена !',10,0
                db ' - antivirus base is corrupted !',10,0
                dw 0EE01h,mesErrMsb
mesLoadMs       db ' - загружено масок вирусов : ',0
                db ' - load virus mask is : ',0
                dw 0EE01h,mesLoadMs
mesBadVer       db ' - файл был создан более ранней версией !',10,0
                db ' - file was created is old version !',10,0
                dw 0EE01h,mesBadVer
mesNoMemMSB     db ' - недостаточно памяти для загрузки .MSB файла !',10,0
                db ' - Insufficient memory to load .MSB file !',10,0
                dw 0EE01h,mesNoMemMSB
mesNoGr100MSB   db ' - невозможна загрузка более 100 .MSB файлов !',10,0
                db ' - can''t load above of 100 .MSB files !',10,0
                dw 0EE01h,mesNoGr100MSB
strBeg1         db 'BEGIN:'
lenBegS1        equ $-strBeg1
strEnd1         db 'END.'
lenEndS1        equ $-strEnd1
end
