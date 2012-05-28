
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; ù‚Æ §®ß†··•¨°´•‡. ë®´Ï≠Æ ≠•§Æ§•´†≠Î© ® · ÆË®°™Æ© (•·´® ¢·• ≠†Á®≠†•‚·Ô ·
; 0-£Æ †§‡•·†)

public  outASM,stopAs,oldCom,lenBuf,lenStr,fillInst
public  storeScr,scrollSt,outScr,redrawAsm,storeOutScr
extrn   regAX:word,regIP:word,regCS:word,videoSeg:word,checkBreak1:near
extrn   varAS:byte,listPoint:near,cursor:byte,localHex:near,bufScr:dword
extrn   varStop:word,pointT:word,varWidth:word,varLeft:word
        .model small
        .code
storeScr proc
        cmp varAs,0
        je noStore
        push cx si di ds es
        mov si,varLeft
        les di,bufScr
        mov ds,videoSeg
        mov cx,24
storeStr:
        push cx si
        mov cx,54
        rep movsw
        pop si cx
        add si,ss:varWidth
        add si,ss:varWidth
        loop storeStr
        pop es ds di si cx
noStore:
        ret
        endp
scrollSt proc
        cmp ss:varAs,0
        je noStore
        push cx si di ds es
        push ss
        pop  ds
        les di,bufScr
        push es
        pop  ds
        lea si,[di+54*2]
        mov cx,23*54
        rep movsw
        mov al,46
        mul byte ptr ss:varWidth
        xchg si,ax
        add si,ss:varLeft
        mov ds,ss:videoSeg
        mov cx,54
        rep movsw
        pop es ds di si cx
        ret
        endp
outScr proc
        cmp varAs,0
        je noStore
        push cx si di ds es
        lds si,bufScr
        mov di,ss:varLeft
        mov es,ss:videoSeg
        mov cx,24
outItStr:
        push cx di
        mov cx,54
        rep movsw
        pop di cx
        add di,ss:varWidth
        add di,ss:varWidth
        loop outItStr
        pop es ds di si cx
        ret
        endp
redrawAsm proc
        call outScr
        call outAsmWin
        ret
        endp
storeOutScr proc
        call storeScr
        call outAsmWin
        ret
        endp
stop0 proc
        push ax bx cx dx
        xchg ax,bx
        xor ah,ah
        int 1Ah
        add bx,dx
        mov varStop,bx
popStop:
        pop dx cx bx ax
        ret
        endp
stop1 proc
        push ax bx cx dx
        mov bx,varStop
wait1:
        xor ah,ah
        int 1Ah
        call checkBreak1
        jc popStop
        cmp dx,bx
        jb  wait1
        jmp popStop
        endp
outLine proc
        lodsb
        stosw
        loop outLine
        ret
        endp
fillDec proc
        aam
        xchg al,ah
        or ax,'00'
        cmp al,'0'
        jne noSetSp
        mov al,' '
noSetSp:
        stosw
skipOutAs:
        ret
        endp
outAsmWin proc
        cmp varAs,0
        je skipOutAs
        push ax cx dx si di es
        mov ax,stopAs
        lea di,count
        call fillDec
        mov ax,videoSeg
        mov es,ax
        lea si,outBuf
        xor dx,dx
        mov cx,lenStr           ; ™Æ´-¢Æ ´®≠®©
        add cx,5
        mov di,varLeft
outField:
        push cx di
        mov cl,54
        mov ah,7
        cmp dl,cursor
        jne outStr
        lodsb
        stosw
        push ax
        mov ah,70h
        mov cx,offset lenBuf
        call outLine
        pop ax
        mov cl,5
outStr:
        lodsb
        cmp al,4
        ja oldCol
        push ax cx         ; ah
        mov cl,al
        cmp al,1
        mov al,'='
        je outEqu
        mov al,' '
outEqu:
        stosw   ; ' '
        mov ah,0Fh
        call outLine
        pop cx ax
        sub cl,al
        dec cx
        jmp outStr
oldCol:
        stosw
        loop outStr
        pop di cx
        add di,ss:varWidth
        add di,ss:varWidth
        inc dx
        loop outField

        lea si,lastL
        mov cx,offset lenLine
        call outLine
        pop es di si dx cx ax
        ret
        endp
outPic proc
        push ax
        mov ax,stopAs
        call stop0
        call outAsmWin
        call stop1
        pop ax
        ret
        endp
getPoint proc
        push ax cx si di
        mov ax,regIP
        lea di,listPoint
        mov cx,lenStr           ; ®È•¨ ™Æ¨†≠§„
        push di
findCom:                ;*
        scasw
        je fixAdres
        inc di
        loop findCom    ;*
        pop di
        dec ax
        mov cx,lenStr           ; ®È•¨ Ø‡•‰®™·
findPref:
        scasw
        je checkF
        inc di
        loop findPref
        jmp short reRead
checkF:
        mov al,1
        scasb
        clc
        je skipCom
reRead:
        mov al,cursor
        mov ah,54
        mul ah
        lea si,outBuf+1
        add si,ax
        lea di,oldCom
        mov cx,offset lenBuf
        rep movsb
        stc
