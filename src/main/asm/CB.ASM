
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
;lenFile equ 85360+562+6         ; Длина ЕХЕ файла.

; Этот модуль делает много чего. Но с самого начала он должен был делать
; самопроверку файла MSCAN.EXE

public  writeDec,getKeys,getName,findBody
public  scanParam,checkBody,mesNotF
extrn   printPath:near,print0D0A:near,writeHex:near,who:near,setPadeg:near
extrn   setPos:near,closeFile:near,delString:near,writeChar:near
extrn   mesStatMem:byte,memCount:word,memInfected:word,posLoAll:word
extrn   varKeyOk:byte,varKeyHel:near,scanChSum:near
extrn   varPage:near,varMesOk:near,varFiles:near,baseSeg:word
extrn   varKeySt:near,varVakcine:near,varMem:near,varMes:near,varRap:near
extrn   mesBody1:byte,mesBody2:byte,mesBody3:byte,mesStatMemCur:byte
extrn   pathIni:byte,mesBody:byte,color:byte,varEng:near,printEng:near
extrn   varEvr:near,checkVirus:near,path:near,pathMs:near,openFile:near
extrn   var0D:byte,pointComStr:word,repName:near,varSM:near
extrn   setMus:near,resetMus:near,findPath:near,default:near,varBW:near
extrn   openIni:near,readF:near,varNP:near,varSound:near,print0D:near
extrn   copyPath:near,varAm:near,amName:near,varAs:near,varDl:near,varMB:near
extrn   varST:byte,varFN:byte,varViewOn:byte,varFM:byte,varCT:byte
extrn   varNV:byte,startTime:near,varFS:byte,varWin:near,varAA:near
extrn   varML:near,mlName:near,lngName:near,varSS:near,varRS:near,varWT:near
extrn   ssName:near,rsName:near,closeF:near,getSpecWord:near,typeNum:byte
extrn   varMS:near,varRN:near,varND:near,offFS:word,offMS:word,varStd:byte
extrn   stopTime:word,varBS:near,offBS:word,varNonStop:word,calcSum:near
extrn   varPages:near
        .model small
        .code
writeDec proc
        push ax bx cx dx
        mov ax,dx
        test ah,80h
        jz noSign
        mov dl,'-'
        call writeChar
        neg ax
noSign:
        mov bx,10
        xor cx,cx
cicDec:
        xor dx,dx
        div bx
        push dx
        inc cx
        or ax,ax
        jnz cicDec
cicDec2:
        pop dx
        call writeHex
        loop cicDec2
        pop dx cx bx ax
        ret
        endp
getKeys proc
        push ax bx cx si di ds es
        xor cx,cx
        mov si,80h
        mov cl,byte ptr es:[si]
        or cl,cl
        jne scanKeys
        call readIni
        jnc scanKeys
        mov byte ptr varKeyHel,1
        jmp short exitKeys
scanKeys:
        mov typeNum,10h
        push ds es
        pop  ds es
        inc si
scanParam:
        lodsb
        cmp al,'/'
        je checkKey
        cmp al,'-'
        jne noCheckKey
        cmp 1 ptr [si-2],' '
        je checkKey
noCheckKey:
        loop scanParam
        clc
        jmp short exitKeys
checkKey:
        mov bx,si
        dec cx
        jz exitKeys
nextCk:
        lodsb
        cmp al,' '
        je checkStr
        cmp al,'/'
        je checkStr
        cmp al,'A'
        jb noOR
        cmp al,'Z'
        ja noOR
        or byte ptr [si-1],20h
noOR:
        loop nextCk
checkStr:
        dec si
        push cx si
        lea di,tableKey
        xor ch,ch
moreKey:
        mov si,bx
        mov cl,es:[di]
        inc di
        rep cmpsb
        jne noSetKey
        call setKey
        jmp short moreNextKey
noSetKey:
        add di,cx
        scasw
        scasb
        cmp di,offset endTableKey
        jc moreKey
moreNextKey:
        pop si cx
        or cx,cx
        jnz scanParam
exitKeys:
        pop es ds di si cx bx ax
        ret
        endp
