
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Модуль позволил лечить вирусы OneHalf 3544,3570,3666.

public  oneCure,infect
extrn   writeDec:near,who:near,readF:near,writeF:near,setPos1:near,beep:near
extrn   writeChar:near,setTime:near,printEng:near,changeOpen:near
extrn   buf:near,mesWho:byte,typeFile:byte,buf1:near,posHi:word,posLo:word
extrn   myTitle:word,itEXE:byte,itCOM:byte,fillNameV:near,virFoundF:byte
extrn   regIP:word,baseSeg:word,infBadCount:word,curDelCount:word
extrn   oneAdr:near
        .model small
        .code
oneCure proc
        push ax cx dx si di
        push posLo
        push posHi
        mov ax,regIP
        add posLo,ax
        adc posHi,0
        call readOne
        jc badCell1
        cmp typeFile,1
        je noJmp
        lea si,buf1
        call checkCell
        mov posHi,0
        call readOne
        jc badCell1
noJmp:
        lea di,tableOne
        mov word ptr tablePos,offset buf+400
        mov cx,12
findOne:
        mov si,dx
        call word ptr [di]
        jc  badCell1
        lea cx,buf1+12
        sub cx,si
        call storePos
        call checkCell
        call readOne
badCell1:
        jc  badCell
        inc di
        inc di
        cmp di,offset endOneTab
        jne findOne
        inc virFoundF
        inc infBadCount
        lea si,oneAdr
        mov ax,endAdr
        sub ax,startAdr
        cwd
        call fillNameV
        lea dx,infect
        call printEng
        xchg ax,dx
        call writeDec
        mov dl,'.'
        call writeChar
        call beep
        lea dx,mesWho
        call who
        jc  noCur
        call readBeg
        jc  noCur
        call changeOpen
        jc  noCur
        call decod
        call cured
        jc noCur
        inc curDelCount
noCur:
badCell:
        cmc
        pop posHi
        pop posLo
        pop di si dx cx ax
        ret
        endp
cured proc
        push ax cx dx
        mov word ptr tablePos,offset buf+400
        call write0
        jc  writeErr
        lea dx,buf+40h
        mov cx,10
nextCell:
        push cx
        mov cx,10
        cmp byte ptr typeOne,1
        jne oldType
        mov cx,12
oldType:
        call setPosInTable
        call writeOne
        pushf
        add dx,cx
        popf
        pop cx
        jc  writeErr
        loop nextCell
        xor ax,ax
        mov posLo,ax
        mov posHi,ax
        lea dx,buf+10h
        mov cx,3
        cmp typeFile,0
        je write3
        mov cx,24
write3:
        call writeOne
        jc  writeErr
        lea dx,itCOM
        cmp typeFile,0
        je  outCOM
        lea dx,itEXE
outCOM:
        call printEng
        call setTime
writeErr:
        pop dx cx ax
        ret
        endp
write0 proc
        push cx
        call setPos1
        xor cx,cx
        call writeF
        pop cx
        ret
        endp
setPosInTable proc
        push ax si
        mov si,tablePos
        lodsw
        sub posLo,ax
        cmp posLo,12
        ja storeLo
        add posLo,cx
        jmp short storeHi
storeLo:
        mov posLo,ax
storeHi:
        lodsw
        mov posHi,ax
        mov tablePos,si
        pop si ax
        ret
        endp
storePos proc
        push ax di
        mov di,tablePos
        mov ax,posLo
        stosw
        mov ax,posHi
        stosw
        mov tablePos,di
        pop di ax
        ret
        endp
readBeg proc
        push ax cx dx
        cmp typeFile,0
        je  restCOM
        mov ax,ds:[myTitle+8]
        add ax,ds:[myTitle+22]
        mov dx,16
        imul dx
        add ax,startAdr
        adc dx,0
        mov posLo,ax
        mov posHi,dx
        jmp short restOne
restCOM:
        mov ax,startAdr
        sub ax,100h
        mov posLo,ax
restOne:
        call setPos1
        mov cx,184
        lea dx,buf
        call readF
        pop dx cx ax
        ret
        endp
check1 proc near
findPush:
        lodsb
        cmp al,50h
        je exitCheck1
        loop findPush
        stc
