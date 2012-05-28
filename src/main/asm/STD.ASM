
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Здесь ищутся и лечатся файловые вирусы. Сколько здесь каши. Может
; написать новый антивирус ?

public  cureStd,mesWar,mesModInf,iniPos,printNameVir
public  mesWar,mesEkz,mesDelete,mesDelOk,mesModInf,mesPack,mesCoPr
public  mesStand,fillAsm,fillNameV,printLen,getSigAx,getSigLw,subLenAX
public  printVSig,compare,compareB,compareM,sigSeg,check_1,iniSegDS
public  callProcAx,mesRename,mesRenOk,mesNoCure,newName,saveSig,iniSigOff
public  getMemWord,getMemWord1,getMemWord12,getMemWord2,getMemWord3,getMemWord4
public  getBootWord,getBootWord1,getBootWord2,getBootWord3,getBootWord4
public  printNotCure,fillNewSig,iniSigSeg,offSig,getLenVir,getComWord
public  getExeWord
extrn   buf:near,reloIP:word,printEng:near,print0D0A1:near,beep:near
extrn   typeFile:byte,readF:near,setTime:near,scanChSum:near,print:near
extrn   mesWho:near,writeHead:near,changeOpen:near,seekF:near,countExec:word
extrn   myTitle:word,who:near,posLoAll:word,posHiAll:word,lenVirus:word
extrn   writeDec:near,writeChar:near,itCom:near,itExe:near
extrn   tabPoly:near,path:near,maskHa:byte,tableOfViruses:near
extrn   posLo:word,poshi:word,writeF:near,setPos:near,getIPCS:near
extrn   varBreak:byte,erase:byte,varNP:byte,varAuto:byte,varBat:byte
extrn   scanSpec:near,baseSeg:word,complBlock:near,countErr:byte
extrn   lenCr:word,hand:word,dtaSeg:word,baseIP:word,envSeg:word,offFS:word
extrn   globalLo:word,globalHi:word,regIP:word,oldCom:near,lenBuf:near
extrn   listPoint:near,cursor:byte,varAs:byte,falseSeg:word,tabBlock:word
extrn   scanBoot:near,varKeyOk:byte,longFlo:word,longFhi:word,itSys:near
extrn   segVirInf:word,virModCount:word,modCount:word,curDelCount:word
extrn   infbadCount:word,badCount:word,scan2sum:near,symExec:near,color:byte
extrn   bPoint:word,varFound:byte,newSig:byte,calcSum:near,virFoundF:byte
extrn   clearSign:near,offInFile1:word,writePalBr:near,createF:near,closeF:near
extrn	varPages:byte
        .model small
        .code
iniPos proc
        push ax cx dx
        push ss
        pop  es
        call clearSign
        call fillEnv
        mov ax,dtaSeg
        mov baseSeg,ax
        xor ax,ax
        mov tabBlock,ax
        call setPos
        lea dx,myTitle
        mov cx,80
        call readF
        jc badRead
        mov ax,100h+24
        mov [tabBlock+4],ax
        mov ax,myTitle
        cmp ax,'ZM'
        je itMZ
        cmp ax,'MZ'
        je itMZ
        cmp longFHi,2
        cmc
        jc badRead
        cmp ax,-1
        jne itnFF
        cmp [myTitle+2],-1
        jne itnFF
sysFile:
        mov typeFile,2
        call setSys
        jmp short badRead
itnFF:
        mov typeFile,0
        cmp varBat,1
        jne itnBat
        mov varBat,0
        call setBat
        jmp short badRead
itnBat:
        call setCom
        jmp short badRead
itMZ:
        mov typeFile,1
        call setExe
badRead:
        pop dx cx ax
        ret
        endp
checkNE proc
        mov ax,[si]
        cmp ax,'EN'
        jz  setNEhead
        cmp ax,'EP'
        jz  setPEhead
badHead:
        stc
        ret
setNEhead:
        call getDXAXNE
        ret
setPEhead:
        test byte ptr [si+16h],02
        jz  badHead
        cmp word ptr [si+18h],010Bh
        jnz badHead
        call getDXAXPE
        ret
        endp
getDXAXNE proc
        push dx
        mov ax,[si+16h]
        dec ax
        mov cx,0008
        mul cx
        pop cx
        push word ptr [si+14h]
        push word ptr [si+32h]
        add ax,[si+22h]
        adc dx,0000
        or  dx,dx
        jnz l_04d9
        cmp ax,511
        add si,ax
        jb  l_04fb
