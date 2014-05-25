
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Это служило для добавления сигнатур в паямть, но многое было добавлено.
;

public  insertCE,insertR,insertBoot,insertName,complete,openSig
public  copyPath,readLng,decodVint,openIni,openRec,readMes
public  openMsb,openFnt,mesCreat,copyPath,copyName,mesSigOver,writeBigDec
;extrn   arrayCE:near,arrayR21:near,arrayR13:near,arrayBoot:near,arrayName:near
extrn   sigOff:near,memOff:word,nameVir:near,sizeVir:word,bootOff:word
extrn   formDI_CX:near,path:near,segLng:word,varEng:byte
extrn   delString:near,printPath:near,color:byte,writeChar:near,writeDec:near
extrn   setPos:near,readF:near,closeFile:near,curPos:word,falseSeg:word
extrn   procDec:word,print0D0A:near,printEng:near,print0D:near,segMes:word
extrn   pointMes:word,startMes:word,varMes:byte,baseSeg:word,typeNum:byte
extrn   getWord:near,findPath:near,findNextP:near,fname:near,writeF:near
extrn   diskType:byte,varMb:byte,writeDateTime:near,tableMes:word,allocMemAX:near
;extrn   limitCE:near,limitR21:near,limitR13:near,limitBoot:near,limitName:near
extrn   countSerr:byte,beep2:near,lngName:near,createF:near,appendF:near
extrn	load80:near,closeF:near
extrn   iniSigOff:word,cureMemory:byte,tabOff:byte,storeCX:byte,curVer:byte
extrn   pBaseRead:word,pBaseLo:word,pBaseHi:word
        .model small
        .code
decodVint proc
        push ax bx cx dx es
        mov es,falseSeg
        mov cx,4
        mov bx,7C00h+1EEh
scan:
        mov al,es:[bx+4]
        cmp al,1
        je found
        cmp al,4
        jb nextCell0
        cmp al,6
        jbe found
nextCell0:
        sub bx,10h
        loop scan
        stc
        jmp short notFound
found:
        mov cx,es:[bx+6]
        mov dh,es:[bx+1]
        call makeSI
        cmp si,di
        je  notFound
        cmp decSecs,0
        clc
        jne notFound
        lea dx,mesDecod
        call printEng
        xchg si,di
        call getMemS
        jc notFound
        call scrollIni
        mov dl,diskType
        xor dh,dh
        mov cx,1
        call getCXDX
decodMore:
        call decodCyl
        call writeScroll
        inc si
        inc ch
        jne cmpSi
        add cl,40h
        jne cmpSi
        add dh,40h
cmpSi:
        cmp si,di
        jbe decodMore
        call print0D0A
        clc
notFound:
        pop es dx cx bx ax
        ret
        endp

getCXDX proc
        push ax
        mov ax,si
        mov ch,al       ; дорожка в ch
        push cx
        mov cl,4
        shl ah,cl       ; ah <<= 4
        pop cx
        mov al,3Fh
        and ah,al
        and cl,al
        not al
        push ax
        and ah,al
        or dh,ah        ; поверхность в dh
        pop ax
        shl ah,1
        shl ah,1
        and ah,al
        or cl,ah        ; сектор в cl
        pop ax
        ret
        endp

scrollIni proc
        push ax di
        sub di,si
        mov sizeS,di
        mov startS,si
        mov al,maxSec
        mul maxHead
        shr ax,1
        mov addKb,ax
        pop di ax
        ret
        endp

writeScroll proc
        push ax bx cx dx
        call print0D
        mov dl,' '
        call writeChar
        mov ax,si
        sub ax,startS
        mov bx,1000
        mul bx
        div sizeS
        mov bx,10
        xor dx,dx
        div bx
        call writePol
        mov byte ptr curPos,23
        mov color,0
        xchg ax,dx
        call writeDec
        mov dl,'.'
        call writeChar
        xchg ax,dx
        call writeDec
        mov dl,'%'
        call writeChar
        mov byte ptr curPos,53
        mov color,11
        lea dx,mesSk
        call printPath
        mov ax,addKb
        add decSecs,ax
        adc word ptr decSecs+2,0
        mov ax,decSecs
        mov dx,decSecs+2
        call writeBigDec
        lea dx,mesKb
        call printPath
        pop dx cx bx ax
        ret
        endp

