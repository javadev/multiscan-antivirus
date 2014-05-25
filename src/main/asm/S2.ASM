
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Это очень крутой модуль. Создает файл отчета и много всего.
;

public  bye,getParam,moveIPCS,getIPCS,writeHead,closeRap,printFeng
public  checkBreak,int23Entry,offCursor,restCursor,setPos1
public  checkBreak1,openRep,mesReport,mesComSt,fillDate,fillTime
extrn   getKeys:near,clearBuffer:near,printEng:near,who:near
extrn   setpos:near,writeF:near,print:near,mesStop:near,print0D:near
extrn   color:byte,myTitle:word,poslo:word,poshi:word,off1C:word
extrn   reloIP:word,varBreak:byte,off23:word,off24:word,seg23:word,varBW:byte
extrn   varPage:byte,varRap:byte,handleRep:word,seg24:word
extrn   int24Entry:near,curSize:word,sizeInByte:near,memCount:near
extrn   lenClear:near,videoSeg:word,curPos:word,checkShow:byte
extrn   segLng:word,repName:near,varKeyOk:byte,seekF:near
extrn   install:near,segLst:word,varAm:byte,segRec:word,outPic:near
extrn   segMes:word,baseSeg:word,falseSeg:word,dtaSeg:word,stopAs:word
extrn   envSeg:word,varAs:byte,mesStop1:near,print0D0A:near,varEng:byte
extrn   checkEng:near,writeBuf:near,fillBuffer:near,fDate:near,lenStr:byte
extrn   outScr:near,storeScr:near,delString:near,segVirInf:word
extrn   readFont:near,setFont:near,virusSeg:word,varWidth:byte,varLeft:word
extrn   leftBound:word,rightBound:word,varWin:byte,infBadCount:word
extrn   infNewCount:word,createF:near,closeF:near,asmSeg:word,redrawAsm:near
extrn   outScr:near,storeOutScr:near,findBody:near,varNonStop:byte
        .model small
        .code
bye proc
        call closeRap
        call outPic
        call setFont    ;*
        xor ax,ax
        cmp infBadCount,0
        je skipAddInf
        inc ax
skipAddInf:
        cmp infNewCount,0
        je skipAddNew
        inc ax
        inc ax
skipAddNew:
        ret
        endp
getParam proc
        call fillPage
        jc memoryError
        call getKeys
        call setWin
        call setFont    ;*
        call install
        call findBody
        clc
memoryError:
        ret
        endp

setWin proc
        cmp varWin,0
        je noSetWin
        mov leftBound,3*100h+5
        mov rightBound,21*100h+75
        push ax bx dx
        mov bh,varPage
        mov dx,leftBound
        mov curPos,dx
        mov ah,2
        int 10h
        pop dx bx ax
noSetWin:
        ret
        endp

allocMem proc
        push ax bx cx dx
        mov ax,ds
        mov bx,es
        sub ax,bx
        mov bx,offset sizeInByte
        mov cl,4
        shr bx,cl
        inc bx
        add bx,ax
        mov ah,4Ah
        int 21h
        jc allocBad
        mov bx,1077h+375+8000/16+54*3
        mov ah,48h
        int 21h
        jc allocBad
        mov asmSeg,ax
        add ax,54*3
        mov segVirInf,ax
        add ax,375
        mov falseSeg,ax
        add ax,60h
        mov virusSeg,ax
        add ax,8000/16
        mov envSeg,ax
        add ax,5
        mov dtaSeg,ax
        mov baseSeg,ax
        clc
        jmp short allocOk
allocBad:
        lea dx,memoryErr
        call print
        stc
allocOk:
        pop dx cx bx ax
        ret
        endp
setVar proc
        push ax bx cx dx si
        mov segLng,ss
getVideo:
        mov ah,0Fh
        int 10h
        mov varPage,bh
        or ah,ah
        jne setWidth
        mov ah,80
setWidth:
        mov varWidth,ah
        push ax
        mov leftBound,0
        mov al,ah
        mov ah,100
        mov rightBound,ax
        pop ax
        and al,7Fh
        cmp al,7
        jne colorMode
        mov cs:varBW,0
        mov bx,0B000h
        jmp short setVideoSeg
