
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Это вобщет-то кодо-эмулятор с вызовами кодо-анализатора.
; Очень медленный. Я его обязательно переделаю.

public  ha,pushReg,setOpt1,checkRange
public  doRead,optim,symExec,bPoint,countExec,viewCode
extrn   runIt1:near,lenPar:near,scanInt:near,countTab:word,offOpt:word
extrn   tabBlock:word,myTitle:word,baseSeg:word,falseSeg:word,dtaSeg:word
extrn   posLo:word,posHi:word,readF:near,cureStd:near,reloIP:word,off3:near
extrn   outASM:near,checkBreak1:near,countBlock:byte,varAs:byte
extrn   countInBl:word,writePalBr:near,typeFile:byte,fillInst:near
extrn   complBlock:near,scanUpB:near,fillEvent:near,varViewOn:byte
extrn   varView:byte,eventReg:near,varAuto:byte,virusSeg:word,envSeg:word
extrn   listChar:word,bufferOut:byte,curPos:byte,check1C:near,tabSkipO:word
extrn   posHiAll:word,posLoAll:word,tabSkip:word,checkSkipC:near
extrn   calcSum:near,newSig:byte,saveSig:byte,scanBlock:near,scanCode:near
        .model small
        .code
viewCode proc
        cmp varViewOn,1
        je noViewIt
        cmp varAuto,2
        je noViewIt
        mov varView,1
        push 2 ptr varAS
        mov varAs,0
        call ha
        cmp countErr,99
        je noViewIt1
        call haFalse
noViewIt1:
        pop 2 ptr varAs
        mov varView,0
noViewIt:
        ret
        endp
haFalse proc
        push ax cx si di ds es
        mov ax,virusSeg
        cmp ax,baseSeg
        je noChFalse
        mov es,ax
        mov cx,4000
        xor di,di
        mov al,-1
        rep scasb
        je noChFalse
        lea si,[di-1]
        mov hand,0
        mov ax,es
        mov baseSeg,ax
        mov cx,ax
        push ss
        pop  es
        lea di,regCS
        stosw
        stosw
        stosw
        mov globalLo,si
        mov globalHi,8000
        mov countExec,1000      ; 800
        mov byte ptr cs:doRead,0C3h
        call setAXDI
        mov ds,cx
        call symExec
noChFalse:
        pop es ds di si cx ax
        mov hand,bx
        ret
        endp
ha proc
        push cx si ds es
        push ss
        pop  es
        call setReg
        call symExec
        cmp byte ptr ss:countErr,50
        je nextVir
        clc
endHa:
        pop es ds si cx
        ret
        endp
nextVir:
        stc
        mov word ptr ss:lenCr,0
        jmp endHa
setAXDI proc
        push ax cx di
        xor ax,ax
        pushf
        pop regFlags
        mov tabSkip,ax
        mov tabSkipO,ax
        lea di,varOpt
        mov cx,offset lenNull
        rep stosb
        lea di,regAX
        xor ax,ax
        stosw           ; ax
        stosw           ; ax
        mov ax,0FFh
        stosw           ; cx
        stosw           ; cx
        mov ax,baseSeg           ;*
        cmp typeFile,1
        jne noChangeDX
        sub ax,myTitle+16h
        sub ax,10h
noChangeDX:
        stosw           ; dx
        stosw           ; dx
        xor ax,ax
        stosw           ; bx
        stosw           ; bx
        mov ax,-2
        stosw           ; sp
        stosw           ; sp
        xor ax,ax
        mov cl,6
        rep stosw
        pop di cx ax
        ret
        endp
setReg proc
        push ax di
        mov hand,bx
        mov countExec,2250      ;2500
        mov byte ptr cs:fillSigN,0C3h
        lea si,tableForRet
        mov al,90h
        cmp varView,0
        jne viewOk
        mov countBlock,40
        mov countInBl,200
        mov countExec,1500
        mov lenCr,0
        mov byte ptr cs:fillSigN,al
        mov al,0C3h
viewOk:
nextProc:
        push ax
        lodsw
        xchg di,ax
        pop ax
        or di,di
        je endMovRet
        mov cs:[di],al
        jmp nextProc
endMovRet:
        mov byte ptr cs:checkRange,8Ch
        mov byte ptr cs:doRead,36h
        mov byte ptr cs:optim,36h
        mov al,0C3h
        mov byte ptr cs:setOpt1,al
        mov byte ptr cs:extent,al
        call setAXDI
        call fillInt
        mov ax,dtaSeg
        mov cx,ax
        mov regES,ax
        mov ax,baseSeg
        mov regCS,ax
        mov regSS,ax
        lds si,dword ptr regIP
        call skipSetIP
        dec bp
        pop di ax
        ret
        endp
fillInt proc
        push ax cx di es
        mov es,falseSeg
        xor ax,ax
        xor di,di
        mov ch,1
fillT:
        stosw
        stosw
        inc ax
        loop fillT
        pop es di cx ax
        ret
        endp
symExec proc
        pushf
        push ax bx cx dx di es
        mov byte ptr ss:countErr,0
nextK:
        call TVK
        jc exitOk1
        lodsb
        xor ah,ah
        mov bx,ax
        mov ah,byte ptr ss:[bx+instrTab]
        or ah,ah
        je setErr1
        shr bx,1
        shr bx,1
        add bx,bx
        push ax
        call word ptr ss:[bx+classLib]
        pop ax
        pushf
        test ah,00001000b
        pop ax
        jz notStoreF
        mov word ptr ss:regFlags,ax
notStoreF:
        cld
        call extent
        call skipBack           ;sk
        dec bp          ; seg & rep prefix
        cmp ss:countErr,0
        je  nextK
exitOk1:
        call skipErr            ;sk
exitOk:
        pop es di dx cx bx ax
        popf
        ret
        endp
setErr1:
        mov 1 ptr ss:countErr,1
        jmp exitOk1
TVK proc
        cmp byte ptr ss:countT,0
        je noTrace
        or bp,bp
        je  noTrace
        dec ss:countT
        jnz noTrace
        mov es,ss:falseSeg
        mov bx,es:4     ;+
        mov ax,es:6
        cmp bx,1
        je  noTrace
        push ax
        mov ax,ss:regFlagT
        call pushReg
        mov ax,ds
        call pushReg
        xchg si,ax
        call pushReg
        pop ax
        call checkJump
noTrace:
checkRange:
        mov ax,ds
        xchg si,ax
        push ss
        pop  ds

        dec countExec
        jz  exitRbad

        cmp si,baseSeg
        jne noSetRegC   ;exitRbad

        call skipRange
bPoint  equ word ptr $+1

        cmp ax,-1
        je  noSetRegC   ;au exitRbad

        clc
        mov es,si
        call doRead
        jc noSetReg     ;sk exitRbad     ;**

        cmp varAs,0
        je noSetReg
        mov regIP,ax
        mov regCS,si
        mov regDS,cx
        call outASM     ;**
        jnc noSetReg
        mov byte ptr countErr,99
noSetRegC:
        stc
noSetReg:

        xchg si,ax
        mov ds,ax
        ret
        endp
exitRbad:
        stc
        ret
extent:
        ret
        dec byte ptr ss:countExt
        jnz noExtent
        mov byte ptr cs:extent,0C3h
noExtent:
        ret

doRead:
        cmp ax,ss:globalHi
        ja  exitRbad
        cmp ax,ss:globalLo
        jb  exitRbad
        push ds bx dx ax cx si
        push ss
        pop  ds
        xchg dx,ax
        mov ax,es       ;m
        cmp ax,baseSeg
        jne endDoR      ;m
        call scanBlock
        xchg dx,ax
        jz endDoR

        cmp si,offset off3
        jb siOkey
        inc countErr
siOkey:
        jnc endDoR

        call scanUpB    ;*
        clc
        jcxz endDoR

        call readBytes
        jc endDoR

        call fillBlock

        cmp varView,0
        clc
        jne endDoR

        call fillSigN

        pop si cx
        cmp si,baseSeg  ;rc
        mov ax,si
        jne readData
        pop  si
        push si
readData:
        push cx ax
        call cureStd

endDoR:
        pop si cx ax dx bx ds
        ret
fillSigN:
        nop
        cmp si,offset tabBlock+2
        je  fillNew
        cmp typeFile,0
        jne noFillN
        cmp si,offset tabBlock+6
        jne noFillN
fillNew:
        mov byte ptr cs:fillSigN,0C3h
        inc saveSig
noFillN:
        ret

readBytes:
        push bx cx
        mov bx,hand
        or bx,bx
        je noSub6
        call setPosAx
        js noSub6
        push ds
        mov ds,baseSeg
        call readF
        pop ds
        jc endRead
        cmp ax,512
        jne noSub6
        sub ax,6