writeBigDec proc
        push ax bx cx dx si
        mov si,10
        xor cx,cx
cicl:
        inc cx
        push ax
        mov ax,dx
        xor dx,dx
        div si
        xchg ax,bx
        pop ax
        div si
        xchg bx,dx
        push ax
        or ax,dx
        pop ax
        push bx
        jnz cicl
outBig:
        pop dx
        or dl,30h
        call writeChar
        loop outBig
        pop si dx cx bx ax
        ret
        endp

writePol proc
        push ax dx
        shr ax,1
        jz writeSc2
        mov color,01110000b
        mov dl,'▒'
        push ax
writeSc:
        call writeChar
        dec al
        jnz writeSc
        pop ax
writeSc2:
        sub ax,50
        jz exitSc
        neg ax
        mov color,01000000b
        mov dl,'░'
writeSc3:
        call writeChar
        dec al
        jnz writeSc3
exitSc:
        pop dx ax
        ret
        endp

decodCyl proc
        push ax bx cx dx es
        mov es,baseSeg  ; segOne
        xor bx,bx
nextHead:
        mov al,maxSec
        mov ah,2
        int 13h
        call decodSec
        mov al,maxSec
        mov ah,3
        int 13h
        inc dh
        cmp dh,maxHead
        jb nextHead
        pop es dx cx bx ax
        ret
        endp

decodSec proc
        push ax bx
        mov al,maxSec
nextDec:
        call word ptr ds:procDec
        dec al
        jnz nextDec
        pop bx ax
        ret
        endp

getMemS proc
        push ax bx cx dx
        mov dx,word ptr diskType
        mov ah,8
        int 13h
        jc badMem
        xchg ax,cx
        and ax,63
        mov maxSec,al
        inc dh
        mov maxHead,dh
badMem:
        pop dx cx bx ax
        ret
        endp

makeSI proc
        push cx dx
        shr cl,1
        shr cl,1
        and dh,11000000b
        or dh,cl
        mov cl,4
        shr dh,cl
        mov dl,ch
        xchg si,dx
        pop dx cx
        ret
        endp

readMes proc
        cmp varMes,0
        je exitRM
        push ax bx cx dx
        call openMes
        jc notExistM
        xchg ax,bx
        mov al,2
        call setPos
        or dx,dx
        je checkAx
setNorm:
        mov ax,60000
        jmp short readM
checkAx:
        or ax,ax
        je closeMes
        cmp ax,60000
        ja setNorm
readM:
        inc ax
        mov pointMes,ax
        mov startMes,ax
        add ax,5000
        call allocMemAX
        jc closeMes
        mov segMes,ax
        call readInSeg
        jc closeMes
        mov cx,ax
        call setupMes
closeMes:
        call closeF
notExistM:
        pop dx cx bx ax
exitRM:
        ret
        endp

upChar proc
        lodsb
        cmp al,'A'
        jb notUp
        cmp al,'Z'
        jb notUp
        cmp al,'a'
        jb notUp
        cmp al,'z'
        ja notUp
        and al,0DFh
        mov byte ptr [si-1],al
notUp:
        ret
        endp

setupMes proc
        push si di ds
        mov ds,segMes
        xor si,si
checkName:
        call upChar
        cmp al,'0'
        jb find0A
        cmp al,'9'
        jbe foundNam
        cmp al,'A'
        jb find0A
        cmp al,'Z'
        ja find0A