skipCom:
        inc ax
endGetP:
        pop di si cx ax
        ret
        endp
fixAdres proc
        pop di
        xchg ax,cx
        sub al,byte ptr lenStr
        neg al
        add al,5
        mov cursor,al
        xor ax,ax
        jmp endGetP
        endp
fillHex1_ proc
        lodsw
        inc si
        inc si
        jmp short fillHe
        endp
fillHex1 proc
        lodsw
        endp
fillHe:
        push si di
        lea di,localHex
        mov si,di
        call fillHex
        pop  di
        push di
        push si
        cmpsw
        jne chCol
        cmpsw
        jne chCol
        pop si di
        mov byte ptr [di-1],20h
transReg:
        movsw
        movsw
        pop si
        ret
chCol proc
        pop si di
        mov byte ptr [di-1],4
        jmp transReg
setFreg:
        push ax
        mov al,'0'
        je fillFlag
        mov al,'1'
fillFlag:
        cmp [di],al
        je noSetFl
        mov [di],al
        mov byte ptr [di-1],1
        jmp short addDI
noSetFl:
        mov byte ptr [di-1],'='
addDI:
        add di,54
        pop ax
        ret
        endp
fillReg proc
        push ax si di
        lea si,regAX
        lea di,pAX
;        lodsw
        call fillHex1_   ; AX
        lea di,pCX
;        lodsw
        call fillHex1_   ; CX
        lea di,pDX
;        lodsw
        call fillHex1_   ; DX
        lea di,pBX
;        lodsw
        call fillHex1_   ; BX
        lea di,pSP
;        lodsw
        call fillHex1_   ; SP
        lea di,pBP
;        lodsw
        call fillHex1_   ; BP
        lea di,pSI
;        lodsw
        call fillHex1_   ; SI
        lea di,pDI
;        lodsw
        call fillHex1_   ; DI
        lodsw
        lea di,pOF
        test ax,0000100000000000b
        call setFreg            ; OF
        test ax,0000010000000000b
        call setFreg            ; DF
        test ax,0000001000000000b
        call setFreg            ; IF
        test ax,0000000100000000b
        call setFreg            ; TF
        test al,10000000b
        call setFreg            ; SF
        test al,01000000b
        call setFreg            ; ZF
        test al,00010000b
        call setFreg            ; AF
        test al,00000100b
        call setFreg            ; PF
        test al,00000001b
        call setFreg            ; CF
        lea si,regCS
        lea di,pCS
        call fillHex1   ; CS
        lea di,pSS
        call fillHex1   ; SS
        lea di,pDS
        call fillHex1   ; DS
        lea di,pES
        call fillHex1   ; ES
        pop di si ax
noAsm0:
        ret
        endp
fillInst proc
        cmp varAs,0
        je noAsm0
fillInst1:
        push ax bx cx dx si di es
        push ss
        pop  es
        push regIP1
        mov pointB,offset outCom        ; ®≠®Ê®®‡Æ¢†‚Ï „™†ß†‚•´®
        mov pointT,offset listPoint
        mov cx,18               ; ß†ØÆ´≠Ô•¨ °„‰•‡
nextCell:
        push cx
nextCom:
        push ds
        lds si,dword ptr regIP1
        lea di,RK
        push si
        movsw
        movsw
        movsw
        call clearF
        pop ax
        pop ds
        call fillHEX
        mov al,RK
        inc di
        call fillHexB
        push ax
        xor ah,ah
        shl ax,1
        shl ax,1
        lea si,tableD
        add si,ax
        lodsw
        push si
        xchg ax,si
        lea di,oper1
        cmp byte ptr [si],0
        jne oldTab
        inc si
        mov al,RK+1
        shr al,1
        and ax,11100b
        add si,ax
oldTab:
        movsw
        movsw
        pop bx ax
        lea di,oper2
        mov ah,al
        call word ptr [bx]
        add regIP1,cx
        xor al,al       ; V
        cmp kopPref,0   ; cx=cx
        je noSdvig
        dec dx
        jz nextCom
        mov al,kopPref
        cmp dl,1
        je sdvigOk
        call restPr     ; cx=1
        jmp short noSdvig
sdvigOk:
        call sdvig      ; cx=cx+1
noSdvig:
        call fillTab
        call shiftBuf
        pop cx
        loop nextCell
        pop regIP1
        pop es di si dx cx bx ax
noASM:
        ret
        endp
outASM proc
        cmp varAS,0
        je noASM
        push ax
        push ds
        pop  es
        call fillREG
        call getPoint
        je outPoint
        jnc skipPoint
        mov ax,regIP            ; Ø•‡•≠•·‚® ‡•£®·‚‡Î CS:IP
        mov regIP1,ax
        mov ax,regCS
        mov regCS1,ax
        call fillInst1
        mov byte ptr cursor,5
outPoint:
        call outPic
skipPoint:
        pop ax
        ret
        endp
clearF proc
        push ax di
        mov cx,offset lenBuf
        mov al,' '
        rep stosb
        inc cx
        pop di ax
        ret
        endp
