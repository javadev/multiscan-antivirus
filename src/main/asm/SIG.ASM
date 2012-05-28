
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модуль загружает .SIG файлы. Почти не комментирован. Можете дополнить
; эго каким-либо скриптом.

; ошибки:
;       1 - недостаточно данных для определения вируса
;       2 - отсутствует тип вируса
;       3 - неверный тип вируса
;       4 - отсутствует или неправильная длина вируса
;       5 - требуется число или выражение
;       6 - отсутствует имя вируса
;       7 - мало байт сигнатуры
;       8 - слишком много байт для восстановления
;       9 - требуется число в диапазоне (0-FF).

public  checkSig,load80,mesError,getWord,getSpecWord
public  mesErr00,mesErr01,mesErr02,mesErr03,mesErr04
public  mesErr05,mesErr06,mesErr07,mesErr08,mesErr09
public  pBaseRead,pBaseLo,pBaseHi         

extrn   insertName:near,printPath:near,insertCE:near,insertR:near
extrn   insertBoot:near,writeDec:near,writeChar:near,print0D0A:near,var0D:byte
extrn   closeFile:near,complete:near,color:byte,printEng:near
extrn   openSig:near,delString:near,print0D:near
extrn   printOk:near,checkBreak:near,buf:near,readPic:near,path:near
extrn   nameVir:byte,sigOff:word,bufSig:byte
extrn   tabOff:word,sizeVir:word,memOff:word,cureMemory:word
extrn   bootOff:word,storeCX:word,localWord:word,mySign:byte
extrn   typeNum:byte,saveSi:word,saveCX:word,countSerr:byte,bytesWrite1:byte
extrn   saveAl:byte,baseSeg:word,readF:near,beep:near
extrn   fileSigCount:word,virsigCount:word
        .model small
        .code
checkSig proc
        call readPic
        push ax bx cx dx si di es
        xor ax,ax
openNext:
        cmp countSerr,30
        ja exit1
        call openSig
        jc exit1
        mov handleBase,ax
        mov countStr,1
        inc fileSigCount
        call print0D
        mov color,11
        lea dx,path
        call printPath
        call print0D0A
        xchg ax,bx
        push ss
        pop  es
        mov var0D,1
        xor ax,ax
	mov pBaseLo,ax
	mov pBaseHi,ax
        mov pBaseRead,ax
nextCell:
        call load80
        jc exit
nextVirus:
        call checkBreak
        jc exit
        call findIdentF ; o
        jc exit0
        call findID     ; o
        jc printErr
        call getType    ; o
        jc printErr
        call getSize
        jc printErr
        call getNameVir
        jc printErr
        call getSign
        jc printErr
        lea di,tableType
        cbw
        shl ax,1
        add di,ax
        call word ptr [di]
        jc printErr
        call insertName
        jc printErr
        inc virsigCount
        call printNameSig

        jmp nextVirus
exit1:
        mov var0D,0
        pop es di si dx cx bx ax
        ret
        endp
exit0:
        call complete
        call delString
exit:
        call closeFile
        mov al,1
        jmp openNext
printErr proc
        call beep
        call print0D0A
        inc countSerr
        cmp countSerr,100
        jae exit0
        cmp countSerr,30
        ja exit
        push si cx ax
        xor cx,cx
        push ds
        mov ds,baseSeg
findBeg:
        dec si
        mov al,[si]
        cmp al,0Ah
        je begFound
        inc cx
        or  si,si
        jns findBeg
begFound:
        inc si
        mov dx,si
        call delString
        mov ss:color,3
        push cx
        mov cx,79
findz:
        lodsb
        or al,al
        je zfound
        cmp al,0Dh      ; 0Ah
        je zfound
        mov dl,al
        call writeChar
zfound:
        loopne findz
        pop cx
        pop ds
        call print0D0A
        jcxz outError
        mov dl,' '
outSpace:
        call writeChar
        loop outSpace
outError:
        pop ax
        lea dx,mesError
        call printEng
        xor ah,ah
        shl ax,1
        add ax,offset tabMesErr
        xchg si,ax
        mov dx,[si]
        call printEng
        mov dl,'('
        call writeChar
        mov dx,countStr
        call writeDec
        mov dl,')'
        call writeChar
        call print0D0A
        pop cx si
        jmp nextVirus
        endp
printNameSig proc
        push ax dx
        mov color,3
        lea dx,nameVir
        call printPath
        mov ax,sizeVir
        cmp ax,1
        jbe noPrintSize
        or ax,ax
        js  noPrintSize
        mov dl,'.'
        call writeChar
        xchg dx,ax
        call writeDec
