
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Модуль выводит текстовые комментарии к файлам. Была испралена ошибка 
; из-за которой комментарии не выводились.

public  prikol
extrn   print:near,print0D0A1:near,formDI_CX:near,color:byte,varMes:byte
extrn   writeChar:near,startMes:word,pointMes:word,segMes:word
extrn   printPathFI:near
        .model small
        .code
prikol proc
        cmp varMes,0
        je  exitC
        push ax bx cx dx si di ds es
        push ss
        pop  es
        call formDI_CX
        call printPathFI
        mov color,2
        call scanMes
        jc  exitCheck
        lea si,tableName
        xor ch,ch
checkName:
        lodsb
        mov cl,al
        push di
        rep cmpsb
        pushf
        add si,cx
        popf
        pop di
        je printMes
        lodsw
        cmp ax,20
        ja oldSkip
        shl ax,1
        add si,ax
oldSkip:
        cmp si,offset tableEnd
        jb checkName
exitCheck:
        pop es ds di si dx cx bx ax
exitC:
        ret
        endp
printMes proc
        mov dl,' '
        call writeChar
        lodsw
        cmp ax,20
        ja write1
        push ax         ; ax это количество альтернатив
        mov ah,0
        int 1Ah
        xchg ax,dx      ; теперь в ax значение таймера
        pop bx
        xor dx,dx
        div bx          ; в dx случайное число 0 · ax-1
        shl dx,1
        add si,dx
        lodsw
write1:
        xchg dx,ax
        call print
        call print0D0A1
        jmp short exitCheck
        endp
scanMes proc
        cmp segMes,0
        je endSmes
        push si ds
        mov si,startMes
        mov ds,segMes
        dec cx
nextMes:
        lodsw
        push cx si di
        xchg ax,si
        rep cmpsb
        je outMesB
        clc
nextMess:
        pop di si cx
        jc endMes
        cmp si,ss:pointMes
        jb nextMes
endMes:
        pop ds si
endSmes:
        ret
outMesB:
nextCharS:
        lodsb
        cmp al,' '
        je nextCharS
        lea dx,[si-2]
        call print
        call print0D0A1
        stc
        jmp nextMess
        endp
	.data