colorMode:
        cmp al,13h
        ja noInitVideo
        cmp al,4
        jb noInitVideo
        mov ax,3
        int 10h
        jmp getVideo
noInitVideo:
        mov bx,0B800h
setVideoSeg:
        mov videoSeg,bx
        push ds
        xor ax,ax
        mov ds,ax
        mov ax,ds:44Eh
        shr ax,1
        shr ax,1
        shr ax,1
        shr ax,1
        add ss:videoSeg,ax
        mov al,ds:487h
        pop ds
        or al,al
        je no_Ega
        mov cs:checkShow,0
no_Ega:
        mov bh,varPage
        mov ah,3
        int 10h
        mov curPos,dx
        mov al,23h
        lea si,off23
        lea dx,int23Entry
        call get&setVect
        inc ax
        lea si,off24
        lea dx,int24Entry
        call get&setVect
        call saveOffCursor
        pop si dx cx bx ax
        ret
        endp
get&setVect proc
        push ax bx ds es
        mov ah,35h
        int 21h
        mov [si],bx
        mov [si+2],es
        push cs
        pop  ds
        mov ah,25h
        int 21h
        pop es ds bx ax
        ret
        endp
fillPage proc
        push ss
        pop  ds
        call clearVar
        call setVar
        call allocMem
        ret
        endp
clearVar proc
        push ax cx di es
        push ss
        pop  es
        lea cx,lenClear
        lea di,memCount
        xor ax,ax
        shr cx,1
        rep stosw
        pop es di cx ax
        ret
        endp
saveOffCursor proc
        push ax ds
        mov ax,40h
        mov ds,ax
        mov ax,ds:60h
        pop ds
        mov curSize,ax
        pop ax
        endp
offCursor proc
        push ax cx
        mov ch,20h
        mov ah,1
        int 10h
        pop cx ax
        ret
        endp
openRep proc
        cmp varRap,0
        je noOpenR
        push ax bx cx dx
        xor cx,cx
        lea dx,repName
        cmp varRap,1
        je oldOpen
        mov ah,5Bh
        int 21h
        xchg ax,bx
        jnc storeOk
        mov ax,3DC1h
        int 21h
        jc badRopen
        xchg ax,bx
        mov al,2
        call setPos
        jmp short storeOk
oldOpen:
        call createF
        jnc storeOk
badRopen:
        mov varRap,0
        jmp short endOpenR
storeOk:
        mov handleRep,bx
        call clearBuffer
        call saveTitle
endOpenR:
        pop dx cx bx ax
noOpenR:
        ret
        endp
saveTitle proc
        push dx
        lea dx,mesReport
        call printFeng
        lea dx,fDate
        call fillDate
        call printF
        call fillTime
        call printF
        lea dx,mesComSt
        call printFeng
        call fillStr
        pop dx
        ret
        endp
fillDate proc
        push ax cx dx di es
        push ds
        pop  es
        mov di,dx
        mov ah,2Ah
        int 21h
        cmp varEng,0
        je fillR
        mov al,dh
        call fillNum
        mov al,'-'
        stosb
        mov al,dl
        call fillNum
        mov al,'-'
        jmp short setYear
fillR:
        mov al,dl
        call fillNum
        mov al,'.'
        stosb
        mov al,dh
        call fillNum
        mov al,'.'
setYear:
        stosb
        mov ax,'91'
        sub cx,1900
        cmp cl,100
        jb set19
        mov ax,'02'
        sub cl,100
set19:
        stosw
        mov al,cl
        call fillNum
        mov ax,' '
        stosw
        pop es di dx cx ax
        ret
        endp
fillTime proc
        push ax cx dx di es
        push ds
        pop es
        mov di,dx
        mov ah,2Ch
        int 21h
        mov al,ch
        call fillNum
        mov al,':'
        stosb
        mov al,cl
        call fillNum
        mov al,':'
        stosb
        mov al,dh
        call fillNum
        xor al,al
        stosb
        pop es di dx cx ax
        ret
        endp