restPr proc
        sub regIP1,cx
        push ax
        lea di,adrIp
        call clearF
        mov ax,offPref
        call fillHex
        inc di
        pop ax
        call fillHexb
        lea di,oper1
        call outPre
        mov kopPref,dh
        mov cl,1
        cwd
        xor al,al       ; V
        ret
        endp
sdvig:
        push ax
        lea di,adrIp
        mov ax,offPref
        call fillHex
        pop ax
        inc di
        call fillHexb
        lea si,RK
        push cx
moreSd:
        lodsb
        call fillHexb
        loop moreSd
        pop cx
        inc cx
        mov kopPref,dh
        mov al,1        ; V
        ret
fillTab proc
        push di ax
        mov ax,regIP1
        sub ax,cx
        mov di,pointT
        stosw
        pop ax
        stosb
        mov pointT,di
        pop di
        ret
        endp
shiftBuf proc
        push cx si di
        lea si,adrIP
        mov di,pointB
        mov cx,offset lenBuf
        rep movsb
        lea di,[di+6]
        mov pointB,di
        pop di si cx
        ret
        endp
fill23 proc
        inc cx
        inc cx
        push di
        mov ax,word ptr RK+1
        lea di,byte2
comp23:
        call fillHEXb
        xchg ah,al
        call fillHEXb
        xchg ah,al
        pop di
        ret
        endp
fill34 proc
        inc cx
        inc cx
        push di
        mov ax,word ptr RK+2
        lea di,byte3
        jmp comp23
        endp
fill45 proc
        inc cx
        inc cx
        push di
        mov ax,word ptr RK+3
        lea di,byte4
        jmp comp23
        endp
fill56 proc
        inc cx
        inc cx
        push di
        mov ax,word ptr RK+4
        lea di,byte5
        jmp comp23
        endp
fill2 proc
        inc cx
        push di
        mov al,RK+1
        lea di,byte2
comp2:
        call fillHEXb
        pop di
        ret
        endp
fill3 proc
        inc cx
        push di
        mov al,RK+2
        lea di,byte3
        jmp comp2
        endp
fill4 proc
        inc cx
        push di
        mov al,RK+3
        lea di,byte4
        jmp comp2
        endp
fill5 proc
        inc cx
        push di
        mov al,RK+4
        lea di,byte5
        jmp comp2
        endp
prREG1 proc
        mov ah,1
        mov al,RK+1
        not al
        and al,11000000b
        jnz prRegD
        jmp outDbs
        endp
prREG proc
        test al,2
        je normalOut
prRegD:
        call fill2
        call fillBX
        push ax
        mov al,','
        stosb
        pop ax
        call fillDI
        ret
        endp
normalOut:
        call fill2
        call fillDI
        push ax
        mov al,','
        stosb
        pop ax
        call fillBX
        ret
prDI proc
        call fill2
        call fillDI
        ret
        endp
prXX:
        push ax
        mov ah,1
prXX1:
        shl al,1
        jmp short outXX
fillBX:
        push ax
        shr al,1
        shr al,1
outXX:
        push si
        and al,00001110b
        lea si,tableRb
        test ah,1
        jz regB
        lea si,tableR
regB:
        xor ah,ah
        add si,ax
        movsw
        pop si ax
        ret

fillDI proc                 ; ß†ØÆ¨≠®‚Ï Øp•‰®™·, RK+1, RK+2, RK+3
        push ax
        test al,10000000b
        jnz check11
        call outPreS
        test al,01000000b
        jnz it1
        and al,7
        cmp al,6
        jne indexReg
        mov al,'['
        stosb
        call fill34
        call fillHEX
        mov al,']'
        stosb
        pop ax
        ret
        endp
indexReg proc
        push si
        lea si,tableI
        and ax,7
        xchg ah,al
        aad
        shr ax,1
        add si,ax
        cmp al,20
        mov al,'['
        stosb
        movsw
        jae endMov
        movsw
        movsb
endMov:
        mov al,']'
        stosb
        pop si ax
        ret
        endp
itREG:
        jmp prXX1

check11 proc
        test al,01000000b
        jnz itREG
        call outPreS
        call fill34
        xchg ax,bx
        pop ax
        push ax
        and ax,7
        xchg ah,al
        push si
        lea si,tableI
        aad
        shr ax,1
        add si,ax
        cmp al,20
        mov al,'['
        stosb
        movsw
        jae endMov1
        movsw
        movsb
endMov1:
        mov al,'+'
        stosb
        xchg ax,bx
        call fillHex
        mov al,']'
        stosb
        pop si ax
        ret
it1:
        call fill3
        xchg ax,bx
        pop ax
        push ax
        and ax,7
        xchg ah,al
        push si
        lea si,tableI
        aad
        shr ax,1
        add si,ax
        cmp al,20
        mov al,'['
        stosb
        movsw
        jae endMov2
        movsw
        movsb
endMov2:
        mov al,'+'
        test bl,80h
        jz oldOff
        mov al,'-'
        neg bl
