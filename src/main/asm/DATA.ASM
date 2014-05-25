
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модуль сохранил свое изначальное предназначение и содержит множество
; данных.

public  storeSeg,memCount,memInfected,varPage,varPages,varFiles
public  varMesOk,varKeySt,varAll,varKeyOk,varKeyHel,color,pVer,itCom,itSys
public  itExe,diskete,mesDisk,mesSt,mesBody,mesBody1,mesBody2,mesBody3
public  mesTrace,memCurOk,listPoint
public  mesWho,mesOK,mesHelp,mes2,fptr,tableP,path,maskF,erase,verDos,buf
public  typeFile,poshi,poslo,poshiAll,posloAll,time,date,lenVirus,reloIP
public  bytesRead,buf1,myTitle,myDta,attrib,longFlo,longFhi,fname,padeg
public  varMem,diskType,varEng,varVakcine,varRap,handleRep,varBreak,bufferOut
public  varMes,varEvr,pathIni,pathDir,tableRoot,itDir,device,off23,seg23
public  off24,seg24,curSize,sizeInByte,curPos,videoSeg,color2,cxBoot
public  nameVir,sigOff,bufSig,tabOff,sizeVir,memOff,mesYN
public  cureMemory,bootOff,storeCX,localWord,mySign,curVer
public  typeNum,saveSi,saveCX,myStack,lenClear,pointComStr,oldOff
public  countSerr,countCr,off3,flagWrite,varViewOn,varSaveB,varLeft
public  pathMs,handleW,tableMes,segLng,adrSub,repName,count0A,mesStop1
public  mesAnyKey,var0D,countE,mesStop,varSM,varNP
public  varSound,saveAl,varAm,amName,segLst,pointLst,segRec,lenRec
public  startMes,pointMes,segMes,falseSeg,dtaSeg,baseSeg,asmSeg,baseIP,varAS
public  countTab,offOpt,tabBlock,envSeg,cursor,pointT,msbPosLo,msbPosHi
public  localHex,varStop,varMemF,fDate,countStr,countBlock
public  countInBl,bufScr,segProg,varDl,varMB,dhBoot,varST,varFN,varAA
public  filesCount,progCount,virModCount,modCount,infBadCount,badCount
public  infNewCount,renCount,varAuto,virusSeg,varWidth,varCT,varWT
public  curDelCount,delCount,dateCount,curDatCount,cryptCount,curChas1
public  dirCount,fileTime,dirTime,curSecond,curChas,segVirInf,curSecond1
public  varFM,myOff13,mySeg13,myOff21,mySeg21,handleMem,listChar,varView
public  saveOffSeg,myOff1,tabSkip,tabSkipO,varNV,eventTab,varFS,offSigForS
public  offOfCell,segOfCell
public  fileSigCount,virsigCount,memCellCount,memstdCount,offInFile1
public  memvirCount ,memnewCount,memcureCount,memlockCount,virFoundF,varMl
public  leftBound,rightBound,tabMsb,varWin,countNam,varBat,lngName,mlName
public  varSS,varRS,ssName,rsName,varRN,varMS,varND,offBS,offMS,offFS
public  varStd,varBS,varNonStop
extrn   memoryLo:near,mesBoot:near,mesBootV:near,mesMbr:near,infMbr:near
extrn   curOk:near,mesCr:near,mesSecNotFound:near,mesWriteProtect:near
extrn   mesTotalError:near,ioErr:near,diskNotReady:near,mesDataErr:near
extrn   mesWrite:near,mesRead:near,infMem:near,wasCur:near
extrn   mesWar:near,mesEkz:near,mesDelete:near,mesDelOk:near,mesModInf:near
extrn   mesDelV:near,mesAnti:near,mesVacOk,mesOver:near,mesWhoO:near
extrn   mesOverOk:near,infect:near,mesError:near,delIt:near,mesStrCom:near
extrn   mesProg:near,stdMbr:near,mesCoPr:near,mesPaus:near
extrn   mesPack:near,mesLab:near,mesBadD:near,mesBadT:near,mesVirMem:near
extrn   mesSetD:near,mesOkD:near,mesOkT:near
extrn   mesReport:near,mesComSt:near,mesFull:near,mesStand:near
extrn   mesPboot:near,mesClBad:near,mesNoCure:near
extrn   mesStatist:near,mesFiles&Sec:near,mesProgTest:near,mesVir&Mod:near
extrn   mesModTest:near,mesInf&BadF:near,mesBadTest:near,mesCure&Del:near
extrn   mesDelTest:near,mesStranDate:near,mesDateCur:near,mesFilesCrypt:near
extrn   mesTimeScan:near,mesTimeFile:near,mesSpeedFile:near,mesSpeedDir:near
extrn   mesDirMin:near,mesNewVir:near,mesRenTest:near,mesRename:near
extrn   mesRenOk:near,mesPosInf:near,mesKillMem:near,mesBlockOk:near
extrn   mesErrMsb:near,mesLoadMs:near,mesTimeTest:near
extrn   mesNoStdBoot:near,mesSaveFboot:near,mesWasSaveDb:near
extrn   mesWasInclud:near,mesCreat:near,mesFileSig:near,mesFileSigVir:near
extrn   mesMemCell:near,mesMemCellStd:near,mesMemVir:near,mesMemVirNew:near
extrn   mesAmountCureM:near,mesAmountLock:near,mesStInBoot:near
extrn   mesStBcured:near,mesNotF:near,mesStoreBoot:near,mesRestorBoot:near
extrn   mesBnotFound:near,mesBchSumErr:near,mesCmosErr:near,mesMBError:near
extrn   mesErr00:near,mesErr01:near,mesErr02:near,mesErr03:near,mesErr04:near
extrn   mesErr05:near,mesErr06:near,mesErr07:near,mesErr08:near,mesErr09:near
extrn   mesBadVer:near,mesWasLoad:near,mesNoMemMSB:near,mesNoGr100MSB:near
extrn   mesSaveCMB:near
extrn   mesV01,mesV02,mesV03,mesV04,mesV05,mesV06,mesV07
extrn   mesV08,mesV09,mesV10,mesV11,mesV12,mesV13,mesV14,mesV15,mesV16
extrn   mesV17,mesV18,mesV19,mesV20,mesV21,mesV22,mesV23,mesV24,mesV25
extrn   mesV26,mesV27,mesV28,mesV29,mesV30,mesV31,mesFinal,mesMemory
extrn   mesCom,mesAnd,mesExe,mesFiles,mesWriteOver
        .model small
        .data