noSub6:
        clc
endRead:
        pop cx bx
        ret

setPosAx:
        push cx ax         ;*
        mov reloIP,ax
        mov [si],ax
        mov dx,posLo
        mov cx,posHi
        add dx,ax
        adc cx,0
        js endReadS
        mov ax,4200h
        int 21h
        or dx,dx
endReadS:
        pop dx cx
        ret

fillBlock:
        push dx
        add dx,ax
        mov [si+2],dx
        inc tabBlock
        pop ax
        cmp ax,11Eh
        ja  noComb
        cmp typeFile,0
        jne noComb
        mov ax,100h
        mov reloIP,ax
noComb:
        call fillInst
        ret

makeES_DI_BX:
        call makeBX
makeES_DI:
        push ax
        mov ah,al
        lodsb
        mov dl,al
        push ax
        and al,11000111b
        cmp al,6
        je noOffset
        and al,11000000b
        cmp al,11000000b
        pop ax
        jz regAdr
        call memAdr
        and al,11000000b
        jz endMake      ; noOffset
        cmp al,01000000b
        jz byteOff
        lodsw
        jmp short endMake0
byteOff:
        lodsb
        cbw
endMake0:
        add di,ax
        jmp short endMake
regAdr:
        and al,7
        shl al,1        ;32
        shl al,1
        call checkAdrB
        xchg di,ax
        push ss
        pop  es
        pop  ax
        ret
noOffset:
        pop ax
        mov es,cx
        cmp si,-1
        je badInstr1
        lodsw			;error !!!
        xchg di,ax

endMake:
        or bp,bp
        jne noPref0
        mov es,ss:regPrefix        ; заменить es
noPref0:
        pop ax                     ; для скорости здесь нужен ret

        test ah,00010000b
        jnz checkWrite

checkRead:
        push ax
        test al,1
        jz noChRead
        cmp di,-1
        je badInstr1
noChRead:
        call checkAdrR          ; чтение из 0-го сегмента
        jc setFalse
        call fixRead            ; чтение из baseSeg
        jc badInstr1
        mov ss:segRead,es
cheRW:
        mov ax,di
        call doRead
readOk:
        pop ax
        ret
setFalseW:
        push ax
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        add ax,di
        call check2113
        pop ax
setFalse:
        add ax,ss:falseSeg
        mov es,ax
        pop ax
        ret
checkWrite:
        push ax
        call skipWrite          ;sk
        cmp di,-1
        je badInstr
        call checkAdrW
        jc setFalseW            ; запись в 0-й сегмент
        call fixWrite
        jnc cheRW               ; запись в baseSeg
badInstr:
        mov byte ptr ss:varOpt,0
badInstr1:
        cmp byte ptr cs:kopRep,90h
        je noSetCX0
        mov 1 ptr cs:kopRep,90h
        mov ss:regCX,0
noSetCX0:
        pop ax
        mov al,ah
        and ax,111b
        dec ax
        jz it1byte
        dec ax
        add si,ax
it1byte:
        pop ax
        push ss:regFlags
        popf
        xor ax,ax
        ret
checkDI_4:
        cmp di,-4
        jbe noSkipDI
        push ax
        jmp badInstr
noSkipDI:
        ret
checkAdrR:
        mov ax,es
        cmp ax,60h
        jae noZerroR
        push ax
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        add ax,di
        cmp ax,601h
        pop ax
        jb  noZerroR
        or ax,ax
        clc
        jne noZerroR
        stc
noZerroR:
        ret
checkAdrW:
        mov ax,es
        cmp ax,60h
        jae noZerroW
        push ax
        or ax,ax
        je checkFalse
        shl ax,1        ; ax=ax*16
        shl ax,1
        shl ax,1
        shl ax,1
        add ax,di
        cmp ax,413h
        jne checkFalse
        or ss:maskHa,1
checkFalse:
        cmp ax,601h
        pop ax
noZerroW:
        ret
fixWrite:
        call fixRead
        jc noStoreW
        cmp ss:regSP,di         
        jb noStoreW0            
        mov ss:segWrite,es
        mov ss:disWrite,di
noStoreW0:
        clc
noStoreW:
        ret
fixRead:
        cmp ax,ss:baseSeg
        je segReadOk
        ja segReadOk2
        cmp ax,ss:envSeg
        jb  segReadBad
        sub ax,ss:baseSeg
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        add di,ax
        jc segReadOk1
        sub di,ax
        clc
        ret
segReadOk2:
        sub ax,ss:baseSeg
        cmp ax,1000h
        jnc segReadBad
segReadOk3:
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        add di,ax
        jnc segReadOk1          ; cf=0
checkOverR:
        sub di,ax
segReadBad:
        cmp di,8000
        cmc
        mov es,ss:virusSeg
segReadOk:
        ret
segReadOk1:
        cmp di,-1
        cmc
        push ds
        pop  es
        ret
checkJump:
        call skipAuto
        cmp ax,60h      ; в ax - сегмент пеpехода
        jae noChJ
        inc bx
        jz jBad1
        dec bx
        cmp ax,bx       ; trace
        jne checkJ1
        and byte ptr ss:regFlagT+1,0FEh
        ret
checkJ1:
        push ax
        jmp short jOk2
noChJ:
        push ax
        sub ax,ss:baseSeg
        je  jOk0
        jc  jBad        ;m
        cmp ax,1000h
        cmc
        jc  jBad
        mov ss:addCS,ax ;ac
jOk2:
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        add bx,ax
jBad:
        pop ax
        jnc jOk
jBad1:
        mov byte ptr ss:varOpt,0
        ret
jOk0:
        pop ax
        mov ds,ax
jOk:
        mov si,bx
        ret
memAdr:
        push ax
        mov es,cx
        mov di,ss:regBX
        and al,7
        jnz checkM1
setRegSI:
        add di,ss:regSI
        pop ax
        ret
checkM1:
        cmp al,1
        jnz checkM7
setRegDI:
        add di,ss:regDI
setRegBX:
        pop ax
        ret
checkM7:
        cmp al,7
        je setRegBX
        xor di,di
        cmp al,4
        je setRegSI
        cmp al,5
        je setRegDI
        mov es,ss:regSS
        mov di,ss:regBP
        cmp al,2
        je setRegSI
        cmp al,3
        je setRegDI
        pop ax
        ret
makeBX:
        push ax
        mov ah,al
        mov al,[si]
        and al,00111000b
        shr al,1
        call checkAdrB
        xchg bx,ax
        pop ax
        ret
makeBXB:
        and al,7
        shl al,1
        shl al,1
        jmp short getByteA
checkAdrB:
        test ah,1
        jnz loByteB
getByteA:
        cmp al,16
        jc loByteB
        cmp ss:countExt,0
        jne loByteB
        sub al,15
loByteB:
        cbw
        add ax,offset regAX
        ret
;---
gr00_03:
gr08_0B:
gr10_13:
gr18_1B:
gr20_23:
gr28_2B:
gr30_33:
gr38_3B:
exec07:
        call makeES_DI_BX
        mov dl,al
        and dx,00111000b        ; 0 8 10
        shr dx,1
        test al,00000010b
        jnz tree0c1
exec80:
        cmp ss:countExt,0
        jne tree0c7
        test al,00000001b
        jnz tree0c2
        mov al,ss:[bx]
exec80b:
        add dx,offset tab00
exec00:
        push ss:regFlags
        popf
        jmp dx
tree0c7:
        call checkDI_4
        mov ax,ss:[bx]
        mov bx,ss:[bx+2]
        shl dx,1
        add dx,offset tab000
        jmp short exec00
tree0c2:
        mov ax,ss:[bx]
exec80w:
        add dx,offset tab01
        jmp short exec00
tree0c1:
        cmp ss:countExt,0
        jne tree0c8
        test al,00000001b
        jnz tree0c3
        mov al,es:[di]
        add dx,offset tab10
        jmp exec00
tree0c3:
        mov ax,es:[di]
        add dx,offset tab11
        jmp exec00
tree0c8:
        call checkDI_4
        mov ax,es:[di]
        mov di,es:[di+2]
        shl dx,1
        add dx,offset tab001
        jmp exec00
exec45:
        mov dl,al
        and dx,00111000b        ; 0 8 10
        shr dx,1
        lea bx,regAX
        cmp ss:countExt,0
        jne tree0c9
        test al,00000001b
        jnz tree0c5
        lodsb
        add dx,offset tab10
        jmp exec00
tree0c5:
        lodsw
        add dx,offset tab11
        jmp exec00