oldOff:
        stosb
        xchg ax,bx
        call fillHexb
        mov al,']'
        stosb
        pop si ax
        ret
        endp
outPreS proc
        cmp byte ptr kopPref,70h
        jb outPre
        ret
        endp

outPreR proc
        cmp byte ptr kopPref,70h
        ja outPre
        ret
        endp
outPre:
        cmp kopPref,0
        je noPref
        push ax si
        mov al,kopPref
        push ax
        xor ah,ah
        shl ax,1
        shl ax,1
        add ax,offset tableD
        xchg ax,si
        lodsw
        xchg ax,si
        movsw
        movsb
        pop ax
        cmp al,0F2h
        jne noNz
        mov ax,'EN'
        stosw
noNz:
        pop si ax
        mov dx,2
noPref:
        ret
fillByteC proc
        push ax
        shr ax,cl
        and al,0Fh
        or al,'0'
        cmp al,'9'
        jbe fillC
        add al,7
fillC:
        stosb
        pop ax
        ret
        endp
outDb:
        mov al,RK
        jmp short fillHEXb
fillHEX proc
        push cx      ; 1111000011110000b
        mov cl,12    ;  ¿ƒ
        call fillByteC
        mov cl,8
        call fillByteC
        pop cx
        endp
fillHexB proc
        push cx
        mov cl,4
        call fillByteC
        xor cl,cl
        call fillByteC
        pop cx
        ret
        endp
prAL proc
        mov ax,'LA'
        stosw
        mov al,','
        stosb
        call fill2
        call fillHexB
        jmp outRem
        endp
prAX proc
        mov ax,'XA'
        stosw
        mov al,','
        stosb
        call fill23
        call fillHex
        ret
        endp
prSEG proc
        cmp al,40h
        jb oldPrS
        shl al,1
        and al,10b
        lea si,tableS+8
        jmp short outSeg
oldPrS:
        shr al,1
        shr al,1
        and ax,110b
        lea si,tableS
outSeg:
        add si,ax
        movsw
        ret
        endp
outBW proc
        push ax
        not al
        test al,11000000b
        jz itRegBW
        not al
        test ah,1
        jnz outWW
        mov ax,'/B'
        jmp short itRegBW0
        endp
outWW:
        mov ax,'/W'
itRegBW0:
        stosw
itRegBW:
        pop ax
        ret
prA:
        mov byte ptr operX,'A'
        ret
prE:
        mov byte ptr operX,'E'
        ret
prF:
        mov byte ptr operX,'F'
        ret
prR:
        mov byte ptr operX,'R'
        ret
out23:
        call fill23
out23p:
        call fillHex
        ret
out2:
        call fill2
        call fillHexB
        ret
out2p:
        call fill2
        cbw
        jmp out23p
prJmp:
        call fill2
        cbw
        mov bx,regIP1
        inc bx
        inc bx
goJmp:
        add bx,ax
        cmp bx,regIP1
;        test ah,80h
        mov al,''
        ja setJmpd
        mov al,''
setJmpd:
        mov remark,al
        xchg ax,bx
        call fillHex
prVoid:
        ret
prNeL:
        mov word ptr operX,'EN'
        jmp prJmp
prEL:
        mov byte ptr operX,'E'
        jmp prJmp
pr80:
        push ax
        call fillDIc
        cmp cl,2
        jne next1
        call fill3
        jmp short end80
next1:
        cmp cl,3
        jne next2
        call fill4
        jmp short end80
next2:
        call fill5
end80:
        pop bx
        test bl,2
        jz it80
        cbw
        call fillHex
        ret
it80:
        call fillHexB
        jmp outRem
pr81:
        call fillDIc
        cmp cl,2
        jne next1_
        call fill34
        jmp short end81
next1_:
        cmp cl,3
        jne next2_
        call fill45
        jmp short end81
next2_:
        call fill56
end81:
        call fillHex
        ret
prPre:
        cmp kopPref,0
        jne goonPre
        mov kopPref,al
        mov ax,regIP1
        mov offPref,ax
        mov dx,1
goonPre:
        ret
prRepn:
        mov byte ptr operX,'E'
        jmp prPre
priSeg:
        mov al,RK+1
;        xor ah,ah
        and ax,00111000b
        cmp al,00011000b
        jbe normalS
        cmp al,00110000b
        jb  normalS
outDbs:
        lea di,oper1
        lea si,strDb
        movsw
        movsw
        lea di,oper2
        jmp outDb
normalS:
        shr ax,1
        shr ax,1
        lea si,tableS
        add si,ax
        mov ah,1
        call fillDIc
        movsw
        ret
proSeg:
        mov al,RK+1
        xor ah,ah
        and al,00111000b
        cmp al,00011000b
        ja  outDbs
        cmp al,00001000b
        je  outDbs
        shr ax,1
        shr ax,1
        lea si,tableS
        add si,ax
        movsw
        mov al,','
        stosb
        mov ah,1
        jmp prDI
prAXX:
        push ax
        mov ax,'XA'
        stosw
        mov al,','
        stosb
        pop ax
        jmp prXX