l_04d9:
        lea si,buf
        add ax,cx
        adc dx,0
        xchg dx,cx
        xchg ax,dx
        call seekF
        mov dx,si
        mov cx,512
        call readF
l_04fb:
        pop cx
        mov ax,[si]
        xor dx,dx
        or  cx,cx
        jnz l_0507
        mov cx,0009
l_0507:
        shl ax,1
        rcl dx,1
        loop l_0507
        pop si   ; 14
        ret
        endp
getdxaxPE proc
        push bx cx si
        mov bx,[si+14h]
        mov cx,[si+06]
        add si,0018h
        mov dx,[si+12h]
        mov ax,[si+10h]
        lea si,[bx+si]
loop0488:
        mov bx,[si+36h]
        mov di,[si+34h]
        cmp bx,dx
        ja  l_049e
        cmp di,ax
        ja  l_049e
        add si,0028h
        cmp si,offset buf
        ja l_0490
        loop loop0488
l_0490:
        sub si,0028h
l_049e:
        mov bx,[si+0eh]
        mov di,[si+0ch]
        mov cx,[si+16h]
        mov si,[si+14h]
        add ax,si
        adc dx,cx
        sub ax,di
        sbb dx,bx
        xor si,si
        pop si cx bx
        ret
        endp
setExe proc
        push ax cx dx
        cmp word ptr [myTitle+18h],40h
        jb normalExe
        xor cx,cx
        mov dx,[MyTitle+3Ch]
        push dx
        call seekF
        lea dx,buf
        mov cx,512
        call readF
        jc badReadEx
        mov si,dx
        pop dx
        call checkNE
        jc normalExe
        mov posLo,ax
        mov posHi,dx
        mov regIP,si
        jmp short oldExe
normalExe:
        add baseSeg,0Fh
        mov ax,[myTitle+22]
        add ax,[myTitle+8 ]
        mov cx,16
        imul cx
        mov posLo,ax
        mov posHi,dx
        add ax,[myTitle+20]
        adc dx,0
        mov cx,dx
        xchg dx,ax
        mov ax,[myTitle+20]
        mov regIP,ax
        mov baseIP,ax
oldExe:
        xor ax,ax
        call moveCell
        mov globalLo,ax
        call readGo
        sub ax,posLo
        sbb dx,posHi
        or dx,dx
        je setHii
        mov ax,-256
setHii:
        mov globalHi,ax
        clc
badReadEx:
        pop dx cx ax
        ret
        endp
setBat proc
        push ax cx dx
        xor ax,ax
        cmp longFhi,ax
        stc
        jne badBat
        mov posLo,ax
        mov posHi,ax
        mov globalLo,ax
        mov regIP,ax
        call readGo
        mov globalHi,ax
badBat:
        pop dx cx ax
        ret
        endp
setCom proc
        push ax cx dx
        mov posLo,-100h
        mov posHi,-1
        mov ax,0F8h
        mov globalLo,ax
        mov ax,100h
        mov regIP,ax
        inc tabBlock
        call moveCell
        mov [tabBlock+2],ax
        add ax,word ptr myTitle+1
        add ax,3
        mov baseIP,ax
        call readGo
        add ax,100h
        mov globalHi,ax
        pop dx cx ax
        clc
        ret
        endp
setSys proc
        push ax cx dx
        xor ax,ax
        cmp longFhi,ax
        stc
        jne badSys
        mov posLo,ax
        mov posHi,ax
        mov globalLo,14
        mov ax,[myTitle+6]      ;*
        cmp ax,longFlo
        cmc
        jb badSys
        mov regIP,ax
        call moveCell
        call readGo
        mov globalHi,ax
badSys:
        pop dx cx ax
        ret
        endp
moveCell proc
        push ax cx si di es
        lea si,myTitle
        mov di,ax
        mov cx,15
        mov es,baseSeg
        rep movsw
        mov cx,di
        not cx
        shr cx,1
        mov ax,-1
        rep stosw
        pop es di si cx ax
        ret
        endp