itCom           db ' Вылечен как COM файл.',10,0
                db ' Repaired as COM file.',10,0
                dw 0EE01h,itCom
itExe           db ' Вылечен как EXE файл.',10,0
                db ' Repaired as EXE file.',10,0
                dw 0EE01h,itExe
itSys           db ' Вылечен как SYS файл.',10,0
                db ' Repaired as SYS file.',10,0
                dw 0EE01h,itSys
itDir           db ' Исправлен начальный кластер.',10,0
                db ' Restored first cluster.',10,0
                dw 0EE01h,itDir
diskete         db 9,9,'  Проверить еще один флоппи диск',0
                db 9,9,'     Checked another diskette',0
                dw 0EE01h,diskete
mesDisk         db 'Проверка диска ',0
                db 'Checking disk ',0
                dw 0EE01h,mesDisk
mesSt           db 10,9,'     Внимание !!! При открытии данного файла его длина'
                db 10,9,9,'        увеличилась на М',0
                db 10,9,'   Attention!!! At opening of the given file his length'
                db 10,9,9,'       has increased on М',0
                dw 0EE01h,mesSt
mesBody         db '     Внимание !!! Длина файла М',0
                db 'Attention!!! Length of a file М',0
                dw 0EE01h,mesBody
mesBody1        db ' увеличилась на М',0
                db ' has increased on М',0
                dw 0EE01h,mesBody1
mesBody2        db ' байт'
padeg           db '. '
                db 10,'       В памяти компьютера может находиться М'
                db 'активный резидентный вирус.',10,0
                db ' byte(s).'
                db 10,'       In memory of the computer there is М'
                db 'the active resident virus.',10,0
                dw 0EE01h,mesBody2
mesBody3        db 9,9,'   Хотите продолжить работу',0
                db 9,9,'   Do you want to continue',0
                dw 0EE01h,mesBody3
mesStop         db 10,9,9,1,13,'Продолжить проверку текущего диска',0
                db 10,9,1,13,'   Do you want to continue scanning current disk',0
                dw 0EE01h,mesStop
mesStop1        db 10,9,9,'    Продолжить проверку файла',0
                db 10,9,'      Do you want to continue scanning file',0
                dw 0EE01h,mesStop1