foundNam:
        mov di,ss:pointMes
        dec si
        mov [di],si
        inc di
        inc di
        mov ss:pointMes,di
cicNamC:
        call upChar
        cmp al,' '
        je find0A
        loop cicNamC
endMes:
        mov byte ptr [si],0
endMes1:
        pop ds di si
        ret
find0A:
        dec cx
        jz endMes
scanMes:
        lodsb
        cmp al,0Ah
        je set00
        loop scanMes
        jmp endMes
set00:
        mov byte ptr [si-1],0
        dec cx
        jz endMes1
        jmp checkName
        endp

readInSeg proc
        push ds
        mov ds,ax
        xor al,al
        call setPos
        xor dx,dx
        mov cx,65500
        call readF
        pop ds
        ret
        endp

readLng proc
        cmp varEng,1
        je exitRL
        push ax bx cx dx
        call openLng
        jc notExistL
        xchg ax,bx
        mov al,2
        call setPos
        or dx,dx
        jne closeLng
        or ax,ax
        je closeLng
        call allocMemAX
        jc closeLng
        mov segLng,ax
        call readInSeg
        jc closeLng
        mov cx,ax
        call setupLng
closeLng:
        call closeF
notExistL:
        pop dx cx bx ax
exitRL:
        ret
        endp

setupLng proc
        push ax bx cx si di es
        mov ax,segLng
        mov es,ax
        xchg baseSeg,ax
        push ax
        lea bx,tableMes
        mov typeNum,10
        xor si,si
nextChv:
        lods byte ptr es:[si]
        cmp al,'{'
        loopne nextChv
        jcxz exitSetup1
        mov di,si
        push cx si
        lea si,curVer
        mov cx,6
        rep cmpsb
        pop si cx
        je setVarLng
exitSetup1:
        mov ah,49h
        int 21h
        mov segLng,ds
        jmp short exitSetup
setVarLng:
        mov varEng,2
nextStro:
        cmp word ptr [bx],-1
        je exitSetup

nextCha:
        lods byte ptr es:[si]
        cmp al,'{'
        loopne nextCha
        jcxz exitSetup
        mov di,si
nextChb:
        lods byte ptr es:[si]
        cmp al,'['
        je setColo
        cmp al,1
        jne nextChc
        mov byte ptr es:[si-1],' '
nextChc:
        cmp al,'}'
        loopne nextChb

        jcxz exitSetup
        dec si
        cmp si,di
        je nextStro
        mov byte ptr es:[si],0
        inc si
        push si
        mov si,[bx]
        inc bx
        inc bx
findMark:
        dec si
        lodsw
        cmp ax,0EE01h
        jne findMark
        mov byte ptr [si-1],0EFh
        mov [si],di
        pop si
        jmp nextStro

setColo:
        push cx si
        mov cx,3
        call getWord
        mov ah,cl
        pop si cx

        jc nextChc

        or al,al
        je  nextChc
        cmp al,0EEh
        jae nextChc
        mov byte ptr es:[si-1],1
        mov byte ptr es:[si],al
nextChd:
        cmp ah,2
        je nextChc

        inc ah
        inc si
        mov byte ptr es:[si],0Dh
        loop nextChd

exitSetup:
        pop baseSeg
        pop es di si cx bx ax
        ret
        endp

copyPath proc
        push ax cx si di ds es
        mov ds,es:2Ch
        mov si,1
cicBody:
        dec si
        lodsw
        or ax,ax
        jnz cicBody
        inc si
        inc si
        push ss
        pop es
        lea di,path
nextSym:
        lodsb
        stosb
        or al,al
        jne nextSym
        pop es ds di si cx ax
        ret
        endp

copyName proc
        push ax cx si di es
        push ss
        pop es
        call formDI_CX
        mov si,dx
transName:
        lodsb
        stosb
        or al,al
        jnz transName
        pop es di si cx ax
        ret
        endp

openMsb proc
        push dx
        lea dx,msbName
        or ax,ax
        je firstF
        call findNextP
        jmp short openFn
        endp