fillDtaSeg proc
        push di es
        mov es,dtaSeg
        xor di,di
        mov ax,20CDh
        stosw
        mov ax,0A000h
        stosw
        mov cx,3Fh
        mov ax,0D00h
        rep stosw
        mov cx,3Fh
        mov ax,7777h
        rep stosw
        mov ax,envSeg
        mov es:2Ch,ax
        pop es di
        ret
        endp
readGo proc
        call fillDtaSeg
        mov al,2
        call setPos
        mov posHiAll,dx
        mov posLoAll,ax
        ret
        endp
fillAsm proc
        cmp varAs,0
        je skipList
        push ax cx di es
        push ss
        pop es
        lea di,oldCom
        mov cx,offset lenBuf
        mov al,' '
        rep stosb
        mov cursor,4
        lea di,listPoint
        mov cl,18
        mov ax,-1
        rep stosw
        pop es di cx ax
skipList:
        ret
        endp
fillEnv proc
        push cx si di es
        call fillAsm
        mov es,envSeg
        xor di,di
        xor ax,ax
        stosw
        inc ax
        stosw
        lea si,path
        mov cx,60
moveNam:
        lodsb
        stosb
        or al,al
        loopne moveNam
        lea si,strPath
        mov cl,offset lenStP
        rep movsb
        mov byte ptr es:40h,'Z'
        pop es di si cx
        ret
        endp
check_1 proc
        cmp ax,-1
        jne setSI
        lodsw
        push ax
        lodsw
        mov ss:sigSeg,ax
        mov ds,ax
        pop ax
setSI:
        xchg si,ax
        ret
        endp
scanMBR proc
        push word ptr varKeyOk
        mov varKeyOk,2
        mov di,100h
        call scanBoot
        pop word ptr varKeyOk
        ret
        endp
iniSegDS proc
        mov ax,iniSigSeg
        mov sigSeg,ax
        mov ds,ax
        ret
        endp

WritePages proc
		push ax bx cx dx si di
		mov ax, 2 ptr nameNew
		cmp al,'1'
		jb set_al1
		cmp al,'9'
		jae set_al1
		inc al
		jmp short save_al		
set_al1:
        mov ax,'1'
save_al:
		mov 2 ptr nameNew,ax
		lea dx,nameNew
		call createF
		jc exit_write
		mov dx,si
		mov cx,0FF00h
		sub cx,dx
		push ds
		mov ds,baseSeg
		call writeF
		pop ds
		call closeF
exit_write:
		pop di si dx cx bx ax
		ret
		endp

cureStd proc
        push ax cx dx si di es
        cmp varAuto,1
        je noSetErr
        mov oldSI,si            ;au
        mov oldCX,cx
        mov es,baseSeg
        mov di,reloIP
        call fillNewSig
        mov si,iniSigOff

		cmp varPages,0
		je skip_WP
;		call WritePages
skip_WP:

        push ds
        call iniSegDS
        cmp ss:varAuto,2
        jne nextPoly
        push ss
        pop  ds
        mov sigSeg,ds
        lea si,autoSig
        jmp short cureAuto
nextPoly:
        mov dx,si
        lodsw
        cmp ax,-1
        jne contComp
        lodsw
        or ax,ax
        je endScanFile
        call check_1
        jmp nextPoly
contComp:
        cmp al,'f'
        je cmpFile
skipSig:
        mov al,ah
        cbw
        add si,ax
        jmp nextPoly
cmpFile:
        lodsw
        call compare
        jne checkModify
cureAuto:
        call polyFound
        pop ds
        jmp short noSetErr
checkModify:
        cmp al,3
        jae nextCheck
        call modify
nextCheck:
        mov si,dx
        lodsw
        jmp skipSig
endScanFile:
        pop ds
        call scanMBR
        mov si,modifySi
        or si,si
        je noSetErr
        call printModify
        clc
noSetErr:
        pop es di si dx cx ax
        ret
        endp
modify proc
        push ds
        push ss
        pop  ds
        call getComWord
        cmp typeFile,0
        je checkComS
        call getExeWord
checkComS:
        cmp ax,0FD01h
        pop ds
        je noSaveMod
        mov word ptr ss:modifySi,si
        mov word ptr ss:modifyDS,ds
noSaveMod:
        ret
        endp
