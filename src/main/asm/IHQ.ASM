
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Это кодо-оптимизатор и кодо-анализатор с самого начала, но тут еще есть
; куча кода для создания .SIG файлов.

public  runIt1,scanInt,complBlock,scanUpB,mesPosInf,checkSkipC,writeDateTime
public  outCr,check1C,mesCr,mesPboot,fillEvent,eventReg,clearMask,writeRCE
public  mesWasInclud,newSig,scanBlock,scanCode,writeNullS1,writeNewMem
public  fillWord,mesV00,mesV01,mesV02,mesV03,mesV04,mesV05,mesV06,mesV07
public  mesV08,mesV09,mesV10,mesV11,mesV12,mesV13,mesV14,mesV15,mesV16
public  mesV17,mesV18,mesV19,mesV20,mesV21,mesV22,mesV23,mesV24,mesV25
public  mesV26,mesV27,mesV28,mesV29,mesV30,mesV31,mesFinal,mesMemory
public  mesCom,mesAnd,mesExe,mesFiles,clearSign,createTable,writeNewBoot
extrn   regAX:word,regCX:word,regDX:word,regBX:word
extrn   regSP:word,regBP:word,regSI:word,regDI:word
extrn   regIP:word,regCS:word,regFlags:word
extrn   regES:word,regSS:word,offInFile1:word
extrn   saveSS:word,saveSP:word,falseSeg:word,pushReg:near
extrn   varOpt:byte,varMS:byte,countErr:byte,disWrite:word,segWrite:word
extrn   segRead:word,globalLo:word,globalHi:word,iniSP:word
extrn   posLo:word,posHi:word,hand:word,baseSeg:word,segLng:word,openF:near
extrn   printEng:near,writeChar:near,writeDec:near,print0D0A1:near,color:byte
extrn   readF:near,lenCr:word,varEvr:byte,closeF:near,checkEng:near
extrn   reloIP:word,cureStd:near,countTab:word,offOpt:word
extrn   tabBlock:word,off3:word,seg3:word,outEnd:near,checkRange:byte
extrn   setOpt1:byte,offFS:word,offMS:word,varMemF:byte
extrn   countBlock:byte,countInBl:word,maskHa:byte,doRead:near,optim:byte
extrn   cryptCount:word,beep:near,infNewCount:word,virFoundF:byte
extrn   erase:byte,varView:byte,virusSeg:word,newName:byte,varFS:byte
extrn   varViewOn:byte,varAuto:byte,tabSkip:word,buf:byte,getFileName:near
extrn   varNV:byte,path:byte,writeF:near,setPos:near,eventTab:byte
extrn   fillDate:near,fillTime:near,print0D0A:near,formDI_CX:near
extrn   typeFile:byte,offSigForS:word,printPath:near,tabSkipO:byte
extrn   varCT:byte,iniSegDS:near,check_1:near,getLenVir:near,getComWord:near
extrn   getExeWord:near,iniSigOff:word,getBootWord:near,varBS:byte,varNP:byte
        .model small
        .code
check1C proc
        push es
        mov es,ss:falseSeg
        xchg ax,es:1Ch*4+2
        mov bx,ss:baseSeg
        cmp ax,bx
        jne no1C
        mov dx,es:1Ch*4
it8:
        mov ax,ss:regFlags
        call pushReg
        mov ax,bx
        call pushReg
        mov ax,si
        call pushReg
        mov si,dx
        xor ax,ax
        mov ss:varOpt,al
        pop es
        ret
        endp
no1C:
        mov dx,es:8*4
        xchg ax,es:8*4+2
        cmp ax,bx
        je it8
        pop es
        ret
scanBlock proc
        push cx
        lea si,tabBlock
        lodsw
        xchg cx,ax
        or si,si
        jcxz found
scanBlo:
        lodsw
        cmp dx,ax
        lodsw
        jb nextB2
        cmp dx,ax
        ja nextB2
        cmp ax,ax
        jmp short found
nextB2:
        loop scanBlo
found:
        pop cx
        ret
        endp
scanUpB proc
        push bx dx si
        xchg dx,ax              ; dx=ax
        mov bx,8000             ;512
        lea si,tabBlock
        lodsw
        xchg cx,ax      ;fd     ; в cx - кол-во эл-ов
        jcxz endScUp
nextUp:
        lodsw
        cmp ax,dx       ; сpавнить нижнюю гpаницу с dx
        jb nextUpb      ; если блок выше, то далее
        sub ax,dx
        cmp ax,bx       ; сpавнить длину с bx
        ja nextUpb      ; если больше, то далее
        xchg ax,bx      ; установить новую длину
nextUpb:
        lodsw
        loop nextUp
endScUp:
        mov cx,bx
        xchg dx,ax
        pop si dx bx
        ret
        endp
complBlock proc
        push ax bx cx dx si di ds
        push ss
        pop  ds
        mov bx,hand
        or bx,bx
        je noRead1

        call scanBlock          ; найти блок, котоpый будет досчитываться
        jnz makeBlockR          ; если блок не найден, то считать cx байт
        call scanUpB
        or cx,cx
        jne readNow
makeBlockR:
        mov ax,globalHi
        sub ax,8000
        jnc noSetLoAx
        mov ax,globalLo
noSetLoAx:
        cmp dx,ax
        jb noChangeDX
        xchg dx,ax
noChangeDX:
        call scanBlock          ; найти блок, котоpый будет досчитываться
        je readNow
        mov ax,dx
        cmp ax,globalLo
        jb  noRead
        cmp ax,globalHi
noRead1:
        jae noRead
        mov [si  ],ax
        inc ax
        mov [si+2],ax
        dec ax
        lea si,[si+4]
        cmp si,offset off3
        ja noRead
        inc tabBlock
readNow:
        xchg dx,ax
        mov lenCr,ax
        add ax,8000
        jc  setAxHi
        cmp ax,globalHi
        jc setDI
setAxHi:
        mov ax,globalHi
setDI:
        xchg di,ax
nextCell:       ; dx,si,di
        call scanBlock          ; найти блок, котоpый будет досчитываться
        clc
        jne noRead
        xchg dx,ax
        call scanUpBDI
        jz noReadB
        call readDXCX
        jnc noReadB
        mov countErr,99
        jmp short noRead
noReadB:
        pushf
        add dx,cx
        inc dx
        popf
        add [si-2],cx
        cmp dx,di
        jb nextCell
        dec dx
        sub lenCr,dx
        neg lenCr
        clc
noRead:
        pop ds di si dx cx bx ax
        ret
        endp
scanUpBDI proc
        push ax si
        lea si,tabBlock
        lodsw
        push bx
        mov bx,di
        xchg cx,ax
nextUpDI:
        lodsw
        cmp ax,dx
        je setNullR
        jb nextBlDI
        cmp ax,bx
        jae nextBlDI
setNullR:
        xchg bx,ax
nextBlDI:
        lodsw
        loop nextUpDI
        mov cx,bx
        pop bx
        sub cx,dx
        pop si ax
        ret
        endp
readDXCX proc
        call seekDX
        push ax ds
        mov ds,baseSeg
        call readF
        pop ds ax
        ret
        endp
seekDX proc
        push ax bx cx dx
        xor cx,cx
        add dx,posLo
        adc cx,posHi
        mov ax,4200h
        int 21h
        pop dx cx bx ax
        ret
        endp
        ; - нет чтения
        ; - нет записи
        ; - чтение из baseSeg
        ; - запись в  baseSeg
        ; - чтение из virusSeg
        ; - запись в virusSeg
        ; - чтение из любого
        ; чтение -> 00 - нет чтения
        ;           01 - чтение из baseSeg
        ;           10 - чтение из virusSeg
        ;           11 - чтение из любого ???
        ; запись -> 00 - нет записи
        ;           01 - запись в baseSeg
        ;           10 - запись в virusSeg
        ;                ||--- запись
        ; обpаботчики -> 0000 (пpовеpить диапазон SP, если подходит,
        ;                      то досчитывание с offOpt)
        ;             -> 0001 (пpопустить цикл)
        ;             -> 0010 (пpопустить цикл)
        ;             -> 0011 (пpопустить цикл)

        ;             -> 0100 (досчитывание с disWrite и оптимизация)
        ;             -> 0101 (досчитывание с disWrite и оптимизация)
        ;             -> 0110 (оптимизация без досчитывания и без пpовеpки)
        ;             -> 0111 (досчитывание с disWrite и оптимизация) +

        ;             -> 1000 (пропустить цикл)                 +
        ;             -> 1001 (оптимизация без досчитывания)    +
        ;             -> 1010 (пропустить цикл)                 +
        ;             -> 1011 (пропустить цикл)                 +
