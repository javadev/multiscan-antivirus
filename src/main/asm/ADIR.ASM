
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модуль сканирует каталоги, используя int25. Применялся для вирусов
; Driver1024. Также располагает модулем проверки стелс-вирусов.
; FAT32 не проверяет. 

public  antiDir,memoryLo,whoB
extrn   print:near,buf:near,path:word,who:near,mesWho:near,mesDir20:near
extrn   print0D:near,tableRoot:word,itDir:near,mesDir_d:near
extrn   mesWar:near,printEng:near,color:byte,printOk:near,setDta:near
extrn   checkBreak:near,analizErrDir:near,device:byte,myDta:word
extrn   verDos:byte,varKeySt:byte,outTSR:near,longFlo:word,longFhi:word
extrn   varBreak:byte,beep:near,writeF:near,dirCount:word
extrn   fillNameV:near,infBadCount:word,curDelCount:word,mesDirF:near
extrn   fname:near,pathDir:word,printPath:near,formDI_CX1:near,printPSp:near
extrn   varND:byte
        .model small
        .code
; Здесь происходит запрос с звуковым сигналом
whoB proc
        call beep
        call who
        ret
        endp
; скопировать строку path в pathDir
movePath proc
        push cx si di
        lea si,path
        lea di,pathDir
        mov cx,64
        rep movsb
        pop di si cx
        ret
        endp
; Главная подпрограмма, сканирующая каталоги используя int 25
antiDir proc
        call print0D
        push ax es
        push ss
        pop  es
        call movePath
        mov ah,30h
        int 21h
        mov verDos,al
        cmp varND,1  	; проверка, если ключ /D установлен, то сканировать
        jne exitAdirOk
        mov al,device
        sub al,'A'
        mov disk,al
        call checkNet	; проверка сетевой диск или нет
        jc  exitAdirOk
        call getParam	; получить параметры раздела
        jc  exitAdirOk
        call scanDisk	; сканировать диск сейчас
        pushf
        call deleteBlock
        popf
exitAdir:
        pop es ax
        ret
        endp
exitAdirOk:
        clc
        jmp short exitAdir
; проверка сетевой диск или нет
checkNet proc
        push ax bx dx
        xor ah,ah
        inc ax
        xchg bx,ax
        mov ax,4409h
        int 21h
        jc unknownDisk
        test dh,92h
        jz unknownDisk
        stc
unknownDisk:
        pop dx bx ax
        ret
        endp
; удалить блок памяти в которм хранится FAT
deleteBlock proc
        push ax es
        mov es,segFat
        mov ah,49h
        int 21h
        pop es ax
        ret
        endp
; главная подпрограмма сканирования диска
scanDisk proc
        push ax bx cx dx
        mov ax,[myDta+0Fh]
        call makeSect		; начальный кластер выбираем из DTA
        lea bx,tableRoot
        mov word ptr [bx],offset tableRoot+2
        mov word ptr [bx+2],ax
        mov word ptr [bx+4],dx
        mov word ptr [bx+6],0   
        inc dirCount    ;st
nextFile1:
        call checkBreak		; проверкка на клавишу ESC
        jc exit
        call readSec		; читать сектор диска
        jc exitOk
nextFile:
        call checkSec		; проверить сектор диска
        or bl,bl        	; проверка - это файл ?
        jne nextCheck1
moreDirVir:
        call printFname		; проверить поля имени
        jc  exit
        jmp short nextFile
nextCheck1:
        cmp bl,1        ; это dir ?
        jne nextCheck2
        inc dirCount    
        call addDir     ; зайти в подкаталог
        call go
        jmp short nextFile1
nextCheck2:
        cmp bl,2        ; последняя запись в секторе ?
        je  nextFile1
        cmp bl,3        ; удаленный файл ?
        je  nextFile
nextCheck3:
        cmp bl,4        ; метка диска ?
        je  nextFile
nextCheck4:
        cmp bl,5	; каталог проверен полностью ?
        jne nextCheck5
        call subDir	; вернуться на подкаталог вверх
        call back
        jnc nextFile1	; все каталоги пройдены ?