setKey proc
        mov bx,es:[di]
        mov al,es:[di+2]
        or al,al
        jne setDS
        mov cs:[bx],al
        jmp short chEnd
setDS:
        mov es:[bx],al
chEnd:
        cmp bx,offset varRap
        jne checkAm
        lea di,repName
        call getRname
        ret
checkAm:
        cmp bx,offset varAm
        jne checkML
        lea di,amName
        call getRname
        ret
checkML:
        cmp bx,offset varML
        jne checkEng
        lea di,mlName
        call getRname
        ret
checkEng:
        cmp bx,offset varEng
        jne checkSS
        cmp al,2
        jne noSetLeng
        lea di,lngName
        call getRname
noSetLeng:
        ret
checkSS:
        cmp bx,offset varSS
        jne checkRS
        lea di,ssName
        call getRname
        ret
checkRS:
        cmp bx,offset varRS
        jne checkFS
        lea di,rsName
        call getRname
        ret
checkFS:
        cmp bx,offset varFS
        jne checkNV
        xor ax,ax
        call getStrWord
        mov es:offFS,ax
        ret
checkNV:
        cmp bx,offset varNV
        jne checkMS
        xor ax,ax
        call getStrWord
        mov es:offFS,ax
        ret
checkMS:
        cmp bx,offset varMS
        jne noSetOffMs
        mov ax,5
        call getStrWord
        mov es:offMS,ax
noSetOffMs:
        cmp bx,offset varBS
        jne noSetOffBS
        mov ax,40h
        call getStrWord
        mov es:offBS,ax
noSetOffBS:
        cmp bx,offset varWT
        jne noWiteVar
        xor ax,ax
        call getStrWord
        push bx dx
        mov bx,91
        mul bx
        mov bx,5
        cmp bx,dx
        jb  noDiv
        div bx
noDiv:
        mov es:stopTime,ax
        pop dx bx
noWiteVar:
        ret
        endp

getStrWord proc
        cmp 1 ptr [si],':'
        jne endGetStr
        push cx si ds ax
        mov ax,ds
        push ss
        pop  ds
        inc si
        mov cl,5
        push baseSeg
        mov baseSeg,ax
        call getSpecWord
        pop  baseSeg
        jnc setupWord
        pop  ax
        push ax
setupWord:
        pop cx ds si cx
endGetStr:
        ret
        endp

getRname proc
        push ax cx si di
        lodsb
        dec cx
        jz noSetR
        cmp al,' '
        je noSetR
        cmp al,0Dh
        je noSetR
        cmp al,'/'
        je noSetR
        cmp al,':'
        je setPl1
        inc cx
        dec si
setPl1:
        lodsb
        cmp al,0Dh
        je set0r
        cmp al,' '
        je set0r
        cmp al,'/'
        je set0r
        stosb
        loop setPl1
set0r:
        xor al,al
        stosb
noSetR:
        pop di si cx ax
        ret
        endp
readIni proc
        push ax dx ds
        call openIni
        jc endIni
        xchg bx,ax
        push es
        pop  ds
        mov dx,81h
        mov cx,7Fh
        call readF
        mov ds:80h,al
        push ax
        call closeF
        pop cx
endIni:
        pop ds dx ax
        ret
        endp
getName proc
        push ax cx si di ds es
        xor cx,cx
        mov si,pointComStr      ; 81h
        lea di,pathIni
        push ds es
        pop  ds es
        mov cl,byte ptr ds:80h
        mov ax,81h
        sub ax,si
        add cx,ax
        jcxz noParam
cicDisk:
        lodsb
        cmp al,9
        je  cicDisk1
        cmp al,' '
        jne storePath
cicDisk1:
        loop cicDisk
noParam:
        stc
endParam:
        pop es ds di si cx ax
        ret
        endp
noParam2:
        xor al,al
        stosb
        dec si
        mov ss:pointComStr,si
        jmp short endParam
storePath:
        dec si
        cmp al,'-'
        je skipSp
        cmp al,'/'
        jne storePath1
skipSp:
        lodsb
        cmp al,' '
        je cicDisk1
        loop skipSp
        jmp noParam