runIt1 proc
        push ds ss
        pop ds
        xor bx,bx
        mov ax,segRead
        or ax,ax
        je endReadS
        inc bx
        cmp ax,baseSeg
        je endReadS
        inc bx
        cmp ax,virusSeg
        je endReadS
        inc bx
endReadS:
        mov ax,segWrite
        or ax,ax
        je endWriteS
        add bx,4
        cmp ax,baseSeg
        ja noWriteS
        cmp ax,virusSeg
        ja endWriteS
noWriteS:
        add bx,4
        cmp ax,virusSeg
        je endWriteS
        and bx,3
endWriteS:
        shl bx,1
        call ds:[tableRun+bx]
endRunIt:
        pop ds
        ret
        endp
checkSkipC proc
        push cx si
        lea si,tabSkip
        lods word ptr ss:[si]
        xchg cx,ax
        or si,si
        jcxz endCheckS
nextSkip:
        lods word ptr ss:[si]
        cmp ax,bx
        je endCheckS
        loop nextSkip
endCheckS:
        pop si cx
        jne noSkipCyc
        mov si,bx       ; пропустить цикл
noSkipCyc:
        ret
        endp

skipCyc:
        lea si,offOpt
noskipIT:
        lodsw
        cmp ax,-1
        je noskipIT

        push cx
        lea si,tabSkip
        mov cx,[si]
        jcxz noCheckTSk
nextTSk:
        inc si
        inc si
        cmp ax,[si]
        loopne nextTSk
noCheckTSk:
        pop cx

        je noSaveC
        cmp si,offset tabSkip+42
        jae noSaveC
        inc tabSkip
        mov [si+2],ax
noSaveC:
        mov si,ax
        mov varOpt,0
noMem:
        ret

code0000 proc
        call check1C
        je noMem
        mov ax,regSP    ; запись через SP ;*
        cmp ax,iniSP
        je skipCyc
        cmp ax,globalHi
        ja skipCyc
        cmp ax,globalLo
        jb skipCyc
        mov dx,offOpt
        inc dx
        jmp short checkOW1
optOnly:
        mov ax,regSP
        cmp ax,iniSP
        jne skipCyc
        mov reloIP,1
        jmp short setOpt
read&opt:       ; 4 5 6 7
        mov ax,iniSP
        sub ax,regSP
        cmp ax,1
        ja noMem
        mov dx,disWrite
        cmp dx,globalHi         ;+
        ja noMem                ;+
        cmp dx,globalLO
        jb noMem
checkOW1:
        mov reloIP,dx
        call complBlock
setOpt:
        xor ax,ax
        mov varOpt,al
        mov disWrite,ax
        mov cs:setOpt1,5Ah
        mov al,0C3h
        mov          cs:checkRange,al
        mov byte ptr cs:doRead,al
        mov          cs:optim,al
        ret
        endp
outCr proc
        cmp virFoundF,0
        jne noCr
        cmp maskHa,3
        jne noBootV
        lea dx,mesPboot
        call printEng
        inc infNewCount
        mov erase,2
noBootV:
        cmp varEvr,0
        je noCr
        cmp countErr,1
        je noCr
        push ax dx
        mov ax,lenCr
        cmp ax,8000
        je noCrypt
        cmp ax,10000
        ja noCrypt
        cmp ax,50
        jb noCrypt
        inc cryptCount
        lea dx,mesCr
        call printEng
        mov dl,'.'
        call writeChar
        xchg ax,dx
        call writeDec
        mov dl,'.'
        call writeChar
        call print0D0A1
noCrypt:
        pop dx ax
noCr:
        call outEnd
        ret
        endp
skipInt proc
;       mov ss:varOpt,0
bigInt:
        mov si,dx
        jmp clearF
        endp
scanInt proc
        mov dx,si
        cmp al,2Fh
        jbe execInt
f6_01_:
        mov si,dx
        jmp f6_01
execInt:
        xor ah,ah
        xchg si,ax
        add si,si
        mov si,ss:[si+tabInt]
        lods word ptr ss:[si]
        or ax,ax
        je f6_01_;bigInt               ;
        cmp ax,1
        je  itExec
        cmp al,byte ptr ss:regAX+1
        jae okExec
        mov si,dx
fun18:
fun61:
        mov byte ptr ss:regAX,0
        jmp short scanCode
int2526:
        sub ss:regSP,2
        ret
okExec:
        mov al,byte ptr ss:regAX+1
        shl ax,1
        add si,ax
itExec:
        lods word ptr ss:[si]
        or ax,ax
;        je skipInt
        je bigInt
        mov si,dx
        push ax
        mov ax,ss:regAX
;fun02:
fun01:
f0_0E:
        ret
        endp
fun4F proc
        or ss:regFlags,1
clearOpt:
        mov ss:varOpt,0
        ret
        endp
fun62:
        mov ax,ss:regES
        mov ss:regBx,ax
        jmp short scanCode
fun25:
fun35:
        push ax
        xor ah,ah
        mov di,ax
        shl di,1
        shl di,1
        mov es,ss:falseSeg
        pop ax
        cmp ah,25h
        je setVect
        mov ax,es:[di]
        mov ss:regBX,ax
        scasw
        mov ax,es:[di]
        mov ss:regES,ax
        ret
setVect:
        push ds es
        push ss
        pop  ds
        mov es,baseSeg
        mov ax,regDX    ; tabBlock+4
        call doRead
        mov ax,regDX
        pop es ds
        stosw
        mov ax,cx
        stosw
        ret
fun30:
        mov ss:regAX,5
scanCode:
        push ds
        push ss
        pop ds
        cmp varView,0
        jne noScan
        mov reloIP,si
        call cureStd
noScan:
        pop ds
        ret
fun00:
fun4C:
fun31:
exitProg:
        call scanCode
        mov ss:countErr,1
        ret
fun4B:
        cmp al,3
        jbe exitProg
        ret
f6_00:
        mov ss:regAX,0Dh
clearF:
        mov ss:varOpt,0
f6_01:
        push ss:regFlags
        popf
        cmp ax,ax
        pushf
        pop ss:regFlags
        ret
f6_02:
        mov ah,2
        int 16h
        mov ss:regAX,ax
        ret
f0_0F:
        mov ss:regAX,3
        mov ss:regBX,0
        jmp clearF
fun3F:
fun40:
        mov ax,ss:regCX
        or ax,ax
        jns noCrearR
        xor ax,ax
noCrearR:
        mov ss:regAX,ax
        jmp clearF
fun48:
        mov ss:regAx,-3
        jmp clearF
fillEvent:
        push ax bx cx dx di es
        push ss
        pop  es
        mov ax,ss:regAX
        xchg ah,al
        lea di,tableEvent
        mov cx,offset lenTabEvent
        cld
nextEvent:
        scasb
        je fillItE
        scasw
        loop nextEvent
exitFE:
        pop es di dx cx bx ax
        ret
fillItE:
        xchg ah,al
        mov bx,ss:regBX
        mov cx,ss:regCX
        mov dx,ss:regDX
        call ss:[di]
        or al,al
        je exitFE
        call eventReg
        jmp exitFE

openReg:
        mov ss:regAx,'VA'
        mov al,1        ;ok
        ret

readReg:
;       cmp bx,'VA'
;       jne clearEvent
        mov al,27
        or cx,cx
        js exitReadR
        mov al,3        ;ok
        cmp cx,28
        ja exitReadR
        cmp cx,24
        jb exitReadR
        mov al,2        ;ok
exitReadR:
        ret

writeReg:
;       cmp bx,'VA'
;       jne clearEvent
        mov al,4        ;ok
        cmp cx,28
        ja  checkCx100
        cmp cx,24
        jae exitWriteR
        mov al,5        ;ok
        jmp short exitWriteR
checkCx100:
        cmp cx,10000
        ja clearEvent
        mov al,6        ;ok
        cmp word ptr ss:lenVir,0
        jne exitWriteR
        cmp cx,80
        jb exitWriteR
        mov ss:lenVir,cx
exitWriteR:
        cmp bx,'VA'
        jne noCallWr
        call eventReg
        mov al,30
noCallWr:
        ret

closeReg:
        mov al,7        ;ok
        cmp bx,'VA'
        jne noCallCl
        call eventReg
        mov al,31
noCallCl:
        ret

setVectReg:
        cmp al,21h
        je exitE8
        cmp al,13h
        je exitE9
        cmp al,24h
        je exitE29