prFar:
        call fill45
        call fillHex
        mov al,':'
        stosb
        call fill23
        call fillHex
        ret
prImA:
        test al,2
        jnz fiAx
        test al,1
        jnz imA2
        mov ax,'LA'
        jmp short imA3
imA2:
        mov ax,'XA'
imA3:
        stosw
        mov al,','
        stosb
        call outPreS
        mov al,'['
        stosb
        call fill23
        call fillHex
        mov al,']'
        stosb
        ret
fiAx:
        push ax
        call outPreS
        mov al,'['
        stosb
        call fill23
        call fillHex
        mov ax,',]'
        stosw
        pop ax
        test al,1
        jnz imA1
        mov ax,'LA'
        stosw
        ret
imA1:
        mov ax,'XA'
        stosw
        ret
prMb:
        and ax,7
        shl ax,1
        lea si,tableRb
        add si,ax
        movsw
        mov al,','
        stosb
        call fill2
        call fillHexb
outRem:
        cmp al,20h
        jb  noRem
        lea di,remark
        cmp byte ptr [di],20h
        jne noRem
        push ax
        mov ax,' ;'
        stosw
        mov al,''''
        stosb
        pop ax
        stosb
        mov al,''''
        stosb
noRem:
        ret
prMw:
        and ax,7
        shl ax,1
        lea si,tableR
        add si,ax
        movsw
        mov al,','
        stosb
        call fill23
        call fillHex
        ret
fillDIc:
        call fill2
        call fillDI
        mov al,','
        stosb
        ret
prAam:
        mov al,RK+1
        cmp al,0Ah
        je outAam
        mov byte ptr operX,'?'
outAam:
        call fill2
        ret
prShC:
        mov al,RK+1
        call outBW
        and al,00111000b
        cmp al,00110000b
        jne outCL
        mov byte ptr operX,'?'
outCL:
        call fillDIc
        mov ax,'LC'
        stosw
        ret
prSh1:
        mov al,RK+1
        call outBW
        and al,00111000b
        cmp al,00110000b
        jne outc1
        mov byte ptr operX,'?'
outc1:
        call fillDIc
        mov al,'1'
        stosb
        ret
prShb:
        mov al,RK+1
        call outBW
        and al,00111000b
        cmp al,00110000b
        jne prS1
        mov byte ptr operX,'?'
;goDb:
;        jmp outDbs
prS1:
        call fillDIc
        cmp cl,2
        jne s11
        call fill3
        jmp short outS1
s11:
        cmp cl,3
        jne s12
        call fill4
        jmp short outS1
s12:
        call fill5
outS1:
        call fillHexb
        jmp outRem
prS2:
        call fillDIc
        cmp cl,2
        jne s21
        call fill34
        jmp short outS2
s21:
        cmp cl,3
        jne s22
        call fill45
        jmp short outS2
s22:
        call fill56
outS2:
        call fillHex
        ret
prEnt:
        call prR
        call fill23
        call fillHex
        mov al,','
        stosb
        call fill4
        call fillHexb
        ret
prLat:
        call outPreS
        je endLat
        mov ax,'B['
        stosw
        mov ax,']X'
        stosw
endLat:
        ret
prEsc:
        and ax,7
        shl ax,1
        shl ax,1
        shl ax,1
        push ax
        call fill2
        and ax,111000b
        shr ax,1
        shr ax,1
        shr ax,1
        pop bx
        add bx,ax
        xchg ax,bx
        call fillHexb
        mov al,','
        stosb
        xor ah,ah
        mov al,RK+1
        call fillDI
        ret
prIn:
        test al,1
        mov ax,'LA'
        jz  setIn
        mov ax,'XA'
setIn:
        stosw
        mov ax,'[,'
        stosw
        call fill2
        call fillHexb
        mov al,']'
        stosb
        ret
prOut:
        push ax
        mov al,'['
        stosb
        call fill2
        call fillHexb
        mov ax,',]'
        stosw
        pop ax
        test al,1
        mov ax,'LA'
        jz  setOut
        mov ax,'XA'
setOut:
        stosw
        ret
prJmpF:
        mov al,RK+1
        and al,11110000b
        cmp al,80h
        je prJnear
        jmp outDbs
prJnear:
        call fill2
        call fill34
        mov bx,regIP1
        add bx,4
        jmp goJmp
prNear:
        call fill23
outJmp:
        mov bx,regIP1
        add bx,3
        jmp goJmp
prInD:
        test al,1
        mov ax,'XA'
        jnz inDx
        mov ax,'LA'
inDx:
        stosw
        mov al,','
        stosb
        mov ax,'XD'
        stosw
        ret
prOd:
        push ax
        mov ax,'XD'
        stosw
        mov al,','
        stosb
        pop ax
        test al,1
        mov ax,'XA'
        jnz ouDx
        mov ax,'LA'
ouDx:
        stosw
        ret
prF6:
        mov al,RK+1
        and al,00111000b
        cmp al,00001000b
        jne checkTe
        mov byte ptr operX,'?'
;        jmp outDb
checkTe:
        cmp al,00001000b
        ja  outF6
        jmp pr80