tree0c9:
        lodsw
        xchg di,ax
        lodsw
        xchg di,ax
        shl dx,1
        add dx,offset tab001
        jmp exec00
tab00:
        add es:[di],al  ; 000
        ret
        or  es:[di],al
        ret
        adc es:[di],al
        ret
        sbb es:[di],al
        ret
        and es:[di],al
        ret
        sub es:[di],al
        ret
        xor es:[di],al
        ret
        cmp es:[di],al
        ret
tab01:
        add es:[di],ax  ; 001
        ret
        or  es:[di],ax
        ret
        adc es:[di],ax
        ret
        sbb es:[di],ax
        ret
        and es:[di],ax
        ret
        sub es:[di],ax
        ret
        xor es:[di],ax
        ret
        cmp es:[di],ax
        ret
tab000:
        add es:[di],ax
        adc es:[di+2],bx
        ret
        or  es:[di],ax
        or  es:[di+2],bx
        ret
        adc es:[di],ax
        adc es:[di+2],bx
        ret
        sbb es:[di],ax
        sbb es:[di+2],bx
        ret
        and es:[di],ax
        and es:[di+2],bx
        ret
        sub es:[di],ax
        sbb es:[di+2],bx
        ret
        xor es:[di],ax
        xor es:[di+2],bx
        ret
        sub ax,es:[di]
        sbb bx,es:[di+2]
        ret
tab001:
        add ss:[bx],ax
        adc ss:[bx+2],di
        ret
        or  ss:[bx],ax
        or  ss:[bx+2],di
        ret
        adc ss:[bx],ax
        adc ss:[bx+2],di
        ret
        sbb ss:[bx],ax
        sbb ss:[bx+2],di
        ret
        and ss:[bx],ax
        and ss:[bx+2],di
        ret
        sub ss:[bx],ax
        sbb ss:[bx+2],di
        ret
        xor ss:[bx],ax
        xor ss:[bx+2],di
        ret
        sub ax,ss:[bx]
        sbb di,ss:[bx+2]
        ret
tab10:
        add ss:[bx],al  ; 010
        ret
        or  ss:[bx],al
        ret
        adc ss:[bx],al
        ret
        sbb ss:[bx],al
        ret
        and ss:[bx],al
        ret
        sub ss:[bx],al
        ret
        xor ss:[bx],al
        ret
        cmp ss:[bx],al
        ret
tab11:
        add ss:[bx],ax  ; 011
        ret
        or  ss:[bx],ax
        ret
        adc ss:[bx],ax
        ret
        sbb ss:[bx],ax
        ret
        and ss:[bx],ax
        ret
        sub ss:[bx],ax
        ret
        xor ss:[bx],ax
        ret
        cmp ss:[bx],ax
        ret
gr04_07:
        test al,00000010b
        jnz tree0c4
        jmp exec45
tree0c4:
        test al,00000001b
        jnz tree0c6
        mov ax,ss:regES         ; es
        jmp pushREG
tree0c6:
        call popREG
        mov ss:regES,ax         ; es
        ret
gr0C_0F:
        test al,00000010b
        jnz tree1c4
        jmp exec45
tree1c4:
        test al,00000001b
        jnz tree1c5
        mov ax,ds       ;ss:regCS               ; cs
        add ax,ss:addCS ;ac
        jmp pushREG
tree1c5:
        lodsb
        cmp al,80h
        jc bad0F
        cmp al,8Fh
        ja bad0F
        sub al,10h
        mov bl,al
        lodsw
        jmp treeEc3
bad0F:
        inc ss:countErr         ; cs
        ret
gr14_17:
        test al,00000010b
        jnz tree2c4
        jmp exec45
tree2c4:
        test al,00000001b
        jnz tree2c5
        mov ax,ss:regSS         ; ss
        jmp pushREG
tree2c5:
        call popREG
        ret
gr1C_1F:
        test al,00000010b
        jnz tree3c4
        jmp exec45
tree3c4:
        test al,00000001b
        jnz tree3c5
        mov ax,cx               ; ds
        jmp pushREG
tree3c5:
        call popREG
        mov cx,ax               ; ds
        ret
gr24_27:
        test al,00000010b
        jnz tree4c4
        jmp exec45
tree4c4:
        test al,00000001b
        jnz tree4c5
        mov ax,ss:regES         ; es
        mov ss:regPrefix,ax
        mov bp,1
        ret
tree4c5:
        push ss:regFlags
        popf
        mov ax,ss:regAX
        daa
        mov ss:regAX,ax
        ret
gr2C_2F:
        test al,00000010b
        jnz tree5c4
        jmp exec45
tree5c4:
        test al,00000001b
        jnz tree5c5
        mov ax,ds       ; ss:regCS
        add ax,ss:addCS ;ac
        mov ss:regPrefix,ax     ; cs
        mov bp,1
        ret
tree5c5:
        push ss:regFlags
        popf
        mov ax,ss:regAX
        das
        mov ss:regAX,ax
        ret
gr34_37:
        test al,00000010b
        jnz tree6c4
        jmp exec45
tree6c4:
        test al,00000001b
        jnz tree6c5
        mov ax,ss:regSS
        mov ss:regPrefix,ax
        mov bp,1
        ret
tree6c5:
        push ss:regFlags
        popf
        mov ax,ss:regAX
        aaa
        mov ss:regAX,ax
        ret
gr3C_3F:
        test al,00000010b
        jnz tree7c4
        jmp exec45
tree7c4:
        test al,00000001b
        jnz tree7c5
        mov ss:regPrefix,cx
        mov bp,1
        ret
tree7c5:
        push ss:regFlags
        popf
        mov ax,ss:regAX
        aas
        mov ss:regAX,ax
        ret
grB8_BB:
grBC_BF:
        and ax,00000111b
        shl al,1        ;32
        shl al,1
        add ax,offset regAx
        xchg bx,ax
        lodsw
        mov ss:[bx],ax
        cmp ss:countExt,0
        je tree17_c0
        lodsw
        mov ss:[bx+2],ax
tree17_c0:
        ret
grB0_B3:
grB4_B7:
        call makeBXB
        xchg bx,ax
        lodsb
        mov ss:[bx],al
        cmp ss:countExt,0
        je tree16_c0
        xor ax,ax
        mov ss:[bx+1],al
        mov ss:[bx+2],ax
tree16_c0:
        ret
gr40_43:
gr44_47:
        and ax,00000111b
        shl al,1        ;32
        shl al,1
        xchg bx,ax
        push ss:regFlags
        cmp ss:countExt,0
        jne tree8_c0
        popf
        inc ss:[bx+regAx]
        ret
tree8_c0:
        popf
        inc ss:[bx+regAx]
        jne tree8_c1
        inc ss:[bx+regAx+2]
tree8_c1:
        ret
gr48_4B:
gr4C_4F:
        and ax,00000111b
        shl al,1        ;32
        shl al,1
        xchg bx,ax
        push ss:regFlags
        cmp ss:countExt,0
        jne tree9_c0
tree9_c1:
        popf
        dec ss:[bx+regAx]
        ret
tree9_c0:
        cmp word ptr ss:[bx+regAx],0
        jne tree9_c1
        popf
        dec ss:[bx+regAx]
        dec ss:[bx+regAx+2]
        ret
gr50_53:
gr54_57:
        and ax,00000111b
        shl al,1        ;32
        shl al,1
        xchg bx,ax
        mov ax,ss:[bx+regAx]
        cmp ss:countExt,0
        je treeA_c0
        call pushREG
        mov ax,ss:[bx+regAx+2]
treeA_c0:
        jmp pushReg
gr58_5B:
gr5C_5F:
        and ax,00000111b
        shl al,1        ;32
        shl al,1
        xchg bx,ax
        call popREG
        cmp ss:countExt,0
        je treeB_c0
        mov ss:[bx+regAx+2],ax
        call popREG
treeB_c0:
        mov ss:[bx+regAx],ax
        ret
grE8_EB:
        test al,00000010b
        jnz tree1Dc1
        test al,00000001b
        jnz tree1Dc2
        lea ax,[si+2]
        call pushREG    ; call near
        call skipCall   ;sk
        lodsw
        cmp ax,-1
        je noCall
        add si,ax
noCall:
        ret
tree1Dc2:
        call skipCall   ;sk
        lodsw
        cmp ax,-1
        je noCall
jumpNear1:                ; jmp near
        call skip1bj            ;sk
        mov bx,-1
        or ax,ax
        jns noBackJmp
        jmp setOpt1_      ;*
noBackJmp:
        add si,ax
        ret