clearEvent:
        mov al,0
        ret

exitE8:
        mov al,8        ;ok
        ret

exitE9:
        mov al,9        ;ok
        ret

exitE29:
        mov al,29
        ret

getVectReg:
        cmp al,21h
        je exitE10
        cmp al,13h
        jne clearEvent
        mov al,11       ;ok
        ret

exitE10:
        mov al,10       ;ok
        ret

int2Freg:
        cmp al,20h
        je exitE12
        cmp al,16h
        jne clearEvent
        mov al,13       ;ok
        ret

exitE12:
        mov al,12       ;ok
        ret

setTimeF:
        cmp al,1
        je setE14
        or al,al
        jne clearEvent
        mov al,15       ; getTime       ;ok
        ret
setE14:
        mov al,14       ; setTime       ;ok
        ret

setAttrib:
        cmp al,1
        je setE16
        or al,al
        jne clearEvent
        mov al,17       ; getAttrib     ;ok
        ret
setE16:
        mov al,16       ; setAttrib     ;ok
        ret

setLseek:
        or cx,cx
        jne clearEvent
        cmp al,2
        je setE19
        cmp al,0
        jne clearEvent
        mov al,18       ;ok begin
        ret
setE19:
        mov al,19       ;ok end
        ret

allocMem:
        mov al,28
        ret

checkAxN:
        push ds es
        mov es,baseSeg
        call doRead
        push es
        pop  ds
        pop  es
        mov si,ax
        call convertNorm
        pop  ds
        ret

findFReg:
;        cmp cx,3Fh
;        ja clearEvent
        push bp si ds
        push ss
        pop  ds
        mov bp,sp
        mov ax,[bp+14]
        sub ax,baseSeg
        mov cl,4
        shl ax,cl
        add ax,regDX
        call checkAxN
        jnc setExe1
        mov ax,regDX
        call checkAxN
        jc noSetExe1
setExe1:
        lea si,extALL
        call cmpEXT
        mov al,20
        je noSetExe
        lea si,extCOM
        call cmpEXT
        mov al,21       ; findFirst COM
        je noSetExe
        lea si,extEXE
        call cmpEXT
        mov al,22       ; findFirst EXE
        je noSetExe
noSetExe1:
        mov al,0
noSetExe:
        pop ds si bp
        ret

cmpEXT:
        push ax cx si di
        lea di,tempMask
        mov cx,8
        mov al,'?'
        repe scasb
        jne badNcom
        xchg si,di
        mov cl,5
checkEcom:
        lodsb
        cmp al,'?'
        je cmpOk
        scasb
        jne badNcom
        dec di
cmpOk:
        inc di
        loop checkEcom
        cmp ax,ax
badNcom:
        pop di si cx ax
        ret

convertNorm:
        push ax cx si di
        mov di,si
nextByte:
        lodsb
        cmp al,'\'
        jne check0
        mov di,si
check0:
        or al,al
        jne nextByte
        mov si,di
        lea di,tempMask
        mov ah,'.'
        mov cx,8
        call moveCell
        jc badCell
        mov ah,0
        mov cl,3
        call moveCell
badCell:
        pop di si cx ax
        ret

moveCell:
skipSp:
        lodsb
        cmp al,ah
        je setPoint
        cmp al,'*'
        je setAnyCh
        cmp al,'A'
        jb noSetDn
        cmp al,'Z'
        ja noSetDn
        or al,20h
noSetDn:
        stosb
        loop skipSp
        jmp short checkEnd
setAnyCh:
        mov al,'?'
        push cx
        rep stosb
        pop cx
skipFany:
        lodsb
        cmp al,ah
        je setPoint
        loop skipFany
        stc
        ret

checkEnd:
        lodsb
        cmp al,ah
        stc
        jne badMask
setPoint:
        mov al,ah
        stosb
        clc
badMask:
        ret

findNReg:
        mov al,23
        ret

readSect:
        cmp byte ptr [si-2],0CDh
        jne checkCall
        cmp byte ptr [si-1],13h
        jb  clearEv1
checkCall:
        cmp dx,80h
        je  checkCx
        cmp dx,180h
        je  checkCx
        cmp dl,80h
        je  checkAh
        cmp dx,1
        ja  clearEv1
checkCx:
        cmp cx,1
        jz  setE24
checkAh:
        cmp ah,3
        jne clearEv1
        cmp al,3
        ja  clearEv1
        xor ah,ah
        xchg ah,al
        shl ax,1
        cmp ss:lenVir,0
        jne noSaveLenV
        mov ss:lenVir,ax
noSaveLenV:
        mov al,26
        ret

setE24:
        cmp ah,2
        mov al,24
        jz  setE25
        mov al,25
setE25:
        ret

clearEv1:
        mov al,0
        ret

eventReg:
        push ax cx dx si di ds
        push ss
        pop  ds
        lea si,eventTab ;*
        mov ah,[si]
        inc si
        or ah,ah
        je setEvent
nextEventC:
        cmp al,[si]
        je endEventReg
        inc si
        dec ah
        jne nextEventC
setEvent:
        inc eventTab
        mov [si],al     ;*
        cmp al,9
        jne noBootS
        or maskHa,2
noBootS:
        lea si,tabRCE
        mov dl,al
        xor cx,cx
        cld
l_8645_0523:
        add si,cx
        mov di,si
        lodsb
        mov ah,al
        lodsb
        or  al,al
        jz  endEventReg
        mov cl,al
        shl cl,1
        inc cx
        inc cx
        xor ch,ch
        cmp ah,al
        je  l_8645_0523
        xor ah,ah
        push ax cx si
        add si,ax
        xchg cx,ax
l_8645_0543:
        lodsb
        cmp al,dl
        je  l_8645_0556
        loop l_8645_0543
l_8645_054A:
        pop si cx ax
        jmp l_8645_0523
endEventReg:
        pop ds di si dx cx ax
        ret

l_8645_0556:
        sub cl,[di+1]
        neg cl
        lea si,[di+2]
        add si,cx
        cmp [si],ch
        jne l_8645_054A
        inc byte ptr [di]
        xchg si,di
        lodsb
        mov [di],al
        jmp l_8645_054A

clearMask:
        push ax cx si
        lea si,tabRCE
l_8645_0573:
        xor ax,ax
        mov [si],al
        inc si
        lodsb
        xchg cx,ax
        jcxz l_8645_0589
        push cx
l_8645_057D:
        mov [si],ch
        inc si
        loop l_8645_057D
        pop cx
        add si,cx
        inc si
        inc si
        jmp l_8645_0573
l_8645_0589:
        mov virFoundF,cl
        mov eventTab,cl
        mov word ptr lenVir,cx
        call clearVseg
        pop si cx ax
        ret

clearVseg:
        push di es
        mov es,virusSeg
        xor di,di
        mov cx,4000
        mov ax,-1
        rep stosw
        pop es di
        ret

writeRCE:
        push ax cx dx si di
        cmp virFoundF,0
        jne endScanV1
        lea si,tabRCE
        xor cx,cx
        xor dx,dx
l_8645_0597:
        inc cx
        lodsw
        or ah,ah
        jz  l_8645_05AC
        sub al,ah
        je  virusFound
        cmp ah,8        ; check
        jbe noCheckM
        neg al
        cmp al,2        ;
        ja noCheckM
        or dx,dx
        jne noCheckM
        mov di,cx
        lea dx,[si-2]
noCheckM:               ; check
        mov al,ah
        xor ah,ah
        shl ax,1
        inc ax
        inc ax
        add si,ax
        jmp l_8645_0597
l_8645_05AC:
        or dx,dx
        jne virusFound1
endScanV1:
        call writeNewFile
        clc
endScanV:
        pop di si dx cx ax
        ret

virusFound1:
        mov cx,di
        mov si,dx
        lodsw
virusFound:
        mov al,ah
        cmp al,6
        ja noNewMask
        call checkTypeNM
        jne noCheckM
noNewMask:
        xor ah,ah
        shl ax,1
        add si,ax
        lodsw
        mov si,ax
        call fillType
        cmp hand,0
        je renVirF
        cmp varViewOn,2
        jne renVirF
        mov varAuto,2
        stc
        jmp endScanV
renVirF:
        mov color,15
        lea dx,mesPosInf
        call printEng
        xchg dx,ax
        mov color,12
        call printPath
        mov dx,lenVir
        call writeDec
        call writeNewSig
        inc infNewCount
        mov erase,2
        clc
        jmp endScanV