printModify proc
;        inc virFoundF
        push ax dx
        mov ax,modifyDS
        mov sigSeg,ax
        xor ax,ax
        mov modifySi,ax
        mov color,12
        lea dx,mesModInf
        call printEng
        call printNameVir
        mov dx,100h
        call fillNameV          ; gs
        inc infbadCount         ;st
        inc badCount            ;st
        inc countErr
        mov erase,2
        pop dx ax
        ret
        endp
clearVar proc
        push ax
        xor ax,ax
        mov lenCr,ax
        mov countErr,al
        mov maskHa,al
        mov modifySi,ax         ; забыть о модификациях
        pop ax
        ret
        endp
deleteFile proc
        push dx
        inc virFoundF
        mov color,12
        lea dx,mesEkz           ; сообщение экземпляр
        call printEng
        call printNameVir
        xor dx,dx
        call fillNameV          ; gs
        inc infbadCount         ;st
        inc badCount            ;st
        inc countErr
        mov erase,1
        clc
        pop dx
        ret
        endp
printPackStd proc
        push ax dx
        call getLenWord
        mov color,01
        lea dx,mesPack
        or ax,ax
        je printPack
        mov color,10
        lea dx,mesCoPr          ; сообщение : защищен
        dec ax
        jne printPack
        inc virFoundF
        inc countErr
        mov color,11
        lea dx,mesStand
printPack:
        cmp varNP,0
        je noOutPack
        call printEng
        call printNameVir
        call print0D0A1
noOutPack:
        clc
        pop dx ax
        ret
        endp
printInfect proc
        push dx
        inc virFoundF
        inc countErr
        inc infbadCount         ;st
        mov color,12
        lea dx,mesWar           ; указать на строку : болен
        call printEng
        call printNameVir
        call getLenWord
        or  ax,ax
        jne noGetAutoLen
        call getLenVir
        call printLenVir
noGetAutoLen:
        xor dx,dx
        call fillNameV          ; gs
        stc
        pop dx
        ret
        endp
writeStrName proc
        push ax
        call getComWord
        cmp ax,0FF01h
        jne noVirusForDel
        call deleteFile
        jmp short endWrName
noVirusForDel:
        cmp typeFile,0
        je checkComSTD
        call getExeWord
        cmp al,0
        jne checkComSTD
        call getComWord
checkComSTD:
        cmp ax,0FD01h
        jne noPackedOrStd
        call printPackStd
        jmp short endWrName
noPackedOrStd:
        call printInfect
endWrName:
        pop ax
        ret
        endp
polyFound proc
        push ds
        push ss
        pop  ds
        call clearVar
        call writeStrName
        jnc noCureFile
        call cureFile
noCureFile:
        pop ds
        ret
        endp
cureFile proc
        push ax bx dx
        call beep
        lea dx,mesWho
        call who
        jc exitCureFile
        mov bx,hand
        call changeOpen
        jc badExitCureFile
        mov dx,reloIP
        call complBlock
        jc badExitCureFile
        mov al,typeFile
        cmp al,0
        je resCom
        cmp al,1
        je resExe
        cmp al,2
        je resSys
badExitCureFile:
        call printNotCure
        jmp short exitCureFile
resSys:
        call resSysPoly
        jmp short exitCureFile
resExe:
        call resExePoly
        jmp short exitCureFile
resCom:
        call resComPoly
exitCureFile:
        jc noMoreScan
        inc curDelCount
        mov countErr,50
noMoreScan:
        pop dx bx ax
        ret
        endp
printNotCure proc
        lea dx,mesNoCure
        call printEng
        stc
        ret
        endp
printNameVir proc
        push ax dx
        call getNameWord
        cmp al,2
        je printNameRed
        cmp al,4
        je printNameLen
        cmp al,6
        je printGroupNameLen
        call beep
endPrintNam:
        pop dx ax
        ret
printNameRed:
        call getNameWord1
        xchg dx,ax
        xor ax,ax
        jmp short printNLV
printNameLen:
        call getNameWord1
        xchg dx,ax
        call getNameWord2

printNLV:
        call printVSig
        call printLenVir
        jmp endPrintNam
printGroupNameLen:
        call getNameWord1
        xchg dx,ax
        call printVSig
        mov dl,'.'
        call writeChar
        call getNameWord2
        xchg dx,ax
        call getNameWord3
        jmp printNLV
        endp

printLenVir proc
        cmp ax,1
        jbe noPrintLen
        mov dl,'.'
        call writeChar
        xchg dx,ax
        call writeDec
        mov dl,'.'
        call writeChar