noPrintSize:
        call print0D
        pop dx ax
        ret
        endp
procCOM proc
        call procC1
        jc noInsertC
        call insertCE
noInsertC:
        ret
        endp
procC1 proc
        call procC
        jc comError
        xor al,al
        stosb
comError:
        ret
        endp
procC proc
        call findID
        jc comError
        lea di,tabOff

        call checkShMoDeFaSt
        jnc exitComBad2

        call checkAUTO
        jc noAutCom
        mov ax,0F603h
        stosw
        xor ax,ax
        call checkPlus
        jne noSetPlus
        call getID&Word
        jc exitComBad
noSetPlus:
        stosw
        clc
        jmp short exitComBad
noAutCom:
        mov typeNum,10
        call getWord
        jc exitComBad
        cmp byte ptr mySign,'-'
        jne noNegAx
        neg ax
noNegAx:
        cmp ax,-3
        jne noStdFile
        mov ax,0FD01h
        stosw
exitComBad2:
        jmp short exitComBad
noStdFile:
        cmp ax,-4
        je beginVir
        cmp ax,-5
        je beginVir
        cmp ax,28
        ja exitComBad1
        cmp al,2
        jbe addCure
beginVir:
        push ax
        mov al,3
        stosb
        pop ax
        stosb
        call getID&Word
        jc exitComBad
        stosw
        jmp short exitComBad
addCure:
        push ax
        mov al,6
        stosb
        pop ax
        stosb
        call getID&Word
        jc exitComBad
        stosw
        call findID
        jc exitComBad
        mov typeNum,10
        call getSpecWord
        jc exitComBad
        stosb
        call getID&Word
        jc exitComBad
        stosw
exitComBad:
        ret
exitComBad1:
        mov al,8        ; слишком много байт для восстановления
        stc
        ret
        endp
getID&Word proc
        call findID
        jc exitIDBad
        mov typeNum,16
        call getSpecWord
exitIDBad:
        ret
        endp
procEXE proc
        call procE1
        jc noInsertE
        call insertCE
noInsertE:
        ret
        endp
procE1 proc
        lea di,tabOff
        xor al,al
        stosb
procE:
        call findID
        jc exitComBadE

        call checkShMoDeFaSt
        jnc exitComBadE

        call checkAUTO
        jc noExeAutOn
        mov ax,0F603h
        stosw
        xor ax,ax
        call checkPlus
        jne set10Aut
        call getID&Word
        jc exitComBadE
set10Aut:
        stosw
        clc
        jmp short exitComBadE
noExeAutOn:
        mov typeNum,16
        call getSpecWord
        jc exitComBadE
        cmp ax,-3
        jne noStdExe
        mov ax,0FD01h
        stosw
        jmp short exitComBadE
noStdExe:
        push ax
        mov al,8
        stosb
        pop ax
        stosw
        call getSpecWord
        jc exitComBadE
        stosw
        call getSpecWord
        jc exitComBadE
        stosw
        call getSpecWord
        jc exitComBadE
        stosw
exitComBadE:
        ret
        endp
procCE proc
        call procC
        jc exitCE
        call procE
        jc exitCE
        call insertCE
exitCE:
        ret
        endp
procR proc
        call findID
        jc exitResid
        call getSpecWord
        jc exitResid
        mov memOff,ax
procR1:
        call findID
        jc exitResid
        lea di,cureMemory

        call checkFaSt
        jnc exitResid
        call checkAUTO
        jc noexitResid
        mov ax,0F601h
        stosw
        jmp short exitResid
noexitResid:
        call getSpecWord
        jc exitResid
setCureMem:
        or ax,ax
        jne noIntMetod
        call getWord            ; для 0
        jc exitResid
        or ah,ah
        jne exitResid1
        mov ah,al
        mov al,1
        stosw
        jmp short exitResid
noIntMetod:
        cmp ax,-3
        jne noStdCell
        mov ax,0FD01h
        stosw
        jmp short exitResid
noStdCell:
        cmp ax,-1
        jne noSpecMetod
        mov saveAl,4
        mov al,8
        stosb
readWd:
        call getWord
        jc exitResid
        stosw
        dec saveAl
        jne readWd
        jmp short exitResid
noSpecMetod:
        cmp ax,-2
        jne noSmartMetod
        mov ax,0FE03h
        stosw
        call getSpecWord            ; для -2
        jc exitResid
        stosw
        jmp short exitResid