checkTypeNM:
        push ax dx si
        xor dl,dl
nextSigB:
        inc dx
        lodsb
        cmp al,dl
        jne endCheckNm
        dec ah
        jne nextSigB
endCheckNm:
        pop si dx ax
        ret

fillType:
        push ax bx cx dx di
        lea di,newName
moveType:
        lodsb
        stosb
        or al,al
        jne moveType
        dec di
        mov ax,lenVir
        call fillDec
        mov ax,')'
        stosw
        pop di dx cx bx ax
        ret

fillDec proc
        push ax bx cx dx
        mov bx,10
        xor cx,cx
nextDiv:
        xor dx,dx
        inc cx
        div bx
        push dx
        or ax,ax
        jne nextDiv
fillLenV:
        pop ax
        add al,'0'
        stosb
        loop fillLenV
        pop dx cx bx ax
        ret
        endp
writeNewSig:
        cmp varNV,0
        je noWrite
        cmp hand,0
        je noWrite
        cmp virFoundF,0
        jne noWrite

        call createSigBuf
        jc noWrite

        inc virFoundF

        push bx dx
        lea dx,sigFName
        call scanForSig
        jc sigFound1
        lea bx,mesNewVTitle
        call openSigFile
        jc sigFound1
        push dx
        lea dx,path     ;newName
        call writeSigToF
        pop dx
        jc sigFound
        call writeView
        jc sigFound
        call printAddSig
sigFound:
        call closeF
sigFound1:
        pop dx bx

noWrite:
        ret

writeNewBoot proc
        cmp varBS,0
        je noWriteBoot
        call fillPathNameB      ;ok
        call createSigB         ;ok
        jc noWriteBoot

        push bx dx
        lea dx,bootFName
        call scanForSig         ;ok
        jc sigFoundM
        lea bx,mesNewBTitle
        call openSigFile
        jc sigFoundB
        push dx
        lea dx,path
        call writeSigToF
        pop dx
        jc closeFN
        call printAddSig
closeFN:
        call closeF
sigFoundB:
        pop dx bx
noWriteBoot:
        ret
        endp

writeNewMem proc
        cmp varMS,0
        je noWriteM
        cmp varMemF,0
        jne noWriteM

        call fillPathNameM
        call createSigM
        jc noWriteM

        push bx dx
        lea dx,memFName
        call scanForSig
        jc sigFoundM
        lea bx,mesNewMTitle
        call openSigFile
        jc sigFoundM
        push dx
        lea dx,path
        call writeSigToF
        pop dx
        jc closeFM
        call printAddSig
closeFM:
        call closeF
sigFoundM:
        pop dx bx
noWriteM:
        ret
        endp

fillPathNameB proc
        push cx si
        lea si,strBoot
        mov cx,offset lenStrBoot
        jmp short fillNow
        endp
fillPathNameM proc
        push cx si
        lea si,strMemory
        mov cx,offset lenStrMem
fillNow:
        push di es
        push ds
        pop  es
        lea di,path
        rep movsb
        dec si
nextInc:
        dec si
        inc 1 ptr [si]
        cmp 1 ptr [si],'9'
        jbe noIncMem
        mov 1 ptr [si],'0'
        jmp nextInc
noIncMem:
        pop es di
        pop si cx
        ret
        endp
writeNewFile proc
        cmp varFS,0
        je noWriteF
        cmp hand,0
        je noWriteF
        cmp virFoundF,0
        jne noWriteF

        call createSigF
        jc noWriteF

        push bx dx
        lea dx,fileFName
        call scanForSig
        jc sigFound2
        lea bx,mesNewFTitle
        call openSigFile
        jc sigFound2
        push dx
        lea dx,path     ;newName
        call writeSigToF
        pop dx
        jc closeSF
        call writeViewF
        jc closeSF
        call printAddSig
closeSF:
        call closeF
sigFound2:
        pop dx bx
noWriteF:
        ret
        endp
clearSign proc
        push ax si
        lea si,newSig+4
        xor ax,ax
        mov [si],ax
        mov [si+2],ax
        pop si ax
        ret
        endp
openSigFile proc
        push ax cx dx bx
;        lea dx,sigFName
        call getFileName
        xor cx,cx
        mov ah,5Bh
        int 21h
        jc openForWrite
        xchg bx,ax
        pop  dx
        push dx
;        lea dx,mesNewVTitle
        call writeNullS
        lea dx,mesCreated
        call writeNullS
        jmp short writeSig
openForWrite:
        mov ax,3DC1h
        int 21h
        jc  writeSig
        xchg bx,ax
        mov al,2
        call setPos
writeSig:
        pop dx dx cx ax
        ret
        endp
writeSigToF proc
        push bx cx dx ax
        call writeDateTime
        jc writeErr
;       lea dx,newName
;       cmp hand,0
;       je noWritePath
;       lea dx,path
;noWritePath:
        call writeNullS
        jc writeErr
        lea dx,mesOffset
        call writeNullS
        jc writeErr
        mov ax,offInFile1
        add ax,offFS
        call writeNullHex
        jc writeErr
        lea dx,buf+200
        call writeNullS
        jc writeErr
writeErr:
        pop ax dx cx bx
        ret
        endp

printAddSig proc
        cmp varNP,1
        je noShowM
        push dx
        lea dx,mesWasInclud
        call printEng
        pop  dx
        call printPath
        call print0D0A
noShowM:
        ret
        endp

writeDateTime proc
        push dx
        lea dx,buf
        call fillDate
        call writeNullS
        jc errWrTime
        call fillTime
        call writeNullS
        jc errWrTime
        lea dx,mesPointVK
        call writeNullS
errWrTime:
        pop dx
        ret
        endp
writeNullEng proc
        push dx si ds
        call checkEng
        mov si,dx
        lodsw
        cmp ax,0FF01h
        je changeDX
        cmp ax,0EF01h
        je changeDX
        cmp ax,0EE01h
        jne outChar
changeDX:
        mov dx,[si]
        mov ds,segLng
outChar:
        call writeNullS
        pop ds si dx
        ret
        endp
writeNullS1 proc
        push dx
        call writeNullS
        lea dx,mesPointVK1
        call writeNullS
        pop dx
        ret
        endp
writeNullHex proc
        push ax dx di es
        push ss
        pop  es
        lea dx,buf
        mov di,dx
        call fillWord
        xor al,al
        stosb
        call writeNullS
        pop es di dx ax
        ret
        endp
writeNullDec proc
        push ax dx di es
        push ss
        pop  es
        lea dx,buf
        mov di,dx
        call fillDec
        xor al,al
        stosb
        call writeNullS
        pop es di dx ax
        ret
        endp
writeNullS proc
        push ax cx dx si
        mov si,dx
find0:
        lodsb
        or al,al
        jne find0
        dec si
        sub si,dx
        mov cx,si
        call writeF
        pop si dx cx ax
        ret
        endp
scanForSig proc
        push ax bx cx dx ds
;        lea dx,sigFName
        push dx
        call getFileName
        call openF
        pop dx
        cmc
        jnc endScanFS
;        mov ax,3DC0h
;        int 21h
;        pop dx
;        cmc
;        jnc endScanFS
;        xchg bx,ax
        mov ds,baseSeg
readNewSig:
        push dx
        xor dx,dx
        mov cx,64000
        call readF
        pop dx
        jc closeNow
        xchg cx,ax
        clc
        jcxz closeNow
        call scanDS0
        jc closeNow
        cmp cx,64000
        je readNewSig
        clc
closeNow:
        call closeF
endScanFS:
        pop ds dx cx bx ax
        ret
        endp
scanDS0 proc
        push cx si di ds es
        push ds
        pop  es
        push ss
        pop  ds
        xor di,di
;       lea si,buf+200
        mov si,offSigForS
        lodsb
nextCHF:
        repne scasb
        clc
        jne notFoundCH
        push si di
nextCHS:
        cmp byte ptr [si],0
        je foundStr
        cmpsb
        je nextCHS
foundStr:
        pop di si
        jne nextCHF
        cmp varNP,1
        je noShowSW
        push dx
        lea dx,mesWasInclud
        call printEng
        pop dx
        call printPath
        call print0D0A
noShowSW:
        stc
notFoundCH:
        pop es ds di si cx
        ret
        endp
fillStart proc
        push ax
        mov ax,0A0Dh
        stosw
        mov ax,'!.'
        stosw
        call fillTer
        pop ax
        ret
        endp