nextCheck5:
exitOk:
        clc
exit:
        pop dx cx bx ax
        ret
        endp
; вернуться на подкаталог вверх
back proc
        push bx
        sub tableRoot,6
        mov bx,tableRoot
        call getSector
        cmp bx,offset tableRoot
        pop bx
        ret
        endp
; войти в покаталог
addDir proc
        push ax cx dx si di
        call formDI_CX
        call formName
        dec di
        mov ax,'\'
        stosw
        call outName
        call printOk
        pop di si dx cx ax
        ret
        endp
; выйти из подкаталога
subDir proc
        push ax cx dx si di
        call formDI_CX
        dec di
        xor al,al
        stosb
        call formDI_CX
        stosb
        pop di si dx cx ax
        ret
        endp
; сформировать имя файла (в обход ДОС)
formName proc
        push ax cx si di
        mov si,pName
        lea di,[si+8]
        mov cx,9
skipSpace:
        dec di
        cmp byte ptr [di],' '
        loopz skipSpace
        pop di
        push si
        rep movsb
        pop si
        push di
        lea di,[si+11]
        mov cx,4
skipForExt:
        dec di
        cmp byte ptr [di],' '
        loopz skipForExt
        pop di
        jcxz skipPoint
        mov al,'.'
        stosb
        add si,8
        rep movsb
skipPoint:
        xor al,al
        stosb
        pop si cx ax
        ret
        endp
; получить номер сектора, через номер кластера
go proc
        push si
        mov si,pName
        mov ax,[si+1Ah]
        call makeSect
        call stepGo
        pop si
        ret
        endp
; получить номер кластера, через номер сектора
makeClust proc
        mov ax,[bx]
        mov dx,[bx+2]   ; сектор в dx:ax
        sub ax,endRoot
        sbb dx,0
        div word ptr clustSize  ; кластер в ax
        add ax,2
        adc dx,0
        ret
        endp
; получеть номер следующего кластера, используя ФАТ
getNextClust proc
        push bx cx
        call makeClust
        call getCLinAX
        cmp bx,ax
        jb lastCl       ; последний кластер
        call makeSect   ; прочитать кластер в ax
        clc
lastCl:
        pop cx bx
        ret
        endp
; выбрать номер кластера из ФАТ
getClinAX proc
        push cx
        push es
        mov es,segFat
        mov cx,ax
        mul word ptr fatUp      ; умножим на 3 или 4
        shr dx,1
        rcr ax,1        ; делим на 2
        or dx,dx
        jz getOldCl
        mov bx,es
        add bx,1000h
        mov es,bx
getOldCl:
        xchg ax,bx
        mov ax,es:[bx]
        pop es
        mov bx,0FFF5h
        cmp word ptr fatUp,4
        je  cont
        mov bx,0FF5h
        test cx,1
        jnz odd_cl
        and ax,0FFFh
        jmp short cont
odd_cl:
        mov cl,4
        shr ax,cl
cont:
        pop cx
        ret
        endp
; перевести кластер в сектор
makeSect proc      
        or ax,ax
        jne oldMakeS
        mov ax,startRoot
        cwd
        ret
oldMakeS:
        dec ax
        dec ax
        mul word ptr clustSize
        add ax,endRoot
        adc dx,0
        ret
        endp
; обнулить указатель в таблице
stepGo1 proc
        push bx
        jmp short setDx
        endp
; перейти к следующему элементу
stepGo proc
        push bx
        add tableRoot,6
setDx:
        mov bx,tableRoot
        mov [bx],ax
        mov [bx+2],dx
        mov word ptr [bx+4],0
        pop bx
        ret
        endp
; 
checkSec proc
; table | sectorLo | sectorHi | count cell | count sec |
        push cx si
        mov bx,tableRoot
        call checkOut   ; проверить сектор кластера
        jc  exitClust
        mov si,word ptr [bx+4]  ; номер файла в si
        inc byte ptr [bx+4]     ; увеличить номер файла
        and si,0FFh
        mov cl,5
        shl si,cl
        lea si,[buf+si] ; в si - указатель на имя
