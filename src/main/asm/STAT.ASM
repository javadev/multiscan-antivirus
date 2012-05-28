
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; В этом модуле выводится статистика проверки. Ошибки в английском просьба
; исправлять.

public  outFullStat,startTime,saveTimeD,saveTimeF,saveTimeO,outMemStat
public  mesStatist,mesFiles&Sec,mesProgTest,mesVir&Mod,mesModTest,mesInf&BadF
public  mesBadTest,mesCure&Del,mesDelTest,mesStranDate,mesDateCur,mesFilesCrypt
public  mesTimeScan,mesTimeFile,mesSpeedFile,mesSpeedDir,mesDirMin
public  mesNewVir,mesRenTest,mesFileSig,mesFileSigVir,mesMemCell
public  mesMemCellStd,mesMemVir,mesMemVirNew,mesAmountCureM,mesAmountLock
extrn   filesCount:word,progCount:word
extrn   virmodCount:word,modCount:word
extrn   infbadCount:word,badCount:word
extrn   infNewCount:word,renCount:word
extrn   curdelCount:word,delCount:word
extrn   dateCount:word,curdatCount:word
extrn   cryptCount:word,dirCount:word
extrn   fileSigCount:word,virsigCount:word
extrn   memCellCount:word,memstdCount:word
extrn   memvirCount :word,memnewCount:word
extrn   memcureCount:word,memlockCount:word
extrn   dirTime:word,fileTime:word,curSecond1:word,curChas1:word
extrn   color:byte,printEng:near,writeDec:near,writeChar:near,curPos:byte
extrn   print0D0A:near,curSecond:word,curChas:word,var0D:byte,varEvr:byte
extrn   varViewOn:byte,delString:near,varWin:byte
        .model small
        .code
outMemStat proc
        push cx dx si
        mov var0D,1
        lea si,tabOffMes1
        call delString
        call print0D0A
        mov color,11
        call outPunkt
        lea si,[si+8]
        mov cx,3
nextMpunkt:
        call outPunkt
        push si
        mov si,[si+10]
        cmp word ptr [si],0
        pop si
        mov color,3
        je  blueColM
        mov color,12
blueColM:
        lea si,[si+8]
        loop nextMpunkt
        call print0D0A
        mov cx,8
        lea si,tabOffMes1
        call clearVar
        mov var0D,0
        pop si dx cx
        ret
        endp
outFullStat proc
        push cx dx si
        mov color,11
        lea dx,mesStatist
        call printEng
        mov var0D,1
        mov cx,6

        lea si,tabOffMes2
nextPunkt:
        cmp cx,3
        jne noTestCo
        cmp varViewOn,0
        jne noTestCo
        cmp infNewCount,0
        je setColor
noTestCo:
        call outPunkt
setColor:
        push si
        mov si,[si+10]
        cmp word ptr [si],0
        pop si
        mov color,3
        je  blueCol
        mov color,12
blueCol:
        lea si,[si+8]
        loop nextPunkt

        cmp varEvr,0
        je noOutCr
        mov cl,6
        lodsw
        xchg ax,dx
        call printEng
        lodsw
        xchg ax,bx
        mov dx,[bx]
        call writeDecF
        call print0D0A
noOutCr:
        mov color,3
        lea dx,mesTimeScan
        call printEng
        mov dx,dirTime
        add dx,fileTime
        call outTime
        call check0D0A
        lea dx,mesTimeFile
        call printEng
        mov dx,fileTime
        call outTime
        call writeSC
        lea dx,mesSpeedFile
        call printEng
        mov dx,fileTime
        mov cx,filesCount
        call outSpeed
        lea dx,mesSpeedDir
        call printEng
        call check0D0A
        mov dx,dirTime
        mov cx,dirCount
        call outSpeed
        lea dx,mesDirMin
        call printEng
        call print0D0A
        mov cx,14
        lea si,tabOffMes2
        call clearVar
        mov var0D,0
        pop si dx cx
        ret
        endp
clearVar proc
        push bx cx si
nextCl:
        lodsw
        lodsw
        xchg bx,ax
        mov word ptr [bx],0
        loop nextCl
        pop si cx bx
        ret
        endp
outSpeed proc
        push ax cx dx
        mov ax,60
        mul cx
        pop cx
        push cx
        or cx,cx
        jnz divonCx
        inc cx
