
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Модуль для проверки памяти. Много других функций было добавлено.
; Совсем недавно была исправлена ошибка при работе с win95,os/2.

public  traceMem,checkMCB,infMem,wasCur,mesStrCom,mesProg
public  scanSpec,mesVirMem,scanChSum,scan2sum,mesKillmem,mesBlockOk
public  offRe13,calcSum,scanChSumB
extrn   writeWordInHex:near,writeChar:near,delString:near,print:near
extrn   printOk:near,who:near,print0D0A1:near,printEng:near,beep:near
extrn   color:byte,mesTrace:byte,buf:near,iniSigOff:word
extrn   mesWho:byte,memCurOk:byte
extrn   writeDec:near,oldOff:word,verDos:byte
extrn   beep1:near,outASM:near,regIP:word,regCS:word,regSS:word,regDS:word
extrn   regES:word,regAX:word,varAs:byte,outEnd:near,print0D:near
extrn   varMemF:byte,beep2:near,storeScr:near,outScr:near,segProg:word
extrn   delToEnd:near,fillAsm:near,cursor:byte,varNP:byte,printLen:near
extrn   sigSeg:word,getSigAx:near,getSigLw:near,printVSig:near,check_1:near
extrn   iniSegDS:near,compareM:near,createMem:near,writeMem:near
extrn   closeMem:near,myOff21:word,mySeg21:word,myOff13:word,mySeg13:word
extrn   varViewOn:byte,virusSeg:word,baseSeg:word,clearMask:near,viewCode:near
extrn   writeRce:near,tabBlock:near,globalLo:word,globalHi:word,erase:byte
extrn   myOff1:dword,saveOffSeg:near,varKeyOk:byte,print0D0A:near
extrn   offOfCell:word,segOfCell:word,getMemWord:near,getMemWord1:near
extrn   getMemWord2:near,printNameVir:near,getMemWord12:near,printNotCure:near
extrn   memCellCount:word,memstdCount:word,getMemWord3:near,getMemWord4:near
extrn   memvirCount:word,memnewCount:word,memcureCount:word,memlockCount:word
        .model small
        .code
traceMem proc
        call createMem
checkMem:
        pushf
        push ax bx cx dx si di ds es
        call storeScr
        mov cursor,4
        mov color,7
        lea dx,mesTrace
        call printEng
        mov cs:storeSeg,cs

        lea di,saveOffSeg
        xor ax,ax
        mov ds,ax
        mov bx,21h*4
        call moveVect
        mov bx,13h*4
        call moveVect
        mov bx,4
        call moveVect
        lea ax,int1Entry
        cli
        mov ds:4,ax
        mov ds:6,cs
        push ss
        pop  ds
        mov byte ptr cs:prizT,0

        pushf
        push cs
        lea ax,endTrace21
        push ax

        pushf
        pop ax
        or ah,1
        push ax

        mov ah,62h
        push myOff21+2
        push myOff21
        jmp int1Entry

endTrace21:
        call outEnd
        mov ax,-1
        mov saveOff,ax
        mov offRe13,ax

        pushf
        push cs
        lea ax,endTrace13
        push ax

        pushf
        pop ax
        or ah,1
        push ax

        mov ah,8h
        mov dx,80h
        push myOff13+2
        push myOff13
        jmp int1Entry

endTrace13:
        call outEnd
        mov saveOff,-1

        call outScr
        lds dx,myOff1
        mov ax,2501h
        int 21h
        pop es ds di si dx cx bx ax
        popf
        ret
        endp

enableTrace proc
        pushf
        pop ax
        or ah,1
        push ax
        popf
        ret
        endp

disableTrace proc
        pushf
        pop ax
        and ah,0FEh
        push ax
        popf
        ret
        endp
moveVect proc
        push ax
        les bx,ds:[bx]
        mov ax,es
        push ss
        pop  es
        xchg bx,ax
        stosw
        xchg bx,ax
        stosw
        pop ax
        ret
        endp
