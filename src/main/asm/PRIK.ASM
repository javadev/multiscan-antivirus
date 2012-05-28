
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; ����� �뢮��� ⥪�⮢� �������ਨ � 䠩���. �뫠 ��ࠫ��� �訡�� 
; ��-�� ���ன �������ਨ �� �뢮������.

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
        push ax         ; ax �� ������⢮ ����ୠ⨢
        mov ah,0
        int 1Ah
        xchg ax,dx      ; ⥯��� � ax ���祭�� ⠩���
        pop bx
        xor dx,dx
        div bx          ; � dx ��砩��� �᫮ 0 � ax-1
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
mes8001         db '�ࠩ��� ��c��. (���� Alberto PASQUALE.)'   ,0
mes8002         db '��ᥬ��⪠ ��� ���쬨�⭨� ?'             ,0
mes8003         db '���㦭� ��� ��祣� ����� � ᮡ��'         ,0
mes8004         db '��� ����� �ਬ�୮ 8.805'                  ,0
mes8005         db '��� 䠩� ������� �������� ��᪮�����'    ,0
mesAdonis       db '��� ���஢����. (�㦭�� ����)'            ,0
mesAdm          db '�⨫�� ��� ࠧ����� � �ଠ�஢���� ����-�',0
mesAfd          db '�������࠭�� �⫠�稪'                    ,0
mesAids1        db '��⨢���� AIDSTEST. (���� �����᪨� �.�.)',0
mesAids2        db '�祭� ��訩 ��⨢����'                   ,0
mesAin          db '��娢��� AIN'                             ,0
mesAidstest     db 'AIDS-��� �����᪮��'                      ,0
mesArj          db '��娢��� ARJ'                             ,0
mesAutoexec     db '��,��㤠 � �㤠 ����㦠�� �� ���� ��� ���� !! (��������)',0
mesAvp          db '��ᯮ��� ������ ��ᯥ�᪨� - ��, ����� ����� ������� ����� !',0
mesAvptsr       db '��⨢����� ������'                      ,0
mesAvp321       db '��⨢���� ��ᯥ�᪮�� ��� ��� Windows 95/NT',0
mesAvp322       db '���� �㦥� 䠩� AVP.KEY - �த�� ����ண�' ,0
mesBc1          db '�������࠭�� ��������� �몠 C++'        ,0
mesBc2          db '�� �++. (���室�� �� ����� 5.0)'      ,0
mesChk          db '��� �������⨪� ��᪠. ���� NDD ��� ADINF' ,0
mesCiv          db '�� ��� � � Civilization, �� � ��'        ,0
mesComp         db '��� �ࠢ����� 䠩���'                      ,0
mesConfig       db '��� ��� ���������� ��� , ��� ������ ���������� !!!',0
mesCpp          db '����� ��������� �몠 �++'             ,0
mesCw           db '⥪�⮢� ।����. (⥪�� � ���)'     ,0
mesDescent1     db '�� ��ࠩ� � DESCENT'                     ,0
mesDescent2     db '�� ��-� ᢥ�����⢥����'              ,0
mesDelphi1      db '᪮�쪮 ��த� ����蠫��� �� �⮬'         ,0
mesDelphi2      db 'PASCAL 9.0'                                ,0
mesDisk         db '��� ����஢���� ��᪥�. (���)'             ,0
mesDiet         db '���� �� ����� �������஢ COM,EXE,*.*'   ,0
mesDiskrest     db '��� �ଠ� ��᪥� ⨯� TRACK 0 -BAD, �᫨ ��� �� ��� �����!',0
mesDn1          db '楫�� �।� ��� ࠡ��� � 䠩����'          ,0
mesDn2          db '���� �����. (���室�� �� ����� 2.0)'  ,0
mesDn3          db 'ॡ��, ��ࠢ�� UPLOAD � �ନ����'      ,0
mesDoom         db '��Doom''��� �����. (IDD ⢮� QD)'         ,0
mesDrweb        db '������ ����䠣� ������ WEB'               ,0
mesElite        db '����� ��娫� �������'                     ,0
mesExcel        db '�����஭�� ⠡���� - ��室�� ��� ���������� !!',0
mesF117         db '�஧� ��� SU25'                            ,0
mesFF2          db '����骠, ��५﫪�'                        ,0
mesFdisk        db '�⨫�� ��� ࠧ����� ����-� �� �����-� ��᪨. (���)',0
mesFdoor        db 'Best''��� ������'                         ,0
mesFind         db '��� ���᪠ 䠩���'                         ,0
mesFormat       db '�⨫�� ��� �ଠ�஢���� ������ ��᪮� � ����-�. (���)',0
mesHa           db '⮦� ��娢���. (���室�� �� ����� 1.0)',0
mesHb           db '�ᥬ �� ����� ⠪�� �ணࠬ��'            ,0
mesHeretic      db '����� ⠬ ��몠 ... � ����� ��祬 ��� ��� ?',0
mesHoney        db '� ��� � �⠫������� - ���������'           ,0
mesIndy1        db '��娫� ��������� ���, ��୨ !'            ,0
mesIndy2        db '� ��, ���堫 �� 䨭�� ?'                  ,0
mesKb           db '����誠. (���������� ���)'                ,0
mesKey1         db '�ࠩ��� ���������� � ��࠭�. (����ᠭ � ����檥.)',0
mesKey2         db '�� ��� ��᫮த ��� ������� �� ���'       ,0
mesLabel        db '��� ᮧ����� ��⮪ �� ��᪠�'              ,0
mesLex          db '।���� ⥪�⮢. (���� ��ᥫ��)'         ,0
mesLecar1       db '���� �� ����� ����᪨� ��⨢���ᮢ'       ,0
mesLecar2       db '���� ���㬥���� - 75% �ᯥ�'         ,0
mesLem3D1       db '� �� ��襫 61-� �஢��� ?'                ,0
mesLem3D2       db '����� � 61-�� �஢��, �� �祭� �����'     ,0
mesLha          db '��娢���. (����ᠭ � ������)'             ,0
mesLhx          db '����� �� ������ ���⮫��'                 ,0
mesLight        db 'ᢥ� �� �쬥'                              ,0
mesMemmaker     db '�������� ����� - ��� ࠡ��� � ���孥� ����� !',0
mesMoon         db '��� ����� ��᪮� ����-� �� �����'       ,0
mesMouse1       db '�ࠩ��� ���'                              ,0
mesMouse2       db '���� gmouse.sys'                          ,0
mesMore         db '�����, �����, ����� ..'                 ,0
mesMscan1       db '��宦 �� ����'                             ,0
mesMscan2       db '�� �� �㯥� ��⨢����'                    ,0
mesMscan3       db '��������� �ॢ��室�� १����'          ,0
mesMscan4       db '�����뢠�� ������ਨ ����� !'           ,0
mesMscdex       db '��� ������祭�� CD-ROM'                    ,0
mesNc           db '�⨫�� ��� ࠡ��� � 䠩����. (Symantic Inc.)',0
mesNdd          db '��� ��ࠢ����� �訡�� �� ��᪥. (����᪠�� ���஦��)',0
mesNetscape     db '����㦨�� ����譥� �����樨'               ,0
mesP51          db '����� �� ᠬ���� �६� II ��஢�� �����' ,0
mesPU_1700      db '������ �⨫���, ������ ��᪮���� - ��� ������� !!!',0
mesPcdl         db '���嫥�쪨� ।���� ��᪠'                ,0
mesPc           db 'PC-TOOLS - ��� ।���஢���� HDD ��� ��᪥� , ������',0
mesPkl          db 'ᦨ����騪 䠩���, �� �� ���'             ,0
mesPop          db 'POPCORN - �����譠� ����㧠'              ,0
mesPole         db '����骠 - FILE OF MAGIC (���� �㤥�)'      ,0
mesPu           db '��� ����� ��᪮� ����-� �� �����/�⥭��',0
mesPu_wrcfd     db '��� �஢�ન ����⢠ ����� �� �.���� ��� �������',0
mesPu_1700f     db '��������� �ଠ��� ��᪥�,� ⠪�� ��᪥� ⨯� TRACK -0 bad',0
mesQb           db '�������࠭�� ��������� �몠 ���ᨪ. (Microsoft Corp.)',0
mesQemm         db '�� "����" 祬 memmaker , ⮦� ��ᯥ��� �����!',0
mesRar1         db '��娢��� RAR. (���室�� �� ����� 2.03)',0
mesRar2         db '���訩 �� ��娢��஢ - RAR !'             ,0
mesRamdrive     db '�㦥� RAM(����㠫��) ��� - �������� !'  ,0
mesReet         db '����� ��� �� ᠬ��� ᥡ�'               ,0
mesRetal        db '���� ������� ⥡�, super boy'            ,0
mesScandisk     db '���, 祬 NDD - � �㭪樨 � ��'          ,0
mesSd           db '�⨫�� ��� ��⨬���樨 ��᪮�. (Symantic Inc.)',0
mesSmart1       db '�⨫�� ��� ���஢���� ��᪠. (Microsoft Corp.)',0
mesSmart2       db '�� ⠪ �������� � ࠡ�� !!!'              ,0
mesSobor        db '�ࠪ� � ���᪮� �⨫�'                     ,0
mesSol          db '�� ��ࠩ� � ᮫�����'                   ,0
mesSpear1       db '�������,��५﫪�,���﫪�'                 ,0
mesSpear2       db '����᪠�� � ���箬 debugmode'             ,0
mesStunts       db 'Das is fantastish. ���쪮 ��� ������'      ,0
mesSu25         db '�஧� ��� F117'                            ,0
mesSys1         db '��稫�� ��� COMMAND.COM'                   ,0
mesSys2         db '��⠢�� � autoexec.bat ��⥬��� ��᪥��' ,0
mesTasm1        db '��������� � �몠 ��ᥬ����.(Borland Inc.)',0
mesTasm2        db '����������� ���������'                   ,0
mesTasm3        db '���� �����'                              ,0
mesTc           db '�������࠭�� �������� �몠 C'           ,0
mesTcc          db '����� ��������� �몠 Turbo C'         ,0
mesTlink        db '������騪 .obj 䠩��� (Borland Inc.)'      ,0
mesTlib         db 'ᮡ�ࠥ� OBJ 䠩�� � ������⥪� (.lib)'    ,0
mesTmail        db 'Rulez''�� ������'                         ,0
mesTpc          db '����� ��������� �몠 Turbo Pascal'    ,0
mesTurbo1       db '�������࠭�� ��������� �몠 Pascal'     ,0
mesTurbo2       db '�������� ���� ��㤥�⮢'                   ,0
mesUni          db '�ਬ�⨢�� �ࠩ��� ��࠭�'                ,0
mesVc1          db '�㯥� �ணࠬ��. ���室�� �� ����� 5.0' ,0
mesVc2          db '�⨫�� ��� ࠡ��� � 䠩����. (���� ������ �.�.)',0
mesVc3          db '�ਢ�� ���� �� Bita Music'                 ,0
mesVformat      db '��� �ଠ� � ���樭�஢���� BOOT� ��᪥� -  �.�.����',0
mesVirus        db '�������� �� - �����'                      ,0
mesVkey         db '�ਬ�⨢�� �ࠩ��� ����������'            ,0
mesWar          db '��䮭�� 室�, ��䮭�� 室� !'            ,0
mesWd           db '।���� ⥪�⮢. (४������� ����� 8.0)' ,0
mesWeb1         db '��⨢���� WEB. (���⨭�, ���� �. �������)',0
mesWeb2         db '��ᯮ��, � ��� �� ��� ������ ��⨢���ᠬ� ?',0
mesWin1         db '������� ��������� �� ���窥'            ,0
mesWin2         db 'WINDOWS ��ᯮ��'                           ,0
mesWin3         db '���室�� �� WINDOWS 98'                  ,0
mesWin4         db '�� ���� � ���� � �६����'               ,0
mesWin          db '����⭮ WINDOWS, 3.x ��� 95  ���� - ��� ������ !!',0
mesWinword      db 'WORD for WINDOWS'                          ,0
mesWolf1        db '����� ���᭮ ����५���'                   ,0
mesWolf2        db '����᪠�� � ���箬 -goobers'              ,0
mesYeag         db 'ࠡ�� ����� ����뢠��'                   ,0
mesZip          db '��娢��� PKZIP'                           ,0
end