divonCx:
        div cx
        xchg ax,dx
        mov cx,6
        call writeDecF
        pop dx cx ax
        ret
        endp
outTime proc
        push ax cx dx
        xchg ax,dx
        mov cx,3600
        xor dx,dx
        div cx
        or al,'0'
        push dx
        mov dl,al
        call writeChar
        mov dl,':'
        call writeChar
        pop ax
        mov cx,60
        xor dx,dx
        div cx
        call outMinSec
        xchg ax,dx
        mov dl,':'
        call writeChar
        call outMinSec
        mov dl,' '
        call writeChar
        pop dx cx ax
        ret
        endp
outMinSec proc
        push ax dx
        aam
        or ax,'00'
        mov dl,ah
        call writeChar
        mov dl,al
        call writeChar
        pop dx ax
        ret
        endp
check0D0A proc
        cmp varWin,0
        je noCLCF
        call print0D0A
noCLCF:
        ret
        endp
outPunkt proc
        push ax bx cx dx si
        mov cx,6
        lodsw           ; si+2
        xchg dx,ax
        call printEng
        lodsw           ; si+4
        xchg bx,ax
        mov dx,[bx]
        call writeDecF
        call check0D0A
        lodsw           ; si+6
        xchg dx,ax
        call printEng
        lodsw           ; si+8
        xchg bx,ax
        mov dx,[bx]
        call writeDecFpl
        pop si dx cx bx ax
        ret
        endp
writeDecFpl proc
        push dx
        call writeDecF
        pop dx
writeSC:
        push dx
        mov dl,')'
        call writeChar
        mov dl,';'
        call writeChar
        call print0D0A
        pop dx
        ret
        endp
writeDecF proc
        push ax cx dx
        mov ah,curPos
        call writeDec
        mov al,curPos
        sub al,ah
        xor ah,ah
        sub cx,ax
        jbe noOutSp
        mov dl,' '
nextSP:
        call writeChar
        loop nextSP
noOutSp:
        pop dx cx ax
        ret
        endp
startTime proc
        push ax cx dx
        xor ax,ax
        int 1Ah
        mov curSecond,dx
        mov curSecond1,dx
        mov curChas,cx
        mov curChas1,cx
        pop dx cx ax
        ret
        endp
saveTimeD proc
        push ax
        call saveTime
        add dirTime,ax
        pop ax
        ret
        endp
saveTimeF proc
        push ax
        call saveTime
        add fileTime,ax
        pop ax
        ret
        endp
saveTimeO proc
        push ax cx
        xor ax,ax
        int 1Ah
        push cx dx
        sub dx,curSecond1
        sbb cx,curChas1
        pop curSecond1
        pop curChas1
        jnc noOverC
        neg dx
noOverC:
        mov ax,55
        mul dx
        xchg dx,ax
        pop cx ax
        ret
        endp
saveTime proc
        push cx dx
        xor ax,ax
        int 1Ah
newTime:
        sub dx,curSecond
        sbb cx,curChas
        jnc timeOk
        add dx,curSecond
        adc cx,curChas
        add dx,24
        jmp newTime
timeOk:
        push dx
        mov ax,3600
        mul cx
        pop dx
        push ax
        xchg ax,dx
        mov dx,5
        mul dx
        mov cx,92
        div cx
        pop cx
        add ax,cx
        pop dx cx
        ret
        endp
        .data
mesStatist      db 10,9,9,9,1,10,' Результаты сканирования:',10,0
                db 10,9,9,9,1,10,'     Scanning result:',10,0
                dw 0EE01h,mesStatist
mesFileSig      db 'Загружено файлов сигнатур и внешних баз    - ',0
                db 'Is loaded of files .Sig and external bases - ',0
                dw 0EE01h,mesFileSig
mesFileSigVir   db '(сигнатур вирусов   ',0
                db '(sig. of viruses    ',0
                dw 0EE01h,mesFileSigVir
mesMemCell      db 1,14,'Проверено участков памяти                  - ',0
                db 1,14,'Is checked of sites of memory              - ',0
                dw 0EE01h,mesMemCell
mesMemCellStd   db '(из них стандартных ',0
                db '(from them standard ',0
                dw 0EE01h,MesMemCellStd
mesMemVir       db 'Обнаружено старых и новых вирусов в памяти - ',0
                db 'Is found out of old and new viruses        - ',0
                dw 0EE01h,mesMemVir