mesTrace        db '▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ Проверяю память'
mesLine         db ' ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',10,0
                db '▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ Scanning memory'
                dw 0FF01h,mesLine
                db 0
                dw 0EE01h,mesTrace
memCurOk        db 1,13,' ОБЕЗВРЕЖЕН.',10,0
                db 1,13,' CURED.',10,0
                dw 0EE01h,memCurOk
mesWho          db ' Вылечить',0
                db ' Restore',0
                dw 0EE01h,mesWho
mesYN           db ' [YNAIQ] ? ',0
                db ' [YNAIQ] ? ',0
                dw 0EE01h,mesYN
mesOK           db ' : в порядке',0
                db ' : ok',0
                dw 0EE01h,mesOk
mesAnyKey       db '~ Нажмите любую клавишу ...~',0
                db '~ Press a key ...~',0
                dw 0EE01h,mesAnyKey
mesHelp         equ $
        db 1,3
        db 10,9,' C:\AVIR>mscan path1 [path2] [path3] [/key1/key2 /key3]'
        db 10,9,'    где path - логический диск (* для C:, D:, ...)'
        db 10,9,'               или каталог.'
        db 10,9,'        key  - ключи.'
        db 10
        db 10,  ' Список ключей:'
        db 10,9,'~/-,CU,Y~ - лечить инфицированные файлы;'
        db 10,9,'~/T~    - запуск в режиме тестирования;'
        db 10,9,'~/C-~     - отключить кодо-анализатор;'
        db 10,9,1,12,'/C+   - автолечение новых вирусов;',1,3
        db 10,9,'~/*~     - проверять все файлы ( не только COM,EXE );'
        db 10,9,'~/E~   - удалять файлы, восстановление которых невозможно;'
        db 10,9,'~/RN~    - переименовывать подозрительные на вирус файлы и модификации;'
        db 10,9,'~/R-~  - не вести контроль за резидентными и стелс вирусами;'
        db 10,9,'~/CR~    - сообщать о шифрующихся механизмах в файлах (CRYPT);'
        db 10,9,'~/M-~  - не проверять память;'
        db 10,9,'~/D~     - сканировать каталоги;'
        db 10,9,'~/P~   - выводить имена упаковщиков и защит;'
        db 10,9,'~/S~     - включить звуковые эффекты;'
        db 10,9,'~/O~[+] - выдавать сообщение Ok после проверки;'
        db 10,9,'~~   └─  - выдавать время тестирования для файлов;'
        db 10,9,'~/B~     - режим для монохромного монитора;'
        db 10,9,'~/C~   - выводить комментарии к названиям файлов;'
        db 10,9,'~~         (дополнительные комментарии берутся из файла ~MSCAN.MES~);'
        db 10,9,'~/W~[+][:fname] - создать файл с протоколом работы;'
        db 10,9,'~~   └───────── - (добавлять к существующему файлу);'
        db 10,9,'~/F~     - load the Russian alphabet generator'
        db 10,9,'~~         (внешние шрифты считываются из файла ~MSCAN.FNT~);'
        db 10,9,'~/@~:fname.lst  - проверять файлы из списка;'
        db 10,9,'~/=~[:][fname]  - создать файл со списком подозрительных'
        db 10,9,'~~                и больных файлов ~MSCAN.LST~;'
        db 10,9,'~/A~     - дизассемблирование тестируемого файла'
        db 10,9,'~~         (для динамического включения/выключения используйте ~ALT+A~);'
        db 10,9,'~/S+~[:][fname] - сохранить CMOS, MBR и BOOT в файле ~MSCAN.CMB~;'
        db 10,9,'~/S-~[:][fname] - восстановить CMOS, MBR и BOOT из файла ┘;'
        db 10,9,'~~         └─── - имя файла;'
        db 10,9,'~/V~[+]  - защищать COM и EXE файлы вакциной;'
        db 10,9,'~~   └─  - неудаляемая вакцина;'
        db 10,9,'~/V-~  - снимать вакцину с COM и EXE файлов;'
        db 10,9,'~/ST~    - выводить статистику после проверки каждого диска;'
        db 10,9,'~/LE~  - display messages in alternate language (English);'
        db 10,9,'~/LA~[:fname] - загрузить сообщения из файла ~MSCAN.LNG~;'
        db 10,9,'~-STD~   - вывод на экран через DOS функции;'
        db 10,9,'~/SM~  - специальный режим (переворот экрана для EGA/VGA);'
        db 10,9,'~/MB~    - перекомпилировать внешние сигнатуры в .MSB файлы;'
        db 10,9,'~/NV~[+][:offset] - добавлять сигнатуры новых вирусов в файл ~NEWVIR.SIG~;'
        db 10,9,'~~    └─ - составлять описание новых вирусов;'
        db 10,9,'~/FM~    - сохранять участки памяти в файле ~MEMORY.DAT~;'
        db 10,9,'~/MS~[:offset]  - добавлять сигнатуры участков памяти в ~MEMORY.SIG~;'
        db 10,9,'~/BS~[:offset]  - добавлять сигнатуры загрузочных секторов в ~BOOT.SIG~;'
        db 10,9,'~/FS~[+][:offset] - добавлять сигнатуры стандартных файлов в ~FILE.SIG~;'
        db 10,9,'~~    │     └──── - (16-ое число) дополнительное смещение для сигнатуры;'
        db 10,9,'~~    └──────── - составлять описание действий файлов;'
        db 10,9,'~/WT:~%time - установить задержку в секундах при запросах;'
        db 10,9,'~/Z~       - тестирование без возможности остановки;'
        db 10,9,'~/?,H~   - выдать эту справку.'
        db 10,0

        db 1,3,9,' C:\AVIR>mscan path1 [path2] [path3] [/key1/key2 /key3]'
        db 10
        db 10,  ' Key list:'
        db 10,9,'~/-,CU,Y~ - repair infected objects;'
        db 10,9,'~/T~    - no cure, test only;'
        db 10,9,'~/C-~     - disable code analizer;'
        db 10,9,1,12,'/C+   - enable autorepair infected;',1,3
        db 10,9,'~/*~     - check all files;'
        db 10,9,'~/E~   - erase bad files;'
        db 10,9,'~/RN~    - rename infected files;'
        db 10,9,'~/R-~  - don''t check for stealth viruses;'
        db 10,9,'~/CR~    - show crypted information;'
        db 10,9,'~/M-~  - disamle scan memory;'
        db 10,9,'~/D~     - enable scan of directories;'
        db 10,9,'~/P~   - show names of packed utilites;'
        db 10,9,'~/S~     - enable sound;'
        db 10,9,'~/O~[+] - show Ok message;'
        db 10,9,'~~   └─  - show time for scan of object;'
        db 10,9,'~/B~   - display B/W colors;'
        db 10,9,'~/C~     - show comments for files (russian only);'
        db 10,9,'~~         (add-on comments will load from ~MSCAN.MES~);'
        db 10,9,'~/W~[+][:fname] - create report file;'
        db 10,9,'~~   └───────── - (add message to report file);'
        db 10,9,'~/F~     - load the Russian alphabet generator'
        db 10,9,'~~         (add-on file is ~MSCAN.FNT~);'
        db 10,9,'~/@~:fname.lst  - add-on list file for check;'
        db 10,9,'~/=~[:][fname]  - create report file with name infected '
        db 10,9,'~~                (default name is ~MSCAN.LST~);;'
        db 10,9,'~/A~     - disassembling testing file'
        db 10,9,'~~         (for interactive enable use ~ALT+A~);'
        db 10,9,'~/S+~[:][fname] - save CMOS, MBR and BOOT into ~MSCAN.CMB~;'
        db 10,9,'~/S-~[:][fname] - restore CMOS, MBR and BOOT from ─┘;'
        db 10,9,'~~         └─── - file name;'
        db 10,9,'~/V~[+]  - protect COM and EXE files with vaccine;'
        db 10,9,'~~   └─  - enable unremoved vaccine setup;'
        db 10,9,'~/V-~    - delete of vaccine from COM and EXE files;'
        db 10,9,'~/ST~  - show statistic information after scan of disk;'
        db 10,9,'~/LE~    - display messages in alternate language (English);'
        db 10,9,'~/LA~[:fname] - load add-on file with messages ~MSCAN.LNG~;'
        db 10,9,'~-STD~   - output with DOS functions;'
        db 10,9,'~/SM~  - special mode (joke from me);'
        db 10,9,'~/MB~    - translete .SIG files into .MSB files;'
        db 10,9,'~/NV~[+] - append sigantures of new viruses into ~NEWVIR.SIG~;'
        db 10,9,'~~    └─ - create new virus report;'
        db 10,9,'~/FM~    - save cell of memory into ~MEMORY.DAT~;'
        db 10,9,'~/FS~[+][:offset] - append signatures for files into ~FILE.SIG~;'
        db 10,9,'~~    │     └──── - (Hex number) additional offset for signatures;'
        db 10,9,'~~    └──────── - create files actions report;'
        db 10,9,'~/MS~[:offset]  - append signatures for memory into ~MEMORY.SIG~;'
        db 10,9,'~/BS~[:offset]  - append signatures for boot sectors into ~BOOT.SIG~;'
        db 10,9,'~/WT:~%time - time in seconds for wite to respond;'
        db 10,9,'~/Z~       - non stop continue mode;'
        db 10,9,'~/?,H~   - show this help screen.'
        db 10,0
        dw 0EE01h,mesHelp