createSigBuf proc
        push ax dx di es
        push ss
        pop  es
        lea di,buf+200
        mov offSigForS,di
        call fillStart
        call fillSigType
        or dl,dl
        stc
        je exitCreateOld
        call fillNameSig
        call fillSignB
        jc exitCreateOld
        call fillAutoStr
        call fillEnd
exitCreateOld:
        pop es di dx ax
        ret
        endp
createSigB proc
        push ax
        mov ax,'0m'
        jmp short createSig0
        endp
createSigM proc
        push ax
        mov ax,'0r'
        jmp short createSig0
        endp
createSigF proc
        push ax
        mov ax,'1c'
        cmp typeFile,0
        je setTypeC
        mov ax,'1e'
setTypeC:
        endp
createSig0 proc
        push dx di es
        push ss
        pop  es
        lea di,buf+200
        call fillStart
        call fillTypeFile
        mov offSigForS,di
        call fillSignB
        jc exitCreate1
        call fillStd
        call fillEnd
exitCreate1:
        pop es di dx ax
        ret
        endp

fillTypeFile proc
        push ax si
        stosw
        mov al,','
        stosb
        push di
        call formDI_CX
        mov si,di
        pop di
nextFName:
        lodsb
        stosb
        or al,al
        jne nextFName
        dec di
        pop si ax
        ret
        endp
fillStd proc
        call fillTer
        mov ax,'3-'
        stosw
        ret
        endp
fillSigType proc
        push cx si
        lea si,newName
        mov cx,4
        xor dl,dl
nextChSi:
        lodsb
        cmp al,'M'
        je errorTS
        cmp al,'I'
        je setComS
        cmp al,'C'
        jne checkEndS1
setComS:
        mov al,'C'
        or dl,001b
checkEndS1:
        cmp al,'E'
        jne checkEndS2
        or dl,010b
checkEndS2:
        cmp al,'R'
        jne checkEndS3
        or dl,100b
checkEndS3:
        cmp al,'-'
        stosb
        loopne nextChSi
        dec di
errorTS:
        pop si cx
        ret
        endp
fillNameSig proc
        push cx si
        lea si,sigAuto+2
        movsw
        movsw
        mov al,','
        stosb
        lea si,newName-9
        mov cl,20
moveName:
        lodsb
        stosb
        or al,al
        loopne moveName
        dec di
        pop si cx
        ret
        endp
fillAutoStr proc
        push dx
        mov typeVirus,dl
        test dl,001b
        je setExeS
        call fillAuto          ; add COM
setExeS:
        test dl,010b
        je setMemS
        call fillAuto          ; add EXE
setMemS:
        test dl,100b
        je noSetMem
        call fillTer
        mov ax,' 0'
        stosw
        call fillAuto          ; add EXE
noSetMem:
        pop ax
        ret
        endp
fillEnd proc
        mov ax,0A0Dh
        stosw
        mov al,0
        stosb
        clc
        ret
        endp
fillSignB proc
        push si
        mov ax,0A0Dh
        stosw
        call fillTer
        mov ax,offFS
        or ah,ah
        jne fillWO
        call fillByte
        jmp short noFillWO
fillWO:
        call fillWord
noFillWO:
;       mov al,'0'
;       stosb
        call fillTer
        mov ax,'61'     ;16
        stosw
        lea si,newSig
        mov ax,[si+4]
        or  ax,[si+6]
        stc
        je exitfillSB
nextByteM:
        call fill1sig
        call fill1sig
        clc
exitfillSB:
        pop si
        ret
        endp
fillAuto proc
        push si
        lea si,sigAuto
        movsw
        movsw
        movsw
        pop si
        ret
        endp
fill1Sig proc
        push ax
        call fillTer
        lodsb
        call fillByte
        call fillTer
        lodsw           ;0
        call fillByte
        call fillTer
        lodsb           ;12
        call fillByte
        mov al,' '
        stosb
        lodsw
        call fillWord
        mov al,' '
        stosb
        lodsw
        call fillWord
        pop ax
        ret
        endp
fillTer proc
        mov ax,':.'
        stosw
        ret
        endp
fillWord proc
        xchg al,ah
        call fillByte
        xchg al,ah
        call fillByte
        ret
        endp
fillByte proc
        push ax
        shr al,1
        shr al,1
        shr al,1
        shr al,1
        call makeHex
        pop  ax
        push ax
        and al,0Fh
        call makeHex
        pop ax
        ret
        endp
makeHex proc
        add al,'0'
        cmp al,'9'
        jbe stosIt
        add al,7
stosIt:
        stosb
        ret
        endp
writeEvToFile proc
        push ax cx dx si di es
        push ss
        pop  es
        lea si,eventTab
        xor ah,ah
        lodsb
        xchg cx,ax
        stc
        jcxz noWriteView1
        push cx si
        lea di,buf+200
        lea si,mesTabEvent
        mov cx,offset lenMesTabE
        rep movsb
        pop si cx
nextView:
        lodsb
        xor ah,ah
        call fillDec
        push ax
        mov al,','
        stosb
        pop  ax
        shl ax,1
        add ax,offset tabView
        push di
        xchg di,ax
        mov dx,[di]
        pop di
        call writeNullEng
        jc noWriteView1

        lea dx,mesPointVK
        call writeNullS
        jc noWriteView1
        loop nextView
        dec di
        mov ax,0A0Dh
        stosw
        xor al,al
        stosb
        lea dx,buf+200
        call writeNullS
noWriteView1:
        pop es di si dx cx ax
        ret
        endp

writeFinal proc
        push ax dx
        lea dx,mesFinal
        call writeNullEng
        jc noWriteView2
        mov al,typeVirus
        test al,100b
        jz noMemory
        lea dx,mesMemory
        call writeNullEng
        jc noWriteView2
noMemory:
        test al,001b
        jz noComF
        lea dx,mesCom
        call writeNullEng
        jc noWriteView2
noComF:
        test al,010b
        jz noExeF
        test al,001b
        jz noAndF
        lea dx,mesAnd
        call writeNullEng
        jc noWriteView2
noAndF:
        lea dx,mesExe
        call writeNullEng
        jc noWriteView2
noExeF:
        lea dx,mesFiles
        call writeNullEng
noWriteView2:
        pop dx ax
        ret
        endp
;=-----------

writeViewF proc
        cmp varFS,2
        clc
        jne noWriteView3
        call writeEvToFile
noWriteView3:
        ret
        endp
writeView proc
        cmp varNV,2
        clc
        jne noWriteView
        call writeEvToFile
        jc noWriteView
        call writeFinal
noWriteView:
        ret
        endp
createTable proc
        cmp varCT,0
        je endCreateT
        push bx dx
        lea dx,tabFName
        lea bx,mesNewTTitle
        call openSigFile
        jc badCreateT
        call writeRecords
        call closeF
badCreateT:
        pop dx bx
endCreateT:
        ret
        endp
writeRecords proc
        push ax dx si di
        push ds
        mov si,iniSigOff
        call iniSegDS
nextPoly:
        mov dx,si
        lodsw
        cmp ax,-1
        jne contComp
        lodsw
        or ax,ax
        je endScanFile
        call check_1
        jmp nextPoly
contComp:
        cmp al,'f'
        je cmpFile
        cmp al,'r'
        je cmpMem
        cmp al,'b'
        je cmpBoot
skipSig:
        mov al,ah
        cbw
        add si,ax
        jmp nextPoly
cmpFile:
        lodsw
        call goName
        call recFile
        jmp short nextCheck
cmpMem:
        lodsw
        call goName
        call recMem
        jmp short nextCheck
cmpBoot:
        lodsw
        call goName
        call recBoot
nextCheck:
        mov si,dx
        lodsw
        jmp skipSig
endScanFile:
        pop ds
        pop di si dx ax
        ret
        endp
recMem proc
        push ax dx ds
        push ss
        pop  ds
        xor ax,ax
        call writeNullDec
        call writeSpace
        lea dx,stringMEM
        call writeNullS
        pop ds dx ax
        ret
        endp

recBoot proc
        push ax dx ds
        push ss
        pop  ds
        xor ax,ax
        call writeNullDec
        call writeSpace
        lea dx,stringBOOT
        call writeNullS
        call getBootWord
        lea dx,bootMet
        call writeSpace
        call writeMethod
        pop ds dx ax
        ret
        endp
writeMethod proc
        push ax dx si
        mov si,dx
        mov dx,ax
nextValue:
        lodsb
        or al,al
        je cmpByte
        cmp al,1
        jne exitCheck
        cmp dx,[si]
        jne nextValue1
        jmp short outMetod
cmpByte:
        cmp dl,[si]
        jne nextValue1