noSmartMetod:
        push ax
        mov al,2
        stosb
        pop ax
        stosw
        clc
exitResid:
        ret
exitResid1:
        stc
        mov al,9
        ret
        endp
procRez proc
        mov ax,sigOff
        mov memOff,ax
        call procR1
        jc exitRez
        call insertR
exitRez:
        ret
        endp
procRC proc
        call procC1
        jc exitRC
        call procR
        jc exitRC
        call insertCE
        jc exitRC
        call insertR
exitRC:
        ret
        endp
procRE proc
        call procE1
        jc exitRE
        call procR
        jc exitRE
        call insertCE
        jc exitRE
        call insertR
exitRE:
        ret
        endp
procRCE proc
        call procC
        jc exitRCE
        call procE
        jc exitRCE
        call procR
        jc exitRCE
        call insertCE
        jc exitRCE
        call insertR
exitRCE:
        ret
        endp
procB proc
        call procM
        jc bootErr
        cmp ax,0FD01h
        je bootErr
        call getID&Word
        jc bootErr
        stosw           ; 3
        call getID&Word
        jc bootErr
        stosw           ; 4
        mov 1 ptr [di-9],8
bootErr:
        ret
        endp
procM proc
        call findID
        jc exitMb

        lea di,storeCX
        call checkAuto
        jc noAutoM
        mov ax,0F601h
        stosw
        jmp short exitMb
noAutoM:
        call checkFaSt
        jnc exitMb
        call getSpecWord
        jc exitMb

        cmp ax,-3
        jne noStdBoot
        mov ax,0FD01h
        stosw
        jmp short exitMb
noStdBoot:
        push ax
        mov al,4
        stosb
        pop ax
        stosw           ; 1
        call getID&Word
        jc exitMb
        stosw           ; 2
        mov al,4
exitMb:
        ret
        endp
checkPlus proc
        push ax ds
        mov ds,baseSeg
        mov al,[si]
        cmp al,'+'
        pop ds ax
        ret
        endp
checkAUTO proc
        push ax ds
        mov ds,baseSeg
        mov ax,[si]
        or ax,2020h
        cmp ax,'ua'
        stc
        jne exitCAU
        mov ax,[si+2]
        or ax,2020h
        cmp ax,'ot'
        stc
        jne exitCAU
        lea si,[si+4]
        sub cx,4
        jnc exitCAU
        mov al,1
        pop ds dx dx
        ret
exitCAU:
        pop ds ax
        ret
        endp
procBOOT proc
        mov ax,sigOff
        mov bootOff,ax
        call procB
        jmp short checkMbr
        endp
procMbr proc
        mov ax,sigOff
        mov bootOff,ax
        call procM
checkMbr:
        jc exitMbr
        cmp ax,0FD01h
        je noReadR
        call procR
        jc exitMbr
        call insertR
        jc exitMbr
noReadR:
        call insertBoot
exitMbr:
        ret
        endp

procMC proc
        call procC1
        jc exitMC
        call getID&Word
        jc exitMC
        mov bootOff,ax
        call procM
        jc exitMC
        call insertCE
        jc exitMC
        call insertBoot
exitMC:
proc0:
        ret
        endp
load80 proc
        push ax bx dx ds
        mov bx,handleBase
        mov cx,pBaseHi
        mov dx,pBaseLo
        mov ax,4200h
        int 21h
        mov ds,baseSeg
        xor dx,dx
        mov si,dx
        mov cx,32000
        call readF
        jc exit80
        mov ss:pBaseRead,ax
        push si
        mov si,ax
        mov byte ptr [si],0
        pop si
        mov cx,ax
        cmp ax,3
        jc exit80
        cmp ax,32000
;        clc
        jne setupBase

        push cx dx
        xchg si,ax
        xor dx,dx
find0A:
        dec si
        mov al,[si]
        cmp al,0Ah
        je found0A
        dec dx
        or  si,si
        ja find0A
        xor dx,dx
found0A:
;        or dx,dx
;        je notMove
;        push dx
;        mov cx,-1
;        mov ax,4201h
;        int 21h
;        pop dx
;notMove:
        pop si cx
        add cx,dx
setupBase:
        mov ss:pBaseRead,cx
        add ss:pBaseLo,cx
        adc ss:pBaseHi,0
        clc
exit80:
        pop ds dx bx ax
        ret
        endp
findIdentF proc
        push ax ds
        jcxz readIden
findIdentF0:
        mov ds,baseSeg