tree1Dc1:
        test al,00000001b
        jnz tree1Dc3
        push ds
        pop es
        mov di,si
        jmp jumpFar     ; jmp far
tree1Dc3:
        lodsb           ; jmp short
        cbw
        jmp jumpNear1
grE4_E7:
        xor dh,dh
        mov dl,[si]
        inc si
        jmp short goIO
grEC_EF:
        mov dx,ss:regDX
goIO:
        cmp dx,20h
        je  tree1D_c5
        cmp dx,21h
        je  tree1D_c3
        test al,00000010b
        jnz tree1D_c4           ; out
        test al,00000001b
        jnz tree1D_c1
        not byte ptr ss:regAX   ; in al,dx
tree1D_c3:
        ret
tree1D_c1:
        not ss:regAX
        ret
tree1D_c5:
		mov ss:regAX,0B000h
		ret
tree1D_c4:
        mov byte ptr ss:varOpt,0
        ret
pushREG:
        sub ss:regSP,2
        mov es,ss:regSS
        mov di,ss:regSP
        inc di
        jz badPush
        dec di
        stosw                   ; push reg
        ret
badPush:
        mov byte ptr ss:countErr,1
        ret
popREG:
        mov es,ss:regSS
        mov di,ss:regSP
        inc di
        jz badPush
        dec di
        mov ax,es:[di]
        add ss:regSP,2
        ret
gr70_73:
gr74_77:
gr78_7B:
gr7C_7F:
        mov bl,al
        mov ah,al
        lodsb                    ; jmp if
        cbw
treeEc3:
        call skip0B
        and bx,00001111b
        add bx,bx
        add bx,bx
        add bx,offset tabIF
        push ss:regFlags
        popf
        cld
        jmp bx
tabIF:
        jo  treeEc0
        jmp short treeEc1_
        jno treeEc0
        jmp short treeEc1
        jb  treeEc0
        jmp short treeEc1
        jnb treeEc0
        jmp short treeEc1
        je  treeEc0
        jmp short treeEc1
        jne treeEc0
        jmp short treeEc1
        jbe treeEc0
        jmp short treeEc1
        ja  treeEc0
        jmp short treeEc1
;---
        js  treeEc0
        jmp short treeEc1
        jns treeEc0
        jmp short treeEc1
        jp  treeEc0
        jmp short treeEc1
        jnp treeEc0
        jmp short treeEc1
        jl  treeEc0
        jmp short treeEc1
        jnl treeEc0
        jmp short treeEc1
        jle treeEc0
        jmp short treeEc1
        jg  treeEc0
treeEc1_:
        jmp short treeEc1
treeEc0:
        mov bx,si
setOpt1_:
        add si,ax
        call setOpt1
        or  ax,ax
        je  treeEc2
        jns noIncz
        cmp ss:varOpt,0   ; выполняемый обратный условный переход
        jne runIt
        call checkSkipC
        je  treeEc2
optim:
        inc ss:varOpt
        call skipOptim          ;sk
        mov ss:countTab,1
        mov ss:offOpt,bx
        mov ax,ss:regSP
        mov ss:iniSP,ax
        push ss
        pop  es
        lea di,segRead
        xor ax,ax
        stosw
        stosw
        stosw
        stosw
        ret
treeEc1:                        ; невыполняемый любой условный переход
        mov bx,si
        add bx,ax
        call setOpt1
noIncz:
        cmp ss:varOpt,0   ; выполняемый прямой условный переход
        je treeEc2
        push ss
        pop  es
        push cx
        mov cx,ss:countTab
        lea di,offOpt
        xchg bx,ax
        repne scasw
        pop cx
        je treeEc2
        cmp ss:countTab,100
        jae treeEc2
        inc ss:countTab
        stosw                   ; запомнить невыполняемый адрес
treeEc2:
        ret
runIt:
        cmp ss:offOpt,bx
        jne optim
        cmp bx,-1
        jne noBjmp
        cmp ss:countTab,1
        je treeEc2
noBjmp:
        jmp runIt1
setOpt1:
        pop dx
        or ax,ax
        je endOpt1
        push ss
        pop  es
        push cx
        mov cx,ss:countTab
        lea di,offOpt
        mov ax,si
        push cx di
        repne scasw
        pop di cx
        je  endOpt
        mov ax,bx
        repne scasw
        jne endOpt
        pop cx
addPoint:
        cmp di,offset offOpt+2  ;op
        jne endOpt1             ;op
addPoint1:
        dec ss:countInBl
        jz  outPoint
endOpt1:
        ret
endOpt:
        pop cx
        call regOrSkip
        je addPoint1
        mov ss:countExec,500    ;1000
        mov al,50
        mul byte ptr ss:tabSkipO
        or ah,ah
        je noMaxAl
        mov al,0FFh
noMaxAl:
        mov ss:countBlock,al
        inc ss:varOpt
endOpt3:
        mov byte ptr cs:checkRange,8Ch
        mov byte ptr cs:doRead,36h
        mov byte ptr cs:optim,36h
        mov byte ptr cs:setOpt1,0C3h
        dec ss:reloIP
        je  endOpt1
        push ds ss
        pop  ds
        inc saveSig
        call fillInst
        call cureStd
        pop ds
        jc  endOpt1
        cmp si,ss:reloIP
        je  endOpt1
        push ds ss
        pop ds
        inc saveSig
        mov reloIP,si
        call cureStd
        pop ds
        jmp endOpt1
outPoint:
        call writePalBr
        jc  endScan
        dec ss:countBlock
        jz  endScan
        mov ss:countInBl,200
        ret
endScan:
        inc ss:countErr
        ret
regOrSkip:
        push cx di
        mov cx,ss:tabSkipO
        lea di,tabSkipO+2
        jcxz regAdress
        repne scasw
        je adrFound
regAdress:
        cmp ss:tabSkipO,20
        je adrFound
        or di,di
        inc ss:tabSkipO
        stosw
adrFound:
        pop di cx
        ret
grA0_A3:
        mov es,cx
        or bp,bp
        jne noPref1
        mov es,ss:regPrefix
noPref1:
        push ax
        lodsw
        xchg di,ax
        pop ax
        test al,00000010b
        jnz tree14c1
        call checkRead
        cmp ss:countExt,0
        jne tree14c4
        test al,00000001b
        jnz tree14c2
        mov al,es:[di]          ; mov al,mem8
        mov byte ptr ss:regAx,al
        ret
tree14c2:
        mov ax,es:[di]          ; mov ax,mem16
        mov ss:regAX,ax
        ret
tree14c4:
        call checkDI_4
        mov ax,es:[di]          ; mov ax,mem32
        mov ss:regAX,ax
        mov ax,es:[di+2]
        mov ss:regAX+2,ax
        ret
tree14c1:
        call checkWrite
        cmp ss:countExt,0
        jne tree14c5
        test al,00000001b
        jnz tree14c3
        mov al,byte ptr ss:regAX
        stosb                   ; mov al,mem8
        ret
tree14c3:
        mov ax,ss:regAX
        stosw                   ; mov ax,mem16
        ret
tree14c5:
        call checkDI_4
        mov ax,ss:regAX
        stosw                   ; mov ax,mem32
        mov ax,ss:regAX+2
        stosw
        ret
grA4_A7:
        mov cs:codeRep,al
        mov es,ss:regES         ; movs?
        mov di,ss:regDI
        test al,00000010b
        jnz tree14_c0
        call checkWrite
        call checkCXm
        jmp short tree14_c3
tree14_c0:
        call checkRead          ; cmps?
        call checkCX
tree14_c3:
        mov bx,di
        mov dx,es
        mov es,cx
        or bp,bp
        jne tree14_c1
        mov es,ss:regPrefix
tree14_c1:
        mov di,ss:regSI
        call checkRead
        call checkCX
        mov ax,ss:regAX
        push ds si
        push di es
        pop  ds si
        mov es,dx
        mov di,bx
tree14_c4:
        call runCommand
        mov ss:regAX,ax         ;**
        call moveDI
        call moveSI
        pop si ds
        ret
moveDI:
        pushf
        mov ax,es
        sub ax,ss:regES
        jz moveDI_
        neg ax
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        sub di,ax
        jnc moveDI_
        add di,ax
moveDI_:
        mov ss:regDI,di         ;**
        popf
        ret
moveSI:
        pushf
        mov ax,ds
        sub ax,cx
        jz moveSI_
        neg ax
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        sub si,ax
        jnc moveSI_
        add si,ax
moveSI_:
        mov ss:regSI,si
        popf
        ret
grAC_AF:
        mov cs:codeRep,al
        test al,00000010b
        jnz tree15_c0
        mov es,ss:regES
        mov di,ss:regDI         ; lods?
        jmp tree14_c3