fillStr proc
        push ax cx dx
        mov al,es:80h
        mov cl,al
        xor ch,ch
        cmp al,100
        jb no100
        mov dl,'1'
        call fillBuffer
        sub al,100
no100:
        aam
        or ax,'00'
        mov dl,ah
        call fillBuffer
        mov dl,al
        call fillBuffer
        lea dx,mesStrel
        call printF
        jcxz nocStr
        call printFc
nocStr:
        mov dl,0Dh
        call fillBuffer
        mov dl,0Ah
        call fillBuffer
        call writeBuf
        pop dx cx ax
        ret
        endp
fillNum proc
        aam
        or ax,'00'
        xchg al,ah
        stosw
        ret
        endp
printFeng proc
        call checkEng
        call printF
        ret
        endp
printFc proc
        push ax dx si ds
        push es
        pop  ds
        mov si,81h
nextFc:
        lodsb
        mov dl,al
        call fillBuffer
        cmp si,81h+50
        jb noWb
        call writeBuf
noWb:
        loop nextFc
        pop ds si dx ax
        ret
        endp
printF proc
        push ax dx si ds
        mov si,dx
nextChF:
        lodsb
        or al,al
        je endScan
        cmp al,1
        jne outChar
        cmp byte ptr [si],0FFh
        je changeSI
        cmp byte ptr [si],0EFh
        jne outChar
        mov si,[si+1]
        mov ds,ss:segLng
        jmp nextChF
changeSI:
        mov si,[si+1]
        jmp nextChF
outChar:
        mov dl,al
        call fillBuffer
        cmp al,0Ah
        jne nextChF
        call writeBuf
        jmp nextChF
endScan:
        pop ds si dx ax
        ret
        endp
delBlock proc
        push es
        mov es,ax
        mov ah,49h
        int 21h
        pop es
        ret
        endp
closeRep proc
        cmp varRap,0
        je noCloseR
        push ax bx
        mov bx,handleRep
        call closeF
        pop bx ax
noCloseR:
        ret
        endp
closeRap proc
        push ax bx dx
        push ss
        pop  ds
        call install
        call closeRep
        mov ax,falseSeg
        call delBlock
        mov ax,ss
        cmp segLng,ax
        je noDel0
        mov ax,segLng
        call delBlock
noDel0:
        cmp varAm,0
        je noDel1
        mov ax,segLst
        call delBlock
noDel1:
        cmp segRec,0
        je noDel2
        mov ax,segRec
        call delBlock
noDel2:
        cmp segMes,0
        je noDel3
        mov ax,segMes
        call delBlock
noDel3:
        push ds
        lds dx,dword ptr ss:off23
        mov ax,2523h
        int 21h
        lds dx,dword ptr ss:off24
        mov ax,2524h
        int 21h
        cmp ss:off1C,0
        je noRest1C
        lds dx,dword ptr ss:off1C
        mov ax,251Ch
        int 21h
        in al,61h
        and al,0FCh
        out 61h,al
noRest1C:
        pop ds
        call restCursor
        call print0D0A
        call delString
        pop dx bx ax
        ret
        endp
restCursor proc
        push ax bx cx dx
        mov cx,curSize
        mov ah,1
        int 10h
        mov dx,curPos
        mov bh,varPage
        mov ah,2
        int 10h
        pop dx cx bx ax
        ret
        endp
int23Entry proc
        push ax ds
        mov ax,@data
        mov ds,ax
        mov varBreak,1
        pop ds ax
        iret
        endp
checkBreak1 proc            ; *1
        push ax
        mov ah,1
        int 16h
        jz exitBnor1
        push ax
        xor ax,ax
        int 16h
        pop ax
        cmp varNonStop,1
        je exitBnor1
        or  al,al
        je checkAH
        cmp al,'-'              ;75
        je minSt
        cmp al,'+'              ;77
        je plSt
        cmp ax,011Bh
        je  exitBr1
        cmp al,0Dh
        je  exitBr1
        cmp al,20h
        je  exitBr1
        jmp short exitBnor1
checkAH:
        mov al,ah
        cmp al,72
        je minSr
        cmp al,80
        je plSr
        cmp al,75
        je moveL
        cmp al,77
        je moveR
        cmp al,1Eh
        je asOFF