openFnt proc
        push dx
        call copyPath
        lea dx,fntName
        jmp short openIT
        endp

openMes proc
        push dx
        call copyPath
        lea dx,mesName
        jmp short openIT
        endp

openRec proc
        push dx
        call copyPath
        lea dx,recName
        jmp short openIT
        endp

openIni proc
        push dx
        call copyPath
        lea dx,iniName
        jmp short openIT
        endp

openLng proc
        push dx
        call copyPath
        lea dx,lngName
        jmp short openIT
        endp

openSig proc
        push dx
        call fillPointer
        lea dx,sigName
        or ax,ax
        je firstF
        call findNextP
        jmp short openFn
        endp
firstF:
        call copyPath
        call copyName
        call findPath
openFn:
        jc  noSig
        lea dx,fname

openIT proc
        call copyName
        lea dx,path
        mov ax,3D40h
        int 21h
noSig:
        pop dx
        ret
        endp

fillPointer proc
        push ax
        mov ax,pointerCE
        mov startCE,ax
        mov ax,pointerName
        mov startName,ax
        pop ax
        ret
        endp

fillBor proc
        xchg dx,ax
        stosw
        xchg dx,ax
        stosw
        ret
        endp

moveName proc
        cmp varMb,0
        je noMove
        push ax cx dx si di es

;        mov ax,-1
;        call allocMemAX
;        jc allocError
        mov es,baseSeg

        mov newPoint,120h
        mov si,startName
        mov di,pointerName

        xor ax,ax

        call moveSig    ; скопировать имена

        mov ax,1

        mov si,startCE
        mov di,pointerCE

        call moveSig   ; скопировать CE

        mov di,110h
        call fillBor    ; заполнить начало и конец
        call setNameCE  ; настроить сигнатуры CE

        call fillTit

        call uucode

;        mov ah,49h
;        int 21h
        mov ax,pBaseRead
        sub pBaseLo,ax
        sbb pBaseHi,0
	call load80
allocError:
        pop es di si dx cx ax
noMove:
        ret
        endp

fillTit proc
        push ax si di
        mov di,100h
        mov ax,'KV'     ; VK,len,key,sum,ver    ; 8
        stosw
        mov ax,newPoint
        sub ax,110h
        stosw
        xchg ax,cx
        in al,40h
        inc ax
        stosb
        xor ah,ah
        mov si,110h
codeIt:
        xor es:[si],al
        xor ah,es:[si]
        inc si
        loop codeIt
        mov al,ah
        stosb
        mov ax,'21'
        stosw
        pop di si ax
        ret
        endp

uucode proc
        push ax bx cx si di ds
        lea si,strBeg
        mov di,newPoint
        mov cx,di
        sub cx,100h
        push cx
        mov cx,offset lenBegS
        rep movsb
        pop cx
        push es
        pop ds
        mov si,100h
newStr:
        mov dx,8        ;14
        mov bx,7
        cmp ss:varMb,1
        je newBlock
        mov dx,14
        mov bx,3
newBlock:
        push cx
        mov cx,bx        ; 3
        xor ax,ax
uuBlock:
        lodsb
        cmp bl,7
        je addOne
        shl al,1
        pushf
        shl al,1
        rcl ah,1
        popf
        rcl ah,1
        jmp short shiftTwo
addOne:
        shl al,1
        rcl ah,1
        jmp short shiftOne
shiftTwo:
        shr al,1
shiftOne:
        shr al,1
        add al,33
        stosb
        loop uuBlock
        mov al,ah
        add al,33
        stosb
        pop cx
        cmp cx,bx        ;3
        jbe endTrans
        sub cx,bx        ;3
        dec dx
        jnz newBlock
        mov ax,0A0Dh
        stosw
        jmp newStr
