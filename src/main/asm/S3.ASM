
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модуль занимается выводом на экран. Правда в текстовом режиме.
;

public  writeWordInHex,writeHex,writeChar,delToEnd,printHelp,checkEXT
public  delString,printOk,printOk1,closeFile,print0D0A,checkShow
public  print0D,fillBuffer,clearBuffer,changeOpen,varBW,writeBuf
public  fillBuffer,mesFull,delFile,writePal,mesTimeTest,iniML,writeToML
public	writePalBr
extrn   print:near,color:byte,varPage:byte,flagWrite:byte,color2:byte
extrn   varKeyHel:byte,mesHelp:byte,mes2:byte,var0D:byte,attrib:byte
extrn   varFiles:byte,mesOk:byte,varMesOk:byte,posHiAll:word,posLoAll:word
extrn   handleRep:word,varRap:byte,printEng:near,info:near,path:near
extrn   writeF:near,settime:near,bufferOut:byte,mesClBad:near
extrn   curPos:word,videoSeg:word,erase:byte,countStr:byte
extrn   fname:near,scrollSt:near,who:near,mesDelOk:near,print0D0A1:near
extrn   mesRenOk:near,varKeyOk:word,varDl:byte,mesRename:near,mesDelete:near
extrn   filesCount:word,progCount:word,curDelCount:word,delCount:word
extrn   beep1:near,renCount:byte,buf:byte,varWidth:byte,writeDec:near
extrn   saveTimeO:near,leftBound:byte,rightBound:byte,varWin:byte,varBat:byte
extrn   varAA:byte,mlName:near,infBadCount:word,infNewCount:word
extrn   writeNullS1:near,varMl:byte,closeF:near,setPos:near,varRn:byte
extrn   varStd:byte,listChar:word,checkBreak1:near
        .model small
        .code
writeWordInHex proc
        push ax bx cx dx
        mov cx,4
        mov ax,dx
makeHex:
        xor dx,dx
        mov bx,16
        div bx
        push dx
        loop makeHex
        mov cx,4
writeHex4:
        pop dx
        call writeHex
        loop writeHex4
        pop dx cx bx ax
        ret
        endp
writeHex proc
        push ax dx
        mov al,dl
        add al,'0'
        cmp al,'9'
        jbe  outHex
        add al,7
outHex:
        mov dl,al
        call writeChar
        pop dx ax
        ret
        endp
getES_DI proc
        push ax dx
        mov ax,ss:curPos
        push ax
        mov al,ah
        xor ah,ah
        mov di,word ptr ss:varWidth
        mul di
        shl ax,1
        xchg di,ax
        pop ax
        xor ah,ah
        shl ax,1
        add di,ax
        mov es,ss:videoSeg
        pop dx ax
        ret
        endp
fillBuffer proc
        push ax di
        cmp ss:varRap,0
        je  noStore
        lea di,bufferOut
        xor ah,ah
        mov al,byte ptr ss:[di]
        cmp al,109
        ja noStore
        inc ax
        mov byte ptr ss:[di],al
        add di,ax
        mov byte ptr ss:[di],dl
noStore:
        pop di ax
        ret
        endp
printHelp proc
        push dx
        mov var0D,1
        mov color,3
        mov color2,11
        lea dx,mes2
        call printEng
        lea dx,mesHelp
        cmp varKeyHel,1
        clc
        jne endPrHel
printHe:
        call printEng
        stc
endPrHel:
        mov var0D,0
        pop dx
        ret
        endp
checkEXT proc
        push ax cx si di es
        push ss
        pop es
        lea di,fname
        xor al,al
        mov cx,255
        repne scasb
found0:
        sub di,5
        lea si,extList
        mov cl,countList
scanExt:
        push di
        cmpsw
        je moreCheckE
        lodsw
nextExt:
        pop di
        loop scanExt
        stc
        jmp short extOk
moreCheckE:
        cmpsw
        jne nextExt
        pop di
        dec cx
        jne noBats
        mov varBat,1
noBats:
        inc progCount   ;st
        inc filesCount  ;st
extOk:
        jnc filesOk
        cmp varFiles,1
        stc
        jne filesOk
        inc filesCount  ;st
        clc
filesOk:
        pop es di si cx ax
        ret
        endp
printOK1 proc
        cmp varMesOk,2
        jne printOK
        push dx
        lea dx,mesTimeTest
        call printEng
        call saveTimeO
        call writeDec
        lea dx,mesMilSec
        call print
        pop dx
        endp
printOK proc
        cmp varMesOk,0
        je  noPrintOk
        push dx
        lea dx,mesOk
        call printEng
        call print0D0A
        pop dx
noPrintOk:
        ret
        endp
delString proc
        call print0D
        call delToEnd
        ret
        endp