visual proc
        push ax di ds es
        mov ds,cs:mySeg
        cmp varAs,0
        je noAsm
        mov regIP,si
        mov regCS,ax
        mov regES,es
        mov regSS,ss
        mov ax,[bp]
        mov regDS,ax
        push ds
        pop es
        lea di,regAX
        mov ax,[bp+8]
        stosw           ; ax
        scasw
        mov ax,cx
        stosw           ; cx
        scasw
        mov ax,dx
        stosw           ; dx
        scasw
        mov ax,bx
        stosw           ; bx
        scasw
        mov ax,sp
        sub ax,22
        stosw           ; sp
        scasw
        mov ax,[bp+6]
        stosw           ; bp
        scasw
        mov ax,[bp+4]
        stosw           ; si
        scasw
        mov ax,di
        stosw           ; di
        scasw
        mov ax,[bp+14]
        stosw           ; flags
        call setSS
        sti
        call outASM
        call setOldSS
noAsm:
        pop es ds di ax
        ret
        endp
storeSeg        dw ?
prizT           db ?
priz1           db 0

int1Entry proc
        cli
        mov cs:priz1,1
        sti
        push ax bp
        mov bp,sp
        mov ax,cs
        cmp ax,[bp+6]
        jnz noCsSeg
        and 1 ptr [bp+9],0FEh
        pop bp ax
        iret
noCsSeg:
        pop bp ax
        push ax bp si di ds
        mov bp,sp
        lds si,4 ptr [bp+10]
        mov ax,ds
        cmp ax,cs:storeSeg
        je getOut
        mov cs:storeSeg,ax

        cmp ax,0F000h
        jne scanVir

        push ax dx
        xchg dx,ax
        call setSS
        mov offRe13,si
        mov segRe13,dx
        call setOldSS
        pop  dx ax

        and byte ptr [bp+15],0FEh

        push di es
        mov di,si
        push ds
        pop  es
        call setSS
        call cureWill
        call setOldSS
        pop  es di
        jmp short exitInt
scanVir:
        call visual
        call scanMem
        call checkBadMem
        jmp short checCommand
getOut:
        call visual
checCommand:
        call checkInt
        jnc enterInt
        call checkBadCommand
exitInt:
        pop ds di si bp ax
        iret
        endp
enterInt:
        pop ds di si bp ax
        pushf
        push cs:segInt
        push cs:offInt
        push bp
        mov bp,sp
        push [bp+0Ch]
        pop  [bp+6  ]
        pop bp
        jmp int1Entry
checkInt proc
        push ax bx
        mov al,[si]
        cmp al,0CFh
        jne noIret
        or 1 ptr [bp+21],1
noIret:
        cmp al,9Dh
        jne noPopF
        or 1 ptr [bp+17],1
noPopF:
        mov bx,3
        cmp al,0CCh
        je setInt3
        cmp al,0CDh
        stc
        jne noIntPres
        mov bl,[si+1]
setInt3:
        shl bx,1
        shl bx,1
        push ds
        xor ax,ax
        mov ds,ax
        mov ax,[bx]
        mov cs:offInt,ax
        mov ax,[bx+2]
        mov cs:segInt,ax
        pop ds
        inc si
        cmp bx,12
        je itInt3
        inc si
itInt3:
        mov [bp+10],si
        clc
noIntPres:
        pop bx ax
        ret
        endp
checkBadMem proc
        push ax bx
        mov ax,cs:storeSeg
        mov bx,si
        shr bx,1
        shr bx,1
        shr bx,1
        shr bx,1
        add bx,ax
        cmp bx,60h
        jb showBadMem
        mov bx,cs
        cmp ax,bx
        jb exitCheckBad
        cmp ax,0A000h
        jae exitCheckBad
showBadMem:
        call badMem
exitCheckBad:
        pop bx ax
        ret
        endp

checkBadCommand proc
        push cx di es
        lea di,tableBadInst
        mov es,cs:mySeg
        xor cx,cx
nextCheckBad:
        add di,cx
        mov cl,es:[di]
        inc di
        jcxz exitCheckBadC
        push cx si di
        cld
        rep cmpsb
        pop di si cx
        jne nextCheckBad
        call writeCom
exitCheckBadC:
        pop es di cx
        ret
        endp

offInt  dw ?
segInt  dw ?

setSS proc near
mySeg   equ word ptr $+1
        mov ax,@data
        mov ds,ax
        pop ax
        mov oldSp,sp
        mov oldSS,ss
        push ds
        pop ss
        lea sp,buf+512
        jmp ax
        endp
