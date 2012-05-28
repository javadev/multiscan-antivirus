
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модули проверяет загрузочные сектора.
;

public  boot,checkMbr,mesWasSavedB,getFileName,mesStInBoot,mesStBcured
public  mesBoot,mesBootV,mesMbr,infMbr,curOk,stdMbr,makeCMB
public  scanBoot,readSect,writeSect,mesNoStdBoot,mesSaveFBoot
public  mesStoreBoot,mesRestorBoot,mesBnotFound,mesBchSumErr,mesCmosErr
public  mesMBError,mesSaveCMB
extrn   path:near,printOk:near,print:near,print0D0A1:near
extrn   delString:near,printEng:near,analizErrDisk:near,device:byte
extrn   mesWho:byte,diskType:byte,cxBoot:word,iniSigOff:word
extrn   countE:byte,varKeyOk:byte,varVakcine:byte,varCP:byte,beep:near
extrn   scanSpec:near,pathMs:near,varTSR:byte,writeF:near,countErr:byte
extrn   baseSeg:word,falseSeg:word,globalLo:word,globalHi:word,regIP:word
extrn   ha:near,storeScr:near,outScr:near,tabBlock:word,outCr:near
extrn   fillAsm:near,maskHa:byte,scanChSum:near,dhBoot:byte,sigSeg:word
extrn   fillNameV:near,filesCount:word,infBadCount:word,curDelCount:word
extrn   compareB:near,getSigAx:near,getSigLw:near,printVSig:near,check_1:near
extrn   iniSegDS:near,callProcAx:near,viewCode:near,clearMask:near
extrn   writeRCE:near,readF:near,buf:near,whoB:near,varSaveB:byte
extrn   printPath:near,print0D0A:near,varKeySt:byte,offRe13:word,hand:word
extrn   writeChar:near,virFoundF:byte,calcSum:near,varSS:byte,ssName:near
extrn   varRS:byte,rsName:near,createF:near,openF:near,closeF:near
extrn   getBootWord:near,getBootWord1:near,getBootWord2:near,printNameVir:near
extrn   printNotCure:near,erase:byte,pathIni:byte,who:near,print0D:near
extrn   getBootWord3:near,getBootWord4:near,writeBoot:near
        .model small
        .code
iniBoot proc
        push ax
        mov regIP,7C00h
        mov ax,1E0h
        mov globalLo,ax
        mov tabBlock,1
        mov [tabBlock+2],ax
        mov ax,7E00h
        mov globalHi,ax
        mov [tabBlock+4],ax
        pop ax
        ret
        endp
haBoot proc
        pushf
        push ax bx
        call storeScr   ;*
        call iniBoot    ;*
        call fillAsm    ;*
        mov ax,falseSeg ;*
        mov baseSeg,ax  ;*
        xor ax,ax
        mov maskHa,al            ; haq
        mov hand,ax
        call clearMask
        call ha         ;*
        xchg ax,es:4Eh          ; haq
        or ax,ax
        jne noBoot              ; haq
        or maskHa,1             ; haq
noBoot:                         ; haq
        mov tabBlock,1
        mov [tabBlock+2],7C00h
        xor bx,bx
        call viewCode           ;sk
        call writeRCE
        call outCr      ;*
        call outScr     ;*
        cmp erase,0
        je no0D0A
        call print0D0A1
no0D0A:
        mov erase,0
        pop bx ax
        popf
        ret
        endp
boot proc
        push ax cx dx es
        mov es,falseSeg
        call checkNumber
        jc  noCheckBoot
readMore1:
        mov cx,1
        mov dh,ch
        mov cxBoot,cx
        mov dhBoot,dh
        call readSect
        jc  noCheckBoot
        lea dx,mesBoot
        call printEng
        call checkMbrVirus
        jc  readMore1
        inc filesCount  ;st
        call printOk
        call delString
        clc
noCheckBoot:
        pop es dx cx ax
        ret
        endp
checkHDD proc
        push ax cx dx bp si
        mov si,3
        mov diskType,dl