findIdentF1:
        lodsw
        cmp al,'.'
        je findVos
        cmp al,0Dh
        jne nextSym
        inc ss:countStr
nextSym:
        dec si
        loop findIdentF1
        pop ds
        push ds
readIden:
        call load80
        jnc findIdentF0
exitId:
        pop ds ax
        ret
        endp
findVos proc
        cmp ah,'!'
        jne nextSym
        dec cx
        dec cx
        clc
        jmp short exitId
findID:
        push ax ds
        jcxz readId
findID0:
        mov ds,baseSeg
findID1:
        lodsw
        cmp al,'.'
        je findVos1
        cmp al,0Dh
        jne nextSym1
        inc ss:countStr
nextSym1:
        dec si
        loop findID1
        pop ds
        push ds
readId:
        call load80
        jnc findID0
error1:
        pop ds ax
        mov al,1        ; непредвиденный конец файла
        ret
exitId1:
        pop ds ax
        ret
        endp
findVos1 proc
        cmp ah,'!'
        je decSi2
        cmp ah,':'
        jne nextSym1
        dec cx
        dec cx
        clc
        jmp short exitId1
decSi2:
        dec si
        dec si
        stc
        jmp short error1
        endp
getType proc
        push ds
        mov ds,baseSeg
        xor dl,dl
skipSpace:
        lodsb
        cmp al,' '
        jne findType
        loop skipSpace
        mov al,2        ; отсутствует тип вируса
        stc
exitId2:
        pop ds
        ret
nextSymType:
        lodsb
findType:
        or  al,' '
        cmp al,'c'
        je setCOM
        cmp al,'e'
        je setEXE
        cmp al,'r'
        je setRES
        cmp al,'m'
        je setMBR
        cmp al,'b'
        je setBOOT
        mov al,dl
noSetMBR:
        dec si
        or al,al
        je typeError
        cmp al,10
        ja typeError
        clc
        jmp exitId2
typeError:
        mov al,3        ; неверный тип вируса
        stc
        jmp exitId2
setCOM:
        or dl,1
        jmp short checkEOL
setEXE:
        or dl,2
        jmp short checkEOL
setRES:
        or dl,4
        jmp short checkEOL
setMBR:
        or dl,8
        jmp short checkEOL
setBOOT:
        or dl,10
checkEOL:
        dec cx
        jnz nextSymType
        jmp short noSetMBR
        endp
getSize proc
        call checkAUTO
        jc nosetAutSize
        push ax
        mov ax,-10
        call checkPlus
        jne setAutSize
        mov ax,-1
setAutSize:
        mov sizeVir,ax
        pop ax
        jmp short sizeOk
nosetAutSize:
        push ax
        mov typeNum,10
        call getWord
        mov sizeVir,ax
        pop ax
        jc sizeError
        cmp word ptr sizeVir,10000
        ja sizeError
sizeOk:
        clc
        ret
sizeError:
        stc
        mov al,4        ; отсутствует или неправильная длина вируса
        ret
        endp
getWord proc
        push word ptr typeNum
        jcxz exitWord0
        mov byte ptr mySign,' '
nextSign:
        push ds
        mov ds,baseSeg
        lodsb
        pop ds
        cmp al,' '
        je nextSign1
        cmp al,'%'
        je setDec
        cmp al,'$'
        je setHex
        cmp al,'-'
        je setSignMu
        cmp al,'+'
        je setSignPl
        cmp al,'.'
        je exitWord1
        cmp al,'0'
        jb nextSign1
        cmp al,'9'
        jbe makeDigit
        cmp typeNum,10   ; dec
        je nextSign1
        and al,0DFh
        cmp al,'A'
        jb exitWord1
        cmp al,'F'
        jbe makeDigit
        jmp short nextSign1
nextSign1:
        loop nextSign
        inc si
exitWord1:
        dec si
exitWord0:
        jmp short exitWord
setDec:
        mov typeNum,10
        jmp short nextSign1
setHex:
        mov typeNum,16
        jmp short nextSign1
setSignMu:
        mov byte ptr mySign,'-'
        jmp short nextSign1
setSignPl:
        mov byte ptr mySign,'+'
        jmp short nextSign1
makeDigit:
        dec si
        xor ax,ax
        xor dh,dh
convert_digit:
        push ds
        mov ds,baseSeg
        mov dl,[si]
        pop ds
        sub dl,'0'
        jc doneWord
        cmp dl,9
        jbe addNum
        cmp typeNum,10
        je doneWord
        and dl,0DFh
        sub dl,7
        jc exitWord
        cmp dl,15
        ja exitWord