writePalBr proc
        push dx si ds
        push ss
        pop  ds
        mov si,listChar
nextCharWr:
        inc listChar
        mov dl,[si+tableChar]
        or dl,dl
        jne writeNow
        xor si,si
        mov listChar,si
        jmp nextCharWr
writeNow:
        call writePal
        call checkBreak1
	pop ds si dx
        ret
        endp	
writePal proc
        cmp ss:varStd,0
        je noWritePstd
        push ax dx
        mov ah,2
        int 21h
        mov dl,8
        int 21h
        pop dx ax
        ret
noWritePstd:
        push ax di es
        call getES_DI
        mov al,dl
        mov ah,ss:color
        cmp ss:varWin,0
        je noSetFon
        or ah,10h
noSetFon:
varBW   equ byte ptr $+1
        jmp short noSetWhite
        test ah,15
        jz noSetWhite
        and ah,0Fh
        or  ah,7
noSetWhite:
        call checkForSh
        or ah,ah
        jne oldWrite
        stosb
        jmp short curRi
oldWrite:
        stosw
curRi:
        pop es di ax
        ret
        endp
writeChar proc
        call fillBuffer
        cmp ss:varStd,0
        je noStdWrite
        push ax
        mov ah,2
        int 21h
        inc ss:curPos
        mov al,1 ptr ss:curPos
        cmp al,ss:rightBound    ; пpавая гpаница
        jb axNormal1
        call print0D
axNormal1:
        pop ax
        ret
noStdWrite:
        call writePal
        call cursorRight
        ret
        endp

cursorRight proc
        push ax
        inc ss:curPos
        mov al,byte ptr ss:curPos
        cmp al,ss:rightBound    ; пpавая гpаница
        jb axNormal
        call print0D0A
axNormal:
        pop ax
        ret
        endp
print0D proc
        push ax
        mov al,ss:leftBound
        mov byte ptr ss:curPos,al        ; левая гpаница
        pop ax

        cmp ss:varStd,0
        je no0Dstd
        push ax dx
        mov dl,0Dh
        mov ah,2
        int 21h
        pop dx ax
no0Dstd:
        endp
clearBuffer proc
        mov ss:bufferOut,0
        ret
        endp

print0D0A proc
        push ax bx cx dx
        call delToEnd
        mov dl,0Dh
        call fillBuffer
        mov dl,0Ah
        call fillBuffer
        call writeBuf
        cmp ss:varStd,0
        je no0D0Astd
        call print0D
        push ax dx
        mov dl,0Ah
        mov ah,2
        int 21h
        pop dx ax
        jmp short exit0D0A
no0D0Astd:
        mov ax,0E0Dh
        int 10h
        cmp ss:varAA,0
        je oldCur0A
        call delString
        jmp short exit0D0A
oldCur0A:
        mov ax,0E0Ah
        int 10h
noMake0A:
        mov bh,ss:varPage
        mov ah,3
        int 10h
        cmp dh,ss:rightBound+1
        jbe noWindow
        call scrollWin
noWindow:
        cmp dh,byte ptr ss:curPos+1
        jne noScroll
        call scrollSt
noScroll:
        mov dl,ss:leftBound
        mov ss:curPos,dx
exit0D0A:
        pop dx cx bx ax
        ret
        endp
scrollWin proc
        push cx
        mov bl,7
        mov cx,word ptr ss:leftBound
        mov dx,word ptr ss:rightBound
        dec dx
        mov ax,601h
        push cx dx
        int 10h
        pop dx cx
        mov dl,cl
        mov ah,2
        int 10h
        pop cx
        ret
        endp
checkForSh proc
checkShow equ byte ptr $+1
        jmp short checkSnow
        ret
        endp
checkSnow:
        push ax cx dx
        mov cx,10
        mov dx,3DAh
waitCl:
        in al,dx
        test al,1
        loopne waitCl
        pop dx cx ax
        ret
        endp
delToEnd proc
        push ax cx dx di es
        xor ch,ch
        mov cl,byte ptr ss:curPos
        sub cl,ss:rightBound    ; 80             ; пpавая гpаница
        neg cl
        cmp ss:varStd,0
        je noExtDel
        jcxz exitDelTo
        dec cx
        jcxz exitDelTo
        push cx
nextStdD:
        mov dl,' '
        mov ah,2
        int 21h
        loop nextStdD
        pop cx
nextStdB:
        mov dl,8
        mov ah,2
        int 21h
        loop nextStdB
        jmp short exitDelTo
noExtDel:
        call checkForSh
        mov ax,720h
        cmp ss:varWin,0
        je setBlack
        mov ah,10h
setBlack:
        call getES_DI
        rep stosw
exitDelTo:
        pop es di dx cx ax
        ret
        endp