nextCheck:
        mov dl,diskType
        mov ah,8
        push es
        int 13h
        pop es
        jnc hddOk
        dec si
        jne nextCheck
hddOk:
        pop si bp dx cx ax
        ret
        endp
checkMbr proc
        push ax bx cx dx es
        mov es,falseSeg
        mov cx,4
        mov device,'C'
        mov dx,80h
nextVint:
        call checkHDD           ; пpовеpить наличие 1-го диска
        jc noVint
        push dx
        and dl,11b
        add dl,'1'
        call checkMbrX          ; пpовеpить MBR и Boot
        pop dx
        jc noVint
        inc device
        inc dx
        loop nextVint
noVint:
        pop es dx cx bx ax
        ret
        endp
checkMbrX proc
        push ax bx cx dx
readMore:
        mov cx,1
        mov dh,ch
        mov cxBoot,cx
        mov dhBoot,dh
        call readSect
        jc exitRead
        inc filesCount  ;st
        lea dx,mesMbr
        call printEng
        pop  dx
        push dx
        call writeChar
        call checkMbrVirus
        jc readMore
        call printOk
        call delString
        call readBoot
        jc exitRead
readMoreB:
        call readSect
        jc exitRead
        inc filesCount  ;st
        lea dx,mesBootV
        call printEng
        pop  dx
        push dx
        call writeChar
        call checkMbrVirus
        jc readMoreB
        call printOk
        call delString
        clc
exitRead:
        pop dx cx bx ax
        ret
        endp
readBoot proc
        push ax bx
        mov bx,7C00h+1AEh
        mov cx,4
findStart:
        add bx,16
        mov ax,es:[bx]
        cmp al,80h
        je  foundStart
        loop findStart
        stc
        jmp short badBsec
foundStart:
        mov cx,es:[bx+2]
        mov cxBoot,cx
        mov dhBoot,ah
        mov dh,ah
badBsec:
        pop bx ax
        ret
        endp
readSect proc
        push ax bx cx dx
        mov bx,7C00h
        push cx di
        mov di,bx
        mov cx,100h
        xor ax,ax
        rep stosw
        pop di cx

        mov dl,diskType
readOk:
        mov countE,5
moreRead:
        mov ax,0201h
        int 13h
        jnc noErrRead
        dec countE
        jne moreRead
        call analizErrDisk
        jnc readOk
noErrRead:
        call checkStBoot
        pop dx cx bx ax
        ret
        endp
writeSect proc
        push ax bx cx dx
        mov dl,diskType
        mov bx,7C00h
        cmp word ptr es:[bx+1FEh],0AA55h
        je writeOk
        call printNotCure
        jmp short noErrWrite
writeOk:
        mov countE,5
moreWrite:
        mov ax,0301h
        int 13h
        jnc noErrWrite
        dec countE
        jnz moreWrite
        call analizErrDisk
        jnc writeOk
noErrWrite:
        pop dx cx bx ax
        ret
        endp
curPrim proc
        call readSect
        jc  badSec
        mov cx,cxBoot
        mov dh,dhBoot
        call writeSect
badSec:
        ret
        endp
getSSname proc
        lea dx,ssName
        jmp short getFileName
        endp
getBootNameDX proc
        lea dx,fileNameB
        endp
getFileName proc
        push ax cx si di es
        push ss
        pop  es
        push dx
        lea si,pathMs
        lea di,buf
        mov dx,di
nextChMo:
        lodsb
        stosb
        cmp al,'\'
        jne check0
        mov dx,di
check0:
        or al,al
        jne nextChMo
        pop si
        mov di,dx
        mov cx,7
        rep movsw
        lea dx,buf
        pop es di si cx ax
        ret
        endp
compBoot proc
        push si di
        mov si,dx
        lea si,[si+3Eh]
        mov di,7C3Eh
        mov cx,200h-3Eh
        rep cmpsb
        pop di si
        ret
        endp
saveBoot proc
        cmp varSaveB,0
        je noSaveB
        push ax bx cx dx
        mov varSaveB,0