storePath1:
        lodsb
        cmp al,9
        je  noParam2
        cmp al,' '
        je  noParam2
        cmp al,'/'
        je  noParam2
        stosb
        loop storePath1
        inc si
        jmp noParam2

checkAll proc
        push cx dx di ds es
        xor al,al
        call setPos
        mov ds,baseSeg
        push ds
        pop  es
        xor dx,dx
        mov cx,0FF00h
        call readF
        jc chkAllErr
        push ax
        mov cx,0FFFFh
        mov dx,-6
        mov ax,4202h
        int 21h
        mov cx,6
        mov dx,0FF00h
        call readF
        pop cx
        cmp ds:0FF00h,'AV'
        jne chkAllErr
        xor si,si
;        call calcSum
;        cmp ds:0FF02h,ax
;        jne chkAllErr
;        cmp ds:0FF04h,dx
chkAllErr:
        pop es ds di dx cx
        ret
        endp

checkForVirus proc
        mov color,15
        call print0D
        lea dx,path
        call printPath
        call startTime
        mov color,3
        push word ptr varKeyOk
        mov varKeyOk,1
        call checkVirus
        pop word ptr varKeyOk
        ret
        endp

checkBody proc
        push ax bx cx dx
        call findComSpec
        jne exitSpec
        call findPath
        jc exitSpec
        call openFile
        xchg bx,ax
        call checkForVirus
        call closeFile
exitSpec:
;        call findBody
        call copyPath
        call findPath
        jnc checkNow
        clc
        jmp short exitBody
checkNow:
        call openFile
        xchg bx,ax
        call checkForVirus
        mov ax,posLoAll
        cmp byte ptr varAA,1
        je noCheckAll
;       mov al,2
;       call setPos
        call checkAll
noCheckAll:
        pushf
        call closeFile
        call delString
;        cmp ax,lenFile
;        jne printBadLen  ; exitBody
        popf
        je exitBody
        lea dx,mesNotF
        call printEng
        jmp short exitBody1
;printBadLen:
;        popf
;        sub ax,lenFile
;        mov var0D,1
;        lea dx,mesBody
;        call printEng
;        lea dx,path
;        call printPath
;        lea dx,mesBody1
;        call printEng
;        mov dx,ax
;        call setPadeg
;        call writeDec
;        lea dx,mesBody2
;        call printEng
exitBody1:
        lea dx,mesBody3
        mov var0D,0
        call setMus
        push 2 ptr varKeyOk
        mov varKeyOk,0
        call who
        pop 2 ptr varKeyOk
        pushf
        call resetMus
        call delString
        popf
exitBody:
        pop dx cx bx ax
        ret
        endp
findComSpec proc
        push ax cx si di es
        mov es,es:2Ch
        xor di,di
        xor al,al
        mov cx,2000
findNext0:
        repne scasb
        jne exitFindCom
        lea si,comStr
        push cx di
        mov cx,offset lenComStr
        rep cmpsb
        jne noSetSI
        mov si,di
noSetSI:
        pop di cx
        jne findNext0
        push ds
        push es ds
        pop  es ds
        lea di,path
nextChMo:
        lodsb
        stosb
        or al,al
        jne nextChMo
        pop ds
exitFindCom:
        pop es di si cx ax
        ret
        endp
findBody proc
        push cx si di es
        call copyPath
        push ds
        pop  es
        lea si,path
        lea di,pathMs
        mov cx,40
        rep movsw
        pop es di si cx
        ret
        endp
        .data