tableMes        label byte
        dw mes2
        dw mesReport
        dw mesComSt
        dw mesError
        dw mesErr00
        dw mesErr01
        dw mesErr02
        dw mesErr03
        dw mesErr04
        dw mesErr05
        dw mesErr06
        dw mesErr07
        dw mesErr08
        dw mesErr09
        dw mesTrace
        dw mesProg
        dw infMem
        dw wasCur
        dw mesVirMem
        dw mesStrCom
        dw mesWho
        dw mesYN
        dw mesOk
        dw memCurOk
        dw mesKillMem
        dw mesBlockOk
        dw mesCreat
        dw mesFileSig,mesFileSigVir,mesMemCell,mesMemCellStd
        dw mesMemVir,mesMemVirNew,mesAmountCureM,mesAmountLock
        dw mesBadVer
        dw mesWasLoad
        dw mesNoMemMSB
        dw mesNoGr100MSB
        dw mesErrMsb
        dw mesLoadMs
        dw mesNoCure
        dw mesSaveCMB
        dw mesStoreBoot,mesRestorBoot,mesBnotFound,mesBchSumErr,mesCmosErr
        dw mesMBError
        dw itCom
        dw itExe
        dw itSys
        dw itDir
        dw diskete
        dw mesTimeTest
        dw mesDisk
        dw mesLab
        dw mesNotF
        dw mesSt
        dw mesBody
        dw mesBody1
        dw mesBody2
        dw mesBody3
        dw mesStatist,mesFiles&Sec,mesProgTest,mesVir&Mod,mesModTest
        dw mesInf&BadF,mesBadTest,mesNewVir,mesRenTest,mesCure&Del,mesDelTest
        dw mesStranDate,mesDateCur,mesFilesCrypt,mesTimeScan,mesTimeFile
        dw mesSpeedFile,mesSpeedDir,mesDirMin
        dw memoryLo
        dw mesMbr
        dw mesBootV
        dw mesBoot
        dw mesStInBoot,mesStBcured
        dw stdMbr
        dw mesNoStdBoot
        dw mesSaveFBoot
        dw mesWasSavedB
        dw infMbr
        dw curOk
        dw mesPboot
        dw mesCr
        dw mesBadD
        dw mesBadT
        dw mesSetD
        dw mesOkD
        dw mesOkT
        dw mesFull
        dw mesSecNotFound
        dw mesWriteProtect
        dw mesTotalError
        dw ioErr
        dw diskNotReady
        dw mesDataErr
        dw mesWrite
        dw mesRead
        dw mesWriteOver
        dw mesClBad
        dw mesPack
        dw mesCoPr
        dw mesStand
        dw mesWar
        dw mesEkz
        dw mesModInf
        dw mesDelete
        dw mesDelOk
        dw mesPosInf
        dw mesV01,mesV02,mesV03,mesV04,mesV05,mesV06,mesV07
        dw mesV08,mesV09,mesV10,mesV11,mesV12,mesV13,mesV14,mesV15,mesV16
        dw mesV17,mesV18,mesV19,mesV20,mesV21,mesV22,mesV23,mesV24,mesV25
        dw mesV26,mesV27,mesV28,mesV29,mesV30,mesV31,mesFinal,mesMemory
        dw mesCom,mesAnd,mesExe,mesFiles
        dw mesRename
        dw mesRenOk
        dw mesWasInclud
        dw delIt
        dw mesDelV
        dw mesAnti
        dw mesVacOk
        dw mesOver
        dw mesWhoO
        dw mesOverOk
        dw infect
        dw mesHelp
        dw mesStop
        dw mesStop1
        dw mesPaus
        dw mesAnyKey
        dw -1