getNextFile:
        call getBootNameDX
        call openF
        jc saveNow
        mov cx,512
        call readF
        call compBoot
        call closeF
        jne nextFile
        lea dx,mesWasSavedB
        call printEng
        call getBootNameDX
        call printPath
        call print0D0A
        jmp short endSaveB
nextFile:
        lea bx,fileNameB+7
forever:
        inc byte ptr [bx]
        cmp byte ptr [bx],'9'
        jbe getNextFile
        mov byte ptr [bx],'0'
        dec bx
        jmp forever
endSaveB:
        pop dx cx bx ax
noSaveB:
        ret
        endp
saveNow:
        call print0D0A
        lea dx,mesNoStdBoot
        call printEng
        lea dx,mesSaveFBoot
        call whoB
        jc endSaveB
        call getBootNameDX
        call createF
        jc endSaveB
        push ds es
        pop  ds
        mov dx,7C00h
        mov cx,512
        call writeF
        call closeF
        pop ds
        jc endSaveB
        lea dx,mesWasSavedB
        call printEng
        call getBootNameDX
        call printPath
        call print0D0A
        jmp endSaveB

checkMbrVirus proc
        push di
        mov di,7C00h
        call scanBoot
        jc noHaBoot
        call writeBoot
        call saveBoot
        call haBoot
        clc
noHaBoot:
        pop di
        ret
        endp

scanBoot proc
        push ax cx dx si di
        mov varSaveB,1
        mov si,iniSigOff
        push ds
        call iniSegDS
;        mov ds,sigSeg
;** table |add for begin reloc|counter|signature|offset mes|offset call|
checkNextSign:
        mov dx,si
        lodsw           ; gs
        cmp ax,-1
        jne scanBootOld
        lodsw           ; gs
        or ax,ax
        je notCureMbrP
        call check_1
        jmp checkNextSign
scanBootOld:
        cmp al,'b'
        je cmpBoot
skipSig:
        mov al,ah
        cbw
        add si,ax
        jmp checkNextSign
cmpBoot:
        lodsw
        call compareB
        je  endFound1
skipStd:
        mov si,dx
        lodsw
        jmp skipSig
notCureMbrP:
        pop ds
notCureMbr:
        clc
exitMbr:
        pop di si dx cx ax
        ret
        endp
endFound1:
        pop ds
        push dx
        inc virFoundF
        mov varSaveB,0
        mov countErr,1
        call getBootWord
        lea dx,stdMbr
        cmp ax,0FD01h
        je itStdBoot
        lea dx,infMbr
itStdBoot:
        pushf
        call printEng
        call printNameVir
        popf
        pop dx
        jne  whoMbr
        call print0D0A1
        push ds
        mov ds,sigSeg
        jmp skipStd
whoMbr:
        xor ax,ax
        cwd
        call fillNameV
        mov maskHa,0
        inc infBadCount         ;st
        lea dx,mesWho
        call whoB
;notCureMbr0:
        jc  notCureMbr
        xor dh,dh
        call getBootWord
        cmp al,2
        je callProc
        cmp al,4
        je cureOld
        cmp al,8
        je cureMbrBoot
        cmp ax,0F601h
        jne outErrExit
        call cureAuto
        jc outErrExit
        jmp short saveSectNow

cureMbrBoot:
        cmp diskType,80h
        jb cureDisk
        call getBootWord1
        xchg bx,ax
        mov cx,es:[bx+7C00h]            ; set CX
        call getBootWord2
        jmp short no0track

cureDisk:
        call getBootWord3
        xchg bx,ax
        mov cx,es:[bx+7C00h]            ; set CX
        call getBootWord4
        jmp short no0track

cureOld:
        call getBootWord1
        xchg bx,ax
        mov cx,es:[bx+7C00h]            ; set CX
        call getBootWord2

        or ch,ch
        jne no0track
        cmp diskType,80h
        jae cureIt
no0track:
        xchg bx,ax
        mov dh,es:[bx+7C00h]            ; set DH
        jmp short cureIt
callProc:
        call getBootWord1
        mov bx,7C00h
        xor cx,cx
        mov dl,diskType
        call callProcAx
        jnc procCallOk