addNum:
        push dx
        mov dl,typeNum
        mul dx
        pop dx
        jc exitWord
        add ax,dx
        inc si
        loop convert_digit
        clc
        jmp short exitWord2
exitWord:
        mov al,5        ; требуется число или выражение
        stc
exitWord2:
        pop word ptr typeNum
        ret
doneWord:
        clc
        jmp short exitWord2
        endp
getNameVir proc
        push ax ds
        jcxz nameError
        mov ds,baseSeg
getNameVir1:
        lodsb
        cmp al,'0'
        jae storeNeame
        cmp al,'.'
        je nameError1
        loop getNameVir1
nameError:
        pop ds ax
        mov al,6        ; отсутствует имя вируса
        stc
        ret
nameError1:
        dec si
        dec cx
        jmp nameError
storeNeame:
        lea di,nameVir
        xor dx,dx
charVir:
        stosb
        lodsb
        cmp al,' '
        jbe endCharVir
        cmp al,'.'
        jne noPoint
        cmp byte ptr [si],':'
        je  endCharVir
noPoint:
        inc dx
        cmp dx,20
        ja endCharVir0
        loop charVir
endCharVir0:
        dec dx
        jmp short add0
endCharVir:
        dec si
        dec cx
add0:
        xor al,al
        stosb
        clc
        pop ds ax
        ret
        endp
getSign proc
        call findID
        jc notFoundID
        call getOffSig
        jc notFoundID
        call findID
        jc notFoundID
        call getBytesSig
notFoundID:
        ret
        endp
getOffSig proc
        push ax
        mov typeNum,16
        call getSpecWord
        mov sigOff,ax
        pop ax
        jc outOldErr1
        cmp sigOff,-1
        je outOldErr1
        clc
        ret
outOldErr1:
        stc
        mov al,5
        ret
        endp
getSpecWord proc
        mov word ptr localWord,0
        call getWord
        jc exitSpec2
        cmp byte ptr mySign,'-'
        jne storeNorAX
        neg ax
storeNorAX:
        mov localWord,ax
        mov saveSi,si
        mov saveCx,cx
readMore:
        call getWord
        jc exitSpec0
        cmp byte ptr mySign,' '
        je exitSpec
        cmp byte ptr mySign,'+'
        je addLocal
        neg ax
addLocal:
        add localWord,ax
        mov saveSi,si
        mov saveCx,cx
        jmp short readMore
exitSpec0:
        clc
exitSpec:
        mov si,saveSi
        mov cx,saveCx
        mov ax,localWord
exitSpec2:
        ret
        endp
getBytesSig proc
        push ax
        mov typeNum,10
        call getWord
        mov typeNum,16
        jc badSig0
        lea di,bufSig
        cmp ax,3
        jne getOldSigB
        mov saveAl,al
        mov al,6
        stosb
readNextCS:
        call getWord
        jc badSig0
        stosw
        dec saveAl
        jnz readNextCS
        cmp word ptr [di-6],10
        jb badSig1
        pop ax
        ret
getOldSigB:
        cmp ax,16
        jne scan618
        jmp short getWeb
scan618:
        cmp ax,6
        je sigNormal
        cmp ax,10
        jc badSig1
        cmp ax,15
        jbe sigNormal
        cmp ax,18
        je sigNormal
        mov ax,15
sigNormal:
        mov saveCX,cx
        mov cx,ax
        stosb
        mov saveAl,al
readSig:
        cmp saveAl,6
        jne oldRS
        inc di
        inc di
oldRS:
        cmp saveAl,18
        jne oldReS
        call getWordScx
badSig0:
        jc badSig
        stosw
        dec cx
        dec cx
oldReS:
        call getWordScx
        jc badSig
        or ah,ah
        jne badSig2
        stosb
        loop readSig
        cmp saveAl,6
        jne oldScan
        lea di,bufSig
        mov al,18
        stosb
        mov cl,6
readOff:
        call getWordScx
        jc badSig
        stosw
        inc di
        loop readOff
oldScan:
        mov cx,saveCX
        pop ax
        clc
        ret
badSig:
        pop dx
        ret
badSig1:
        pop dx
        mov al,7        ; мало байт сигнатуры
        ret
badSig2:
        pop dx
        stc
        mov al,9
        ret
        endp
getWeb proc
        stosb
        call read8
        jc badSig
        call read8
        jc badSig
        pop ax
        ret
        endp