mes2    db 10
        db 1,10,    '   Обнаружение и лечение новых вирусов !!!'
        db 10,1,30h
        db 10,      '╒═~√~══════════════════════════════════[■]╕'
        db 10,1,30h,'│               АНТИВИРУС  ~┼ анализатор~ │',1,1,'█'
        db 10,1,30h,'│           M U L T I S C A N   ~кода~    │',1,1,'█'
        db 10,1,30h,'│~~  Версия 2.X  зима 1999 года           │',1,1,'█'
        db 10,1,30h,'│Автор: ~ВАЛЕНТИН КОЛЕСНИКОВ.~ (C) 1995-98│',1,1,'█'
;        db 10,1,30h,'│  Украина, Киев тел: ~380 44 441-26-35~  │',1,1,'█'
        db 10,1,30h,'│~~     http://virus.komi.ru/mscan        │',1,1,'█'
;        db 10,1,30h,'│~~      Internet ICQ UIN : 5667578       │',1,1,'█'
;        db 10,1,30h,'│          ~mailto:valik@avp.ru~          │',1,1,'█'
        db 10,1,30h,'└~~───────────────────────────────────────┘',1,1,'█'
        db 10,    ' ~~▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',1,3
        db 10,0
mes2l   db 10
        db 1,10,  '      Detect and clean new viruses !!!'
        db 10,1,30h
        db 10,1,30h,'╒═~√~══════════════════════════════════[■]╕'
        db 10,1,30h,'│               ANTIVIRUS       ~┼ code~  │',1,1,'█'
        db 10,1,30h,'│           M U L T I S C A N  ~analizer~ │',1,1,'█'
        db 10,1,30h,'│~~      Version 2.X Winter 1999          │',1,1,'█'
        db 10,1,30h,'│Written by ~VALENTIN KOLESNIKOV~ (C) 1998│',1,1,'█'