outErrExit:
        call printNotCure
        jmp notCureMbr
procCallOk:
        cmp cx,1
        jne cureIt
saveSectNow:
        mov cx,cxBoot
        mov dh,dhBoot
        call writeSect
        jmp short checkErr
cureIt:
        call curPrim
checkErr:
        jc outErrExit
        inc curDelCount
        lea dx,curOk
        call printEng
        stc
        jmp exitMbr

cureAuto proc
        push cx dx
        call saveSect
        mov cx,cxBoot
        mov dh,dhBoot
nextReadSec:
        inc cx
        call readSect
        jc nextHead
        call compareSect
        jne nextReadSec
        clc
notFoundSec:
        pop dx cx
        ret
nextHead:
        inc dh
        mov cx,1
        call readSect
        jc notFoundSec
        jmp nextReadSec
        endp
saveSect proc
        push cx si di ds es
        push ds es
        pop  ds es
        mov cx,100h
        mov si,7C00h
        lea di,buf
        rep movsw
        pop es ds di si cx
        ret
        endp
compareSect proc
        push cx si di
        cmp diskType,80h
        jb cureFloppy
        mov cx,40h
        lea si,buf+1BEh
        mov di,7C00h+1BEh
compareS:
        rep cmpsb
        pop di si cx
        ret
cureFloppy:
        mov cx,10h
        lea si,buf+0Bh
        mov di,7C00h+0Bh
        jmp compareS
        endp
checkNumber proc
        push ax bx
        mov bl,device
        sub bl,'A'-1
        push bx
        mov ax,4408h
        int 21h
        pop bx
        or al,al
        stc
        jnz noCheckBoot1
        dec bl
        and bl,1
        mov al,bl
        xor ah,ah
        push ds
        xor bx,bx
        mov ds,bx
        cmp al,ds:504h
        pop ds
        jne setDiskB
        xor al,al
setDiskB:
        mov diskType,al
        clc
noCheckBoot1:
        pop bx ax
        ret
        endp
checkStBoot proc
        jc noCheckStB
        cmp varKeySt,1
        je noCheckStB
        cmp offRe13,-1
        je noCheckStB
        push ax bx
        mov ax,201h
        xor bx,bx
        pushf
        call dword ptr offRe13
        jc dontRead
        call cmpSectors
dontRead:
        clc
        pop bx ax
noCheckStB:
        ret
        endp
cmpSectors proc
        push si di ds
        push es
        pop  ds
        mov si,bx
        mov di,7C00h
        push cx
        mov cx,100h
        cld
        rep cmpsw
        pop cx
        je noOutStV
        pop  ds
        push ds
        push dx
        lea dx,mesStInBoot
        call print0D0A
        call whoB
        pop dx
        jc noOutStV
        mov bx,7C00h
        mov ax,301h
        pushf
        call dword ptr offRe13
        jc noOutStV
        push dx
        lea dx,mesStBcured
        call printEng
        pop  dx
noOutStV:
        pop ds di si
        ret
        endp
readCMB proc
        cmp varRS,1
        jne noReadCMB
        push ax bx cx dx
        lea dx,rsName
        call openF
        lea dx,mesBnotFound
        jc outErrCMB
        call readByteC
        push ax
        call closeF
        pop cx
        lea dx,mesBchSumErr
        jc outErrCMB
        call calcCMB
        jc outErrCMB
        call writeCMOS
        jnc saveCok
        lea dx,mesCmosErr
        call printEng
saveCok:
        call writeMBRBOOT
        lea dx,mesMBError
        jc outErrCMB
        lea dx,mesRestorBoot
outErrCMB:
        call printEng
        lea dx,rsName
        call printPath
        call print0D0A
        pop dx cx bx ax
noReadCMB:
        ret
        endp
readByteC proc
        push cx dx ds
        xor dx,dx
        mov ds,baseSeg
        mov cx,30000
        call readF
        pop ds dx cx
        ret
        endp