endTrans:
        pop ds
        push ds
        lea si,strEnd
        mov cx,offset lenEndS
        rep movsb
        sub di,newPoint
        push bx
        push di
        call formDI_CX
        lea dx,path
        cmp word ptr [si-4],'SM'        ; .MS
        jne setExt
        cmp byte ptr [si-2],'B'         ;  B
        jne setExt
        call appendF
        jmp short writeMsNow
setExt:
        mov word ptr [si-4],'SM'        ; .MS
        mov byte ptr [si-2],'B'         ;  B
        call createF
writeMsNow:
        pop cx
        jc openErr
        call writeDateTime
        mov dx,newPoint
        push es
        pop  ds
        call writeF
        call closeF
        jc openErr
        push ss
        pop  ds
        call print0D
        lea dx,mesCreat
        call printEng
        lea dx,path
        call printPath
        call print0D0A
openErr:
        pop bx
        pop ds di si cx bx ax
        ret
        endp

setOffName proc
        push ax si
        lodsw
        lodsb
        xor ah,ah
        add si,ax
        lodsb
        cmp al,4
        je nameOk
        call beep2
nameOk:
        sub [si],di
        add word ptr [si],120h
        pop si ax
        ret
        endp

setNameCE proc
        push ax si di ds
        mov di,startName
        push es
        pop  ds
        mov si,dx

nextCellCE:
        lodsw
        cmp ax,-1
        je endSetCE

        call setOffName

        mov al,ah
        cbw
        add si,ax
        jmp nextCellCE

endSetCE:
        pop ds di si ax
        ret
        endp

moveSig proc
        push cx si di
        mov cx,di
        sub cx,si
        mov di,newPoint
        push ds
        mov ds,sigSeg
        mov dx,di               ;начало сигнатур
        rep movsb
        pop ds
        or ax,ax
        je noSet_1
        mov ax,-1
        stosw
        stosw
        mov ax,di               ;хвост сигнатур
        add di,4
noSet_1:
        mov newPoint,di
        pop di si cx
        ret
        endp

complete proc
        push ax dx si di
        call moveName           ;*

        mov si,offset iniSigOff ; si указывает на пеpеменную в cs со стаpым
                                ; смещением
        mov di,pointerCE        ; в di хpанится указатель на хвост сигнатуp
        mov dx,startCE          ; в dx стаpое смещение начала сигнатуp
        call complSig
        mov pointerCE,di

        pop di si dx ax
        ret
        endp

complSig proc
        cmp di,dx
        je noCompl
        push ax es
        mov es,sigSeg
        mov ax,-1
        stosw           ; поставить -1
        stosw           ; поставить -1
        xchg dx,ax
        xchg ax,[si] ; поменять местами стаpый и новый указатели
        stosw
        mov ax,es
        xchg ax,[si+2] ; поменять местами стаpый и новый указатели
        stosw
        pop es ax
noCompl:
        ret
        endp

moveBlock proc
        push ax cx
        lodsb
        stosb
        xor ah,ah
        xchg cx,ax
        rep movsb
        pop cx ax
        ret
        endp

setupPoint proc
        push ax
        mov ax,di
        sub ax,pointerCE
        dec ax
        dec ax
        xchg di,pointerCE
        inc di
        stosb
        pop ax
        ret
        endp

insertCE proc   ;***
        push ax cx si di es

        call allocMemoryES
        jc exitICE
        mov di,pointerCE
        call checkOver
        jc exitICE
        mov ax,'f'
        stosw
        lea si,sigOff
        movsw
        call transSig
        lea si,tabOff
        call moveBlock
        call moveBlock
        mov ax,sizeVir
        stosw
        call setupPoint
exitICE:
        pop es di si cx ax
        ret
        endp

insertR proc
        push ax cx si di es

        call allocMemoryES
        jc exitIR
        mov di,pointerCE
        call checkOver
        jc exitIR

        mov ax,'r'
        stosw
        mov ax,memOff
        stosw
        lea si,sigOff+2
        call transSig   ;off mem|sig file|off name|size vir|jmp xxxx|? int|
        lea si,cureMemory
        call moveBlock
        call setupPoint