tree15_c0:
        mov es,ss:regES         ; scas?
        mov di,ss:regDI
        call checkRead
tree15_c1:                    ; <- stos?
        call checkCX
        mov ax,ss:regAX
        call runCommand
        jmp moveDI
runCommand:
        push ss:regFlags
        popf
        push cx
        mov cx,ss:regCX
kopRep  equ byte ptr $
        nop
codeRep equ byte ptr $
        lodsb
        mov cs:kopRep,90h
        mov ss:regCX,cx
        pop cx
        ret
checkCX:
        test al,1
        jz  tree15_c2
checkCXm:
        push cx
        mov cx,ss:regCX
        cmp byte ptr cs:kopRep,90h
        jne tree15_c3
        mov cx,2
tree15_c3:
        shl cx,1
        jc  checkCF
        test byte ptr ss:regFlags+1,00000100b
        jz itCLD
        sub cx,di
        cmc
        jmp short checkCF
itCLD:
        add cx,di
checkCF:
        pop cx
        jnc tree15_c2
        pop ax
tree15_c2:
        ret
gr80_83:
        mov bl,[si]
        not bl
        test bl,00111000b
        jnz itNoCMP
        and ah,0EFh             ; cmp
itNoCMP:
        call makeES_DI
        and dx,00111000b        ; 0 8 10
        shr dx,1
        test al,00000010b
        jnz tree10c1
        test al,00000001b
        jz  tree10c3
        lodsw
        jmp exec80w
tree10c1:                       ; 82 & 83
        test al,00000001b
        jnz tree10c2
tree10c3:
        lodsb
        jmp exec80b
tree10c2:
        lodsb
        cbw
        jmp exec80w
gr84_87:
        call makeES_DI_BX
        test al,00000010b
        jnz tree10_c0
        test al,00000001b
        jnz tree10_c1
        mov al,ss:[bx]             ; test r/m,r8
        test es:[di],al
        ret
tree10_c1:
        mov ax,ss:[bx]             ; test r/m,r16
        test es:[di],ax
        ret
tree10_c0:
        cmp ss:countExt,0
        jne tree10_c3
        test al,00000001b
        jnz tree10_c2
        mov al,ss:[bx]             ; xchg r8,r/m
        xchg al,es:[di]
        mov ss:[bx],al
        ret
tree10_c2:
        mov ax,ss:[bx]             ; xchg r16,r/m
        xchg ax,es:[di]
        mov ss:[bx],ax
        ret
tree10_c3:
        call checkDI_4
        call tree10_c2
        mov ax,ss:[bx+2]             ; xchg r16,r/m
        xchg ax,es:[di+2]
        mov ss:[bx+2],ax
        ret
grA8_AB:
        test al,00000010b
        jnz tree15c1
        push ss:regFlags
        test al,00000001b
        jnz tree15c2
        lodsb                   ; test al,im8
        popf
        test al,byte ptr ss:regAX
        ret
tree15c2:
        lodsw
        popf
        test ax,ss:regAX        ; test ax,im16
        ret
tree15c1:
        mov cs:codeRep,al       ; stos?
        mov es,ss:regES
        mov di,ss:regDI
        call checkWrite
        jmp tree15_c1
gr88_8B:
        call makeES_DI_BX
        test al,00000010b
        jnz tree11c1
        test al,00000001b
        jnz tree11c2
        mov al,ss:[bx]          ; mov r/m,r8
        stosb
        ret
tree11c2:
        cmp ss:countExt,0
        jne tree11c4
        mov ax,ss:[bx]          ; mov r/m,r16
        stosw
        ret
tree11c4:
        call checkDI_4
        mov ax,ss:[bx]          ; mov r/m,r32
        stosw
        mov ax,ss:[bx+2]
        stosw
        ret
tree11c1:
        test al,00000001b
        jnz tree11c3
        mov al,es:[di]          ; mov r8,r/m
        mov ss:[bx],al
        ret
tree11c3:
        cmp ss:countExt,0
        jne tree11c5
        mov ax,es:[di]          ; mov r16,r/m
        mov ss:[bx],ax
        ret
tree11c5:
        call checkDI_4
        mov ax,es:[di]          ; mov r32,r/m
        mov ss:[bx],ax
        mov ax,es:[di+2]
        mov ss:[bx+2],ax
        ret
gr8C_8F:
        mov bx,ax
        or al,1
        call makeES_DI
        xchg bx,ax
        test al,00000010b
        jnz tree11_c0
        test al,00000001b
        jnz tree11_c1

        test dl,00100000b
        jnz tree11_c7
        test dl,00010000b
        jnz tree11_c2
        test dl,00001000b
        jnz tree11_c3

        mov ax,ss:regES            ; ES mov r/m,seg
saveSeg:
        stosw
        ret
tree11_c3:
        mov ax,ds                  ; CS
        add ax,ss:addCS ;ac
        jmp saveSeg
tree11_c2:
        test dl,00001000b
        jnz tree11_c4
        mov ax,ss:regSS            ; SS
        jmp saveSeg
tree11_c4:
        mov ax,cx
        jmp saveSeg

tree11_c1:
        xchg dx,ax
        and ax,00111000b
        shr ax,1
        xchg bx,ax                   ; lea r16,mem
        mov ss:[bx+regAX],di
        ret
tree11_c0:
        test al,00000001b
        jnz tree11_c5
        mov ax,es:[di]

        test dl,00100000b
        jnz tree11_c7
        test dl,00010000b
        jnz tree11_c6
        test dl,00001000b
        jnz tree11_c7

        mov ss:regES,ax            ; ES
        ret
tree11_c7:
        inc ss:countErr            ; CS error
        ret
tree11_c6:
        test dl,00001000b
        jnz tree11_c8
        cmp ss:varAuto,0
        je tree11_c9
        sub ax,10h              ;au
        sub ax,ss:dtaSeg
        mov ss:myTitle+0Eh,ax
tree11_c9:
        ret
tree11_c8:
        xchg cx,ax
        ret
tree11_c5:
        push di es
        call popREG
        pop es di
        stosw
        ret
grD0_D3:
        call makeES_DI
        and dx,00111000b
        shr dx,1
        push cx
        mov cl,1
        test al,00000010b
        jz tree1Ac1
        mov cl,byte ptr ss:regCX
        cmp cl,32
        jbe tree1Ac1
        pop cx
        push ss:regFlags
        popf
        ret
tree1Ac1:
        cmp ss:countExt,0
        jne tree1Ac3
        test al,00000001b
        jnz tree1Ac2
        add dx,offset tabD0     ; ShftOp r/m8,cl
        jmp short execD0
tree1Ac2:
        add dx,offset tabD1     ; ShftOp r/m16,cl
execD0:
        push ss:regFlags
        popf
        call dx
        pop cx
        ret
tree1Ac3:
        pop cx
        call checkDI_4
        push cx
        shl dx,1
        add dx,offset tabD2
        jmp execD0
grD4_D7:
        test al,00000010b
        jnz tree1Ac4
        inc si
        cmp byte ptr [si-1],0Ah
        jne tree1Ac0
        test al,00000001b
        mov ax,ss:regAX
        push ss:regFlags
        jnz tree1Ac5
        popf
        aam                     ; aam
        mov ss:regAX,ax
tree1Ac0:
        ret
tree1Ac5:
        popf
        aad                     ; aad
        mov ss:regAX,ax
        ret
tree1Ac4:
        test al,00000001b
        jnz tree1Ac8
        test byte ptr ss:regFlags,1
        mov al,-1
        jnz tree1Ac9
        inc ax
tree1Ac9:
        mov byte ptr ss:regAX,al
        ret
tree1Ac8:
        mov es,cx
        or bp,bp
        jne tree1Ac7
        mov es,ss:regPrefix
tree1Ac7:
        mov bx,ss:regBX
        mov al,byte ptr ss:regAX
        xlat es:[bx]
        mov byte ptr ss:regAX,al
        ret
tabD0:
        rol byte ptr es:[di],cl
        ret
        ror byte ptr es:[di],cl
        ret
        rcl byte ptr es:[di],cl
        ret
        rcr byte ptr es:[di],cl
        ret
        shl byte ptr es:[di],cl
        ret
        shr byte ptr es:[di],cl
        ret
        shl byte ptr es:[di],cl
        ret
        sar byte ptr es:[di],cl
        ret
tabD1:
        rol word ptr es:[di],cl
        ret
        ror word ptr es:[di],cl
        ret
        rcl word ptr es:[di],cl
        ret
        rcr word ptr es:[di],cl
        ret
        shl word ptr es:[di],cl
        ret
        shr word ptr es:[di],cl
        ret
        shl word ptr es:[di],cl
        ret
        sar word ptr es:[di],cl
        ret