read8 proc
        call findID
        jc errorR8
        call getWord
        jc errorR8
        or ah,ah
        jne byteReq
        stosb           ; B1
        call findID
        jc errorR8
        call getSpecWord
        jc errorR8
        stosw           ; Off1
        call findID
        jc errorR8
        call getWord
        jc errorR8
        or ah,ah
        jne byteReq
        stosb           ; len1
        call getWord
        jc errorR8
        stosw           ; csL
        call getWord
        stosw           ; csH
errorR8:
        ret
byteReq:
        mov al,9
        stc
        ret
        endp
getWordScx proc
        push cx
        mov cx,saveCX
        call getSpecWord
        mov saveCX,cx
        pop cx
        ret
        endp
checkFaSt proc
        push ax di
        lea di,tableFaSt
        jmp short scanFaSt
        endp

checkShMoDeFaSt proc
        push ax di
        lea di,tableShMoDeFaSt
scanFaSt:
        call scanTab
        je setupByte
        stc
        pop di ax
        ret
        endp
setupByte proc
        mov ax,es:[di-2]
        pop  di
        or al,al
        je stos1
        cmp al,1
        je stos2
        cmp al,3
        je stos4
exitCheckKey:
        pop ax
        ret
        endp
stos1:
        stosb
        jmp exitCheckKey
stos2:
        stosw
        jmp exitCheckKey
stos4:
        stosw
        xor ax,ax
        stosw
        jmp exitCheckKey

scanTab proc
        push ax cx ds
        mov ds,baseSeg
        xor ch,ch
scanNextKey:
        mov cl,es:[di]
        inc di
        jcxz endScan
        push si
nextBkey:
        lodsb
        or al,20h
        scasb
        loope nextBkey
        pop si
        pushf
        add di,cx
        inc di
        inc di
        popf
        jne scanNextKey
endScan:
        pop ds cx ax
        ret
        endp
        .data
tableShMoDeFaSt db 5,'shift'  ,3,-5
                db 4,'move'   ,3,-4
                db 6,'delete' ,1,-1
tableFaSt       db 4,'fail'   ,0,0
                db 3,'std'    ,1,-3
                db 0
mesErr00        db '0 - неизвестная',0
                dw 0FF01h,mesErr00
                db 0
                dw 0EE01h,mesErr00
mesErr01        db '1 - недостаточно данных для определения вируса',0
                dw 0FF01h,mesErr01
                db 0
                dw 0EE01h,mesErr01
mesErr02        db '2 - отсутствует тип вируса',0
                dw 0FF01h,mesErr02
                db 0
                dw 0EE01h,mesErr02
mesErr03        db '3 - неверный тип вируса',0
                dw 0FF01h,mesErr03
                db 0
                dw 0EE01h,mesErr03
mesErr04        db '4 - отсутствует или неправильная длина вируса',0
                dw 0FF01h,mesErr04
                db 0
                dw 0EE01h,mesErr04
mesErr05        db '5 - требуется число или выражение',0
                dw 0FF01h,mesErr05
                db 0
                dw 0EE01h,mesErr05
mesErr06        db '6 - отсутствует имя вируса, длина не более 20 символов',0
                dw 0FF01h,mesErr06
                db 0
                dw 0EE01h,mesErr06
mesErr07        db '7 - мало байт сигнатуры, требуется число от 10 до 15',0
                dw 0FF01h,mesErr07
                db 0
                dw 0EE01h,mesErr07
mesErr08        db '8 - слишком много байт для восстановления, возможно не более 28',0
                dw 0FF01h,mesErr08
                db 0
                dw 0EE01h,mesErr08
mesErr09        db '9 - требуется число в диапазоне (0-FF)',0
                dw 0FF01h,mesErr09
                db 0
                dw 0EE01h,mesErr09
mesError        db '^ ошибка номер ',0
                db '^ error number ',0
                dw 0EE01h,mesError
countStr        dw ?
tableType       equ $
                dw proc0
                dw procCOM
                dw procEXE
                dw procCE
                dw procRez
                dw procRC
                dw procRE
                dw procRCE
                dw procMbr
                dw procMC
                dw procBOOT
tabMesErr       equ $
                dw mesErr00
                dw mesErr01
                dw mesErr02
                dw mesErr03
                dw mesErr04
                dw mesErr05
                dw mesErr06
                dw mesErr07
                dw mesErr08
                dw mesErr09
handleBase	dw ?
pBaseRead	dw ?
pBaseLo         dw ?
pBaseHi         dw ?

end