noPrintLen:
        ret
        endp
getLenWord proc
        call getNameWord
        cmp al,2
        jne checkType4
lenIs0:
        xor ax,ax
        ret
checkType4:
        cmp al,4
        jne checkType6
        call getNameWord2
        ret
checkType6:
        cmp al,6
        jne lenIs0
        call getNameWord3
        ret
        endp
getNameWord proc
        xor ax,ax
getNameWordX:
        push si
        add si,ax
        call getSigLW
        pop si
        ret
getNameWord1:
        mov ax,1
        jmp getNameWordX
getNameWord2:
        mov ax,3
        jmp getNameWordX
getNameWord3:
        mov ax,5
        jmp getNameWordX
        endp

getMemWord:
getBootWord:
getComWord:
        xor ax,ax
getComWordX:
        push si
        call getNextRecord
        add si,ax
        call getSigLW
        pop si
        ret
getMemWord1:
getBootWord1:
getComSub:
        mov ax,1
        jmp getComWordX
getMemWord12:
getComWord1:
        mov ax,2
        jmp getComWordX
getMemWord2:
getBootWord2:
        mov ax,3
        jmp getComWordX
getComByte:
        mov ax,4
        jmp getComWordX
getComWord2:
getMemWord3:
getBootWord3:
        mov ax,5
        jmp getComWordX
getMemWord4:
getBootWord4:
        mov ax,7
        jmp getComWordX

getLenWordFile proc
        push si
        call getNextRecord      ;name
        call getNextRecord      ;com
        call getNextRecord      ;exe
        call getSigLW           ;len
        pop si
        ret
        endp
getExeWord proc
        xor ax,ax
getExeWordX:
        push si
        call getNextRecord
        call getNextRecord
        add si,ax
        call getSigLW
        pop si
        ret
        endp
getExeWord1:
        mov ax,1
        jmp getExeWordX
getExeWord12:
        mov ax,2
        jmp getExeWordX
getExeWord2:
        mov ax,3
        jmp getExeWordX
getExeWord3:
        mov ax,5
        jmp getExeWordX
getExeWord4:
        mov ax,7
        jmp getExeWordX

getNextRecord proc
        push ax
        call getSigLW
        dec si
        cbw
        add si,ax
        pop ax
        ret
        endp
getSigAx proc
        push si
        add si,ax
        call getSigLW
        pop si
        ret
        endp
getSigLw proc
        push ds
        mov ds,sigSeg
        lodsw
        pop ds
        ret
        endp
printVSig proc
        push ds
        mov ds,sigSeg
        call print
        pop ds
        ret
        endp
resSysPoly proc
        call checkExtern
        inc ax
        je noResSys2
        call getExeWord1
        or ax,ax
        je noResSys1
        call getWordInES
        mov myTitle+6,ax
noResSys1:
        call getExeWord2
        or ax,ax
        je noResSys2
        call getWordInES
        mov myTitle+8,ax
noResSys2:
        call subLenVir
        jc writeSYSerr
        lea dx,itSys
        call printEng
        clc
        ret
writeSYSerr:
        call printNotCure
        ret
        endp
getWordInES proc
        push di
        add ax,reloIP
        xchg di,ax
        mov ax,es:[di]
        pop di
        ret
        endp
getWordInES10 proc
        or ax,ax
        pushf
        and ax,7FFFh
        call getWordInES
        popf
        jns noSub10
        sub ax,10h
noSub10:
        ret
        endp
resExePoly proc
        call checkExtern
        inc ax
        jz spEpsent
        call getExeWord
        cmp al,3
        jbe readEXEerr
        call getExeWord1
        call getWordInES
        mov word ptr myTitle+14h,ax      ; IP
        call getExeWord2
        call getWordInES10
        mov word ptr myTitle+22,ax      ; CS
        call getExeWord
        cmp al,4
        jz spEpsent
        call getExeWord3
        or ax,ax
        jz spEpsent
        call getWordInES10
        mov word ptr myTitle+14,ax      ; SS
        call getExeWord
        cmp al,6
        jz spEpsent
        call getExeWord4
        or ax,ax
        jz spEpsent
        call getWordInES
        mov word ptr myTitle+16,ax      ; SP