moreDir:
        mov pName,si
        lodsb
        cmp al,0E5h
        jne nextName
nextName5:
        mov bl,3        ; delete
        jmp short exitClust
nextName:
        cmp al,'.'
        je nextName5
        or  al,al
        jne nextName0
goStop:
        mov bl,5        ; stop
        jmp short exitClust
nextName0:
        mov al,byte ptr [si+10]
        test al,8
        jz  nextName1
        mov bl,4        ; label
        jmp short exitClust
nextName1:
        test al,10h
        jz  nextName2
        cmp word ptr buf,202Eh
        jne goodDir
        mov ax,word ptr [buf+1Ah]       ;*
        cmp ax,[si+19h]         ;*
        jne goodDir             ;*
        cmp word ptr [si+11h],0
        je  nextName5
        call cureDir            ;*
        jnc moreDir             ;*
        jmp nextName5           ;*
goodDir:                        ;*
        cmp word ptr [si+1Bh],0 ; si+13h
        jne goStop
        mov bl,1        ; dir
        jmp short exitClust
nextName2:
        xor bl,bl
exitClust:
        pop si cx
        ret
        endp
getSector proc
        mov ax,[bx]
        mov dx,[bx+2]
        add al,byte ptr [bx+5]
        adc ah,0
        adc dx,0
        ret
        endp
checkOut proc
cellInSec equ byte ptr $+3
        cmp byte ptr [bx+4],16  ; текущий файл 16-й ?
        clc
        jne checkName           ; нет дальше ...
        mov byte ptr [bx+4],0
        inc byte ptr [bx+5]     ; увеличить номер сектора в кластере
        call getSector
        cmp ax,endRoot
        ja  notEnd1
        cmp ax,endRoot
        je  lastDir
myEnd2:
        mov bl,2
        stc
checkName:
        ret
        endp
notEnd1:
        push ax
        mov al,byte ptr [bx+5]
        cmp al,byte ptr clustSize ; проверены все сектора кластера ?
        pop ax
        jb  myEnd2              ; нет не все
        mov byte ptr [bx+5],0   ; обнуляем счетчики
        call getNextClust       ; берем следующий в dx:ax
        jc  lastDir
        call stepGo1            ; запомнить сектор в таблице
        jmp myEnd2
lastDir:
        mov bl,5
        stc
        ret
printFname proc
        push ax cx dx si di
        mov si,pName
        cmp word ptr [si+9],'EX'
        je checkCom
        cmp word ptr [si+9],'MO'
        je checkCom
        cmp word ptr [si+9],'FB'
        clc
        jne badName
checkCom:
        call formDI_CX
        call formName
        call checkVirus
        call chechSte
badName:
        pop di si dx cx ax
        ret
        endp
cureDir proc
        push ax cx dx si
        push si
        call formDI_CX
        call formName
        call outName
        lea dx,badDir
        call printEng
        lea dx,mesWho
        call whoB
        pop si
        jc noCurDir
        xor ax,ax
        xchg ax,[si+11h]
        mov [si+19h],ax
        call writeSec
        jc noCurDir
        lea dx,itDir
        call printEng
        clc
noCurDir:
        pushf
        call printOk
        popf
        pop si dx cx ax
        ret
        endp
checkVirus proc
        push ax dx si
        mov si,pName
        mov ax,[si+1Ah]
        cmp ax,maxClust
        jne checkDIRokt
        lea dx,mesDir_d
        cmp word ptr [si+12h],0
        jne checkDIRD           ;*
        lea dx,mesDirF          ;*
        cmp word ptr [si+14h],0 ;*
        je  checkDIRokt
        cmp word ptr [si+14h],ax;*
        je  checkDIRokt         ;*
        mov ax,[si+14h]         ;*
        jmp short qwes1         ;*
checkDIRD:
        cmp word ptr [si+12h],ax
        je  checkDIRokt
        mov ax,[si+12h]
        jmp short qwes1