tabD2:
        rol word ptr es:[di],cl
        rol word ptr es:[di+2],cl
        ret
        ror word ptr es:[di],cl
        ror word ptr es:[di+2],cl
        ret
        rcl word ptr es:[di],cl
        rcl word ptr es:[di+2],cl
        ret
        rcr word ptr es:[di],cl
        rcr word ptr es:[di+2],cl
        ret
        shl word ptr es:[di],cl
        shl word ptr es:[di+2],cl
        ret
        shr word ptr es:[di],cl
        shr word ptr es:[di+2],cl
        ret
        shl word ptr es:[di],cl
        shl word ptr es:[di+2],cl
        ret
        sar word ptr es:[di],cl
        sar word ptr es:[di+2],cl
        ret
grE0_E3:
        call skip1Bl            ;sk
        push cx
        mov cx,ss:regCX
        test al,00000010b
        jnz tree1Cc1
        test al,00000001b
        jnz tree1Cc2
        push ss:regFlags
        popf
        loopne loopneOk         ; loopne
        jmp short skipLoop1
loopneOk:
        cmp ss:disWrite,0
        je noCheckCX
        cmp cx,20
        ja noCheckCX
        mov al,[si]
        or  al,al
        js  loopneOk1
noCheckCX:
        cld
        mov ss:regCX,cx
        lodsb
        cbw
        pop cx
        jmp treeEc0
loopneOk1:
        cld
        mov ss:regCX,cx
        lodsb
        cbw
        add si,ax
        pop cx
        ret
tree1Cc2:
        push ss:regFlags
        popf
        loope loopneOk1         ; loope
badLoop:
        cld
        lahf
        lodsb
        mov ss:regCX,cx
        test al,80h
        jz skipLoop
        mov byte ptr ss:varOpt,0
skipLoop:
        sahf
        pop cx
        ret
tree1Cc1:
        test al,00000001b
        jnz tree1Cc3
        loop loopneOk           ; loop
skipLoop1:
        cld
        lodsb
        cbw
        mov ss:regCX,cx
        pop cx
        jmp treeEc1
tree1Cc3:
        jcxz loopneOk1          ; jcxz
        lodsb
        cbw
        pop cx
        jmp treeEc1
gr90_93:
gr94_97:
        test al,00000111b
        jnz tree12c0
        ret             ; nop
tree12c0:
        and ax,00000111b
        shl al,1        ;32
        shl al,1
        xchg bx,ax
        mov ax,ss:[bx+regAx]
        xchg ax,ss:regAX           ; xchg ax,reg
        mov ss:[bx+regAx],ax
        cmp ss:countExt,0
        jne tree12c1
        ret
tree12c1:
        mov ax,ss:[bx+regAx+2]
        xchg ax,ss:regAX+2         ; xchg ax,reg
        mov ss:[bx+regAx+2],ax
        ret
gr98_9B:
        test al,00000010b
        jnz tree13c1
        test al,00000001b
        mov ax,ss:regAX         ; cbw
        jnz tree13c2
        cbw
        mov ss:regAX,ax
        ret
tree13c2:
        cwd                     ; cwd
        mov ss:regAX,ax
        mov ss:regDX,dx
tree13c6:                       ; wait
        ret
tree13c1:
        test al,00000001b
        jnz tree13c6
        push ds
        pop es
        mov di,si               ; call far
        lea si,[si+4]
        jmp callFar
gr9C_9F:
        test al,00000010b
        jnz tree13c3
        test al,00000001b
        jnz tree13c4
pushfR:
        mov ax,ss:regFlags
        cmp ss:countT,0
        je  noSetT
        or  ah,1
noSetT:
        jmp pushReg             ; pushf
tree13c4:
        call skip0b             ;sk
        call popReg             ; popf
        mov ss:regFlagT,ax
        test ah,1
        jz clearT
        and ah,0FEh
        mov byte ptr ss:countT,2
clearT:
        and ax,0FFFh
        mov ss:regFlags,ax
        ret
tree13c3:
        test al,00000001b
        jnz tree13c5
        call skip0b             ;sk
        mov al,byte ptr ss:regAX+1    ; sahf
        mov byte ptr ss:regFlags,al
        ret
tree13c5:
        mov al,byte ptr ss:regFlags   ; lahf
        mov byte ptr ss:regAX+1,al
        ret
grC4_C7:
        call makeES_DI
        test al,00000010b
        jnz tree18_c0
        not dl
        test dl,11000000b
        jnz tree18_c4
tree18_c5:
        ret
tree18_c4:
        not dl
        cmp di,-4
        ja tree18_c5
        test al,00000001b
        mov ax,es:[di+2]        ; les, lds r16,mem
        jnz tree18_c1
        mov ss:regES,ax
        jmp short tree18_c2
tree18_c1:
        xchg cx,ax
tree18_c2:
        xchg dx,ax
        and ax,00111000b
        shr ax,1
        xchg bx,ax
        mov ax,es:[di]
        mov ss:[bx+regAX],ax
        ret
tree18_c0:
        push di
        sub di,si
        cmp di,6
        pop di
        jc skipMov
        test al,00000001b
        jnz tree18_c3
        movsb
        ret
tree18_c3:
        cmp ss:countExt,0
        jne tree18_c7
        movsw
        ret                   ; mov mem,im16
tree18_c7:
        call checkDI_4
        movsw
        movsw
        ret
skipMov:
        inc si
        test al,1
        jz tree18_c6
        inc si
tree18_c6:
        ret
grF4_F7:
        test al,00000010b
        jnz tre1Ec0
        test al,00000001b
        jnz tre1Ec1
        jmp check1C              ; hlt
tre1Ec1:
        xor byte ptr ss:regFlags,1 ; cmc
        ret
tre1Ec0:
        mov dl,[si]     ;*
        and dl,00111000b
        jz itTest
        test dl,00100000b
        jnz itTest
        or ah,00010000b
itTest:                 ;*
        call makeES_DI
        test al,00000001b
        jnz tre1Ec2
        mov ax,ss:regAX
        and dl,00111000b
        cmp dl,00001000b
        ja  itNoTestB           ;te
        lodsb
itNoTestB:
        xor dh,dh
        shr dx,1
        add dx,offset tab1Eb
        push ss:regFlags
        popf
        call dx
        pushf
        cmp dx,offset tab1Ebg
        jb noChanRegB
        mov ss:regAX,ax         ; mul
noChanRegB:                     ; not & neg
        popf
error1:
        ret
tre1Ec2:
        mov ax,ss:regAX
        and dl,00111000b
        cmp dl,00001000b
        ja  itNoTestW           ;te
        lodsw
itNoTestW:
        xor bh,bh
        mov bl,dl
        mov dx,ss:regDX
        shr bx,1
        add bx,offset tab1Ew
        push ss:regFlags
        popf
        call bx
        pushf
        cmp bx,offset tab1Ewg
        jb noChanRegW
        mov ss:regAx,ax            ; mul
        mov ss:regDx,dx
noChanRegW:                     ; not & neg
        popf
        ret
tab1Eb:
        test es:[di],al
        ret
        test es:[di],al         ;te
        ret
        not byte ptr es:[di]
        ret
        neg byte ptr es:[di]
        ret
tab1Ebg:
        mul byte ptr es:[di]
        ret
        imul byte ptr es:[di]
        ret
        jmp short checkDivB
        ret
        ret
        push ax
        or ax,ax
        jns checkBd
        neg ax
checkBd:
        mov al,es:[di]
        or al,al
        jns noSignAL
        neg al
noSignAL:
        stc
        rcl ah,1        ;ss
        jc badAH
        cmp al,ah
badAH:
        pop ax
        jbe noIdivB
        idiv byte ptr es:[di]
noIdivB:
        ret
tab1Ew:
        test es:[di],ax
        ret
        test es:[di],ax         ;te
        ret
        not word ptr es:[di]
        ret
        neg word ptr es:[di]
        ret
tab1Ewg:
        mul word ptr es:[di]
        ret
        imul word ptr es:[di]
        ret
        jmp short checkDivW
;        div word ptr es:[di]
        ret
        ret
;        idiv word ptr es:[di]
        push ax dx
        or dx,dx
        jns checkWd
        not dx
        neg ax
        sbb dx,-1
checkWd:
        mov ax,es:[di]
        or ax,ax
        jns noSignAx
        neg ax
noSignAx:
        stc
        rcl dx,1        ;ss
        jc badDX
        cmp ax,dx
badDX:
        pop dx ax
        jbe noIdivW
        idiv word ptr es:[di]