tableName       label byte
        db 9,'TURBO.EXE'
        dw 2
        dw mesTurbo1
        dw mesTurbo2
        db 8,'TASM.EXE'
        dw 3
        dw mesTasm1
        dw mesTasm2
        dw mesTasm3
        db 9,'TLINK.EXE'
        dw mesTlink
        db 7,'AFD.EXE'
        dw mesAfd
        db 6,'TC.EXE'
        dw mesTc
        db 7,'WIN.COM'
        dw 5
        dw mesWin
        dw mesWin1
        dw mesWin2
        dw mesWin3
        dw mesWin4
        db 6,'VC.COM'
        dw 3
        dw mesVc1
        dw mesVc2
        dw mesVc3
        db 6,'NC.EXE'
        dw mesNc
        db 12,'AIDSTEST.EXE'
        dw 3
        dw mesAids1
        dw mesAids2
        dw mesAidstest
        db 9,'DRWEB.EXE'
        dw 2
        dw mesWeb1
        dw mesWeb2
        db 10,'QBASIC.EXE'
        dw mesQb
        db 7,'800.COM'
        dw 5
        dw mes8001
        dw mes8002
        dw mes8003
        dw mes8004
        dw mes8005
        db 10,'KEYRUS.COM'
        dw 2
        dw mesKey1
        dw mesKey2
        db 12,'SMARTDRV.EXE'
        dw 2
        dw mesSmart1
        dw mesSmart2
        db 6,'WD.COM'
        dw mesWd
        db 7,'LEX.EXE'
        dw mesLex
        db 10,'FF2EGA.EXE'
        dw mesFF2
        db 10,'FORMAT.COM'
        dw mesFormat
        db 9,'FDISK.EXE'
        dw mesFdisk
        db 6,'DN.COM'
        dw 3
        dw mesDn1
        dw mesDn2
        dw mesDn3
        db 8,'DISKCOPY'
        dw mesDisk
        db 7,'SYS.COM'
        dw 2
        dw mesSys1
        dw mesSys2
        db 7,'ARJ.EXE'
        dw mesArj
        db 7,'RAR.EXE'
        dw 2
        dw mesRar1
        dw mesRar2
        db 7,'NDD.EXE'
        dw mesNdd
        db 6,'SD.EXE'
        dw mesSd
        db 5,'LIGHT'
        dw mesLight
        db 5,'VIRUS'
        dw mesVirus
        db 7,'LHA.EXE'
        dw mesLha
        db 7,'CIV.EXE'
        dw mesCiv
        db 8,'F117.COM'
        dw mesF117
        db 8,'SU25.EXE'
        dw mesSu25
        db 6,'CW.EXE'
        dw mesCw
        db 10,'ADSTCH.EXE'
        dw mesAdonis
        db 7,'AIN.EXE'
        dw mesAin
        db 9,'PKZIP.EXE'
        dw mesZip
        db 11,'PKUNZIP.EXE'
        dw mesZip
        db 7,'P51.EXE'
        dw mesP51
        db 11,'PU_DISK.COM'
        dw mesPu
        db 12,'DISKMOON.EXE'
        dw mesMoon
        db 12,'DISKREET.EXE'
        dw mesReet
        db 7,'ADM.EXE'
        dw mesAdm
        db 8,'DIET.EXE'
        dw mesDiet
        db 10,'PKLITE.EXE'
        dw mesPkl
        db 9,'HBIOS.COM'
        dw mesHb
        db 9,'ELITE.EXE'
        dw mesElite
        db 7,'POP.EXE'
        dw mesPop
        db 8,'WOLF.EXE'
        dw 2
        dw mesWolf1
        dw mesWolf2
        db 9,'SPEAR.EXE'
        dw 2
        dw mesSpear1
        dw mesSpear2
        db 9,'DOOM2.EXE'
        dw mesDoom
        db 11,'DESCENT.EXE'
        dw 2
        dw mesDescent1
        dw mesDescent2
        db 8,'VKEY.COM'
        dw mesVkey
        db 6,'UNIEGA'
        dw mesUni
        db 8,'COMP.EXE'
        dw mesComp
        db 10,'CHKDSK.EXE'
        dw mesChk
        db 8,'POLE.EXE'
        dw mesPole
        db 9,'MSCAN.EXE'
        dw 4
        dw mesMscan1
        dw mesMscan2
        dw mesMscan3
        dw mesMscan4
        db 8,'PCDL.EXE'
        dw mesPcdl
        db 7,'CPP.EXE'
        dw mesCpp
        db 7,'TPC.EXE'
        dw mesTpc
        db 8,'TLIB.EXE'
        dw mesTlib
        db 7,'LHX.EXE'
        dw mesLhx
        db 9,'SOBOR.EXE'
        dw mesSobor
        db 7,'TCC.EXE'
        dw mesTcc
        db 6,'BC.EXE'
        dw 2
        dw mesBc1
        dw mesBc2
        db 9,'MOUSE.COM'
        dw 2
        dw mesMouse1
        dw mesMouse2
        db 9,'LABEL.EXE'
        dw mesLabel
        db 8,'MORE.EXE'
        dw mesMore
        db 8,'FIND.EXE'
        dw mesFind
        db 8,'INDY.EXE'
        dw 2
        dw mesIndy1
        dw mesIndy2
        db 5,'X.EXE'
        dw mesRetal
        db 12,'WARLORD2.EXE'
        dw mesWar
        db 7,'SOL.EXE'
        dw mesSol
        db 9,'LECAR.EXE'
        dw 2
        dw mesLecar1
        dw mesLecar2
        db 6,'YEAGER'
        dw mesYeag
        db 6,'KB.EXE'
        dw mesKb
        db 9,'HONEY.EXE'
        dw mesHoney
        db 10,'DELPHI.EXE'
        dw 2
        dw mesDelphi1
        dw mesDelphi2
        db 6,'HA.EXE'
        dw mesHa
        db 11,'HERETIC.EXE'
        dw mesHeretic
        db 6,'FD.EXE'
        dw mesFdoor
        db 7,'TMAIL.E'
        dw mesFdoor
        db 10,'NETSCAPE.E'
        dw mesNetscape
        db 9,'STUNTS.CO'
        dw mesStunts
        db 6,'DRWEB'
        dw mesDrweb
        db 7,'AVP.EXE'
        dw mesAvp
        db 9,'AVP32.EXE'
        dw 2
        dw mesAvp321
        dw mesAvp322
        db 7,'AVPTSR'
        dw mesAvptsr
        db 8,'WINWORD'
        dw mesWinword
        db 6,'EXCEL'
        dw mesExcel
        db 9,'SCANDISK'
        dw mesScandisk
        db 6,'PC.EXE'
        dw mesPc
        db 8,'PU_1700'
        dw mesPU_1700
        db 9,'PU_WRCFD'
        dw mesPu_wrcfd
        db 9,'PU_1700F'
        dw mesPu_1700f
        db 9,'DISKREST'
        dw mesDiskrest
        db 8,'VFORMAT'
        dw mesVformat
        db 7,'MSCDEX'
        dw mesMscdex
        db 9,'RAMDRIVE'
        dw mesRamdrive
        db 9,'Memmaker'
        dw mesMemmaker
        db 8,'QEMM.SYS'
        dw mesQemm
        db 10,'CONFIG.SYS'
        dw mesConfig
        db 12,'AUTOEXEC.BAT'
        dw mesAutoexec
        db 6,'LEM3D.'
        dw 2
        dw mesLem3D1
        dw mesLem3D2