setOldSS proc near
        pop ax
        cli
        mov ss,oldSS
        mov sp,oldSP
        jmp ax
        endp
badMem proc
        push ax dx di ds es
        mov dx,ds
        mov di,si
        cmp byte ptr [di],0EAh
        je noVirus
        call setSS
        cmp varMemF,1
        je  memNoBad
        cmp saveOff,-1
        jne memNoBad
        call writeSegOff
        push dx
        lea dx,mesVirMem
        call printEng
        call beep2
        pop dx
        call blocked
memNoBad:
        call setOldSS
noVirus:
        pop es ds di dx ax
        ret
        endp
blocked proc
        push dx
        push word ptr varKeyOk
        mov varKeyOk,0
        inc memvirCount
        inc memnewCount
        lea dx,mesKillmem
        call who
        pop  word ptr varKeyOk
        pop dx
        jc noBlocked
        mov saveOff,di
        mov saveSeg,dx
noBlocked:
        ret
        endp
writeCom proc
        push ax dx di ds es
        mov dx,ds
        mov di,si
        call setSS
        cmp saveOff,-1
        jne noBadCom
        cmp dx,segProg
        je noBadCom
        call writeSegoff
        lea dx,mesStrCom
        call printEng
        call beep1
        mov di,offOfCell
        mov dx,segOfCell
        call blocked
noBadCom:
        call setOldSS
        pop es ds di dx ax
        ret
        endp
writeSegoff proc
        push dx
        mov color,2
        inc memCellCount        ; inc memCount
        call print0D
        call writeWordInHex
        mov dl,':'
        call writeChar
        mov dx,di
        call writeWordInHex
        call delToEnd
        pop dx
        ret
        endp
scanSpec proc
        push ax si
        mov cx,6
checkNext:
        lodsw           ; gs
        push di
        add di,ax
        cmpsb           ; gs
        pop di
        loope checkNext
corrSi:
        pop si ax
        lea si,[si+18]
        ret
        endp
scan2sum proc
        push si
        call scan1sum
        jne notFound
        mov al,2
        call scan1sum
        jne notFound
        mov al,0
notFound:
        pop si
        lea si,[si+16]
        ret
        endp
scan1sum proc
        push ax di
        lodsb
        add di,[si]
        scasb
        jne skipEqu
        dec di
        lodsw
        call scanChSumB
skipEqu:
        pop di ax
        ret
        endp
calcSum proc
        push cx si
        xor ax,ax
        cwd
        jcxz skipCalc
getSum1:
        xor dh,dl
        xor dl,ah
        xor ah,al
        lodsb
        xor al,dh
        loop getSum1
skipCalc:
        pop si cx
        ret
        endp
scanChSumB proc
        push ax dx di
        xor ax,ax
        lodsb
        jmp short sumIt
        endp
scanChSum proc
        push ax dx di
        lodsw           ; gs
sumIt:
        xchg cx,ax
        xor ax,ax
        cwd
        jcxz skipCheck
getSum:
        xor dh,dl
        xor dl,ah
        xor ah,al
        mov al,es:[di]
        inc di
        xor al,dh
        loop getSum
        cmp ax,[si]     ; gs
skipCheck:
        lodsw
        lodsw           ; gs
        jne noEqu
        cmp dx,ax
noEqu:
        pop di dx ax
        ret
        endp
cureWill proc
        cmp saveOff,-1
        je noCureW
        push si ds
        lds si,dword ptr saveOff
        mov byte ptr [si],0EAh
        mov word ptr [si+1],di
        mov word ptr [si+3],es
        pop ds si
        inc memcureCount
        inc memlockCount
        lea dx,mesBlockOk
        call printEng
        mov saveOff,-1
        stc
noCureW:
        ret
        endp
scanMem proc
        push ax bx cx dx si di ds es
        xchg ax,dx
        mov di,si
        call setSS
        mov es,dx
        call cureWill
        mov offOfCell,di
        mov segOfCell,dx
        call writeSegoff
        mov varMemF,0
        mov si,iniSigOff
        push ds
        call iniSegDS
;** table |add for begin reloc|counter|signature|offset mes|word for jmp|
checkNextSign:
        mov dx,si
        lodsw           ; gs
        cmp ax,-1
        jne contOk
        lodsw           ; gs
        or ax,ax
        je endScanMemP
        call check_1
        jmp checkNextSign