;        db 10,1,30h,'│  Ukraine, Kyiv tel: ~380 44 441-26-35~  │',1,1,'█'
        db 10,1,30h,'│~~     http://virus.komi.ru/mscan        │',1,1,'█'
;        db 10,1,30h,'│~~      Internet ICQ UIN : 5667578       │',1,1,'█'
;        db 10,1,30h,'│          ~mailto:valik@avp.ru~          │',1,1,'█'
        db 10,1,30h,'└~~───────────────────────────────────────┘',1,1,'█'
        db 10,    ' ~~▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',1,3
        db 10,0
        dw 0EE01h,mes2l
curVer          db 'VER26'
varLeft         dw 26*2
countStr        db 61
maskF           db '*.*',13 dup (0)
repName         db 'report.ms',0,30 dup (?)
lngName         db 'mscan.lng',0,30 dup (?)
mlName          db 'mscan.lst',0,30 dup (?)
ssName          db 'MSCAN.CMB',0,30 dup (?)
rsName          db 'MSCAN.CMB',0,30 dup (?)
amName          db 'vc.lst',0,30 dup (?)

memCount        dw ?
memInfected     dw ?

varPage         db ?
varFiles        db ?
varMesOk        db ?
varKeySt        db ?
varAll          db ?
varMem          db ?
varEng          db ?
varVakcine      db ?
varRap          db ?
varMes          db ?
varBreak        db ?
varEvr          db ?
varKeyOk        db ?
varKeyHel       db ?
var0D           db ?
varFM           db ?
varSM           db ?
varNP           db ?
varSound        db ?
varAm           db ?
varDl           db ?
varMB           db ?
varAS           db ?
varST           db ?
varFN           db ?
varAA           db ?
varView         db ?
varViewOn       db ?
varAuto         db ?
varWidth        dw ?
varML           db ?
varSaveB        db ?
varNV           db ?
varFS           db ?
varMS           db ?
varWin          db ?
varBat          db ?
varSS           db ?
varRS           db ?
varRN           db ?
varND           db ?
varStd          db ?
varCT           db ?
varWT           db ?
varBS           db ?
varNonStop      db ?
varPages        db ?

offFS           dw ?
offMS           dw ?
offBS           dw ?
msbPosLo        dw ?
msbPosHi        dw ?
offSigForS      dw ?
virFoundF       db ?
countNam        db ?
listChar        dw ?
baseIP          dw ?
countE          db ?
flagWrite       db ?
oldOff          dw ?