spEpsent:
        call subLenVir
        jc readEXEerr
        lea dx,itExe
        cmp typeFile,1
        je outCuredExe
        lea dx,itCom
outCuredExe:
        call printEng
        clc
        ret
readEXEerr:
        call printNotCure
        ret
        endp
resComPoly proc
        call checkExtern        ; gs
        jnc externData

        call getComWord
        cmp al,1
        jbe readErr
        xor ch,ch
        mov cl,ah
        call getComWord1

externData:
        inc ax
        je stdTab1
        dec ax
        add ax,reloIP
        xchg ax,dx
        call complBlock
        jc readErr
        xchg ax,dx

        push si
        xchg si,ax
        lea di,myTitle
        call newMovs
        pop si

        call getComWord
        cmp al,6
        jne stdTab1

        call getComByte
        xor ch,ch
        mov cl,al
        call getComWord2
        add ax,reloIP

        push si
        xchg si,ax
        call newMovs
        pop si

stdTab1:
        call subLenVir
        jc readErr
        lea dx,itCom
        call printEng
        clc
        ret
readErr:
        call printNotCure
        ret
        endp
newMovs proc
        push cx
        push es ds
        pop  es ds
        rep movsb
        push es ds
        pop  es ds
        pop  cx
        ret
        endp
shiftToLen proc
        push ax cx dx
        mov cx,posHiAll
        mov dx,posLoAll
        sub dx,lenVirus
        sbb cx,0
        call seekF
        pop dx cx ax
        ret
        endp
getPage proc
        push ax cx dx
        mov al,2
        call setPos
        mov cx,512
        div cx
        or dx,dx
        je noIncAX
        inc ax
noIncAX:
        mov ds:myTitle+2,dx
        mov ds:myTitle+4,ax
        pop dx cx ax
        ret
        endp
subLenAX proc
        push ax
        mov lenVirus,ax
        mov cl,1
        jmp short subLenNow
        endp
subLenVir proc
        cmp erase,0
        stc
        jne noSubLenVir
        push ax
        call getLenVir
subLenNow:
        call shiftToLen
        push cx
        xor cx,cx
        call writeF
        pop cx
        jcxz noWrHead
        cmp typeFile,1
        jne noSetPage
        call getPage
noSetPage:
        call writeHead
noWrHead:
        call setTime
        pop ax
noSubLenVir:
        ret
        endp
printLen proc
        cmp ax,1
        jbe noOut0
        or ax,ax
        js  noOut0
        mov dl,'.'
        call writeChar
        mov dx,ax
        call writeDec
        mov dl,'.'
        call writeChar
noOut0:
        ret
        endp
getLenVir proc
        push cx dx si
        call getLenWordFile
        or ax,ax
        jns storeLen
        xchg dx,ax
        lea si,tabBlock
        lodsw
        xchg cx,ax
        cmp dx,-10
        je getAutLen
        cmp typeFile,0
        mov cx,1
        jne noIncBlock
        inc cx
noIncBlock:
        call getEP
        inc dx
        je storeLen
        dec dx
        sub ax,dx
        jmp short storeLen
getAutLen:
        call getEP
storeLen:
        mov lenVirus,ax
        pop si dx cx
        ret
        endp
getEP proc
        cmp typeFile,0
        jne getItLen
        xor ax,ax
        dec cx
        jz getLenOk
nextCellT:
        lea si,[si+4]
getItLen:
        mov ax,globalHi
        sub ax,[si]
        dec cx
        jz getLenOk
        push ax
        mov ax,[si+4]
        cmp ax,[si]
        pop ax
        jb nextCellT
getLenOk:
        ret
        endp
compareIB proc
        push cx di
        mov cx,512
        jmp short noSet0di
        endp
compareIT proc
        push cx di
        mov cx,6000
        sub di,4000
        jnc noSet0di
        xor di,di
noSet0di:
        mov al,[si+1]
        repne scasb
        jne endFullSc
;        call writePalBr
        mov ax,-1
        push si
        call compare
        pop  si
        jne noSet0di
endFullSc:
        mov ax,-1
        call compare
        pop di cx
        ret
        endp
compareB proc
        or ax,ax
        jne compare
        cmp byte ptr [si],16
        ja compare
        cmp byte ptr [si],10
        jb compare
        jmp compareIB
        endp