writeCMOS proc
        push ax cx dx si ds
        mov ds,baseSeg
        call calcSumBi
        mov si,80h
        cmp ax,[si]
        stc
        jne exitSCm
        cmp dx,[si+2]
        stc
        jne exitSCm
        mov cx,80h-0Ah
        mov si,84h+0Ah
        mov ax,0Ah
nextBytS:
        mov dx,70h
        out dx,al
        inc dx
        push ax
        lodsb
        out dx,al
        pop ax
        inc ax
        loop nextBytS
        clc
exitSCm:
        pop ds si dx cx ax
        ret
        endp
writeMBRBOOT proc
        push ax bx cx dx si es
        mov es,baseSeg
        mov si,84h+80h
        mov cx,1
        mov dx,80h
        mov diskType,dl
        mov device,'C'
        call calcDisk
        jc exitSaveMB
        cmp ax,es:[si]
        stc
        jne exitSaveMB
        cmp dx,es:[si+2]
        stc
        jne exitSaveMB
        add si,4
        call moveTo7C00
        xor dx,dx
        call writeSect
        jc exitSaveMB
        call readBoot
        jc exitSaveMB
        add si,200h
        call moveTo7C00
        call writeSect
exitSaveMB:
        pop es si dx cx bx ax
        ret
        endp
moveTo7C00 proc
        push cx si di ds
        mov cx,100h
        mov di,7C00h
        push es
        pop  ds
        rep movsw
        pop ds di si cx
        ret
        endp
makeCMB proc
        call readCMB
        cmp varSS,1
        je saveCMB
        push bx dx
        call getSSname
        call openF
        call closeF
        pop dx bx
        jnc noSaveCMB
        push dx
        lea dx,mesSaveCMB
        call whoB
        pop dx
        jc noSaveCMB
        push dx
        call getSSname
        call saveCMBDX
        pop dx
noSaveCMB:
        ret
        endp
saveCMB proc
        push dx
        lea dx,ssName
        call saveCMBDX
        pop dx
        ret
        endp
saveCMBDX proc
        push ax bx cx dx di es
        call createF
        jc exitSaB
        mov es,baseSeg
        xor di,di
        call saveTitle
        call calcSumBi
        stosw
        xchg dx,ax
        stosw
        call saveCMOS
        call fill0204
        mov cx,1
        mov dx,80h
        mov diskType,dl
        call calcDisk
        jc errorMbrR
        stosw
        xchg dx,ax
        stosw
        xor dx,dx
        call readSect
        jc errorMbrR
        call moveSectDI
        call readBoot
        jc errorMbrR
        call readSect
        jc errorMbrR

        call moveSectDI
        call calcSumB
        call callWriteF
        jc errorMbrR
        call print0D
        lea dx,mesStoreBoot
        call printEng
        lea dx,ssName
        call printPath
        call print0D0A
errorMbrR:
exitSaveCMB:
        call closeF
exitSaB:
        pop es di dx cx bx ax
        ret
        endp
saveTitle proc
        push ax cx si
        lea si,titleCMB
        mov cx,80h
nextBC:
        lodsb
        stosb
        or al,al
        loopne nextBC
        rep stosb
        pop si cx ax
        ret
        endp
saveCMOS proc
        push ax cx dx
        mov cx,80h
        xor ax,ax
nextByteC:
        mov dx,70h
        out dx,al
        inc dx
        push ax
        in al,dx
        stosb
        pop ax
        inc ax
        loop nextByteC
        pop dx cx ax
        ret
        endp
fill0204 proc
        push ax cx di
        mov cx,204h
        xor ax,ax
        rep stosw
        pop di cx ax
        ret
        endp
moveSectDI proc
        push cx si ds
        push es
        pop  ds
        mov cx,100h
        mov si,7C00h
        rep movsw
        pop ds si cx
        ret
        endp
calcCMB proc
        push ax cx dx si ds
        mov ds,baseSeg
        xor si,si
        sub cx,4
        call calcSum
        mov si,cx
        cmp ax,[si]
        jne endCmp0
        cmp dx,[si+2]
        je endCmp
endCmp0:
        stc
endCmp:
        pop ds si dx cx ax
        ret
        endp