exitCheck1:
        ret
        endp
check2 proc near
findPush2:
        lodsb
        cmp al,16h
        je exitCheck2
        cmp al,0Eh
        je exitCheck2
        loop findPush2
        stc
exitCheck2:
        ret
        endp
check3 proc near
findPush3:
        lodsb
        cmp al,1Fh
        je exitCheck3
        loop findPush3
        stc
exitCheck3:
        ret
        endp
check4 proc near
findPush4:
        lodsb
        and al,11111000b
        cmp al,0B8h
        je foundCheck4
        loop findPush4
        stc
exitCheck14:
        ret
        endp
foundCheck4:
        lodsw
        mov word ptr startAdr,ax
        jmp short exitCheck14
check5 proc near
findPush5:
        lodsb
        and al,11111000b
        cmp al,0B8h
        je foundCheck5
        loop findPush5
        stc
exitCheck15:
        ret
        endp
foundCheck5:
        lodsw
        mov word ptr cs:startKey,ax
        jmp short exitCheck15
check6 proc near
findPush6:
        lodsb
        cmp al,31h
        je foundCheck6
        cmp al,01h
        je foundCheck6
        cmp al,29h
        je foundCheck6
        loop findPush6
        stc
exitCheck16:
        ret
        endp
foundCheck6:
        mov byte ptr cs:oneCommand,al
        jmp short exitCheck16
check7 proc near
findPush7:
        lodsb
        cmp al,81h
        je foundCheck7
        cmp al,05h
        je foundCheck71
        loop findPush7
        stc
exitCheck17:
        ret
        endp
foundCheck7:
        inc si
foundCheck71:
        lodsw
        mov word ptr cs:addKey,ax
        jmp short exitCheck17
        endp
check8 proc near
findPush8:
        mov byte ptr typeOne,0
        lodsb
        cmp al,40h
        jb nextCell8
        cmp al,48h
        jb exitCheck8
        cmp al,0EBh
        jne nextCell8
        lodsb
        mov byte ptr typeOne,1
        cmp al,0FFh
        je  exitCheck8
nextCell8:
        loop findPush8
        stc
        ret
exitCheck8:
        clc
        ret
        endp
check9 proc near
findPush9:
        lodsb
        cmp al,81h
        je foundCheck9
        loop findPush9
        stc
exitCheck19:
        ret
foundCheck9:
        inc si
        lodsw
        mov word ptr endAdr,ax
        jmp short exitCheck19
        endp
check10 proc near
        clc
        ret
        endp
checkCell proc
        push ax cx dx si
checkLoop:
        lodsb
        cmp al,0EBh
        je setShort
        cmp al,0E9h
        je setLong
        loop checkLoop
        mov ax,12
        jmp short addLong1
exitCheckCell:
        pop si dx cx ax
        ret
setShort:
        lodsb
        cbw
        jmp short withNear
        endp
setLong:
        lodsw           ; считать смещение для jmp near
withNear:
        xchg dx,si      ; dx=si
        sub dx,si       ; в dx - длина команды
        test ah,80h
        jz addLong
        neg ax
        sub ax,dx
        sub posLo,ax
        sbb poshi,0
        jmp short exitCheckCell
addLong:
        add ax,dx
addLong1:
        add posLo,ax
        adc poshi,0
        jmp short exitCheckCell
readOne proc
        call setPos1
        lea dx,buf1
        mov cx,12
        call readF
        ret
        endp
writeOne proc
        call setPos1
        call writeF
        ret
        endp
decod proc
        push ax si
        mov cx,184
        lea si,buf
startKey equ $+1
        mov ax,0
oneCommand:
        xor word ptr [si],ax
addKey  equ $+1
        add ax,1234h
        inc si
        loop oneCommand
        pop si ax
        ret
        endp
        .data
tableOne        equ $
                dw check1
                dw check2
                dw check3
                dw check4
                dw check5
                dw check6
                dw check7
                dw check8
                dw check9
                dw check10
endOneTab       equ $
infect          db ' - болен OneHalf.',0
                db ' - infected OneHalf.',0
                dw 0EE01h,infect
tablePos        dw ?
startAdr        dw ?
endAdr          dw ?
typeOne         db 0
        end