compareM proc
        or ax,ax
        jne compare
        cmp byte ptr [si],16
        ja compare
        cmp byte ptr [si],10
        jb compare
        jmp compareIT
compare:
        cmp byte ptr [si],2
        jne compare1
        push si
        mov si,[si+1]
        call compare1
        pop si
        lea si,[si+3]
        ret
        endp
compare1 proc
        push cx di
        add di,ax
        xor ch,ch
        lodsb
        cmp al,18
        jne check16
        call scanSpec
        jmp short finishS
check16:
        cmp al,16
        jne check6
        call scan2sum
        jmp short finishS
check6:
        cmp al,6
        jne oldScan1
        call scanChSum
        jmp short finishS
oldScan1:
        mov cl,al
        xor ax,ax
        jcxz finishS    ;a
cmpByte:
        cmpsb
        je noInc
        inc ax
noInc:
        loop cmpByte
        or ax,ax
finishS:
        pop di cx
        ret
        endp
callProcAx proc
        push si
        mov si,ds
        cmp sigSeg,si
        jne callFar
        call ax
        jmp short endCall
callFar:
        mov offSig,ax
        call dword ptr offSig     ; адрес подпрограммы ; gs
endCall:
        pop si
        ret
        endp
fillHead proc
        push cx si di ds es
        push ss
        pop es
        mov ds,baseSeg
        mov si,100h
        lea di,myTitle
        mov cx,12
        rep movsw
        pop es ds di si cx
        ret
        endp
autoCureP proc
        add oldSI,ax
        push ds
        mov varAuto,1
        mov si,oldSI
        mov cx,oldCX
        mov countExec,4000
        cmp typeFile,0
        mov ds,baseSeg
        jne noSetBP
        mov cs:bPoint,100h
noSetBP:
        call symExec
        mov ax,-1
        mov cs:bPoint,ax
        pop ds
        mov varAuto,0
        mov countErr,1
        cmp si,100h
        je  cureAutoOk
        mov erase,2
        jmp short noFillHead
cureAutoOk:
        cmp typeFile,0
        jne noFillHead
        call fillHead
noFillHead:
        mov cl,1
        clc
        ret
        endp
checkExtern proc
        push si di
        call getComWord
        cmp al,2
        je extSub
        cmp typeFile,0
        je checkComExt
        call getExeWord
        cmp al,3
        jne noAuto
        mov al,ah
        cmp al,-10
        jne noAutoCom
        call getExeWord12
        call autoCureP
        jmp short noExtern

checkComExt:
        cmp al,3
        jne noAuto
        mov al,ah
        cmp al,-10
        jne noAutoCom
        call getComWord1
        call autoCureP
        jmp short noExtern
noAutoCom:
        call checkMoveShift
        je noExtern
noAuto:
        stc
noExtern:
        pop di si
        ret
extSub:
        call getComSub
        call callProcAx
        clc
        jmp noExtern

checkMoveShift:
        cmp al,-4
        jne noMoveBeg
        call moveBeg
        ret
noMoveBeg:
        cmp al,-5
        jne noShiftBod
        call shiftBod
        ret
noShiftBod:
        cmp al,-6
        jne noSetJmp
        call setJump
noSetJmp:
        ret
        endp

moveBeg proc
        push dx
        call getLenVir
        mov cx,ax
        shl ax,1
        cmp ax,posLoAll
        jb noChangeLen
        sub cx,posLoAll
        neg cx
        mov lenVirus,cx
noChangeLen:
        call shiftToLen
readWrite1:
        call read&write
        jnc noMoveErr
        call printNotCure
noMoveErr:
        mov ax,-1
        xor cx,cx
        pop dx
        ret
        endp
shiftBod proc
        push dx
        call getLenVir
        xor cx,cx
        xchg dx,ax
        call seekF
        mov cx,65500
        jmp readWrite1
        endp
setJump proc
        call getComWord1
        push si
        mov si,reloIP
        add si,ax
        mov 1 ptr es:[si-1],0E9h
        sub 2 ptr es:[si],103h
        pop si
        dec ax
        xor cx,cx
        mov cl,3
        ret
        endp
read&write proc
        push ax cx dx ds
        push es
        pop  ds
        xor dx,dx
        call readF
        jc readErr2
        push ax
        xor al,al
        call setPos
        pop cx
        call writeF
readErr2:
        pop ds dx cx ax
        ret
        endp
