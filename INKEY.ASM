
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Это было придумано для ввода сообщений, но многое было добавлено
;

public  settime,writeF,who,readF,setPos,openFile,setDta,print,getChar
public  printEng,stopTime,outEnd,mesPaus,checkEng,createMem,writeMem
public  closeMem,createF,appendF,openF,closeF,seekF,writeBoot,mesOpenErr
extrn   time:word,date:word,varKeyOk:byte,color:byte,varEng:byte,color2:byte
extrn   writeChar:near,delToEnd:near,print0D0A:near,mesYN:near,segLng:word
extrn   print0D0A1:near,analizErr:near,closeRap:near,varAs:byte,varBS:byte
extrn   myDta:byte,varPage:byte,pVer:byte,path:byte,color:byte,curPos:word
extrn   longFlo:word,longFHi:word,offCursor:near,restCursor:near,adrSub:word
extrn   count0A:byte,mesAnyKey:near,delString:near,var0D:byte,checkBreak:near
extrn   outScr:near,attrib:byte,beep3:near,varRap:byte,outPic:near
extrn   handleMem:word,varFM:byte,mesCreat:near,myOff21:word,mySeg21:word
extrn   print0D:near,copyPath:near,copyName:near,rightBound:byte,segVirInf:word
extrn   printPath:near,varAA:byte,fillNewSig:near,saveSig:byte,writeNewMem:near
extrn   varMS:byte,offMS:word,offFS:word,newName:byte,fillWord:near
extrn   printOver:near,writeNewBoot:near,baseSeg:word,offBS:word,varSaveB:byte
        .model small
        .code
settime proc
        push ax cx dx
        mov cx,time
        mov dx,date
        and cl,11100000b
        mov time,cx
        mov ax,5701h
        int 21h
        pop dx cx ax
        ret
        endp
writeF proc
        push dx
        add dx,cx
        jnc oldWrite
        sub cx,dx
oldWrite:
        pop dx
        push ax
        mov ah,40h
        int 21h
        jnc checkErr
        call analizErr
        jmp short noCheckErr
checkErr:
        cmp ax,cx
        jnc noCheckErr
        call printOver
noCheckErr:
        pop ax
        ret
        endp
who proc
        push ax dx
        call checkBreak
        jc  keyEsc1
        cmp varKeyOk,1
        je  keyOk1
        cmp varKeyOk,2
        je  keyEsc1
        mov pver,0
        call printEng
        lea dx,mesYN
        call printEng
        call restCursor
repeat:
        call getChar
        cmp al,'a'
        jb noDown
        sub al,32
noDown:
        cmp al,27
        je keyEsc
        cmp al,'N'
        je keyEsc
        cmp al,'Y'
        je keyOk
        cmp al,13
        je keyOk
        cmp al,' '
        je putVer
        cmp al,'A'
        je putAll
        cmp al,'I'
        je putIgn
        cmp al,'Q'
        je putQuit
        jmp short repeat
putVer:
        mov pVer,1
keyOk:
        call offCursor
        mov dl,'Y'
keyOk2:
        mov color,11
        call writeChar
keyOk1:
        clc
exitKey:
        pop dx ax
        ret
        endp
keyEsc:
        call offCursor
        mov dl,'N'
keyESC2:
        mov color,1
        call writeChar
keyESC1:
        call print0D0A1
        stc
        jmp exitKey
putAll:
        call offCursor
        mov varKeyOk,1
        mov dl,'A'
        jmp short keyOk2
putIgn:
        call offCursor
        mov varKeyOk,2
        mov dl,'I'
        jmp short keyESC2
putQuit:
        mov dl,'Q'
        call writeChar
        call print0D0A
        call outScr
        call closeRap
        mov ax,4CFFh
        int 21h
getChar proc
        push bx cx dx
        cmp stopTime,0
        je readKey
        xor ah,ah
        int 1Ah
        mov bx,dx
        add bx,stopTime
repeat0:
        mov ah,1
        int 16h
        jnz readKey
        xor ah,ah
        int 1Ah
        cmp dx,bx
        jne repeat0
        mov al,'n'
        jmp short exitGet
readKey:
        xor ax,ax
        int 16h
exitGet:
        pop dx cx bx
        ret
        endp
readF proc
        push dx
        add dx,cx
        jnc oldRead
        sub cx,dx