tableEnd        label byte
mes8001         db 'драйвер диcка. (автор Alberto PASQUALE.)'   ,0
mes8002         db 'восемьсотка или восьмисотник ?'             ,0
mes8003         db 'ненужно ему ничего носить с собой'         ,0
mes8004         db 'его длина примерно 8.805'                  ,0
mes8005         db 'этот файл заменяет половину дисковвода'    ,0
mesAdonis       db 'для тестирования. (нужная вещь)'            ,0
mesAdm          db 'утилита для разбивки и форматирования винч-ра',0
mesAfd          db 'полноэкранный отладчик'                    ,0
mesAids1        db 'антивирус AIDSTEST. (автор Лозинский Д.Н.)',0
mesAids2        db 'очень хороший антивирус'                   ,0
mesAin          db 'архиватор AIN'                             ,0
mesAidstest     db 'AIDS-тест Лозинского'                      ,0
mesArj          db 'архиватор ARJ'                             ,0
mesAutoexec     db 'Что,откуда и куда загружать при старте ДЛЯ МЕНЯ !! (компьютера)',0
mesAvp          db 'Господин ДОКТОР Касперский - НУ, ОЧЕНЬ МНОГО ВИРУСОВ ЗНАЕТ !',0
mesAvptsr       db 'Антивирусный монитор'                      ,0
mesAvp321       db 'Антивирус Касперского АВП для Windows 95/NT',0
mesAvp322       db 'Кому нужен файл AVP.KEY - продаю недорого' ,0
mesBc1          db 'полноэкранный компилятор языка C++'        ,0
mesBc2          db 'язык С++. (переходите на версию 5.0)'      ,0
mesChk          db 'для диагностики диска. Типа NDD или ADINF' ,0
mesCiv          db 'не шарю я в Civilization, ну и что'        ,0
mesComp         db 'для сравнения файлов'                      ,0
mesConfig       db 'ЭТО как РАСПОРЯДОК ДНЯ , ДЛЯ ВАШЕГО КОМПЬЮТЕРА !!!',0
mesCpp          db 'строчный компилятор языка С++'             ,0
mesCw           db 'текстовый редактор. (текста и формул)'     ,0
mesDescent1     db 'все играйте в DESCENT'                     ,0
mesDescent2     db 'это что-то сверхестественное'              ,0
mesDelphi1      db 'сколько народу помешалось на этом'         ,0
mesDelphi2      db 'PASCAL 9.0'                                ,0
mesDisk         db 'для копирования дискет. (ДОС)'             ,0
mesDiet         db 'один из лучших компрессоров COM,EXE,*.*'   ,0
mesDiskrest     db 'Для формата дискет типа TRACK 0 -BAD, если они на вес золота!',0
mesDn1          db 'целая среда для работы с файлами'          ,0
mesDn2          db 'просто класс. (переходите на версию 2.0)'  ,0
mesDn3          db 'ребята, исправьте UPLOAD в терминале'      ,0
mesDoom         db 'поDoom''аем вместе. (IDD твою QD)'         ,0
mesDrweb        db 'ПРИВЕТ Полифагу Доктору WEB'               ,0
mesElite        db 'можно нехило полетать'                     ,0
mesExcel        db 'Электронные таблицы - находка для БУХГАЛТЕРА !!',0
mesF117         db 'гроза для SU25'                            ,0
mesFF2          db 'игрущка, стрелялка'                        ,0
mesFdisk        db 'утилита для разбивки винч-ра на логич-е диски. (ДОС)',0
mesFdoor        db 'Best''овый мейлер'                         ,0
mesFind         db 'для поиска файлов'                         ,0
mesFormat       db 'утилита для форматирования гибких дисков и винч-ра. (ДОС)',0
mesHa           db 'тоже архиватор. (переходите на версию 1.0)',0
mesHb           db 'всем бы писать такие программы'            ,0
mesHeretic      db 'какая там музыка ... И вообще зачем нам ДУМ ?',0
mesHoney        db 'с ней я сталкиваюсь - ежедневно'           ,0
mesIndy1        db 'нехило покататься вам, парни !'            ,0
mesIndy2        db 'а ты, доехал до финиша ?'                  ,0
mesKb           db 'игрушка. (завоевание мира)'                ,0
mesKey1         db 'драйвер клавиатуры и экрана. (написан в Донецке.)',0
mesKey2         db 'это как кислород для каждого из нас'       ,0
mesLabel        db 'для создания меток на дисках'              ,0
mesLex          db 'редактор текстов. (автор Веселов)'         ,0
mesLecar1       db 'один из лучших киевских антивирусов'       ,0
mesLecar2       db 'хорошая документация - 75% успеха'         ,0
mesLem3D1       db 'А ты прошел 61-й уровень ?'                ,0
mesLem3D2       db 'Помни о 61-ом уровне, это очень важно'     ,0
mesLha          db 'архиватор. (написан в Японии)'             ,0
mesLhx          db 'полет на боевом вертолёте'                 ,0
mesLight        db 'свет во тьме'                              ,0
mesMemmaker     db 'Менеджер памяти - Для работы в верхней памяти !',0
mesMoon         db 'для защиты дисков винч-ра от записи'       ,0
mesMouse1       db 'драйвер мыши'                              ,0
mesMouse2       db 'лучше gmouse.sys'                          ,0
mesMore         db 'больше, больше, больше ..'                 ,0
mesMscan1       db 'похож на меня'                             ,0
mesMscan2       db 'это же супер антивирус'                    ,0
mesMscan3       db 'неизменно превосходный результат'          ,0
mesMscan4       db 'заказывайте коментарии автору !'           ,0
mesMscdex       db 'Для подключения CD-ROM'                    ,0
mesNc           db 'утилита для работы с файлами. (Symantic Inc.)',0
mesNdd          db 'для исправления ошибок на диске. (запускайте осторожно)',0
mesNetscape     db 'жемчужина домашней колекции'               ,0
mesP51          db 'полёт на самолёте времён II мировой войны' ,0
mesPU_1700      db 'Панков утилиты, Одному дисководу - ВСЕ ФОРМАТЫ !!!',0
mesPcdl         db 'дряхленький редактор диска'                ,0
mesPc           db 'PC-TOOLS - для редактирования HDD или Дискет , ФАЙЛОВ',0
mesPkl          db 'сжимальщик файлов, но не всех'             ,0
mesPop          db 'POPCORN - воздушная кукуруза'              ,0
mesPole         db 'игрущка - FILE OF MAGIC (поле чудес)'      ,0
mesPu           db 'для защиты дисков винч-ра от записи/чтения',0
mesPu_wrcfd     db 'Для проверки качества записи НА Ж.ДИСК или ДИСКЕТУ',0
mesPu_1700f     db 'Резидентный форматтер дискет,а также дискет типа TRACK -0 bad',0
mesQb           db 'полноэкранный компилятор языка бейсик. (Microsoft Corp.)',0
mesQemm         db 'Еще "круче" чем memmaker , тоже диспетчер памяти!',0
mesRar1         db 'архиватор RAR. (переходите на версию 2.03)',0
mesRar2         db 'лучший из архиваторов - RAR !'             ,0
mesRamdrive     db 'Нужен RAM(виртуальный) диск - ПОЛУЧИТЕ !'  ,0
mesReet         db 'спрячет диск от самого себя'               ,0
mesRetal        db 'круто полетать тебе, super boy'            ,0
mesScandisk     db 'Проще, чем NDD - а функции те же'          ,0
mesSd           db 'утилита для оптимизации дисков. (Symantic Inc.)',0
mesSmart1       db 'утилита для кеширования диска. (Microsoft Corp.)',0
mesSmart2       db 'он так помогает в работе !!!'              ,0
mesSobor        db 'драка в русском стиле'                     ,0
mesSol          db 'все играйте в солиторрр'                   ,0
mesSpear1       db 'бегалка,стрелялка,гонялка'                 ,0
mesSpear2       db 'запускайте с ключом debugmode'             ,0
mesStunts       db 'Das is fantastish. Только для крутых'      ,0
mesSu25         db 'гроза для F117'                            ,0
mesSys1         db 'лечилка для COMMAND.COM'                   ,0
mesSys2         db 'вставьте в autoexec.bat системной дискеты' ,0
mesTasm1        db 'компилятор с языка ассемблер.(Borland Inc.)',0
mesTasm2        db 'великолепный компилятор'                   ,0
mesTasm3        db 'просто класс'                              ,0
mesTc           db 'полноэкранный копилятор языка C'           ,0
mesTcc          db 'строчный компилятор языка Turbo C'         ,0
mesTlink        db 'линковщик .obj файлов (Borland Inc.)'      ,0
mesTlib         db 'собирает OBJ файлы в библиотеку (.lib)'    ,0
mesTmail        db 'Rulez''ный мейлер'                         ,0
mesTpc          db 'строчный компилятор языка Turbo Pascal'    ,0
mesTurbo1       db 'полноэкранный компилятор языка Pascal'     ,0
mesTurbo2       db 'головная боль студентов'                   ,0
mesUni          db 'примитивный драйвер экрана'                ,0
mesVc1          db 'супер программа. Переходите на версию 5.0' ,0
mesVc2          db 'утилита для работы с файлами. (автор Волков В.В.)',0
mesVc3          db 'привет Севе от Bita Music'                 ,0
mesVformat      db 'Для формата и вакцинирования BOOTа дискет -  А.В.Сесса',0
mesVirus        db 'возможно это - вирус'                      ,0
mesVkey         db 'примитивный драйвер клавиатуры'            ,0
mesWar          db 'грифоном ходи, грифоном ходи !'            ,0
mesWd           db 'редактор текстов. (рекомендую версию 8.0)' ,0
mesWeb1         db 'антивирус WEB. (паутина, автор И. Данилов)',0
mesWeb2         db 'Господа, а как на счет обмена антивирусами ?',0
mesWin1         db 'каждому компьютеру по форточке'            ,0
mesWin2         db 'WINDOWS господа'                           ,0
mesWin3         db 'переходите на WINDOWS 98'                  ,0
mesWin4         db 'вы идете в ногу со временем'               ,0
mesWin          db 'Вероятно WINDOWS, 3.x или 95  ОКНО - ЭТО ХОРОШО !!',0
mesWinword      db 'WORD for WINDOWS'                          ,0
mesWolf1        db 'можно класно пострелять'                   ,0
mesWolf2        db 'запускайте с ключом -goobers'              ,0
mesYeag         db 'работа между перерывами'                   ,0
mesZip          db 'архиватор PKZIP'                           ,0
end