writeBuf proc
        cmp ss:varRap,0
        je noWriteRep
        push ax bx cx dx si ds
        push ss
        pop  ds
        mov bx,handleRep
        lea si,bufferOut
        lodsb
        xor ch,ch
        mov cl,al
        mov dx,si
        call writeF
        jnc writeNor
        mov varRap,0
        call closeF
        call print0D
        lea dx,mesFull
        call printEng
writeNor:
        call clearBuffer
        dec countStr
        jnz noWr12
        mov countStr,61
        mov dl,12
        call fillBuffer
        call writeBuf
noWr12:
        pop ds si dx cx bx ax
noWriteRep:
        ret
        endp
closeFile proc
        push ax cx dx
        cmp attrib,-1
        je notClosed
        mov ah,3Eh
        int 21h
        jc outClErr
        cmp flagWrite,0
        je notClosed
        mov flagWrite,0
        xor ch,ch
        mov cl,attrib
        lea dx,path
        mov ax,4301h
        int 21h
notClosed:
        cmp erase,1
        jne notClosed1
        call delFile
        mov erase,0
notClosed1:
        cmp erase,2
        jne notClosed2
        call reNameFile
notClosed2:
        mov erase,0
        pop dx cx ax
        ret
        endp
changeOpen proc
        push ax cx dx
        mov ah,3Eh
        int 21h
        jnc closeOk
outClErr:
        lea dx,mesClBad
        call printEng
        stc
        jmp short oldAtr
closeOk:
        lea dx,path
        xor cx,cx
        mov flagWrite,1
        mov ax,4301h
        int 21h
        jc badOpen
        mov ax,3DC2h
        int 21h
badOpen:
        jnc oldAtr
        mov attrib,-1
oldAtr:
        pop dx cx ax
        ret
        endp
reNameFile proc
        push ax cx dx si di es
        push ds
        pop  es
        lea si,path
        lea di,buf
        mov cx,80
        push cx di
        rep movsw
        pop di cx
        xor al,al
        repne scasb
        cmp byte ptr [di-2],'~'
        je noRenameF1
        mov byte ptr [di-2],'~'
        lea dx,mesRename
        call whoRename
        jc noRenameF
        lea dx,path
        lea di,buf
        mov ah,56h
        int 21h
        jc noRenameF1
        inc renCount
        lea dx,mesRenOk
        call printEng
noRenameF1:
        call print0D0A1
noRenameF:
        pop es di si dx cx ax
        ret
        endp
whoDelete proc
        mov al,varDl
        call whoBeep
        mov varDl,al
        ret
        endp
whoRename proc
        mov al,varRn
        call whoBeep
        mov varRn,al
        ret
        endp
whoBeep proc
        push varKeyOk
        call beep1
        cmp byte ptr varKeyOk,2
        je formalWho
        mov byte ptr varKeyOk,al
formalWho:
        call who
        mov al,byte ptr varKeyOk
        pop varKeyOk
        ret
        endp
delFile proc
        push ax cx dx
        lea dx,mesDelete
        call whoDelete
        jc noDelF1
        lea dx,path
        xor cx,cx
        mov ax,4301h
        int 21h
        jc noDelFile
        mov ah,41h
        int 21h
        jc noDelFile
        inc curDelCount
        inc delCount
        lea dx,mesDelOk
        call printEng
noDelFile:
        call print0D0A1
noDelF1:
        pop dx cx ax
        ret
        endp
iniML proc
        push ax
        mov ax,infBadCount
        add ax,infNewCount
        cmp ax,mlCount
        mov mlCount,ax
        pop ax
        ret
        endp
writeToML proc
        cmp varMl,0
        je exitWml
        call iniML
        je exitWml
        push ax bx cx dx
        lea dx,mlName
        xor cx,cx
        mov ah,5Bh
        int 21h
        xchg bx,ax
        jnc openOk
        mov ax,3DC1h
        int 21h
        jc openErr
        xchg bx,ax
        mov al,2
        call setPos
openOk:
        lea dx,path
        call writeNullS1
        call closeF
openErr:
        pop dx cx bx ax
exitWml:
        ret
        endp
        .data
mesTimeTest     db ' Время проверки : ',0
                db ' Time for test : ',0
                dw 0EE01h,mesTimeTest
mesMilSec       db ' ms.',0
countList       db 10
extList         db '.COM.EXE.SYS.DRV.OVL.OVR.386.BIN.BAT.PRG'
mesFull         db ' - ошибка записи файла-отчета.',10,0
                db ' - disk full, write error ?',10,0
                dw 0EE01h,mesFull
mlCount         dw 0
tableChar       db '|▒▓█▓▒|/-\|/-\|\-/|\-/',0
end