exitIR:
        pop es di si cx ax
        ret
        endp

insertBoot proc
        push ax cx si di es

        call allocMemoryES
        jc exitIB
        mov di,pointerCE
        call checkOver
        jc exitIB

        mov ax,'b'
        stosw
        mov ax,bootOff
        stosw
        lea si,sigOff+2

        call transSig   ;off boot|sig file|off name| 0 | cx | dh |

        lea si,storeCX
        call moveBlock
        call setupPoint
exitIB:
        pop es di si cx ax
        ret
        endp

insertName proc
        push ax si di es

        call allocMemoryES
        jc exitIN
        mov di,pointerName
        call checkOver1
        jc exitIN
        mov di,pointerName

        lea si,nameVir
nextChar:
        lodsb
        stosb
        or al,al
        jne nextChar

        mov pointerName,di
exitIN:
        pop es di si ax
        ret
        endp

allocMemoryES proc
        push ax bx
        mov ax,sigSeg
        or ax,ax
        clc
        jne getPointer
        mov bx,26000/16
        mov ah,48h
        int 21h
        jc getPointer
        mov sigSeg,ax
        mov startName,0
        mov pointerName,0
        mov startCE,6000
        mov pointerCE,6000
getPointer:
        mov es,ax
        pop bx ax
        ret
        endp

checkOver proc
        mov si,26000-80
        jmp short checkOverX
checkOver1:
        mov si,6000-80
checkOverX:
        cmp si,di
        ja noOver
        push bx
        mov bx,pointerCE
        add bx,48
        shr bx,1
        shr bx,1
        shr bx,1
        shr bx,1
        mov ah,4Ah
        int 21h
        pop bx

        call complete

        mov sigSeg,0
        call allocMemoryES
        mov di,pointerCE
        jnc noOver

        push dx
        lea dx,mesSigOver
        call beep2
        call printEng
        mov countSerr,99
        pop dx
        stc
noOver:
        ret
        endp

transSig proc
        push ax cx
        call moveBlock
        mov al,4
        stosb
        mov ax,pointerName      ;curName
        stosw
        mov ax,sizeVir
        or ax,ax
        jns lenOk
        xor ax,ax
lenOk:
        stosw
        pop cx ax
        ret
        endp
        .data
mesSigOver      db 10,'Переполнение при загрузке сигнатур.',10,0
                db 10,'Memory overflow',10,0
                dw 0EE01h,mesSigOver
strBeg          db 13,10,'   <<<  Дополнение к анивирусной базе программы MultiScan >>>'
                db 13,10,'                      для версии 2.5+.',13,10,13,10
                db 'BEGIN:',13,10
lenBegS         equ $-strBeg
strEnd          db 13,10,'END.'
lenEndS         equ $-strEnd
mesDecod        db 10,' Подождите, пока расшифруется жесткий диск ...',10,0
                db 10,' Please wait, while your HD will be decoded ...',10,0
                dw 0EE01h,mesDecod
mesSk           db '( ',0
mesKb           db ' Kb )',0
mesCreat        db 'Создан файл : ',0
                db 'Created file : ',0
                dw 0EE01h,mesCreat
sigName         db '*.sig',0
msbName         db '*.msb',0
iniName         db 'mscan.ini',0
fntName         db 'mscan.fnt',0
recName         db 'MSCAN.REC',0
mesName         db 'mscan.mes',0
sigSeg          dw 0
startCE         dw ?;arrayCE
pointerCE       dw ?;arrayCE
startName       dw ?;arrayName
pointerName     dw ?;arrayName
newPoint        dw ?
maxSec          db ?
maxHead         db ?
sizeS           dw ?
startS          dw ?
addKb           dw ?
decSecs         dw 0,0
        end