outF6:
        call fill2
        push ax
        not al
        and al,11000000b
        jz notBy
        mov ax,'/B'
        stosw
notBy:
        pop ax
        call fillDi
        ret
prF7:
        mov al,RK+1
        and al,00111000b
        cmp al,00001000b
        jne checkTe7
        jmp outDb
checkTe7:
        or al,al
        jne outF7
        jmp pr81
outF7:
        call fill2
        push ax
        not al
        and al,11000000b
        jz notWo
        mov ax,'/W'
        stosw
notWo:
        pop ax
        call fillDi
        ret
prFE:
        mov al,RK+1
        and al,00111000b
        cmp al,00001000b
        jbe outF6
outDbs1:
        jmp outDbs
prFF:
        mov al,RK+1
        and al,00111000b
        not al
        test al,00111000b
        jz outDbs1
        not al
        cmp al,00001000b
        jbe outF7
        cmp al,00110000b
        je outFF
        test al,00001000b
        jz  outFF
        lea si,strFar
        movsw
        movsw
outFF:
        call fill2
        call fillDI
        ret
prStos:                 ; stos, scas
        lea di,oper1
        call outPreR
        jmp short comS
prMovs:                 ; movs, cmps, lods
        lea di,oper1
        call outPre
comS:
        cmp dl,2
        jne noPrPre
        push ax
        mov al,' '
        stosb
        pop ax
noPrPre:
        lea di,operX
        jne itPreR
        lea di,oper2
        push ax
        xor ah,ah
        shl ax,1
        shl ax,1
        add ax,offset tableD
        xchg ax,si
        lodsw
        xchg ax,si
        movsw
        movsw
        pop ax
itPreR:
        test al,1
        mov al,'W'
        jnz movB
        mov al,'B'
movB:
        stosb
        ret
        .data
kopPref         db 0
offPref         dw 0
regIP1          dw 0
regCS1          dw 0
RK              db 6 dup (0)
adrIp           db '0100 '
byte1           db '2E'
byte2           db 'EA'
byte3           db 'FF'
byte4           db 'FF'
byte5           db '00'
                db '00XX '
oper1           db 4 dup (' ')
operX           db 3 dup (' ')
oper2           db 12 dup (' ')
remark          db 9 dup (' ')
lenBuf          equ $-adrIP
                dw 0A0Dh