fillNameV proc
        push ax cx dx di es
        mov cx,virmodCount
        mov es,segVirInf
        xor di,di
        jcxz setupV
        call getLenWord
nextVinf:
        push ax
        call getNameWord1
        scasw           ; адрес имени
        pop ax
        jne skipVI0
        scasw           ; длина
        je skip0len
        cmp word ptr es:[di-2],0
        jne skipVI1
        mov es:[di-2],ax
skip0len:
        xchg dx,ax
        scasw           ; атрибуты
        xchg dx,ax
        jne skipVI
        inc word ptr es:[di]
        jmp short foundVI
skipVI0:
        scasw
skipVI1:
        scasw
skipVI:
        scasw
        loop nextVinf
setupV:
        inc virModCount
        push ax
        call getNameWord1
        stosw
        pop ax
        stosw
        mov ax,dx
        stosw
        mov ax,1
        stosw
        cmp dh,0
        je foundVI
        inc modCount
foundVI:
        pop es di dx cx ax
        ret
        endp
fillNewSig proc
        cmp saveSig,0
        je noFNV
        mov byte ptr saveSig,0
        push ax cx dx si di ds es
        mov ax,di
        add ax,posLo
        add di,offFS
        call checkSig
        ja skipFill
        mov offInFile1,ax
        mov si,di
        push es         ; ds = es
        pop  ds
        push ss         ; es = ss
        pop  es
        lea di,newSig
        mov ch,0
        mov cl,es:[di+3]
        call fill1Sig
        mov cl,es:[di+3]
        add si,es:[di+1]
        call fill1Sig
skipFill:
        pop es ds di si dx cx ax
noFNV:
        ret
        endp
fill1Sig proc
        mov al,[si]
        stosb
        call calcSum
        scasw
        scasb
        stosw
        xchg dx,ax
        stosw
        ret
        endp
checkSig proc
        push ax bx
        xor bx,bx
        mov cx,15
nextByteNS:
        push cx di
        xor ah,ah
        mov al,es:[di+bx]
        inc bx
        inc di
        mov cl,14
nextCharNS:
        scasb
        jne noEquS
        inc ah
noEquS:
        loop nextCharNS
        pop di cx
        cmp ah,7
        ja veryBad
        loop nextByteNS
veryBad:
        pop bx ax
        ret
        endp
        .data
saveSig         db 0
strPath         db 'PATH=C:\;',0
lenStP          equ $-strPath
mesWar          db ' - болен ',0
                db ' - infected with ',0
                dw 0EE01h,mesWar
mesEkz          db ' - экземпляр вируса ',0
                db ' - contain the virus ',0
                dw 0EE01h,mesEkz
mesDelete       db ' Стереть',0
                db ' Erase',0
                dw 0EE01h,mesDelete
mesDelOk        db ' УДАЛЕН.',0
                db ' DELETED.',0
                dw 0EE01h,mesDelOk
mesRename       db 1,12,' Пеpеименовать',0
                db 1,12,' Rename file',0
                dw 0EE01h,mesRename
mesRenOk        db ' Пеpеименован.',0
                db ' Renamed.',0
                dw 0EE01h,mesRenOk
mesModInf       db ' - болен модификацией ',0
                db ' - infected with modify ',0
                dw 0EE01h,mesModInf
mesPack         db 1,9,' - упакован ',0
                db 1,9,' - packed ',0
                dw 0EE01h,mesPack
mesCoPr         db 1,10,' - защищен ',0
                db 1,10,' - protected with ',0
                dw 0EE01h,mesCoPr
mesStand        db ' - стандартный файл ',0
                db ' - standart file - ',0
                dw 0EE01h,mesStand
mesNoCure       db ' Лечение НЕВОЗМОЖНО !',10,0
                db ' Repair IMPOSIBLE !',10,0
                dw 0EE01h,mesNoCure
nameNew         db 'NewVirus('
newName         db 10 dup(0)
autoSig         db 4
                dw nameNew
                dw 0
                db 3,-10
                dw 0
                db 3,-10
                dw 0
                dw -10
iniSigOff       dw tableOfViruses
iniSigSeg       dw @data
oldSI           dw ?
oldCX           dw ?
offSig          dw ?
sigSeg          dw ?
modifySi        dw 0
modifyDS        dw ?
end