; таблица ключей | key | lenKey | offset var | var byte |
tableKey  label byte
        db 1,'a'        ; дизассемблирование
        dw varAs
        db 1
        db 2,'bs'
        dw varBS
        db 1
        db 1,'b'        ; вывод в черно-белом
        dw varBW
        db 0
        db 2,'c+'       ; проверять и лечить вирусы
        dw varViewOn
        db 2
        db 2,'c-'       ; не использовать кодоанализатор
        dw varViewOn
        db 1
        db 2,'cu'       ; лечить вирусы
        dw varKeyOk
        db 1
        db 2,'cr'       ; искать расшифровщики
        dw varEvr
        db 1
        db 2,'ct'       ; создать таблицу вирусов
        dw varCT
        db 1
        db 1,'c'        ; выводить комментарии
        dw varMes
        db 1
        db 1,'d'        ; проверять каталоги
        dw varND
        db 1
        db 1,'e'        ; удалять файлы
        dw varDl
        db 1
        db 3,'fs+'      ; создать файл сигнатур
        dw varFS
        db 2
        db 2,'fs'       ; создать файл сигнатур
        dw varFS
        db 1
        db 2,'fm'       ; создать файл с участками памяти
        dw varFM
        db 1
        db 1,'f'        ; использовать шрифты
        dw varFN
        db 1
        db 1,'h'        ; вывести справку
        dw varKeyHel
        db 1
        db 3,'mb+'      ; создать базу CMB
        dw varMB
        db 2
        db 2,'mb'       ; создать базу CMB
        dw varMB
        db 1
        db 2,'ms'       ; создать сигнатуры участков памяти
        dw varMS
        db 1
        db 2,'m-'       ; не проверять память
        dw varMem
        db 1
        db 3,'nv+'      ; давать пояснения для новых вирусов
        dw varNV
        db 2
        db 2,'nv'       ; определять сигнатуры для новых вирусов
        dw varNV
        db 1
        db 2,'o+'       ; выводить ОК + время
        dw varMesOk
        db 2
        db 1,'o'        ; выводить ОК
        dw varMesOk
        db 1
        db 1,'p'       ; выводить названия упаковщиков
        dw varNP
        db 1
        db 2,'rn'       ; переименовывать подозрительные
        dw varRN
        db 1
        db 2,'r-'       ; поиск резидентных вирусов
        dw varKeySt
        db 1
        db 3,'std'      ; вывод ДОС функциями
        dw varStd
        db 1
        db 2,'st'       ; вывод статистики
        dw varST
        db 1
        db 2,'sm'       ; вывод вверх ногами
        dw varSM
        db 1
        db 2,'s+'       ; запомнить состояние
        dw varSS
        db 1
        db 2,'s-'       ; восстановить состояние
        dw varRS
        db 1
        db 2,'xx'       ; сохранить страницы
        dw varPages
        db 1
        db 1,'s'        ; выдавать звук
        dw varSound
        db 1
        db 1,'-'        ; лечить инфицированные
        dw varKeyOk
        db 1
        db 1,'y'        ; лечить вирусы
        dw varKeyOk
        db 1
        db 1,'t'        ; запуск в режиме тестирования
        dw varKeyOk
        db 2
        db 2,'v+'       ; добавлять неснимаемую вакцину
        dw varVakcine
        db 3
        db 2,'v-'       ; снимать вакцину
        dw varVakcine
        db 2
        db 1,'v'        ; добавлять вакцину
        dw varVakcine
        db 1
        db 2,'wt'       ; время задержки при запросах
        dw varWT
        db 1
        db 2,'w+'       ; добавлять к файлу-отчету
        dw varRap
        db 2
        db 2,'wi'       ; вывод в окне
        dw varWin
        db 1
        db 1,'w'        ; записывать файл-отчет
        dw varRap
        db 1
        db 2,'le'       ; вывод на английском
        dw varEng
        db 1
        db 2,'la'       ; загрузить сообщения
        dw varEng
        db 2
        db 1,'@'        ; проверять из списка
        dw varAm
        db 1
        db 2,10,10      ; запуск из резидента
        dw varAA
        db 1
        db 1,'='        ; создать список файлов
        dw varML
        db 1

        db 1,'?'        ; вывод подсказки
        dw varKeyHel
        db 1

        db 1,'*'        ; проверять все файлы
        dw varFiles
        db 1

        db 1,'z'
        dw varNonStop   ; не останавливатья
        db 1
endTableKey equ $
comStr          db 'COMSPEC='
lenComStr       equ $-comStr
mesNotF         db 1,12,9,'      Файл MSCAN.EXE поврежден или модифицирован !!!',10
                db      9,'         Дальнейшее его выполнение неэффективно.',10,0
                db 1,12,9,9,'  File MSCAN.EXE is corrupted or modified !!!',10
                db      9,9,'       Execute of file is bad idea.',10,0
                dw 0EE01h, mesNotF
end