contOk:
        cmp al,'r'
        je cmpMem
skipSig:
        mov al,ah
        cbw
        add si,ax
        jmp checkNextSign
cmpMem:
        lodsw
        call compareM
        je  endFound1
signOk:
        mov si,dx
        lodsw
        jmp skipSig
endScanMemP:
        pop ds
        mov dx,es
        call writeMem
        call scanView   ;sc
        call printOk
endScanMem1:
        call setOldSS
        pop es ds di si dx cx bx ax
        ret
        endp

endFound1:
        pop ds
        inc varMemF
        mov segProg,es
        call getMemWord
        cmp ax,0FE03h
        jne noSkipIt
        call skipCell
        jmp endScanMem1

noSkipIt:
        cmp ax,0FD01h
        jne noStdCell
        call printStd
notCureMem:
        push ds
        mov ds,sigSeg
        jmp signOk

noStdCell:
        call whoCure
        jc  notCureMem
        call cureInfCell
        jmp endScanMem1

skipCell:
        push dx
        call getMemWord12
        xchg di,ax
        mov ax,es:[di]
        mov dx,es:[di+2]
        mov es,oldSS
        mov es:[bp+10],ax
        mov es:[bp+12],dx
        pop dx
        ret

printStd proc
        push dx
        inc memstdCount
        lea dx,mesProg
        cmp varNP,1
        je notOutPack
        call printEng
        call printNameVir
        call print0D0A1
notOutPack:
        pop dx
        ret
        endp
whoCure proc
        push dx
        lea dx,wasCur
        call checkE9    ; gs
        je noPrintInf
        lea dx,infMem
noPrintInf:
        pushf
        call printEng
        call printNameVir       ; gs
        popf
        jne checkInf
        call print0D0A1
        stc
        jmp short endWhoCure
checkInf:
        inc memVirCount         ;inc memInfected
        lea dx,mesWho
        sti
        call beep
        call who
endWhoCure:
        pop dx
        ret
        endp
cureInfCell proc
        push dx
        call getMemWord
        cmp ax,0F601h
        je cureAuto
        cmp al,1
        je cureInt
        cmp al,8
        je cureDirVir
        cmp al,2
        je setJMPN
        call printNotCure
        jmp short endCureInf
cureAuto:
        mov saveSeg,es
        mov saveOff,di
        jmp short endCureInf
setJMPN:
        call getMemWord1
        mov byte ptr es:[di],0E9h
printMesCur:
        mov word ptr es:[di+1],ax
outCurOk:
        lea dx,memCurOk
        call printEng
        inc memcureCount
endCureInf:
        pop dx
        ret
        endp
cureInt:
        mov al,ah
        xor ah,ah
        shl ax,1
        shl ax,1
        call getVect
        mov byte ptr es:[di],0EAh
        mov word ptr es:[di+3],dx
        jmp printMesCur

cureDirVir:
        push di
        call getMemWord1
        add di,ax
        call getMemWord2
        stosw
        pop  di
        push di
        call getMemWord3
        add di,ax
        call getMemWord4
        stosw
        pop  di
        jmp outCurOk

checkE9 proc
        push ax di
        cmp al,8
        jne checkTr
; table off mes|len vir|-1|add ins1|ins1|add ins2|ins2|
        call getMemWord1
        add di,ax
        call getMemWord2
        scasw
        jmp short printWar
checkTr:
        call getMemWord1
        cmp byte ptr es:[di],0E9h
        jne checkEA
        cmp word ptr es:[di+1],ax
        je  printWar
checkEA:
        cmp byte ptr es:[di],0EAh
printWar:
        pop di ax
        ret
        endp
getVect proc
        push bx ds
        mov bx,ax
        xor dx,dx
        mov ds,dx
        mov ax,ds:[bx]
        mov dx,ds:[bx+2]
        pop ds bx
        ret
        endp
checkMCB proc
        push ax bx cx dx si di ds es
        mov ah,30h
        int 21h
        mov verDos,al
        cmp al,14h
        je noCheckDrv
        cmp al,4
        sbb si,si
        mov ah,52h                      ;Запрашиваем аддрес DOS List of
        int 21h                         ;List в регистры ES:BX
        push es:[bx-2]
        lds bx,es:[bx]                  ;DS:BX указывает на первый DPB
                                        ;( Drive Parametr Block)