pointB          dw ?
tableS          db 'ESCSSSDSFSGS'
tableR          db 'AXCXDXBXSPBPSIDI'
tableRb         db 'ALCLDLBLAHCHDHBH'
tableI          db 'BX+SIBX+DIBP+SIBP+DISI   DI   BP   BX'
table80         db 0
strAdd  db 'ADD '
strOr   db 'OR','  '
strAdc  db 'ADC '
strSbb  db 'SBB '
strAnd  db 'AND '
strSub  db 'SUB '
strXor  db 'XOR '
strCmp  db 'CMP '
strInc  db 'INC '
strDec  db 'DEC '
strPush db 'PUSH'
strPop  db 'POP '
strPopa db 'POPA'
strDb   db 'DB','  '
strInsb db 'INSB'
strInsw db 'INSW'
strOuts db 'OUTS'
tableJx db 0
strJo   db 'JO','  '
strJno  db 'JNO '
strJc   db 'JC','  '
strJnc  db 'JNC '
strJe   db 'JE','  '
strJne  db 'JNE '
strJbe  db 'JNA '
strJa   db 'JA','  '
strJs   db 'JS','  '
strJns  db 'JNS '
strJp   db 'JP','  '
strJnp  db 'JNP '
strJl   db 'JL','  '
strJnl  db 'JNL '
strJle  db 'JNG '
strJg   db 'JG','  '
strPrES db 'ES: '
strPrCS db 'CS: '
strPrSS db 'SS: '
strPrDS db 'DS: '
strPrFS db 'FS: '
strPrGS db 'GS: '
strTest db 'TEST'
strXchg db 'XCHG'
strMov  db 'MOV '
strLea  db 'LEA '
strNop  db 'NOP '
strCbw  db 'CBW '
strCwd  db 'CWD '
strCall db 'CALL'
strWait db 'WAIT'
strPopf db 'POPF'
strSahf db 'SAHF'
strLahf db 'LAHF'
strMovs db 'MOVS'
strCmps db 'CMPS'
strStos db 'STOS'
strLods db 'LODS'
strScas db 'SCAS'
strShif db 0,'ROL ','ROR ','RCL ','RCR ','SHL ','SHR ','SHL ','SAR '
strRet  db 'RET '
strLes  db 'LES '
strLds  db 'LDS '
strEnte db 'ENTE'
strLeav db 'LEAV'
strRetf db 'RETF'
strInt3 db 'INT3'
strInt  db 'INT '
strInto db 'INTO'
strIret db 'IRET'
strAam  db 'AAM '
strAad  db 'AAD '
strXlat db 'XLAT'
strEsc  db 'ESC '
strLoop db 'LOOP'
strJcxz db 'JCXZ'
strIn   db 'IN','  '
strOut  db 'OUT '
strJmp  db 'JMP '
strLock db 'LOCK'
strRepn db 'REPN'
strRep  db 'REP '
strHlt  db 'HLT '
strCmc  db 'CMC '
strGr1  db 0,'TEST','TEST','NOT ','NEG ','MUL ','IMUL','DIV ','IDIV'
strClc  db 'CLC '
strStc  db 'STC '
strCli  db 'CLI '
strSti  db 'STI '
strCld  db 'CLD '
strStd  db 'STD '
strGr3  db 0,'INC ','DEC ','CALL','CALL','JMP ','JMP ','PUSH','DB  '
strFar  db 'Far '
strDaa  db 'DAA '
strAaa  db 'AAA '
strDas  db 'DAS '
strAas  db 'AAS '
strArpl db 'ARPL'
strLalc db 'SALC'
tableD  equ $
        dw strAdd, prREG, strAdd, prREG, strAdd, prREG, strAdd, prREG  ; 0
        dw strAdd, prAL , strAdd, prAX ,strPush, prSEG, strPOP, prSEG  ; 4
        dw strOr , prREG, strOr , prREG, strOr , prREG, strOr , prREG  ; 8
        dw strOr , prAL , strOr , prAX ,strPush, prSEG, tableJx,prJmpF ; C
        dw strAdc, prREG, strAdc, prREG, strAdc, prREG, strAdc, prREG  ; 10
        dw strAdc, prAL , strAdc, prAX ,strPush, prSEG, strPOP, prSEG  ; 14
        dw strSbb, prREG, strSbb, prREG, strSbb, prREG, strSbb, prREG  ; 18
        dw strSbb, prAL , strSbb, prAX ,strPush, prSEG, strPOP, prSEG  ; 1C
        dw strAnd, prREG, strAnd, prREG, strAnd, prREG, strAnd, prREG  ; 20
        dw strAnd, prAL , strAnd, prAX ,strPrES, prPre, strDaa, prVoid ; 24
        dw strSub, prREG, strSub, prREG, strSub, prREG, strSub, prREG  ; 28
        dw strSub, prAL , strSub, prAX ,strPrCS, prPre, strDas, prVoid ; 2C
        dw strXor, prREG, strXor, prREG, strXor, prREG, strXor, prREG  ; 30
        dw strXor, prAL , strXor, prAX ,strPrSS, prPre, strAaa, prVoid ; 34
        dw strCmp, prREG, strCmp, prREG, strCmp, prREG, strCmp, prREG  ; 38
        dw strCmp, prAL , strCmp, prAX ,strPrDS, prPre, strAas, prVoid ; 3C
        dw strInc, prXX,  strInc, prXX,  strInc, prXX,  strInc, prXX   ; 40
        dw strInc, prXX,  strInc, prXX,  strInc, prXX,  strInc, prXX   ; 44
        dw strDec, prXX,  strDec, prXX,  strDec, prXX,  strDec, prXX   ; 48
        dw strDec, prXX,  strDec, prXX,  strDec, prXX,  strDec, prXX   ; 4C
        dw strPush,prXX,  strPush,prXX,  strPush,prXX,  strPush,prXX   ; 50
        dw strPush,prXX,  strPush,prXX,  strPush,prXX,  strPush,prXX   ; 54
        dw strPop, prXX,  strPop, prXX,  strPop, prXX,  strPop, prXX   ; 58
        dw strPop, prXX,  strPop, prXX,  strPop, prXX,  strPop, prXX   ; 5C
        dw strPush,prA  , strPopa,prVoid,strDb , outDb ,strArpl,prREG  ; 60
        dw strPrFS,prPre, strPrGS,prPre ,strDb , outDb ,strDb , outDb  ; 64
        dw strPush,out23 ,strDb , outDb ,strPush,out2p ,strDb , outDb  ; 68
        dw strInsb,prVoid,strInsw,prVoid,strOuts,prStos,strOuts,prStos ; 6C
        dw strJo  ,prJmp ,strJno ,prJmp ,strJc  ,prJmp ,strJnc ,prJmp  ; 70
        dw strJe  ,prJmp ,strJne ,prJmp ,strJbe ,prJmp ,strJa  ,prJmp  ; 74
        dw strJs  ,prJmp ,strJns ,prJmp ,strJp  ,prJmp ,strJnp ,prJmp  ; 78
        dw strJl  ,prJmp ,strJnl ,prJmp ,strJle ,prJmp ,strJg  ,prJmp  ; 7C
        dw table80,pr80  ,table80,pr81  ,table80,pr80  ,table80,pr80   ; 80
        dw strTest,prReg ,strTest,prReg ,strXchg,prReg ,strXchg,prReg  ; 84
        dw strMov ,prReg ,strMov ,prReg ,strMov ,prReg ,strMov ,prReg  ; 88
        dw strMov ,priSeg,strLea ,prRegD,strMov ,proSeg,strPop ,prDI   ; 8C
        dw strNop ,prVoid,strXchg,prAXX ,strXchg,prAXX,strXchg,prAXX   ; 90
        dw strXchg,prAXX ,strXchg,prAXX ,strXchg,prAXX ,strXchg,prAXX  ; 94
        dw strCbw ,prVoid,strCwd ,prVoid,strCall,prFar ,strWait,prVoid ; 98
        dw strPush,prF   ,strPopf,prVoid,strSahf,prVoid,strLahf,prVoid ; 9C
        dw strMov ,prImA ,strMov ,prImA ,strMov ,prImA ,strMov ,prImA  ; A0
        dw strMovs,prMovs,strMovs,prMovs,strCmps,prMovs,strCmps,prMovs ; A4
        dw strTest,prAL  ,strTest,prAX  ,strStos,prStos,strStos,prStos ; A8
        dw strLods,prMovs,strLods,prMovs,strScas,prStos,strScas,prStos ; AC
        dw strMov ,prMb  ,strMov ,prMb  ,strMov ,prMb  ,strMov ,prMb   ; B0
        dw strMov ,prMb  ,strMov ,prMb  ,strMov ,prMb  ,strMov ,prMb   ; B4
        dw strMov ,prMw  ,strMov ,prMw  ,strMov ,prMw  ,strMov ,prMw   ; B8
        dw strMov ,prMw  ,strMov ,prMw  ,strMov ,prMw  ,strMov ,prMw   ; BC
        dw strShif,prShb ,strShif,prShb ,strRet ,out23 ,strRet ,prVoid ; C0
        dw strLes ,prREG1,strLds ,prREG1,strMov ,prS1  ,strMov ,prS2   ; C4
        dw strEnte,prEnt ,strLeav,prE   ,strRetf,out23 ,strRetf,prVoid ; C8
        dw strInt3,prVoid,strInt ,out2  ,strInto,prVoid,strIret,prVoid ; CC
        dw strShif,prSh1 ,strShif,prSh1 ,strShif,prShC ,strShif,prShC  ; D0
        dw strAam ,prAam ,strAad ,prAam ,strLalc,prVoid,strXlat,prLat  ; D4
        dw strEsc ,prEsc ,strEsc ,prEsc ,strEsc ,prEsc ,strEsc ,prEsc  ; D8
        dw strEsc ,prEsc ,strEsc ,prEsc ,strEsc ,prEsc ,strEsc ,prEsc  ; DC
        dw strLoop,prNeL ,strLoop,prEL  ,strLoop,prJmp ,strJcxz,prJmp  ; E0
        dw strIn  ,prIn  ,strIn  ,prIn  ,strOut ,prOut ,strOut ,prOut  ; E4
        dw strCall,prNear,strJmp ,prNear,strJmp ,prFar ,strJmp ,prJmp  ; E8
        dw strIn  ,prInD ,strIn  ,prInD ,strOut ,prOd  ,strOut ,prOd   ; EC
        dw strLock,prVoid,strDb  ,outDb ,strRepn,prRepn,strRep ,prPre  ; F0
        dw strHlt ,prVoid,strCmc ,prVoid,strGr1 ,prF6  ,strGr1 ,prF7   ; F4
        dw strClc ,prVoid,strStc ,prVoid,strCli ,prVoid,strSti ,prVoid ; F8
        dw strCld ,prVoid,strStd ,prVoid,strGr3 ,prFE  ,strGr3 ,prFF   ; FC