oldRead:
        pop dx
        mov ah,3Fh
        int 21h
        jnc noCheckErr1
        call analizErr
noCheckErr1:
        ret
        endp
seekF proc
        mov ax,4200h
        int 21h
        ret
        endp
setPos proc
        xor cx,cx
        xor dx,dx
        mov ah,42h
        int 21h
        ret
        endp
openFile proc
        cmp longFHi,0
        je  openOk
        cmp longFlo,24
        jb  openBad
openOk:
        push dx
        lea dx,path
        mov ax,3DC0h
        int 21h
        jnc skipOerr
	lea dx,mesOpenErr
        call printEng
        stc
skipOerr:
        pop dx
	
openBad:
        ret
        endp
setDta proc
        push ax dx
        lea dx,myDta
        mov ah,1ah
        int 21h
        pop dx ax
        ret
        endp
skipSTR proc
        lodsb
        cmp al,1
        jne check0
        lodsb
        cmp al,0EEh
        jb skipSTR
        inc si
        inc si
check0:
        or al,al
        jne skipSTR
        ret
        endp
checkEng proc
        push ax si
        cmp varEng,0
        je exinEng
        mov si,dx
        call skipSTR
        cmp varEng,2
        jne exinEng0
        call skipSTR
exinEng0:
        mov dx,si
exinEng:
        pop si ax
        ret
        endp
printEng proc
        call checkEng
        call print
        ret
        endp
print proc
        push ax bx cx dx si ds
        cld
        mov si,dx
        mov ss:count0A,15
getNext:
        lodsb
        or al,al
        jne check13
        xor si,si
        xchg si,ss:adrSub
        or si,si
        jne getNext
        jmp endPrint
check13:
        cmp al,13
        je getNext
        cmp al,10
        je fun0E
        cmp al,' '
        je checkCur
        cmp al,9
        jne checkNext
        mov dx,ss:curPos
        mov cx,dx
        add cx,8
        and cx,0FFF8h
        sub cx,dx
        mov dl,' '
outTab:
        call writeChar
        loop outTab
        jmp short getNext
checkNext:
        cmp al,1
        jne checkC2
        lodsb
        cmp al,0FFh
        jne checkC3
getAdr:
        lodsw
getAdr1:
        mov si,ax
        jmp short getNext
fun0E:
        call print0D0A
        dec ss:count0A
        jnz getNext
        call outPause
        jmp getNext
checkC3:
        cmp al,0EEh
        je  getAdr
        cmp al,0FEh
        jne checkJmp
        lodsw
        mov adrSub,si
        jmp getAdr1
checkJmp:
        cmp al,0EFh
        jne changeCol
        lodsw
        mov ds,segLng
        jmp getAdr1
changeCol:
        cmp al,12
        jne noClAA
        mov ss:varAA,0
noClAA:
        mov ss:color,al
        jmp getNext
checkCur:
        push ax
        mov ax,ss:curPos
        add al,12
        cmp al,ss:rightBound    ; 70
        pop ax
        jb  printChar
        cmp byte ptr ss:var0D,0
        jne printChar
        call print0D0A
checkC2:
        cmp al,'~'
        jne printChar
        mov al,ss:color
        xchg al,ss:color2
        mov ss:color,al
        jmp getNext
printChar:
        mov dl,al
        call writeChar
        jmp getNext

endPrint:
        call delToEnd
        pop ds si dx cx bx ax
        ret
        endp
outPause proc
        push ax dx ds
        push ss
        pop  ds
        lea dx,mesAnyKey
        call printEng
        call getChar
        cmp ax,1700h
        jne delStr
        call outCommand
delStr:
        call delString
        pop ds dx ax
        ret
        endp
outCommand proc
        push ax bx cx dx
        push curPos
nextNam0:
        xor cx,cx
nextNam:
        call scrollWin
        mov curPos,500h+30
        mov ax,lenMess
        mul cx
        lea dx,mesCC
        add dx,ax
        mov bx,dx
        cmp byte ptr [bx],0
        je nextNam0
        mov color,0Ah
        call print
        mov color,3
        lea dx,mesPal
        call print
        push cx
        xor ah,ah
        int 1Ah
        mov bx,dx
        add bx,16
waitTime:
        mov ah,1
        int 16h
        pop cx
        jnz backKey
        push cx
        xor ah,ah
        int 1Ah
        cmp dx,bx
        jb waitTime
        pop cx
        inc cx
        jmp nextNam