calcSumBi proc
        push cx si ds
        mov ax,0F000h
        mov ds,ax
        mov si,0E000h
        mov cx,1000h
        call calcSum
        pop ds si cx
        ret
        endp
calcDisk proc
        push bx cx
        mov ah,8
        int 13h
        xchg cx,ax
        pop cx bx
        ret
        endp
calcSumB proc
        push ax cx dx si ds
        xor si,si
        push es
        pop  ds
        mov cx,di
        call calcSum
        stosw
        xchg dx,ax
        stosw
        pop ds si dx cx ax
        ret
        endp
callWriteF proc
        push ax cx dx ds
        xor dx,dx
        push es
        pop  ds
        mov cx,di
        call writeF
        pop ds dx cx ax
        ret
        endp
        .data
mesMbr          db 'Проверяю MASTER BOOT RECORD HDD',0
                db 'Is checked up MASTER BOOT RECORD HDD',0
                dw 0EE01h,mesMbr
mesBootV        db 'Проверяю ACTIVE BOOT SECTOR HDD',0
                db 'Is checked up MASTER BOOT RECORD HDD',0
                dw 0EE01h,mesBootV
mesBoot         db 'Проверяю BOOT SECTOR',0
                db 'Is checked up BOOT SECTOR',0
                dw 0EE01h,mesBoot
infMbr          db ' - заражен ',0
                db ' - infected with ',0
                dw 0EE01h,mesBoot
curOk           db ' ИСЦЕЛЕН.',10,0
                db ' CURED.',10,0
                dw 0EE01h,mesBoot
stdMbr          db ' - это стандартный ',0
                db ' - this is standart ',0
                dw 0EE01h,stdMbr
mesNoStdBoot    db 'Этот загрузочный сектор - нестандартный ! ',10,0
                db 'This loading sector - non-standard! ',10,0
                dw 0EE01h,mesNoStdBoot
mesSaveFBoot    db 'Сохранить его в файле',0
                db 'To save him in file',0
                dw 0EE01h,mesSaveFBoot
mesWasSavedB    db ' Сохранен в файле ',0
                db ' Is saved in file ',0
                dw 0EE01h,mesWasSavedB
mesStInBoot     db 9,'Внимание !!! Данный загрузочный сектор маскируется неизвестной'
                db 10,'    резидентной программой. Записать подставляемый сектор',0
                db 9,'Attention !!! This boot sector hided is unknown rezident'
                db 10,9,'       program. Write the boot from memory',0
                dw 0EE01h,mesStInBoot
mesStBcured     db ' ВОССТАНОВЛЕН.',10,0
                db ' IS RESTORED.',10,0
                dw 0EE01h,mesStBcured
mesStoreBoot    db 'CMOS, MBR и BOOT сохранены в файле ',0
                db 'CMOS, MBR & BOOT stored into file ',0
                dw 0EE01h,mesStoreBoot
mesRestorBoot   db 'CMOS, MBR и BOOT восстановлены из файла ',0
                db 'CMOS, MBR & BOOT is restored into file ',0
                dw 0EE01h,mesRestorBoot
mesBnotFound    db 'Файл не найден : ',0
                db 'File not found : ',0
                dw 0EE01h,mesBnotFound
mesBchSumErr    db 'Неверный формат файла ',0
                db 'File is corrupt ',0
                dw 0EE01h,mesBchSumErr
mesCmosErr      db 'Невозможно восстановить CMOS.',10,0
                db 'Imposible restore CMOS.',10,0
                dw 0EE01h,mesCmosErr
mesMBError      db 'Невозможно восстановить MBR и BOOT из ',0
                db 'Imposible restore MBR & BOOT into ',0
                dw 0EE01h,mesMBError
mesSaveCMB      db 'Сохранить CMOS, MBR и BOOT в файле',0
                db 'Store  CMOS, MBR и BOOT into file',0
                dw 0EE01h,mesSaveCMB
titleCMB        db 'MultiScan (c) 1995-97 CMOS, MBR & BOOT data.',13,10,0
fileNameB       db 'boot0000.dat',0
end