noIdivW:
        ret
checkDivB:
        cmp es:[di],ah
        jbe noDivB
        div byte ptr es:[di]
noDivB:
        ret
checkDivW:
        cmp es:[di],dx
        jbe noDivW
        div word ptr es:[di]
noDivW:
        ret
grF0_F3:
        test al,00000010b
        jnz tree1Ec0
        ret
tree1Ec0:
        mov cs:kopRep,al           ; repe / repne
        ret
grF8_FB:
        test al,00000010b
        jz tree1Fc0
        ret                     ; cli / sti
tree1Fc0:
        test al,00000001b
        jnz tree1Fc1
        and byte ptr ss:regFlags,0FEh      ; clc
        ret
tree1Fc1:
        or byte ptr ss:regFlags,1          ; stc
        ret
grFC_FF:
        test al,00000010b
        jnz tree1F_c0
        test al,00000001b
        push ss:regFlags
        jnz tree1F_c1
        popf
        cld                     ; cld
        ret
tree1F_c1:
        popf
        std                     ; std
        ret
tree1F_c0:
        push ax
        mov al,[si]
        and al,00111000b
        cmp al,00110000b
        jne noPush
        sub ss:regSP,2
noPush:
        cmp al,00001000b
        pop ax
        ja  noInc
        or ah,10h
noInc:
        call makeES_DI
        test al,00000001b
        jnz tree1F_c2
        test dl,00110000b
        jnz tree1F_c3
        test dl,00001000b
        jnz tree1F_c4
        push ss:regFlags
        popf
        inc byte ptr es:[di]    ; inc
        ret
tree1F_c4:
        push ss:regFlags
        popf
        dec byte ptr es:[di]    ; dec
        ret
tree1F_c2:
        test dl,00100000b
        jnz tree1F_c5
        test dl,00010000b
        jnz tree1F_c6
        test dl,00001000b
        jnz tree1F_c7
        push ss:regFlags
        popf
        inc word ptr es:[di]    ; inc
        pushf
        pop ss:regFlags
        ret
tree1F_c3:
        inc ss:countErr
        ret
tree1F_c7:
        push ss:regFlags
        popf
        dec word ptr es:[di]    ; dec
        pushf
        pop ss:regFlags
        ret
tree1F_c6:
        test dl,00001000b
        jnz tree1F_c8
        push di es
        mov ax,si
        call pushReg            ; call near
        pop es di
jumpNear:
        mov ax,si
        sub ax,es:[di]
        neg ax
        jmp jumpNear1
tree1F_c8:
callFar:                        ; call far
        push di es
        mov ax,ds
        call pushREG
        mov ax,si
        call pushReg
        pop es di
        call jumpFar
        jnc tree1F_c10
        add ss:regSP,4
        call fillEvent
tree1F_c10:
        ret
jumpFar:
        mov byte ptr ss:varOpt,0
        call skip0b             ;sk
        cmp di,-4
        ja tree1F_c3
        mov bx,es:[di]
        mov ax,es:[di+2]
        jmp checkJump
tree1F_c5:
        test dl,00010000b
        jnz tree1F_c9
        test dl,00001000b
        jz  jumpNear
        jmp jumpFar
tree1F_c9:
        test dl,00001000b
        jnz tree1F_c3
        add ss:regSP,2
        mov ax,es:[di]          ; push
        jmp pushReg
grC8_CB:
        test al,00000010b
        jnz tree19c0
        mov byte ptr ss:varOpt,0
        test al,00000001b
        jnz tree19c4
        lodsw
        push ax
        mov ax,ss:regBP
        call pushReg
        mov ax,ss:regSP
        mov ss:regBP,ax
        xor ah,ah
        lodsb
        or al,al
        jz tree19c5
        dec ax
        shl ax,1
        sub ss:regSP,ax
        mov ax,ss:regBP
        call pushReg
tree19c5:
        pop ax
        sub ss:regSP,ax
        ret
tree19c4:
        mov ax,ss:regBP
        mov ss:regSP,ax
        call popReg
        mov ss:regBP,ax
        ret
tree19c0:
        call skip0b             ;sk
        push ax
        call popREG
        xchg bx,ax
        call popREG
        xchg dx,ax
        pop ax
        test al,00000001b
        mov al,[si-2]
        jnz tree19c1
        push ax
        lodsw                   ; retf im16
        add ss:regSP,ax
        pop ax
tree19c1:                       ; retf
        cmp dx,ss:baseSeg
        je  tree18c2
        xchg dx,ax
tree19c3:
        call checkJump
        jnc tree19c2
        inc ss:countErr
tree19c2:
        ret
grC0_C3:
        test al,00000010b
        jnz tree18c1
        call makeES_DI
        and dx,00111000b
        shr dx,1
        push cx
        mov cl,[si]
        inc si
        jmp tree1Ac1            ; ShfOp r/m8,imm
tree18c1:
        call skip0b             ;sk
        push ax
        call popREG
        xchg bx,ax
        pop ax
        test al,00000001b
        mov al,[si-2]
        jnz tree18c2
        push ax
        lodsw                   ; ret near im16
        add ss:regSP,ax
        pop ax
tree18c2:                       ; ret near
        and al,11111000b
        cmp al,50h
        je tree18c3
        mov si,bx
        ret
tree18c3:
        xchg bx,ax
        sub ax,si
        jmp jumpNear1
tree19_c2:
        lodsb                   ; int xx
        mov dl,al
        cmp al,5
        jb interCall
        call fillEvent          ;sk
        jmp scanInt
grCC_CF:
        test al,00000010b
        jnz tree19_c0
        test al,00000001b
        jnz tree19_c2
        mov dl,3                ; int3
interCall:
        call skip0b             ;sk
        mov ax,ss:regFlags      ; ???
        cmp ss:countT,0
        je  noSetTf
        or ah,1
noSetTf:
        call pushREG
        mov ax,ds
        call pushREG
        mov ax,si
        call pushREG
        mov es,ss:falseSeg
        xor dh,dh
        shl dx,1
        shl dx,1
        mov di,dx
        call checkDI_4
        mov bx,es:[di]
        mov ax,es:[di+2]
        call checkJump
        cmp ax,ss:baseSeg
        jne goIret
tree19_c1:                      ; into
        ret
tree19_c0:
        test al,00000001b
        jz tree19_c1
goIret:
        call skip0B
        call popREG
        xchg bx,ax
        call popREG
        call tree19c3           ;chJ
        jmp tree13c4
gr60_63:
        test al,00000010b
        jnz treeCc0
        test al,00000001b
        jnz treeCc1
        lea di,regAX            ; pusha
        push cx
        mov cx,8
treeCc2:
        mov ax,ss:[di]
        push di
        call pushReg
        pop di
        add di,4
        loop treeCc2
        pop cx
        ret
treeCc1:
        lea di,regDI            ; popa
        push ss
        pop  es
        push cx
        mov cx,8
        std
treeCc3:
        push di es
        call popReg
        pop es di
        stosw
        scasw           ;32
        loop treeCc3
        pop cx
treeCc0:
treeDc1:
treeDc2:
        ret
gr64_67:
        test al,00000010b
        jnz treeC_c0
        test al,00000001b
        mov ax,ss:regFS
        jnz treeC_c1
        mov ax,ss:regGS
treeC_c1:
        mov ss:regPrefix,ax
        mov bp,1
        ret
treeC_c0:
        test al,00000001b
        jnz treeC_c2
        mov byte ptr ss:countExt,2
        mov byte ptr cs:extent,90h
treeC_c2:
        ret
gr68_6B:
        test al,00000010b
        jnz treeDc0
        test al,00000001b
        jnz treeDc1
        lodsw                   ; push imm16
        cmp ss:countExt,0
        je treeDc3
        call pushReg
        lodsw
treeDc3:
        jmp pushReg
treeDc0:
        test al,00000001b
        jnz treeDc2
        lodsb                   ; push imm8
        cbw
        cmp ss:countExt,0
        je treeDc4
        call pushReg
        xor ax,ax
treeDc4:
        jmp pushReg
gr6C_6F:
        mov dx,ss:regDX
        cmp dx,20h
        jb treeD_c0
        test al,00000010b
        jnz treeD_c1
        inc ss:regDI
        test al,00000001b
        jnz treeD_c1
        inc ss:regDI
treeD_c1:
        ret
treeD_c0:
        inc ss:countErr
grD8_DB:
grDC_DF:
        ret