writeOrig:
        mov word ptr [si+1Ah],ax
        call writeSec
        jc  exitVir1
        inc curDelCount
        lea dx,itDir
        call printEng
        call printOk
        stc
        jmp short exitVir1
checkDIRokt:
        cmp ax,maxClust_1
        jne exitVir
        cmp word ptr [si+10h],0
        je  exitVir
        cmp word ptr [si+10h],ax
        je  exitVir
        mov ax,[si+10h]
        lea dx,mesDir20
qwes1:
        inc infbadCount
        call qwes
        jnc  writeOrig
        call printOk
exitVir:
        clc
exitVir1:
        pop si dx ax
        ret
        endp
chechSte proc
        push ax cx dx si
        cmp varKeySt,1
        je noChSt
        call outName
        call setDta
        lea dx,pathDir
        mov cx,00110111b
        mov ah,4Eh
        int 21h
        cmc
        jnc noChSt
        mov si,pName
        mov ax,[si+1Ch]
        mov dx,[si+1Eh]
        sub ax,longFlo
        sbb dx,longFhi
        or ax,ax
        clc
        je noChSt
        call outTSR
        jnc noChSt
        mov varBreak,1
noChSt:
        pop si dx cx ax
        ret
        endp
writeSec proc
        push ax bx cx dx si di bp
moreWrite:
        mov bx,tableRoot
        mov ax,[bx]
        mov dx,[bx+2]
        add al,[bx+5]
        adc ah,0
        adc dx,0
        mov cx,1
        cmp byte ptr verDos,4
        jb oldWrite
        lea bx,extTab
        mov [bx],ax
        mov [bx+2],dx
        mov [bx+4],cx
        mov cx,-1
        jmp short call26
oldWrite:
        xchg ax,dx
        lea bx,buf
call26:
        mov al,disk
        int 26h
        pop cx
        jnc noCheckWrite
        call analizErrDir
        jnc moreWrite
noCheckWrite:
        pop bp di si dx cx bx ax
        ret
        endp
outName proc
        push dx
        call print0D
        mov color,9
        lea dx,pathDir
        call printPath
        call printPSp
        pop dx
        ret
        endp
qwes proc
        call outName
        push dx
        lea dx,mesWar
        call printEng
        pop dx
        push dx
        call print
        push ax si
        mov si,dx
        inc si
        inc si
        xor ax,ax
        cwd
        call fillNameV
        pop si ax
        lea dx,mesWho
        call whoB
        pop dx
        ret
        endp
getParam proc
;  table |(0,3) jmp|(3,7) name|( B,2) SectSiz|(D,1) ClustSiz|( E,2) ResSecs|
;   |(10,1) Fat|(11,2) RootSiz|(13,2) TotSecs|(15,1) Medium |(16,2) FatSize|
;|(18,2) TreckSecs|(1A,2) HeadCount|(1C,2) HidnSecs|
        push ax bx cx dx
        call readBoot
        jc exitPar0
        lea bx,buf
        cmp word ptr [bx+1FEh],0AA55h
        stc
        jne exitPar0
        mov dx,[bx+0Eh]
        xor ch,ch
        mov cl,[bx+10h] ; quantity Fat
addFat:
        add dx,[bx+16h] ; fatSize in sectors
        loop addFat
        mov startRoot,dx
        mov ax,[bx+11h] ; rootSize
        mov cl,4
        shr ax,cl
        add dx,ax
        mov endRoot,dx
        mov ax,[bx+0Bh] ; sectorSize
        inc cx
        shr ax,cl
        mov cellInSec,al
        mov cx,dx
        xor dx,dx
        mov ax,[bx+13h] ; totalSectors
        or ax,ax
        jne noBigDisk
        mov ax,[bx+13h+15h-8]
        mov dx,[bx+13h+17h-8]
noBigDisk:
        sub ax,cx
        sbb dx,0
        xor ch,ch
        mov cl,[bx+0Dh] ; clusterSize
        mov byte ptr clustSize,cl
        div cx
        mov maxClust_1,ax
        inc ax
        mov maxClust,ax
        cmp cl,1
        jne contCheck16
        dec ax
        mov maxClust,ax
        dec ax
        mov maxClust_1,ax