exitBnor1:
        clc
exitBr2:
        pop ax
        ret
        endp
exitBr1:
        jmp short exitBr
moveL:
        cmp varLeft,0
        je exitBnor1
        call outScr
        sub varLeft,2
        jmp short redraw1
moveR:
        cmp varLeft,26*2
        je plSt  ;exitBnor1
        call outScr
        add varLeft,2
redraw1:
        call storeOutScr
        jmp exitBnor1
minSt:
        dec stopAs
        jns redraw ;exitBnor1
        inc stopAs
        jmp exitBnor1
plSt:
        inc stopAs
        cmp stopAs,36
        jbe redraw ;exitBnor1
        jmp minSt
minSr:
        cmp lenStr,8
        jbe minSt ;exitBnor1
        dec lenStr
        jmp short redraw   ;exitBnor1
plSr:
        cmp lenStr,18
        jae exitBnor1
        inc lenStr
redraw:
        call redrawAsm
        jmp exitBnor1
asOFF:
        call outScr
        mov varAs,0
        jmp exitBnor1
exitBr:
        push word ptr varKeyOk
        mov varKeyOk,0
        push dx
        mov color,3
        lea dx,mesStop1
        call who
        pop dx
        jnc noOk1
        call print0D
        cmp varKeyOk,2
        stc
        jne noOk1
        call outScr
        mov varAs,0
        clc
noOk1:
        pop word ptr varKeyOk
        jmp exitBr2
checkBreak proc            ;*2
        push ax
        cmp varBreak,1
        stc
        je exitBreak1
        mov ah,1
        int 16h
        jz exitBnor
        push ax
        xor ax,ax
        int 16h
        pop ax
        cmp varNonStop,1
        je exitBreak1
        cmp ax,011Bh
        je  exitBreak
        cmp al,0Dh
        je  exitBreak
        cmp al,20h
        je  exitBreak
        cmp ax,1E00h
        je setVasm
exitBnor:
        clc
exitBreak1:
        pop ax
        ret
        endp
exitBreak:
        push word ptr varKeyOk
        mov varKeyOk,0
        push dx
        mov color,3
        lea dx,mesStop
        call who
        pop dx
        jnc noOk
        call print0D
        cmp varKeyOk,2
        stc
        jne noOk
        mov varBreak,1
noOk:
        pop word ptr varKeyOk
        jmp exitBreak1
setVasm:
        mov varAs,1
        call storeScr
        jmp exitBnor
; ????
moveIPCS proc
        push ax
        mov ax,ds:myTitle+24
        mov ds:myTitle+20,ax
        mov ax,ds:myTitle+26
        mov ds:myTitle+22,ax
        pop ax
        ret
        endp
; !!!!!
getIPCS proc
        push ax bx cx dx
        mov ax,ds:[myTitle+8 ]
        add ax,ds:[myTitle+22]
        mov dx,16
        imul dx
        mov cx,ds:[myTitle+20]
        mov reloIP,cx
        add ax,cx
        adc dx,0
        mov poslo,ax
        mov poshi,dx
        pop dx cx bx ax
        ret
        endp
; ?????
setPos1 proc
        push ax cx dx
        mov dx,poslo
        mov cx,poshi
        call seekF
        pop dx cx ax
        ret
        endp
writeHead proc
        push ax cx dx
        mov al,0
        call setpos
        lea dx,myTitle
        mov cx,30
        call writeF
        pop dx cx ax
        ret
        endp
        .data
memoryErr       db 10,9,9,'Г*** Insufficient memory to run MultiScan ***',10,0
mesReport       db 13,10,'                    <<< Отчет о проведенном тест'
                db 'ировании >>>'
                db 13,10,'                             антивирусом MultiScan'
                db 13,10,13,10,'Дата создания отчета : ',0
                db 13,10,'                  <<< Scanning result by antivirus '
                db 'MultiScan >>>'
                db 13,10,13,10,'Creation time : ',0
                dw 0EE01h,mesReport
mesComSt        db 13,10,'Командная строка при запуске (',0
                db 13,10,'Command string (',0
                dw 0EE01h,mesComSt
mesStrel        db ') ->',0
end