skipRange:
        nop
        cmp ax,globalHi
        jbe noSkipR
        cmp altIP,0
        jne skipAlt
        mov ax,adrView
        cmp ax,maxView
        stc
        je noSkipR
        push si
        inc adrView
        shl ax,1
        shl ax,1
        xchg si,ax
        mov ax,[si+tabBlock+2]
        pop si
        cmp ax,globalLo
        ja noSkipR
        mov ax,globalLo
        clc
noSkipR:
        ret
skipAlt:
        xor ax,ax
        xchg ax,ss:altIP
        ret
skipSetIP:
        nop
        push ax
        lea si,tabBlock
        lods word ptr ss:[si]
        mov ss:maxView,ax
        mov ax,1
        cmp ss:typeFile,1
        je setIP
        cmp ss:tabBlock,ax
        je setIP
        inc ax
        lea si,[si+4]
setIP:
        mov ss:adrView,ax
        mov si,ss:[si]
        pop ax
        ret
skipOptim:
        nop
        mov byte ptr ss:varOpt,0
        pop ax
noSkipB_:
        ret
skipWrite:
        nop
        mov ax,es
        inc ax
        cmp ax,ss:baseSeg
        jne checkNul
        cmp di,3
        jne noNulSeg
        mov ax,28
        jmp short setEvent
checkNul:
        dec ax
        cmp ax,60h
        jae noNulSeg
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1
        add ax,di
setDecMCB:
        call check2113
noNulSeg:
        pop ax
        jmp badInstr
check2113:
        cmp ax,13h*4
        jne checkE21
        mov ax,90Bh
        jmp short setEvent
checkE21:
        cmp ax,21h*4
        jne noSetEv
        mov ax,80Ah
setEvent:
        call eventReg
        mov al,ah
        call eventReg
noSetEv:
        ret
skipErr:
        nop
        cmp word ptr ss:countExec,0
        je noSkipB_
        cmp byte ptr ss:countErr,99
        je noSkipB_
        mov byte ptr ss:countAlt,1
        call skipBack
        mov byte ptr ss:countErr,0
        mov ds,ss:regCS
        pop ax
        jmp nextK
skipBack:
        nop
        cmp word ptr ss:altIP,0
        je noSkipBack
        dec byte ptr ss:countAlt
        jne noSkipBack
        call fillEvent
        mov ax,ss:altSP
        mov ss:regSP,ax
        xor si,si
        xchg si,ss:altIP
noSkipBack:
        ret
skipCall:
        nop
        lodsw
skipCall1:
        cmp word ptr ss:altIP,0
        jne skip0b
        mov byte ptr ss:countAlt,5
        mov ss:altIP,si
        add si,ax
        mov ax,ss:regSP         ;st
        mov ss:altSP,ax
        jmp short skip0b_       ;sk
skip1Bl:
        nop
        mov ss:regCX,0
skip1Bj:
        nop
        cmp ax,2
        ja skipCall1
        ret
skip0b:
        nop
skip0b_:
        call fillEvent
        pop ax
noSkipB:
        ret
skipAuto proc
        cmp ss:varAuto,0
        je noSkipB
        cmp ax,ss:baseSeg
        je noSkipB
        cmp ss:typeFile,0
        je noSkipB
        push ss
        pop  ds
        mov dx,10h
        sub ax,dx
        sub ax,dtaSeg
        mov myTitle+16h,ax
        mov myTitle+14h,bx
        add ax,myTitle+8
        mul dx
        add ax,bx
        adc dx,0
        cmp dx,posHiAll
        ja errorCure
        jb goodCure
        cmp ax,posLoAll
        jae errorCure
goodCure:
        mov ax,regSP
        mov myTitle+10h,ax
        mov si,100h
errorCure:
        pop ax
        ret
        endp
        .data
public          regIP,regCS,regSS,regDS,regES,regAX,regBX,regCX,regDX
public          regSP,regBP,regSI,regDI,regFlags,countErr
public          saveSS,saveSP,segRead,lenCr,varOpt,maskHa
public          disWrite,segWrite,hand,globalLo,globalHi,iniSP
tableForRet     dw skipRange,skipSetIP,skipOptim,skipWrite,skipErr,skipBack
                dw skipCall,skip1Bl,skip1Bj,skip0b,0
countExec       dw ?
lenCr           dw ?
varOpt          db ?    ; 1
maskHa          db ?    ; 2
countSeg        dw ?    ; 6
countRep        dw ?    ; 8
countErr        db ?    ; 9
countT          db ?    ; 10
countExt        db ?
addCS           dw ?    ;ac
countAlt        db ?            ;sk
altIP           dw ?            ;sk
altSP           dw ?            ;sk
adrView         dw ?            ;sk
maxView         dw ?            ;sk
oldSS           dw ?
oldOffOpt       dw ?
lenNull         equ $-varOpt
regIP           dw ?
regCS           dw ?
regSS           dw ?
regDS           dw ?
regES           dw ?
regFS           dw ?
regGS           dw ?
regPrefix       dw ?
;--- общие регистры
regAX           dw ?,?
regCX           dw ?,?
regDX           dw ?,?
regBX           dw ?,?
regSP           dw ?,?
regBP           dw ?,?
regSI           dw ?,?
regDI           dw ?,?

regFlags        dw ?,?
regFlagT        dw ?
saveSS          dw ?
saveSP          dw ?
segRead         dw ?
disWrite        dw ?
segWrite        dw ?
offIf           dw ?
globalLo        dw ?
globalHi        dw ?
hand            dw ?
iniSP           dw ?
classLib        label word
        dw gr00_03, gr04_07, gr08_0B, gr0C_0F, gr10_13, gr14_17
        dw gr18_1B, gr1C_1F, gr20_23, gr24_27, gr28_2B, gr2C_2F
        dw gr30_33, gr34_37, gr38_3B, gr3C_3F, gr40_43, gr44_47
        dw gr48_4B, gr4C_4F, gr50_53, gr54_57, gr58_5B, gr5C_5F
        dw gr60_63, gr64_67, gr68_6B, gr6C_6F, gr70_73, gr74_77
        dw gr78_7B, gr7C_7F, gr80_83, gr84_87, gr88_8B, gr8C_8F
        dw gr90_93, gr94_97, gr98_9B, gr9C_9F, grA0_A3, grA4_A7
        dw grA8_AB, grAC_AF, grB0_B3, grB4_B7, grB8_BB, grBC_BF
        dw grC0_C3, grC4_C7, grC8_CB, grCC_CF, grD0_D3, grD4_D7
        dw grD8_DB, grDC_DF, grE0_E3, grE4_E7, grE8_EB, grEC_EF
        dw grF0_F3, grF4_F7, grF8_FB, grFC_FF
instrTab label byte
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 11h, 11h
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 11h, 01h
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 11h, 11h
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 11h, 11h
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 01h, 09h
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 01h, 09h
        db 9Ah, 9Ah, 8Ah, 8Ah, 0Ah, 0Bh, 01h, 09h
        db 8Ah, 8Ah, 8Ah, 8Ah, 0Ah, 0Bh, 01h, 09h
        db 09h, 09h, 09h, 09h, 09h, 09h, 09h, 09h
        db 09h, 09h, 09h, 09h, 09h, 09h, 09h, 09h
        db 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
        db 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
        db 01h, 01h, 00h, 82h, 01h, 01h, 01h, 01h
        db 03h, 00h, 02h, 83h, 01h, 01h, 01h, 01h
        db 02h, 02h, 02h, 02h, 02h, 02h, 02h, 02h
        db 02h, 02h, 02h, 02h, 02h, 02h, 02h, 02h
        db 9Bh, 9Ch, 9Bh, 9Bh, 8Ah, 8Ah, 92h, 92h
        db 92h, 92h, 82h, 82h, 92h, 82h, 82h, 92h
        db 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
        db 01h, 01h, 05h, 01h, 01h, 01h, 01h, 01h
        db 02h, 02h, 12h, 12h, 01h, 01h, 09h, 09h
        db 0Ah, 0Bh, 01h, 01h, 01h, 01h, 09h, 09h
        db 02h, 02h, 02h, 02h, 02h, 02h, 02h, 02h
        db 03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
        db 9Bh, 9Bh, 03h, 01h, 82h, 82h, 93h, 94h
        db 04h, 01h, 03h, 01h, 01h, 02h, 01h, 01h
        db 9Ah, 9Ah, 9Ah, 9Ah, 0Ah, 0Ah, 01h, 01h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 02h, 02h, 02h, 02h, 02h, 02h, 02h, 02h
        db 03h, 03h, 05h, 02h, 01h, 01h, 01h, 01h
        db 01h, 01h, 01h, 01h, 01h, 01h, 8Ah, 8Ah
        db 01h, 01h, 01h, 01h, 09h, 09h, 8Ah, 82h
end