contCheck16:
        call check16
        call readFat
exitPar0:
        jc exitPar
scanCellF:
        mov ax,maxClust
        cmp cl,1
        jne noIncCF
        inc ax
noIncCF:
        call getClinAX
        cmp ax,0FF7h
        je decMax
        cmp ax,0FFF7h
        clc
        jne exitPar
decMax:
        dec maxClust
        dec maxClust_1
        jmp scanCellF
exitPar:
        pop dx cx bx ax
        ret
        endp
check16 proc
        push ax cx si di
        lea si,[bx+36h]
        lea di,fat16
        mov ax,3
        mov cx,5
        rep cmpsb
        jne set12
        mov ax,4
set12:
        mov fatUp,ax
        pop di si cx ax
        ret
        endp
readBoot proc
        push dx
        xor ax,ax
        xor dx,dx
        call readSec
        pop dx
        ret
        endp
readFat proc
        push ax bx cx dx
        mov dx,[bx+0Eh] ; начальнай сектор
        mov cx,[bx+16h] ; количкство секторов
        call allocMem
        jc badReadF
        mov ax,segFat
        lea bx,extTab
        mov [bx],dx
        mov [bx+8],ax
        cmp cx,128
        jbe oldReadF
        sub cx,128
        push cx
        mov cx,128
        call readManySec
        pop cx
        jc badReadF
        add word ptr [bx],128
        add word ptr [bx+8],1000h
oldReadF:
        call readManySec
        mov word ptr [bx+6],offset buf
        mov word ptr [bx+8],ss
badReadF:
        pop dx cx bx ax
        ret
        endp
readManySec proc
        push ax bx cx dx bp si di
        mov al,disk
        cmp verDos,4
        jb oldRfat
        lea bx,extTab
        mov word ptr [bx+2],0
        mov [bx+4],cx
        mov word ptr [bx+6],0
        mov cx,-1
        push ds
        jmp short call25f
oldRfat:
        push ds
        mov ds,segFat
        xor bx,bx
call25f:
        int 25h
        pop cx ds
        jnc noErrFat
        call analizErrDir
noErrFat:
        pop di si bp dx cx bx ax
        ret
        endp
allocMem proc
        push ax bx cx dx
        mov bx,cx
        mov cl,5
        shl bx,cl
        mov ah,48h
        int 21h
        mov segFat,ax
        jnc memAllocOk
        lea dx,memoryLo
        call printEng
        stc
memAllocOk:
        pop dx cx bx ax
        ret
        endp
readSec proc
        push ax bx cx bp si di
        mov cx,1
        cmp byte ptr verDos,4
        jb oldRead
        lea bx,extTab
        mov [bx],ax
        mov [bx+2],dx
        mov [bx+4],cx
        mov cx,-1
        jmp short call25
oldRead:
        xchg ax,dx
        lea bx,buf
call25:
        mov al,disk
        int 25h
        pop cx
        jnc noCheckErrR
        call analizErrDir
noCheckErrR:
        pop di si bp cx bx ax
        ret
        endp
formDI_CX proc
        lea si,pathDir
        jmp formDI_CX1
        endp
        .data
memoryLo      db 9,1,12,' Недостаточно памяти для проверки вирусов DIR.',10,0
              db 9,1,12,' Not enoth memory to test the virus DIR.',10,0
              dw 0EE01h,memoryLo
badDir          db ' - скрыт вирусом BadDir.',0
                db ' - destroyed with BadDir.',0
                dw 0EE01h,badDir
extTab          dw ?
hiSEC           dw ?
                dw 1
offBuf          dw offset buf
segR            dw @data
fat16           db 'FAT16'
fatUp           dw 3
clustSize       dw ?
disk            db ?
startRoot       dw ?
endRoot         dw ?
maxClust        dw ?
maxClust_1      dw ?
pName           dw ?
segFat          dw ?
end