outBuf  db '’ÕÕ'
count   db 'ÕÕÕÕÕÕ Internal disassembler [+,-,,,,',26,'] ÕÕÕ—[x]∏' ; 1'
        db '≥ AX '
pAX     db 5 dup (' '),'BX '
pBX     db 5 dup (' '),'CX '
pCX     db 5 dup (' '),'DX '
pDX     db 5 dup (' '),'SI '
pSI     db 5 dup (' '),'DI '
pDI     db 4 dup (' '),'≥VK≥' ; 2
        db '≥ SP '
pSP     db 5 dup (' '),'BP '
pBP     db 5 dup (' '),'CS '
pCS     db 5 dup (' '),'SS '
pSS     db 5 dup (' '),'DS '
pDS     db 5 dup (' '),'ES '
pES     db 4 dup (' '),'≥AV≥' ; 3
        db '√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒ¥' ; 4
        db '≥'
oldCom  db     48 dup (' '),'≥O '
pOF     db '0≥' ; 5
        db '≥'
outCom  db     48 dup (' '),'≥D 0≥' ; 6
        db '≥',48 dup (' '),'≥I 0≥' ; 7
        db '≥',48 dup (' '),'≥T 0≥' ; 8
        db '≥',48 dup (' '),'≥S 0≥' ; 9
        db '≥',48 dup (' '),'≥Z 0≥' ; 10
        db '≥',48 dup (' '),'≥A 0≥' ; 11
        db '≥',48 dup (' '),'≥P 0≥' ; 12
        db '≥',48 dup (' '),'≥C 0≥' ; 13
        db 10 dup ('≥',48 dup (' '),'≥',32,32,32,'≥') ; 14
lastL   db '‘ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕæ' ; 24
lenLine equ $-lastL
lenStr          dw 11    ; (14)
stopAs          dw 5
end