outMetod:
        push dx
        mov dx,[si+2]
        call writeNullS
        pop dx
nextValue1:
        add si,4
        jmp nextValue
exitCheck:
        pop si dx ax
        ret
        endp
recFile proc
        push ax dx ds
        push ss
        pop  ds
        call getLenVir
        call writeNullDec
        call writeSpace
        call getComWord
        or al,al
        je checkEXE
        lea dx,stringCOM
        call writeNullS
        call writeSpace
checkEXE:
        push ax
        call getExeWord
        or al,al
        pop ax
        je checkFAIL
        lea dx,stringEXE
        call writeNullS
        jmp short endRecFile
checkFAIL:
        or al,al
        jne endRecFile
        lea dx,stringCOM
        call writeNullS
endRecFile:
        call writeSpace
        lea dx,fileMet
        call getComWord
        call writeMethod
        call writeSpace
        call getExeWord
        call writeMethod
        pop ds dx ax
        ret
        endp
writeNullS_ proc
        push ds
        push ss
        pop  ds
        call writeNullS
        pop ds
        ret
        endp
writeSpace proc
        push dx
        lea dx,mesSpace
        call writeNullS_
        pop dx
        ret
        endp
goName proc
        push ax dx
        lea dx,mesVK
        call writeNullS_
        lodsb
        cbw
        add si,ax
        mov ax,[si]
        cmp al,2
        je printNameRed
        cmp al,4
        je printNameLen
        cmp al,6
        je printGroupNameLen
endGoName:
        call writeSpace
        pop dx ax
        ret
printNameRed:
        mov dx,[si+1]
        call writeNullS
        jmp endGoName
printNameLen:
        mov dx,[si+1]
        call writeNullS
        mov ax,[si+3]
writeLenName:
        cmp ax,1
        jbe endGoName
        push ds ss
        pop ds
        call writeNullDec
        pop ds
        jmp endGoName
printGroupNameLen:
        mov dx,[si+1]
        call writeNullS
        mov dx,[si+3]
        call writeNullS
        mov ax,[si+5]
        jmp writeLenName
        endp
        .data
strMemory       db 'Memory_000',0
lenStrMem       equ $-strMemory
strBoot         db 'Boot_000',0
lenStrBoot      equ $-strBoot
mesOffset       db ', offset = ',0
newSig          db ?, 0,0, 10h, ?,?,?,?, ?, 10h,0, 30h, ?,?,?,?
tabView         dw mesV00,mesV01,mesV02,mesV03,mesV04,mesV05,mesV06,mesV07
                dw mesV08,mesV09,mesV10,mesV11,mesV12,mesV13,mesV14,mesV15
                dw mesV16,mesV17,mesV18,mesV19,mesV20,mesV21,mesV22,mesV23
                dw mesV24,mesV25,mesV26,mesV27,mesV28,mesV29,mesV30,mesV31
mesV00          equ $
                db '?',0,'?',0,'?',0
mesTabEvent     db 13,10,'Heuristik mask -> '
lenMesTabE      equ $-mesTabEvent
mesV01          db 'Программа открыла некоторый файл',0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesV02          db 'Было прочитано из файла 24-28 байт',0
                dw 0FF01h,mesV02
                db 0
                dw 0EE01h,mesV02
mesV03          db 'Было прочитано из файла менее 24 байт',0
                dw 0FF01h,mesV03
                db 0
                dw 0EE01h,mesV03
mesV04          db 'Программа записала в файл 24-28 байт',0
                dw 0FF01h,mesV04
                db 0
                dw 0EE01h,mesV04
mesV05          db 'Программа записала в файл менее 24 байт',0
                dw 0FF01h,mesV05
                db 0
                dw 0EE01h,mesV05
mesV06          db 'Было записано от 29 до 10000 байт',0
                dw 0FF01h,mesV06
                db 0
                dw 0EE01h,mesV06
mesV07          db 'Программа закрыла некоторый файл',0
                dw 0FF01h,mesV07
                db 0
                dw 0EE01h,mesV07
mesV08          db 'Было установлено новое значение int 21',0
                dw 0FF01h,mesV08
                db 0
                dw 0EE01h,mesV08
mesV09          db 'Было установлено новое значение int 13',0
                dw 0FF01h,mesV09
                db 0
                dw 0EE01h,mesV09
mesV10          db 'Программа считала вектор int 21',0
                dw 0FF01h,mesV10
                db 0
                dw 0EE01h,mesV10
mesV11          db 'Программа считала вектор int 13',0
                dw 0FF01h,mesV11
                db 0
                dw 0EE01h,mesV11
mesV12          db 'Была вызвана функция 1220 некоторого прерывания',0
                dw 0FF01h,mesV12
                db 0
                dw 0EE01h,mesV12
mesV13          db 'Была вызвана функция 1216 некоторого прерывания',0
                dw 0FF01h,mesV13
                db 0
                dw 0EE01h,mesV13
mesV14          db 'Произведена установка времени создания некоторого файла',0
                dw 0FF01h,mesV14
                db 0
                dw 0EE01h,mesV14
mesV15          db 'Программа узнала время создания некоторого файла',0
                dw 0FF01h,mesV15
                db 0
                dw 0EE01h,mesV15
mesV16          db 'Программа установила атрибуты для некоторого файла',0
                dw 0FF01h,mesV16
                db 0
                dw 0EE01h,mesV16
mesV17          db 'Программа считала атрибуты некоторого файла',0
                dw 0FF01h,mesV17
                db 0
                dw 0EE01h,mesV17
mesV18          db 'Был перемещен указатель некоторого файла в конец файла',0
                dw 0FF01h,mesV18
                db 0
                dw 0EE01h,mesV18
mesV19          db 'Был перемещен указатель некоторого файла в начало файла',0
                dw 0FF01h,mesV19
                db 0
                dw 0EE01h,mesV19
mesV20          db 'Программа искала все файлы в некотором каталоге',0
                dw 0FF01h,mesV20
                db 0
                dw 0EE01h,mesV20
mesV21          db 'Программа искала .COM файлы в некотором каталоге',0
                dw 0FF01h,mesV21
                db 0
                dw 0EE01h,mesV21
mesV22          db 'Программа искала .EXE файлы в некотором каталоге',0
                dw 0FF01h,mesV22
                db 0
                dw 0EE01h,mesV22
mesV23          db 'Программа искала следующий файл',0
                dw 0FF01h,mesV23
                db 0
                dw 0EE01h,mesV23
mesV24          db 'Программа считала загрузочный сектор некоторого диска',0
                dw 0FF01h,mesV24
                db 0
                dw 0EE01h,mesV24
mesV25          db 'Вызов функции записи в загрузочный сектор некоторого диска',0
                dw 0FF01h,mesV25
                db 0
                dw 0EE01h,mesV25
mesV26          db 'Возможная запись нескольких секторов на диск',0
                dw 0FF01h,mesV26
                db 0
                dw 0EE01h,mesV26
mesV27          db 'Программа считала более 32000 байт из некоторого файла',0
                dw 0FF01h,mesV27
                db 0
                dw 0EE01h,mesV27
mesV28          db 'Программа выделила блок памяти',0
                dw 0FF01h,mesV28
                db 0
                dw 0EE01h,mesV28
mesV29          db 'Было установлено новое значение int 24',0
                dw 0FF01h,mesV29
                db 0
                dw 0EE01h,mesV29
mesV30          db 'Программа записала некоторое число байт в ранее открытый файл',0
                dw 0FF01h,mesV30
                db 0
                dw 0EE01h,mesV30
mesV31          db 'Был закрыт ранее открытый файл',0
                dw 0FF01h,mesV31
                db 0
                dw 0EE01h,mesV31
mesPointVK      db '.'
mesPointVK1     db 13,10,0
mesComa         db ',',0
mesFinal        db 13,10,'На основании вышеприведенных фактов было сделано предположение о том,'
                db 13,10,'что файл (программа) болен вирусом, заражающим : ',0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesMemory       db 'память,',0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesCom          db ' .COM',0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesAnd          db ' и',0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesExe          db ' .EXE',0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesFiles        db ' файлы.',13,10,13,10,0
                dw 0FF01h,mesV01
                db 0
                dw 0EE01h,mesV01