search:
        mov ax,[bx+si+15h]              ;Запрос сегмента драйвера
        les di,dword ptr ds:[bx+si+13h] ;Сохраняем смещение драйвера
                                        ;Адрес оригенального драйвера в ES:DI
        mov di,word ptr es:[di+6]
        push bx si ds
        push ss
        pop  ds
        cmp oldOff,di
        mov oldOff,di
        je notTestOff
        mov si,di
        call scanMem1
notTestOff:
        pop ds si bx
next:
        lds bx,[bx+si+19h]              ;Взять следующий драйвер
        or bx,bx
        je endSearch
        cmp bx,-1                       ;Это последний драйвер?
        jne search                      ;Эсли нет проверить его

endSearch:
        pop  es
noCheckDrv:
        push ss
        pop  ds
comment ~
nextMCB:
        push es
        cmp word ptr es:10h,20CDh
        jne noSmcb
        les si,es:1Ah
        cmp oldOff,si
        mov oldOff,si
        je noSmcb
        mov ax,es
        call scanMem1
noSmcb:
        pop es
        mov ax,es
        add ax,es:3
        inc ax
        mov es,ax
        cmp byte ptr es:0,'M'
        je nextMCB
~
        pop es ds di si dx cx bx ax
        call closeMem
noView:
        ret
        endp
scanView proc
        cmp varViewOn,1
        je noView
        cmp byte ptr es:[di],0EAh
        je noView

        push ax bx cx dx si ds
        push di es
        mov ax,es
        call clearMask
        mov es,virusSeg
        mov baseSeg,es
        mov si,di
        xor di,di
addSeg:
        cmp si,8000
        jbe move0
        sub si,8000
        add ax,8000/16
        jmp addSeg
move0:
        xor si,si
        push ds
        mov ds,ax
        mov cx,4000
        rep movsw
        pop  ds
        push ds
        pop  es
        lea di,tabBlock
        mov ax,1
        stosw
        dec ax
        stosw
        mov globalLo,ax
        mov regIP,ax
        mov ax,8000
        stosw
        mov globalHi,ax
        xor bx,bx
        call viewCode
        call writeRce
        pop dx di
        cmp erase,0
        je noBlock
        mov erase,0
        cmp varMemF,1
        je noBlock
        call print0D0A
        call beep2
        call blocked
noBlock:
        pop ds si dx cx bx ax
        ret
        endp
scanMem1 proc
        call storeScr
        mov regCS,ax
        mov regIP,si
        call fillAsm
        call outAsm
        call scanMem
        call outEnd
        call outScr
        ret
        endp
        .data
tableBadInst    db 3,80h,0FCh,3Dh,3,80h,0FDh,3Dh,3,80h,0FCh,4Bh,3,03Dh,0,4Bh
                db 4,81h,0F9h,0,4Bh,4,81h,0FAh,80h,0,0
infMem          db ' - обнаружен вирус ',0
                db ' - virus found ',0
                dw 0EE01h,infMem
wasCur          db ' - был обезврежен вирус ',0
                db ' - virus was found ',0
                dw 0EE01h,wasCur
mesVirMem       db ' - возможно присутствие Мактивного разидентного вируса'
                db ' !!!',10,0
                db ' - Мactive rezident virus my be present into memory'
                db ' !!!',10,0
                dw 0EE01h,mesVirMem
mesStrCom       db ' - подозрительная команда.',10,0
                db ' - strange command.',10,0
                dw 0EE01h,mesStrCom
mesProg         db ' - загружена программа ',0
                db ' - loaded program ',0
                dw 0EE01h,mesProg
mesKillmem      db ' Заблокировать участок памяти',0
                db ' Blocked memory cell',0
                dw 0EE01h,mesKillmem
mesBlockOk      db 1,13,' ЗАБЛОКИРОВАН.',10,0
                db 1,13,' BLOCKED.',10,0
                dw 0EE01h,mesBlockOk
saveOff         dw -1
saveSeg         dw 0
oldSP           dw 0
oldSS           dw 0
offRe13         dw -1
segRe13         dw -1
end