color           db ?    ; 3
color2          db ?

erase           db ?
pVer            db ?

off23           dw ?
seg23           dw ?
off24           dw ?
seg24           dw ?

curSize         dw ?
device          db ?
pointComStr     dw ?

countSerr       db ?
countCr         dw ?
count0A         db ?
adrSub          dw ?

offInFile1      dw ?
offOfCell       dw ?
segOfCell       dw ?
saveOffSeg      equ $

myOff21         dw ?
mySeg21         dw ?
myOff13         dw ?
mySeg13         dw ?
myOff1          dw ?
mySeg1          dw ?

handleMem       dw ?

filesCount      dw ?
progCount       dw ?
virmodCount     dw ?
modCount        dw ?
infbadCount     dw ?
badCount        dw ?
infNewCount     dw ?
renCount        dw ?
curDelCount     dw ?
delCount        dw ?
dateCount       dw ?
curDatCount     dw ?
cryptCount      dw ?
dirCount        dw ?
fileTime        dw ?
dirTime         dw ?
fileSigCount    dw ?
virsigCount     dw ?
memCellCount    dw ?
memstdCount     dw ?
memvirCount     dw ?
memnewCount     dw ?
memcureCount    dw ?
memlockCount    dw ?
curSecond       dw ?
curChas         dw ?
curSecond1      dw ?
curChas1        dw ?

segVirInf       dw ?
videoSeg        dw ?
curPos          dw ?
handleW         dw ?

bufScr          dw ?
asmSeg          dw ?
falseSeg        dw ?
dtaSeg          dw ?
baseSeg         dw ?
virusSeg        dw ?
envSeg          dw ?

segLng          dw ?
segRec          dw ?
lenRec          dw ?
segProg         dw ?
segLst          dw ?

pointLst        dw ?
startMes        dw ?
pointMes        dw ?
segMes          dw ?

fptr            dw ?
tableP          dw 80 dup (?)

typeNum         db 2 dup (?)    ;***
storeSeg        dw ?

nameVir         db 22 dup (?)
sigOff          dw ?            ; для файла
bufSig          db 19 dup (?)   ; длина сигнатуры и сигнатура
tabOff          db 1+6+1+8 dup (?)    ; IP ; CS ; SS ; SP ; для EXE файла
sizeVir         dw ?            ; длина вируса
memOff          dw ?                    ; смещение в памяти
cureMemory      db 1+8 dup (?)          ; код для команды JMP
bootOff         dw ?                    ; смещение в boot
storeCX         db 1+4 dup (?)          ; off CX

cxBoot          dw ?            ; boot cx
dhBoot          db ?
verDos          db ?

localWord       dw ?
mySign          db ?
saveSi          dw ?
saveCX          dw ?
saveAl          db ?

cursor          db ?
leftBound       dw ?
rightBound      dw ?

tabMsb          dw 51 dup (?)
varStop         dw ?
varMemF         db ?

fDate           db 12 dup (?)

countBlock      db ?
countInBl       dw ?
localHex        db 4 dup (?)

pointT          dw ?
listPoint       dw 30 dup (?)
tabSkip         dw 22 dup (?)
tabSkipO        dw 42 dup (?)
countTab        dw ?
offOpt          dw 100 dup (?)
tabBlock        dw 180 dup (?)
off3            equ $-2

path            db 250 dup (?)
pathMs          db 80 dup (?)
pathIni         db 64 dup (?)
pathDir         db 250 dup (?)
eventTab        db 256 dup (?)
tableRoot       dw 32*3 dup (?)
typeFile        db ?

poshi           dw ?
poslo           dw ?
poshiAll        dw ?
posloAll        dw ?

lenVirus        dw ?
reloIP          dw ?
bytesRead       dw ?
diskType        dw ?

handleRep       dw ?
bufferOut       db 140 dup (?)
buf1            dw 6 dup (?)

myTitle         dw 40 dup (?)

myDta           db 15h dup (?)
attrib          db ?
time            dw ?
date            dw ?
longFlo         dw ?
longFhi         dw ?
lenClear        equ $-memCount
fname           db 20 dup (?)

buf             db 512 dup (?)
                db 200 dup (?)
myStack         equ $

sizeInByte      equ $
end