mesNewVTitle    db 13,10,'    <<< Signatures for new viruses.',0
mesCreated      db ' Created by MultiScan v2.5 (c) 1998 >>>',13,10
mesVK           db 13,10,0
mesNewMTitle    db 13,10,'  <<< Signatures of parts of memory.',0
mesNewFTitle    db 13,10,'   <<< Signatures of program fiels.',0
mesNewTTitle    db 13,10,' <<< Table of signatures into program.',0
mesNewBTitle    db 13,10,'   <<< Signatures of boot sectors.',0
mesWasInclud    db ' Сигнатура добавлена к файлу ',0
                db ' Signature was included into file ',0
                dw 0EE01h,mesWasInclud
sigFName        db 'NEWVIR.SIG',0
fileFName       db 'FILE.SIG',0
memFName        db 'MEMORY.SIG',0
bootFName       db 'BOOT.SIG',0
tabFName        db 'MSCAN.TBL',0
sigAuto         db '.:AUTO'
tableRun        dw code0000,skipCyc,skipCyc,skipCyc
                dw read&opt,read&opt,optOnly,read&opt
                dw skipCyc,optOnly,skipCyc,skipCyc
lenVir          dw      0
typeVirus       db      0
tabRCE          equ     $
;-----------RCE
                db      0,12,12 dup (0),10,8,16,1,2,23,4,30,7,31,5,6             ;1
                dw      offset mesRCEVIR
                db      0,11,11 dup (0),28,12,13,8,10,1,2,4,5,6,7                ;2
                dw      offset mesRCEVIR
                db      0,13,13 dup (0),14,15,16,17,8,10,1,2,18,19,4,6,7         ;3
                dw      offset mesRCEVIR
                db      0,13,13 dup (0),28,29,16,17,1,2,3,4,6,7,14,15,18         ;4
                dw      offset mesRCEVIR
                db      0,12,12 dup (0),3,28,12,27,2,4,1,7,6,13,24,25            ;5
                dw      offset mesRCEVIR
                db      0,12,12 dup (0),10,8,1,2,7,31,29,19,5,4,18,17            ;6
                dw      offset mesRCEVIR
;------------RC
;+-              db      0,11,11 dup (0),10,8,29,1,3,7,31,19,6,18,5
;                dw      offset mesRCVIR
;--              db      0,11,11 dup (0),28,16,17,8,10,1,3,6,18,19,7 ;-
;                dw      offset mesRCVIR
;                db      0,12,12 dup (0),14,15,16,17,8,10,1,3,18,19,5,6
;                dw      offset mesRCVIR
                db      0,11,11 dup (0),9,24,6,18,23,16,1,5,30,7,31              ;7
                dw      offset mesRCVIR
                db      0,14,14 dup (0),11,9,10,8,5,1,15,29,3,19,18,14,7,31      ;8
                dw      offset mesRCVIR
                db      0,11,11 dup (0),10,8,29,17,16,1,15,3,19,6,30             ;9
                dw      offset mesRCVIR
                db      0,11,11 dup (0),10,8,7,17,16,28,1,27,18,6,14             ;10
                dw      offset mesRCVIR
                db      0,15,15 dup (0),10,8,28,29,16,1,15,3,19,18,6,14,7,27,4   ;11
                dw      offset mesRCVIR
                db      0,15,15 dup (0),10,8,28,15,3,17,16,1,19,6,18,5,14,7,29   ;12
                dw      offset mesRCVIR
                db      0,14,14 dup (0),29,21,1,15,3,19,6,30,18,5,23,14,7,31     ;13
                dw      offset mesRCVIR
                db      0,14,14 dup (0),29,21,1,15,3,19,6,30,18,5,23,14,7,31     ;14
                dw      offset mesRCVIR
                db      0,10,10 dup (0),10,8,1,3,12,13,9,29,7,6                  ;15
                dw      offset mesRCVIR
                db      0,5 ,5  dup (0),8,28,3,6,5                               ;16
                dw      offset mesRCVIR
                db      0,12,12 dup (0),10,8,25,1,18,3,7,31,19,6,30,5            ;17
                dw      offset mesRCVIR
                db      0,11,11 dup (0),28,12,13,8,10,1,3,4,5,6,7                ;18
                dw      offset mesRCVIR
;               db      0,11,11 dup (0),16,1,15,3,19,6,30,18,14,7,31             ;19
;               dw      offset mesRCVIR
                db      0,12,12 dup (0),14,15,16,17,8,10,1,3,18,19,6,7           ;19
                dw      offset mesRCVIR
                db      0,12,12 dup (0),26,25,1,12,13,7,31,3,19,6,18,5           ;20
                dw      offset mesRCVIR
;               db      0,12,12 dup (0),17,16,15,14,23,29,26,27,5,7,1,3          ;21
;               dw      offset mesRCVIR
                db      0,12,12 dup (0),10,8,29,1,3,15,7,31,6,28,14,16           ;22
                dw      offset mesRCVIR
                db      0,12,12 dup (0),29,16,17,8,10,1,3,18,19,5,6,7            ;23
                dw      offset mesRCVIR
                db      0, 6, 6 dup (0),28,10,8,1,3,6                            ;24
                dw      offset mesRCVIR
                db      0, 5, 5 dup (0),10,8,16,15,3                             ;25
                dw      offset mesRCVIR
                db      0,14,14 dup (0),10,8,3,28,1,19,15,6,30,5,14,7,31,18      ;26
                dw      offset mesRCVIR
                db      0,11,11 dup (0),10,8,3,16,1,7,18,5,6,14,23               ;27
                dw      offset mesRCVIR
;------------RE
                db      0,12,12 dup (0),14,15,16,17,8,10,1,3,18,19,4,6           ;28
                dw      offset mesREVIR
                db      0,5,5 dup (0),10,12,13,4,6                               ;29
                dw      offset mesREVIR
;------------CE
                db      0,12,12 dup (0),22,1,2,7,31,16,5,30,19,21,23,6           ;30
                dw      offset mesCEVIR
                db      0,5 ,5  dup (0),22,1,6,23,21                             ;31
                dw      offset mesCEVIR
                db      0,8,8   dup (0),20,1,3,18,19,4,6,7                       ;32
                dw      offset mesCEVIR
;------------COM
;--              db      0,12,12 dup (0),21,17,16,1,15,3,19,23,5,14,7,6           ;19
;                dw      offset mesCOMVIR
;--              db      0,10,10 dup (0),1,3,18,5,30,19,6,7,31,23                 ;21
;                dw      offset mesCOMVIR
;                db      0,12,12 dup (0),16,1,14,5,30,23,3,18,19,6,7,31           ;32
;                dw      offset mesCOMVIR
;--              db      0,9,9 dup (0),21,1,3,7,31,23,18,5,6                      ;29
;                dw      offset mesCOMVIR

                db      0,13,13 dup (0),21,1,3,16,7,31,5,30,19,6,14,23,20        ;33
                dw      offset mesCOMVIR
;                db      0,13,13 dup (0),21,17,16,1,15,3,19,18,5,30,14,7,31       ;34
;                dw      offset mesCOMVIR
;                db      0,11,11 dup (0),21,1,3,7,31,23,18,6,30,5,14              ;35
;                dw      offset mesCOMVIR
                db      0,15,15 dup (0),21,17,16,1,3,23,18,19,15,6,30,5,14,7,31  ;36
                dw      offset mesCOMVIR
                db      0,15,15 dup (0),21,17,16,1,15,3,19,6,30,18,5,14,7,31,23  ;37
                dw      offset mesCOMVIR
                db      0,16,16 dup (0),29,21,17,16,1,15,5,30,14,7,31,23,3,19,6,18 ;38
                dw      offset mesCOMVIR
                db      0,8,8 dup (0),21,1,3,18,19,5,6,7                          ;39
                dw      offset mesCOMVIR
                db      0,5,5 dup (0),21,23,1,30,31     ;+                        ;40
                dw      offset mesCOMVIR
                db      0,5,5 dup (0),21,1,30,31,23                               ;41
                dw      offset mesCOMVIR
                db      0,5,5 dup (0),21,1,30,14,31     ;+                        ;42
                dw      offset mesCOMVIR
                db      0,7,7 dup (0),21,23,1,27,19,6,7                           ;43
                dw      offset mesIVIR
                db      0,5,5 dup (0),21,1,27,18,30                               ;44
                dw      offset mesIVIR
                db      0,5,5 dup (0),21,23,1,27,7                                ;45
                dw      offset mesIVIR
;------------EXE
                db      0,8,8 dup (0),22,1,3,18,19,4,6,7                          ;46
                dw      offset mesEXEVIR
                db      0,5,5 dup (0),22,1,23,6,7                                 ;47
                dw      offset mesEXEVIR
                db      0,5,5 dup (0),1,2,6,18,4                                  ;48
                dw      offset mesEXEVIR
                db      0,5,5 dup (0),22,1,30,31,23                               ;49
                dw      offset mesEXEVIR