mesMemVirNew    db '(из них новых       ',0
                db '(from them new      ',0
                dw 0EE01h,mesMemVirNew
mesAmountCureM  db 'Количество обезвреженных и заблокированных - ',0
                db 'The quantity neuralized and blocked        - ',0
                dw 0EE01h,mesAmountCureM
mesAmountLock   db '(из них заблокир.   ',0
                db '(from them is block ',0
                dw 0EE01h,mesAmountLock
mesFiles&Sec    db 1,11,'Проверено файлов и загрузочных секторов    - ',0 ; 1
                db 1,11,'Is checked of files and loading sectors    - ',0
                dw 0EE01h,mesFiles&Sec
mesProgTest     db '(из них программ    ',0
                db '(of the programs    ',0
                dw 0EE01h,mesProgTest
mesVir&Mod      db 'Обнаружено вирусов и их модификаций        - ',0 ; 2
                db 'Is found out of viruses & their updatings  - ',0; 2
                dw 0EE01h,mesVir&Mod
mesModTest      db '(из них модификаций ',0
                db '(of updatings       ',0
                dw 0EE01h,mesModTest
mesInf&BadF     db 'Обнаружено зараженных и испорченных файлов - ',0 ; 3
                db 'Is found out infected and bad files        - ',0; 3
                dw 0EE01h,mesInf&BadF
mesBadTest      db '(из них испорченных ',0
                db '(from them bad      ',0
                dw 0EE01h,mesBadTest
mesNewVir       db 'Обнаружено подозрительных на вирус файлов  - ',0
                db 'Is found out suspicious on virus of files  - ',0
                dw 0EE01h,mesNewVir
mesRenTest      db '(из них пеpеименов. ',0
                db '(from them rename   ',0
                dw 0EE01h,mesRenTest
mesCure&Del     db 'Количество вылеченных и удаленных файлов   - ',0 ; 4
                db 'Quantity of cured and removed files        - ',0
                dw 0EE01h,mesCure&Del
mesDelTest      db '(из них удаленных   ',0
                db '(from them remoted  ',0
                dw 0EE01h,mesDelTest
mesStranDate    db 'Количество файлов со странной датой созд.  - ',0 ; 5
                db 'Quantity of files with strange date        - ',0
                dw 0EE01h,mesStranDate
mesDateCur      db '(дата исправлена у  ',0
                db '(is corrected at    ',0
                dw 0EE01h,mesDateCur
mesFilesCrypt   db 1,14,'Количество файлов, содержащих расшифровщик - ',0 ; 6
                db 1,14,'Quantity of files, containing CRYPT code   - ',0
                dw 0EE01h,mesFilesCrypt
mesTimeScan     db 'Время сканирования директорий и файлов     - ',0 ; 7
                db 'Time of scanning of directories and files  - ',0
                dw 0EE01h,mesTimeScan
mesTimeFile     db '(время на файлы ',0
                db '(time on files  ',0
                dw 0EE01h,mesTimeFile
mesSpeedFile    db 'Скорость проверки - ',0                          ; 8
                db 'Speed of check    - ',0
                dw 0EE01h,mesSpeedFile
mesSpeedDir     db 'файл(ов) в минуту, ',0                          ; 9
                db 'files in minute,   ',0
                dw 0EE01h,mesSpeedDir
mesDirMin       db 'директорий в минуту.',0
                db 'directories in min. ',0
                dw 0EE01h,mesDirMin

tabOffMes1      dw mesFileSig,fileSigCount,mesFileSigVir,virsigCount
                dw mesMemCell,memCellCount,mesMemCellStd,memstdCount
                dw mesMemVir,memvirCount,mesMemVirNew,memnewCount
                dw mesAmountCureM,memcureCount,mesAmountLock,memlockCount

tabOffMes2      dw mesFiles&Sec,filesCount,mesProgTest,progCount     ; 1 6
                dw mesVir&Mod, virmodCount,mesModTest,modCount       ; 2 5
                dw mesInf&BadF,infbadCount,mesBadTest,badCount       ; 3 4
                dw mesNewVir  ,infNewCount,mesRenTest,renCount       ; 3 3
                dw mesCure&Del,curdelCount,mesDelTest,delCount       ; 4 2
                dw mesStranDate,dateCount,mesDateCur,curdatCount     ; 5 1
                dw mesFilesCrypt,cryptCount                          ; 6
                dw 0,dirCount,0,dirTime,0,fileTime
end