backKey:
        xor ax,ax
        int 16h
        mov color,3
        pop curPos
        pop dx cx bx ax
        ret
        endp
scrollWin proc
        push ax bx cx dx
        mov bh,varPage
        mov bl,7
        mov cx,100h+20
        mov dx,500h+58
        mov ax,601h
        int 10h
        pop dx cx bx ax
        ret
        endp
outEnd proc
        cmp varAs,0
        je noPaus
        push ax dx
        lea dx,mesPaus
        call printEng
        call getChar
        cmp ax,1E00h
        jne noASoff
        call outScr
        mov varAs,0
noASoff:
        pop dx ax
noPaus:
        ret
        endp
createMem proc
        cmp varFM,0
        je skipCreat
        push ds
        mov ds,segVirInf
        mov word ptr ds:0,2
        pop ds
skipCreat:
        ret
        endp
writeBoot proc
        cmp varBS,0
        je skipWriteBoot
        cmp varSaveB,0
        je skipWriteBoot
        push ax
        mov saveSig,1
        mov ax,offBS
        xchg ax,offFS
        call fillNewSig
        call writeNewBoot
        mov offFS,ax
        pop ax
skipWriteBoot:
        ret
        endp
writeMem proc
        cmp varMS,0
        je skipWriteMS
        push ax dx es
        push ds
        pop  es
        push di
        xchg di,ax
        lea di,newName
        push ax
        mov ax,dx
        call fillWord
        mov al,':'
        stosb
        pop ax
        call fillWord
        pop di
        mov es,dx
        mov saveSig,1
        mov ax,offMS
        xchg ax,offFS
        call fillNewSig
        call writeNewMem
        mov offFS,ax
        pop es dx ax
skipWriteMS:
        cmp varFM,0
        je skipWrite
writeMS:
        push ax cx si di ds es
        push di dx
        xchg di,ax
        mov es,segVirInf
        mov di,es:0
        stosw
        mov ax,dx
        stosw
        pop ds si
        mov cx,40h-4
        rep movsb
        mov es:0,di
        pop es ds di si cx ax
skipWrite:
        ret
        endp
createF proc
        push cx
        xor cx,cx
        mov ah,3Ch
        int 21h
        xchg bx,ax
        pop cx
        ret
        endp
appendF proc
        mov ax,3DC1h
        int 21h
        xchg bx,ax
        mov al,2
        call setPos
        ret
        endp
openF proc
        mov ax,3DC0h
        int 21h
        xchg bx,ax
        ret
        endp
closeF proc
        pushf
        mov ah,3Eh
        int 21h
        jnc closeOk
        popf
        stc
        ret
closeOk:
        popf
        ret
        endp
closeMem proc
        cmp varFM,0
        je skipClose
        push ax bx cx dx si
        lea si,nameMem
        mov dx,si
        call copyPath
        call copyName
        lea dx,path
        call createF
        jc writeErrM

        push ds
        mov ds,segVirInf
        mov dx,2
        mov cx,ds:0
        sub cx,dx
        call writeF
        pop ds
        call closeF
        jc writeErrM
        call print0D
        lea dx,mesCreat
        call printEng
        lea dx,path
        call printPath
        call print0D0A
writeErrM:
        pop si dx cx bx ax
skipClose:
        ret
        endp
        .data
stopTime        dw 0
mesOpenErr	db ' - ошибка открытия файла.',10,0
		db ' - file open error.',10,0
                dw 0EE01h,mesOpenErr
mesPaus         db ' нажмите любую клавишу ...',0
                db ' press any key ...',0
                dw 0EE01h,mesPaus
nameMem         db 'memory.dat',0
mesCC           db '                     ',0
lenMess         equ $-mesCC
                db '                     ',0
                db ' Зарегистрированные  ',0
                db '    пользователи:    ',0
                db '                     ',0
                db '                     ',0
                db '   Дмитрий Баев      ',0
                db '     Павел Лукашук   ',0
                db ' Александр Клименко  ',0
                db '     Павел Колесников',0
                db '  Валентин Колесников',0
                db '                     ',0
                db '    Спасибо всем,    ',0
                db '   кто использует    ',0
                db ' программу MultiScan ',0
                db '                     ',0
                db '                     ',0
                db '                     ',0
                db 0
mesPal          db '        │',1,8,'█',0
end