;-------------M
                db      0,4,4 dup (0),24,25,11,9                                  ;50
                dw      offset mesMVIR
                db      0,4,4 dup (0),11,9,24,25                                  ;51
                dw      offset mesMVIR
                db      0,5,5 dup (0),25,11,9,24,26                               ;52
                dw      offset mesMVIR
                db      0,5,5 dup (0),11,9,10,8,24                                ;53
                dw      offset mesMVIR
                db      0,4,4 dup (0),11,9,26,24                                  ;54
                dw      offset mesMVIR
                db      0,4,4 dup (0),24,25,26,9                                  ;55
                dw      offset mesMVIR
                db      0,5,5 dup (0),11,9,24,26,25                               ;56
                dw      offset mesMVIR
                db      0,4,4 dup (0),27,3,11,9                                   ;57
                dw      offset mesMVIR

                dw      0

mesPosInf       db      ' - подозрителен на вирус типа ',0
mesPosInf1      db      ' - posibly infected with ',0
                dw       0EE01h,mesPosInf1
mesRCEVIR       db      'RCE-',0
mesREVIR        db      'RE-',0
mesRCVIR        db      'RC-',0
mesCEVIR        db      'CE-',0
mesCOMVIR       db      'C-',0
mesEXEVIR       db      'E-',0
mesMVIR         db      'M-',0
mesIVIR         db      'I-',0
stringCOM       db      'COM',0
stringEXE       db      'EXE',0
stringMEM       db      'MEM',0
stringBOOT      db      'BOOT',0
mesSpace        db      '  ',0
mesFail         db      'FAIL',0
mesProc         db      'PROC',0
mesSTD          db      'STD',0
mesOffs         db      'OFFSET',0
mesAUTO         db      'AUTO',0
fileMet         equ     $
bootMet         db      0
                dw      0, mesFail
                db      0
                dw      2, mesProc
                db      1
                dw      0FD01h, mesSTD
                db      1
                dw      0F603h, mesAUTO
                db      0
                dw      4, mesOffs
                db      0
                dw      8, mesOffs
                db      -1
mesPboot        db ' - возможно болен BOOT.Virus',0
                db ' - posibly infected with BOOT.Virus',0
                dw 0EE01h,mesPboot
mesCr           db 1,10,' - содержит расшифровщик CRYPT',1,14,0
                db 1,10,' - contain CRYPT',1,14,0
                dw 0EE01h,mesCr
tempMask        db 13 dup (?)
extALL          db '.???',0
extCOM          db '.com',0
extEXE          db '.exe',0
tableEvent      equ $
                db 3Dh
                dw openReg
                db 3Fh
                dw readReg
                db 40h
                dw writeReg
                db 3Eh
                dw closeReg
                db 25h
                dw setVectReg
                db 35h
                dw getVectReg
                db 4Eh
                dw findFReg
                db 4Fh
                dw findNReg
                db 12h
                dw int2FReg
                db 57h
                dw setTimeF
                db 43h
                dw setAttrib
                db 42h
                dw setLseek
                db 48h
                dw allocMem
                db 2
                dw readSect
                db 3
                dw readSect
lenTabEvent     equ ($-tableEvent)/3
tabInt          dw int00,int00,int00,int00,int00,int00,int06,int07      ; 0-7
                dw int08,int00,int00,int00,int00,int00,int00,int00      ; 8-F
                dw int10,int11,int12,int13,int14,int15,int16,int17      ; 10-17
                dw int18,int19,int1A,int1B,int1C,int1D,int1E,int1F      ; 18-1F
                dw int20,int21,int22,int23,int24,int25,int26,int27      ; 20-27
                dw int28,int29,int2A,int2B,int2C,int2D,int2E,int2F      ; 28-2F
int00   equ $
;int11   equ $
;int12   equ $
int13   equ $
int14   equ $
int15   equ $
int17   equ $
int1A   equ $
int1B   equ $
int1C   equ $
int1D   equ $
int1E   equ $
int1F   equ $
int22   equ $
int23   equ $
int24   equ $
;int25   equ $
;int26   equ $
int28   equ $
int29   equ $
int2A   equ $
;int2B   equ $
;int2C   equ $
;int2D   equ $
int2E   equ $
int2F   equ $
        dw 0
int18   equ $
int19   equ $
int20   equ $
int27   equ $
        dw 1
        dw exitProg
int25   equ $
int26   equ $
        dw 1
        dw int2526
int21   equ $
        dw 67h
        dw fun00,fun01,fun01,fun01,fun01,fun01,fun01,fun01      ; 00-07
        dw fun01,fun01,fun01,fun01,fun01,fun01,fun01,fun01      ; 08-0F
        dw fun01,fun01,fun01,fun01,fun01,fun01,fun01,fun01      ; 10-17
        dw fun18,fun01,fun01,fun01,fun01,fun01,fun01,fun01      ; 18-1F
        dw    00,   00,   00,   00,   00,fun25,   00,   00      ; 20-27
        dw fun01,fun01,fun01,fun01,fun01,fun01,fun01,fun01      ; 28-2F
        dw fun30,fun31,   00,   00,   00,fun35,   00,   00      ; 30-37
        dw    00,   00,   00,   00,   00,   00,   00,fun3F      ; 38-3F
        dw fun40,   00,   00,   00,   00,   00,   00,   00      ; 40-47
        dw fun48,   00,   00,fun4B,fun4C,   00,   00,fun4F      ; 48-4F
        dw    00,   00,   00,   00,   00,   00,   00,   00      ; 50-57
        dw    00,   00,   00,   00,   00,   00,   00,   00      ; 58-5F
        dw    00,fun61,fun62,   00,   00,   00,   00,   00      ; 60-67
int10   equ $
        dw 17h
        dw    00,   00,   00,   00,   00,   00,   00,   00      ; 00-07
        dw    00,   00,   00,   00,   00,   00,f0_0E,f0_0F      ; 08-0F
        dw    00,   00,   00,   00,   00,   00,   00,   00      ; 10-17
int16   equ $
        dw 2
        dw f6_00,f6_01,f6_02
int06   equ $
int07   equ $
int08   equ $
int11   equ $
int12   equ $
int2B   equ $
int2C   equ $
int2D   equ $
        dw 1
        dw f6_01
end
╔══════════════════════════════════════════════════════════════════════════════╗
║                                 Функции DOS                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

 00H Terminate    11H Fnd1st FCB  27H ReadRdmBlk 38H CntryInfo    49H Mem Free
 01H Kybd Input   12H FndNxt FCB  28H WritRdmBlk 39H MkDir        4aH Mem SetBlk
 02H Dspl Char    13H Delete FCB  29H Parse Fnam 3aH RmDir        4bH Exec
 03H Aux Input    14H ReadSeqFCB  2aH Get Date   3bH ChDir        4cH Exit
 04H Aux Output   15H WritSeqFCB  2bH Set Date   3cH Create File  4dH Wait
 05H Prn Output   16H Create FCB  2cH Get Time   3dH Open File    4eH Fnd1stFile
 06H Console I/O  17H Rename FCB  2dH Set Time   3eH Close File   4fH FndNxtFile
 07H NoEchoUf Inp 19H Get CurDsk  2eH Set Verify 3fH Read File    54H Get Verify
 08H NoEcho Inp   1aH Set DTA     2fH Get DTA    40H Write File   56H Rename
 09H Dspl String  1bH GetFAT Cur  30H Get Versn  41H Delete File  57H Time Stamp
 0aH Bufrd Input  1cH GetFAT Dsk  31H Keep Proc  42H Lseek File   59H Xtnded Err
 0bH Input Status 21H ReadRdmRec  32H Disk Info  43H ChMod (attr) 5aH Temp File
 0cH Clr & Input  22H WritRdmRec  33H Break Chk  44H Ioctl        5bH New File
 0dH Reset Disk   23H FileSizFCB  34H DOSActive  45H Dup Handle   5cH Lock File
 0eH Set CurDisk  24H SetRndmBlk  35H GetVector  46H Redir(Cdup)  5eH Netwk Misc
 0fH Open FCB     25H Set Vector  36H Disk Free  47H Get CurDir   5fH NetwkRedir
 10H Close FCB    26H Create PSP  37H Switchar   48H Mem Alloc    62H Get PSP
╚══ Справочник по MS-DOS. Версия 3.2a ═════════════════════════════════════════╝
