
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Главный модуль программы. Также есть подпрограмма для резидентного вызова
;

public  checkVirus,startMain,scanFile
extrn   getParam:near,printHelp:near,checkBody:near,traceMem:near
extrn   findIni:near,printDisk:near,findRun:near ;statisticMem:near,
extrn   delString:near,statisticFile:near,changePath:near,bye:near
extrn   checkExt:near,moveName:near,openFile:near,checkSt:near,printPathFI:near
extrn   closeFile:near,iniPos:near,checkHomeRun:near,openRep:near
extrn   printOK1:near,checkMCB:near,myStack:near,outLab:near
extrn   oneCure:near,boot:near,checkMbr:near,prikol:near;,outPic:near
extrn   checkBreak:near,decPoly:near,antiDir:near,checkVak:near
extrn   checkSig:near,readLng:near,readLst:near,printPathF:near
extrn   pointComStr:word,getName:near,pathIni:byte,varAll:byte,varAA:byte
extrn   checkTD:near,readMes:near,stayRez:near,ha:near,outCr:near
extrn   storeScr:near,outScr:near,startTime:near,saveTimeD:near,getDisk:near
extrn   saveTimeF:near,outFullStat:near,varST:byte,readMsb:near,viewCode:near
extrn   clearMask:near,writeRCE:near,unp:near,outMemStat:near,var0D:byte
extrn   iniML:near,writeToMl:near,makeCMB:near,varMem:byte,createTable:near
        .model small
        .code
        .startup
startMain:
        push ds
        pop  ss
        lea sp,myStack
        call getParam
        jc  exitProgramQ
        call readLng
        call openRep
        call readMes
        call startInMem
        jc  exitProgramQ
        call printHelp
        jnc  noExitProgram
exitProgramQ:
        jmp exitProgram
noExitProgram:
        call checkSig
        call readMsb
        call createTable
        cmp varMem,0
        jne noCheckM
        call traceMem
        call checkMCB
        call outMemStat
noCheckM:
        call checkBody
        jc  exitProgramQ
        call checkMbr
        call makeCMB
        mov pointComStr,81h
findAgain:
        call checkBreak
        jc exitProgram02
        mov varAll,0
        call getName
        jnc findBegin
        call readLst
        jc  exitProgram0
findBegin:
        call findIni
        jc findAgain
        call getDisk
        call printDisk
        call startTime
        call outLab
        call boot
        call antiDir
        pushf
        call saveTimeD
        call startTime
        popf
        jc  exitTest
        call iniML
findMore:
        call checkBreak
        jc  exitTest
        call findRun
        jc exitTest
        call scanFile
exitProgram02:
        jc exitProgram0
        jmp findMore
exitTest:
        call saveTimeF
        call delString
        cmp varST,0
        je noOutSt
        call outFullStat        ;st
noOutSt:
        call changePath
        jc  findBegin
        jmp findAgain
exitProgram0:
        cmp varST,0
        jne exitProgram
        call outFullStat        ;st
exitProgram:
        call bye
        mov ah,4Ch
        int 21h
scanFile proc
        call checkExt
        jc  findMore1
        call moveName
        call printPathFI
        call openFile
        jc  findMore1
        xchg bx,ax
        call checkSt
        jnc  checkIt
        call closeFile
        stc
        ret
checkIt:
        call checkVirus
        jc  closeF
        call checkVak
        jc  checkIt
        call checkTD
        call prikol
        call writeToMl
closeF:
        call closeFile
noClose:
        call printOK1
findMore1:
        clc
        ret
        endp
checkVirus proc
        push es
        call storeScr
        jmp short noPrintP
more:
        call printPathF
noPrintP:
        call iniPos
        jc  close
        call unp
        call oneCure
        jc  more
        call clearMask
        call ha
        jc  more
        call viewCode
        call writeRCE
        jc noPrintP
        call outCr
        call outScr
close:
        pop es
        ret
        endp
startInMem proc
        cmp varAA,0
        je oldCheck
        mov var0D,1
        call checkSig
        call readMsb
        call traceMem
        call checkMCB
        call checkBody
        jc oldCheck
        call checkMbr
        mov pointComStr,81h
        call getName
        jc oldCheck
        call findIni
        jc oldCheck
        call getDisk
        call boot
        call startTime
        call findRun
        jc oldCheck
        call scanFile
        call delString
        stc
oldCheck:
        ret
        endp
        .data
        .stack
        end
