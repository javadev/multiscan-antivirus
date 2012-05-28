
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Таблица вирусов.
;
_COM    equ 1
_EXE    equ 2
_SYS    equ 4
_BAT    equ 8
_WIN    equ 10h
_FILE   equ 'f'

_INT21  equ 1
_INT13  equ 2
_INT16  equ 4
_INT2A  equ 8
_MEM    equ 'r'

_MBR    equ 1
_BOOT   equ 2
_SEC    equ 'b'

public  tableOfViruses
public  mesDir20,mesDir_d,mesDirF,procDec,oneAdr,listCall,listVar
extrn   diskType:byte,reloIP:word,decodVint:near,myTitle:word
extrn   setPos:near,readF:near,writeF:near,typeFile:byte,tabBlock:word
extrn   posLo:word,posHi:word,posHiAll:word,posLoAll:word
extrn   symExec:near,bPoint:word,optim:byte,complBlock:near
        .model small
        .code
listCall:
        call readF              ; 0
        retf
        call writeF             ; 6
        retf
        call setPos             ; C
        retf
        call symExec            ; 12
        retf
        call complBlock         ; 18
        retf
procNazi2:
        push ax cx dx ds
        mov si,reloIP
        push es
        pop ds
        mov al,[si+3Fh]
        push ax
        mov dx,-5555
        call movePos
        xor dx,dx
        mov cx,5555
        call readF
        jc badRead
        pop ax
        push ax
        mov si,dx
        push cx si
decN2:
        xor [si],al
        inc si
        loop decN2
        jmp short wrNazi
procNazi:
        push ax cx dx ds
        mov si,reloIP
        push es
        pop ds
        mov al,[si+42h]
        push ax
        mov dx,-8600
        call movePos
        xor dx,dx
        mov cx,8600
        call readF
        jc badRead
        pop ax
        push ax
        mov si,dx
        push cx si
decNazi:
        sub [si],al
        inc si
        loop decNazi
wrNazi:
        pop si cx
        push cx
        lea di,myTitle
        mov cx,15
        push es
        push ss
        pop es
        rep movsw
        pop es
        push dx
        xor al,al
        call setPos
        pop dx
        pop cx
        call writeF
        jc badRead
        push ss
        pop ds
        mov ax,myTitle
        cmp ax,'ZM'
        je  badRead
        cmp ax,'MZ'
        je  badRead
        mov typeFile,0
        clc
badRead:
        pop ax
        pop ds dx cx ax
        mov ax,-1
        xor cx,cx
        ret
movePos:
        push dx
        mov al,2
        call setPos
        mov cx,-1
        pop dx
        mov ax,4201h
        int 21h
        ret
procCC:
        mov si,reloIP
        mov ax,myTitle+16h
        sub ax,es:[si+84h]
        mov es:[si+84h],ax
        mov ax,333h
        mov cx,6
        ret
procSen:
        mov si,reloIP
        push ds
        push es
        pop ds
        lea si,[si+1C97h-17E4h]
        xor dx,dx
        mov cx,37h
        push cx si
getKey:
        lodsw
        xor dx,ax
        loop getKey
        pop si cx
        mov di,si
decodSen:
        lodsw
        xor ax,dx
        stosw
        loop decodSen
        pop ds
        mov ax,1C97h-17E4h
        mov cx,5
        ret
getMc:
        mov cx,5
        ret
getUna:
        cmp dl,80h
        jnc bigF1
        mov dh,1
        mov ax,ss:[bx+16h]
        cmp al,2
        ja bigFu
        mov cl,3
        ret
bigFu:
        cmp al,6
        ja bigF1
        mov cl,5
        ret
bigF1:
        mov cl,0Eh
        ret
getAnti:
        mov cx,word ptr es:[bx+4]
        cmp cx,0Dh
        je  setHead
        mov dh,byte ptr es:[bx+6]
setHead:
        clc
        ret
getOne44:
        mov word ptr cs:offKey,1D1h
        mov procDec,offset decod44
        call readKey
        jc unErr0
        mov cx,word ptr es:[bx+1Ch]
        dec cx
        push di
        mov di,word ptr es:[bx+29h]
        call decodVint
        pop di
unErr0:
        ret
getOne:
        mov word ptr cs:offKey,1E1h
        mov procDec,offset decod70
        call readKey
        jc unErr
        mov cx,word ptr es:[bx+22h]
        dec cx
        push di
        mov di,word ptr es:[bx+2Fh]
        call decodVint
        pop di
unErr:
        ret
readKey:
        push ax bx cx dx
        mov dl,diskType
        mov ah,8
        int 13h
        jc reErr
        xchg ax,cx
        and ax,3Fh
        sub ax,7-4
        xchg ax,cx
        mov dl,diskType
        xor dh,dh
        xor bx,bx
        mov ax,201h
        int 13h
        jc reErr
offKey  equ $+2
        add bx,1234h
        mov ax,es:[bx]
        mov word ptr setKey,ax
        clc
reErr:
        pop dx cx bx ax
        ret
getCr:
        mov cx,es:[bx+104h]
        cmp cx,0Ch
        je  setHead1
        mov dh,es:[bx+106h]
setHead1:
        clc
        ret
getHappy2:
        mov cx,es:[bx+70h]
        inc cx
        mov dh,es:[bx+6Eh]
        jmp short decodHap
getHappy:
        mov cx,es:[bx+72h]
        inc cx
        mov dh,es:[bx+70h]
decodHap:
        mov dl,diskType
        mov ax,201h
        int 13h
        jc ghErr
        mov ax,5641h
        mov cx,1FFh
decodH:
        xor es:[bx],ax
        add ax,4C49h
        inc bx
        loop decodH
        clc
ghErr:
        mov cx,1
        ret
getMong:
        mov cx,es:[bx+4Dh]
        inc cx
        inc cx
        mov dh,es:[bx+50h]
        clc
        ret
getDirF:
        mov cx,es:[bx+98h]
        mov dh,es:[bx+9Ch]
        mov dl,diskType
        xor bx,bx
        mov ax,202h
        int 13h
        jc readDiErr
        push si di
        mov di,20h
        lea si,sigDirF
        lodsb
        xor ah,ah
        xchg cx,ax
        rep cmpsb
        stc
        jne readDiErr1
        push ds
        push es
        pop ds
        mov si,3C8h
        mov di,7C00h
        movsw
        mov di,7C80h
        mov cl,2Ah
        rep movsb
        pop ds
        clc
readDiErr1:
        pop di si
        mov cx,1
readDiErr:
        ret
writeTch:
        mov byte ptr es:[bx+3Eh],0EBh
        mov cx,1
        ret
decod70:
        push ax cx
        mov ax,setKey
        mov cx,1FFh
cyc70:
        xor es:[bx],ax
        ror ax,1
        inc bx
        loop cyc70
        inc bx
        pop cx ax
        ret
decod44:
        push ax cx
        mov ax,setKey
        mov cx,100h
cyc44:
        xor es:[bx],ax
        inc bx
        inc bx
        loop cyc44
        pop cx ax
        ret
procTch:
        push dx
        lea si,tabBlock+2
        cmp typeFile,1
        je truncF
        lea si,[si+4]
truncF:
        lodsw
        mov cx,posHi
        mov dx,posLo
        add dx,ax
        adc cx,0
        mov posHiAll,cx
        mov posLoAll,dx
        mov si,reloIP
        mov ah,es:[si+25Dh]
        lea di,[si+381h]
        xor es:[di],ah
        inc di
        mov al,es:[si+11h]
        xor al,ah
        stosb
        mov al,es:[si+250h]
        xor al,ah
        stosb
        mov ax,381h
        mov cx,3
        pop dx
        ret
getBootIn:
        push si
        push cs
        mov byte ptr es:[bx+151h],0CBh
        call bi1
        pop si
        clc
        ret
bi1:
        push es
        lea ax,[bx+10Ah]
        push ax
        retf
procBomb:
        push si ds
        xor al,al
        call setPos
        mov dx,100h
        mov cx,posLoAll
        mov [tabBlock+4],cx
        mov si,reloIP
        push es
        pop ds
        call readF
        jc badBread
        mov dx,si
        add si,61h
        mov cs:bPoint,100h
        mov cs:optim,0C3h
        mov cx,ds
        call symExec
        push es
        pop ds
        xor al,al
        call setPos
        mov dx,100h
        mov cx,ss:posLoAll
        call writeF
badBread:
        pop ds si
        mov cs:bPoint,-3
        mov ax,-1
        xor cx,cx
        ret
procHren:
        push bx
        mov si,reloIP
        lea dx,[si-983h]
        mov cx,40h
        call complBlock
        mov bx,dx
        lea si,[bx+0Fh]
        mov ax,es:[bx+2Bh]
        xor ax,9590h
        mov cx,12
decHren:
        xor es:[si],ax
        inc si
        inc si
        loop decHren
        mov ax,es:[bx+27h]
        xor es:[bx+0Fh],ax
        mov reloIP,bx
        mov ax,0Fh
        mov cx,24
        pop bx
        ret
;code    ends
;data    segment byte public stack
        .data
; off begin | lensig | sig | off mes | off Com | lenCom | off IP | off CS |
; off SS | off SP |
tableOfViruses equ $
        db _FILE,end00-$-1
        dw 06h
sigEM   db 15,4Dh,00,1Eh,56h,2Eh,0C5h,36h,11h,0,89h,36h,8,0,5Eh,1Fh
        db 4
        dw mesEM,3584
        db 3,24
        dw 0BE9h
        db 8
        dw 0BE9h+14h,0BE9h+16h,0BE9h+0Eh,0BE9h+10h,3584
end00   equ $
        db _FILE,end01-$-1
        dw 1Dh
        db 15,4Dh,00,1Eh,56h,2Eh,0C5h,36h,11h,0,89h,36h,8,0,5Eh,1Fh
        db 4
        dw mesEM,3584
        db 3,24
        dw 0BE9h+1Dh-6
        db 8
        dw 0BE9h+14h+1Dh-6,0BE9h+16h+1Dh-6,0BE9h+0Eh+1Dh-6,0BE9h+10h+1Dh-6
        dw 3584
end01   equ $
        db _FILE,end02-$-1
        dw 1h
        db 15,4Dh,00,1Eh,56h,2Eh,0C5h,36h,11h,0,89h,36h,8,0,5Eh,1Fh
        db 4
        dw mesEM,3584
        db 3,24
        dw 0BE9h+1h-6
        db 8
        dw 0BE9h+14h+1h-6,0BE9h+16h+1h-6,0BE9h+0Eh+1h-6,0BE9h+10h+1h-6
        dw 3584
end02   equ $
        db _FILE,end03-$-1
        dw 0
        db 15,4Dh,00,1Eh,56h,2Eh,0C5h,36h,11h,0,89h,36h,8,0,5Eh,1Fh
        db 4
        dw mesEM,3584
        db 1,-10
        db 2
        dw 0BE9h,0BEBh,3584
end03   equ $
        db _FILE,end04-$-1
        dw 20h
sigDirF db 15,0CDh,21h,33h,0C0h,8Eh,0D8h,0BEh,4Ch,00,0B8h,37h,4,3Bh,4,74h
        db 4
        dw mesDirF,1024
        db 1,-1
        db 0
        dw 0
end04   equ $
        db _FILE,end05-$-1
        dw 20h
sigHren db 15,0E8h,1Fh,0FDh,72h,0Dh,0B8h,0F3h,0C1h,0CDh,21h,72h,6,2Eh,0C6h,87h
        db 4
        dw mesHren,4928
        db 2
        dw procHren
        db 8
        dw 15+20,15+22,15+14,15+16,4928
end05   equ $
        db _FILE,end06-$-1
        dw -12h
sigBomb db  15, 0C0h,0BFh,0FCh,00,50h,57h,0B8h,0F3h,0A5h,0ABh,0B8h,0EBh
        db  1Fh,0ABh,0B4h
        db 4
        dw mesBomb,1000h
        db 2
        dw procBomb
        db 0
        dw 1000h
end06   equ $
        db _FILE,end07-$-1
        dw 20h
sigTch  db 15,0,2Eh,89h,9Ch,4Dh,2,2Eh,8Ch,84h,4Fh,2,0C7h,6,0Ah,0
        db 4
        dw mesTch,3036
        db 2
        dw procTch
        db 8
        dw 297h,299h,291h,28Eh,3036
end07   equ $
        db _FILE,end08-$-1
        dw 0Fh
sigUk33 db 15,0E9h,049h,0Ch,51h,52h,56h,1Eh,6,1Eh,6,33h,0FFh,0B8h,6,33h
        db 4
        dw mesUkr,3633
        db 6,2
        dw 0CE8h
        db 1
        dw 0CEDh
        db 8
        dw 0D0Eh,8D10h,8CF6h,0CFAh,3633
end08   equ $
        db _FILE,end09-$-1
        dw 120h
sig3617 db 10,4Eh,74h,5,80h,0FCh,4Fh,75h,19h,53h,6
        db 4
        dw mesUkr,3617
        db 6,2
        dw 0CDAh
        db 1
        dw 0CDFh
        db 8
        dw 0D00h,8D02h,8CE8h,0CECh,3617
end09   equ $
        db _FILE,end10-$-1
        dw 130h
sig3537 db 11,0Ch,9Dh,2Eh,0A1h,0C1h,0Ch,0CAh,2,0,3Dh,53h
        db 4
        dw mesUkr,3537
        db 6,2
        dw 0C8Ah
        db 1
        dw 0C8Fh
        db 8
        dw 0CB0h,8CB2h,8C98h,0C9Ch,3537
end10   equ $
        db _FILE,end11-$-1
        dw 120h
sig3627 db 10,9Ch,72h,64h,26h,0F6h,47h,15h,18h,75h,5Dh
        db 4
        dw mesUkr,3627
        db 6,2
        dw 0CE2h
        db 1
        dw 0CE7h
        db 8
        dw 0D08h,8D0Ah,8CF0h,0CF4h,3627
end11   equ $
        db _FILE,end12-$-1
        dw 10h
sig3000 db 12,02,2Eh,89h,8Dh,56h,02,2Eh,89h,95h,58h,02,2Eh
        db 4
        dw mesBadDir,3000
        db 3,24
        dw 0B2Eh
        db 8
        dw 0B2Eh+20,0B2Eh+22,0B2Eh+14,0B2Eh+16,3000
end12   equ $
        db _FILE,end13-$-1
        dw 10h
sig34_  db 11,0F2h,0Bh,51h,52h,56h,1Eh,6,8Ch,0D8h,48h,8Eh
        db 4
        dw mesUkr,3426
        db 6,2
        dw 0C1Bh
        db 1
        dw 0C20h
        db 8
        dw 0C41h,8C43h,8C29h,0C2Dh,3426
end13   equ $
        db _FILE,end14-$-1
        dw 10h
sig34   db 11,0F3h,0Bh,51h,52h,56h,1Eh,6,8Ch,0D8h,48h,8Eh
        db 4
        dw mesUkr,3426
        db 6,2
        dw 0C1Ch
        db 1
        dw 0C21h
        db 8
        dw 0C42h,8C44h,8C2Ah,0C2Eh,3426
end14   equ $
        db _FILE,end15-$-1
        dw 10h
sigCC   db 11,26h,81h,3Eh,0Ch,0,0E2h,0,74h,48h,8Ch,0D8h
        db 4
        dw mesCC,882
        db 2
        dw procCC
        db 8
        dw 88h,84h,76h,7Ch,882
end15   equ $
        db _FILE,end16-$-1
        dw 1E9h
        db 11,0EDh,86h,0EAh,5,5,8Eh,0BCh,1,0,0,0EFh
        db 4
        dw mesIzv,5555
        db 2
        dw procNazi2
        db 4
        dw 0,0,5555
end16   equ $
        db _FILE,end17-$-1
        dw 1E9h
        db 11,0Eh,52h,8Fh,0E0h,0BCh,0Ah,1,8Fh,0,0,0C8h
        db 4
        dw mesNazi,8600
        db 2
        dw procNazi
        db 4
        dw 0,0,8600
end17   equ $
        db _FILE,end18-$-1
        dw 5    ;*
sigHR88 db 12,81h,0C6h,0D9h,7,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h,0,0E6h ;*
        db 4
        dw mesHome,2188
        db 3,5
        dw 7D9h+5
        db 8
        dw 7D9h+5+24,7D9h+5+26,22h,28h,2188
end18   equ $
        db _FILE,end19-$-1
        dw 4            ; 1
sigUkr33        db 12,0E9h,0A6h,0Bh,51h,52h,56h,1Eh,6,8Ch,0D8h,48h,8Eh
        db 4
        dw mesUkr,3300
        db 6,2
        dw 0BC4h
        db 1
        dw 0BC9h
        db 8
        dw 0BEAh,8BECh,8BD2h,0BD6h,3300
end19   equ $
        db _FILE,end20-$-1
        dw 4            ; 2
sigUkr2        db 12,0E9h,44h,0Bh,51h,52h,56h,1Eh,6,8Ch,0D8h,48h,8Eh
        db 4
        dw mesUkr2,3201
        db 2
        dw 0B62h
        db 1
        dw 0B67h        ; 3
        db 8
        dw 0B88h,8B8Ah,8B70h,0B74h,3201
end20   equ $
        db _FILE,end21-$-1
        dw 5
        db 10,81h,0C6h,09Dh,7,0B0h,0,0E6h,21h,5Bh,8Eh ;*
        db 4
        dw mesHome,850h
        db 3,5
        dw 79Dh+5
        db 8
        dw 79Dh+5+24,79Dh+5+26,52h-1Eh,58h-1Eh,850h         ; 4
end21   equ $
        db _FILE,end22-$-1
        dw 3Eh-3
        db 12,0FBh,0B8h,53h,4Bh,0CDh,21h,3Ah,0E0h,75h,1,0C3h,51h
        db 4
        dw mesUkr,3201
        db 6,2
        dw 11h
        db 1
        dw 16h
        dw 3Ah-3,803Ch-3,8022h-3,26h-3,3201
end22   equ $
        db _FILE,end23-$-1
        dw 0            ; 5
        db 10,55h,89h,0E5h,83h,0ECh,12h,8Ch,5Eh,0F4h,55h
        db 4
        dw mesSen,5173
        db 2
        dw procSen
        db 8
        dw 1C97h-17E4h+20,1C97h-17E4h+22,1C97h-17E4h+14,1C97h-17E4h+16
        dw 5173
end23   equ $
        db _FILE,end24-$-1
        dw 0            ; 6
        db 10,0B4h,30h,0CDh,21h,3Ch,4,1Bh,0F6h,0B4h,52h
        db 2
        dw mesDir20
        db 1,-1
        db 0
        dw 0
end24   equ $
        db _FILE,end25-$-1
        dw 20h          ; 7
        db 10,0F3h,0,3Ch,4,1Bh,0F6h,0Eh,7,0BBh,60h
        db 2
        dw mesDir_d
        db 1,-1
        db 0
        dw 0
end25   equ $
        db _FILE,end26-$-1
        dw 864h         ; 8
        db 12,'Version 2.9a'
        db 4
        dw mesNos,2500
        db 3,5
        dw 8A1h
        db 8
        dw 8B9h,8BBh,21h,27h,2500
end26   equ $
        db _FILE,end27-$-1
        dw 4            ; 9
        db 10,81h,0C6h,0E6h,7,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h
        db 4
        dw mesNos,2308
        db 3,5
        dw 7E6h+4
        db 8
        dw 7E6h+4+24,7E6h+4+26,21h,27h,2308
end27   equ $
        db _FILE,end28-$-1
        dw 5            ;*            ; 10
        db 10,81h,0C6h,06Bh,7,5Bh,8Eh,0C3h,8Eh,0DBh,02Eh
        db 4
        dw mesHome,81Eh
        db 3,5
        dw 76Bh+5
        db 8
        dw 76Bh+5+24,76Bh+5+26,2Fh,35h,81Eh
end28   equ $
        db _FILE,end29-$-1
        dw 5            ;*            ; 11
        db 10,81h,0C6h,0EEh,7,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h
        db 4
        dw mesHome,8A1h
        db 3,5
        dw 7EEh+5
        db 8
        dw 7EEh+5+24,7EEh+5+26,33h,39h,8A1h
end29   equ $
        db _FILE,end30-$-1
        dw 5            ;*            ; 12
        db 10,81h,0C6h,020h,8,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h
        db 4
        dw mesHome,8D3h
        db 3,5
        dw 820h+5
        db 8
        dw 820h+5+24,820h+5+26,33h,39h,8D3h
end30   equ $
        db _FILE,end31-$-1
        dw 4            ; 13
        db 10,81h,0C6h,63h,15h,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h
        db 4
        dw mesNos,5761
        db 3,5
        dw 1563h+4
        db 8
        dw 1563h+4+24,1563h+4+26,21h,27h,5761
end31   equ $
        db _FILE,end32-$-1
        dw 0            ; 14
        db 13,'COMPUTER_VIRU'
        db 4
        dw mesSmall,314
        db 3,-4
        dw 4Ah
        db 0
        dw 314
end32   equ $
        db _FILE,end33-$-1
        dw 0            ; 15
        db 10,0FCh,0E8h,0,0,0B4h,13h,0CDh,2Fh,0B8h,0E2h
        db 4
        dw mesMc,512
        db 3,4
        dw 13Bh
        db 0
        dw 512
end33   equ $
        db _FILE,end34-$-1
        dw 1Ah          ; 16
        db 11,0E8h,0,0,05Eh,83h,0EEh,1Dh,0B4h,052h,0CDh,21h
        db 4
        dw light,1010
        db 3,24
        dw 3DAh
        db 8
        dw 3DAh+20,3DAh+22,3DAh+14,3DAh+16,1010
end34   equ $
        db _FILE,end35-$-1
        dw 0            ; 17
        db 10,0FAh,5Eh,0E8h,0,0,1Eh,33h,0C0h,8Eh,0D8h
        db 4
        dw baba,389
        db 3,4
        dw 177h+5
        db 0
        dw 389
end35   equ $
        db _FILE,end36-$-1
        dw 4            ; 18
        db 10,81h,0C6h,0B1h,8,5Bh,8Eh,0C3h,8Eh,0DBh,33h
        db 4
        dw mesNos,2500
        db 3,5
        dw 8B1h+4
        db 8
        dw 8B1h+4+24,8B1h+4+26,22h,28h,2500
end36   equ $
        db _FILE,end37-$-1
        dw 5            ;*            ; 19
        db 10,81h,0C6h,14h,8,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h
        db 4
        dw mesHome,2247
        db 3,5
        dw 814h+5
        db 8
        dw 814h+5+24,814h+5+26,33h,39h,2247
end37   equ $
;        dw -1
;        dw 0
tableSign21 equ $
;        db _MEM,end38-$-1
;        dw -2EDh
;        db 2
;        dw sigEM
;        db 4
;        dw mesEM,3584
;        db 2
;        dw 455h
end38   equ $
        db _MEM,end39-$-1
        dw -100h
        db 2
        dw sigUk33
        db 4
        dw mesUkr,3633
        db 2
        dw 0C26h
end39   equ $
        db _MEM,end40-$-1
        dw 872h
        db 2
        dw sigHren
        db 4
        dw mesHren,4928
        db 2
        dw 64Ch
end40   equ $
        db _MEM,end41-$-1
        dw 20h
        db 15,0FEh,8Bh,46h,0Ah,89h,46h,0ECh,8Ah,46h,11h,3Ch,3Dh,75h,16h,8Ah
        db 4
        dw mesSen,5173
        db 2
        dw 0F669h
end41   equ $
        db _MEM,end42-$-1
        dw -0A6h
        db 2
        dw sigBomb
        db 4
        dw mesBomb,4096
        db 2
        dw 7
end42   equ $
        db _MEM,end43-$-1
        dw -1D9h
        db 2
        dw sigTch
        db 4
        dw mesTch,3036
        db 2
        dw 4Ah
end43   equ $
        db _MEM,end44-$-1
        dw -27Bh
        db 2
        dw sigTch
        db 4
        dw mesTch,3036
        db 3
        dw 29Dh
end44   equ $
        db _MEM,end45-$-1
        dw 10h
        db 10,75h,3,0E9h,0D6h,0,3Dh,0DFh,0ADh,75h,3
        db 4
        dw mesIzv,5555
        db 1,0E3h
end45   equ $
        db _MEM,end46-$-1
        dw 10h
        db 2
        dw sig3617
        db 4
        dw mesUkr,3617
        db 2
        dw 0D28h-110h-3
end46   equ $
        db _MEM,end47-$-1
        dw 130h-0BFh
        db 2
        dw sig3537
        db 4
        dw mesUkr,3537
        db 2
        dw 0C1Ah
end47   equ $
        db _MEM,end48-$-1
        dw 1
        db 14,0FCh,4Bh,74h,14h,80h,0FCh,31h,74h,14h,80h,0FCh,49h,74h,18h
        db 4
        dw mesVC40,0
        db 1,-3
end48   equ $
        db _MEM,end49-$-1
        dw 10h
        db 10,9Dh,2Eh,0FFh,2Eh,85h,0Ah,0E8h,33h,0,0EBh
        db 4
        dw mesVC32,0
        db 1,-3
end49   equ $
        db _MEM,end50-$-1
        dw 10h
        db 2
        dw sig3627
        db 4
        dw mesUkr,3267
        db 2
        dw 0C1Fh
end50   equ $
        db _MEM,end51-$-1
        dw 17Eh-4E4h
        db 2
        dw sig3000
        db 4
        dw mesBadDir,3000
        db 2
        dw 56h
end51   equ $
        db _MEM,end52-$-1
        dw -0AEh
        db 2
        dw sig34_
        db 4
        dw mesUkr,3426
        db 2
        dw 0BABh
end52   equ $
        db _MEM,end53-$-1
        dw -0AEh
        db 2
        dw sig34
        db 4
        dw mesUkr,3426
        db 2
        dw 0BACh
end53   equ $
        db _MEM,end54-$-1
        dw -0BCh
        db 2
        dw sigCC
        db 4
        dw mesCC,882
        db 2
        dw 260h
end54   equ $
        db _MEM,end55-$-1
        dw -93h
        db 2
        dw sigHR88
        db 4
        dw mesHome,2188
        db 2
        dw 4Bh
end55   equ $
        db _MEM,end56-$-1
        dw -0ADh
        db 2
        dw sigUkr33
        db 4
        dw mesUkr,3300
        db 2
        dw 13C3h-85Fh-3
end56   equ $
        db _MEM,end57-$-1
        dw -0BACh
        db 2
        dw sigOne44
        db 4
        dw mesOne,3544
        db 2
        dw 116h
end57   equ $
        db _MEM,end58-$-1
        dw -0A3h+4
        db 2
        dw sigUkr2
        db 4
        dw mesUkr2,3201
        db 2
        dw 0B0Ah
end58   equ $
        db _MEM,end59-$-1
        dw 0E23h-0F66h
        db 10,81h,0C6h,09Dh,7,0B0h,0,0E6h,21h,5Bh,8Eh
        db 4
        dw mesNos,850h
        db 2
        dw 128Ch-0F66h-3
end59   equ $
        db _MEM,end60-$-1
        dw 233h-0DEh
        db 5,0E9h,7Ch,9,0E8h,91h
        db 4
        dw mesUkr,3201
        db 2
        dw 0BB2h-0DEh-3
end60   equ $
        db _MEM,end61-$-1
        dw -13Fh
        db 10,81h,0C6h,06Bh,7,5Bh,8Eh,0C3h,8Eh,0DBh,02Eh
        db 4
        dw mesHome,81Eh
        db 2
        dw 319h
end61   equ $
        db _MEM,end62-$-1
        dw 7DFh
        db 12,'Version 2.9b'
        db 4
        dw mesNos,2500
        db 2
        dw 50h
end62   equ $
        db _MEM,end63-$-1
        dw -09Eh
        db 10,0FAh,5Eh,0E8h,0,0,1Eh,33h,0C0h,8Eh,0D8h
        db 4
        dw baba,389
        db 2
        dw 0D6h
end63   equ $
        db _MEM,end64-$-1
        dw 66Dh
        db 11,'HOME RUN ! '
        db 4
        dw mesNos,2308
        db 2
        dw 48h
end64   equ $
        db _MEM,end65-$-1
        dw 6A3h
        db 13,'(c) v2.1 beta'
        db 4
        dw mesHome,2247
        db 2
        dw 377h
end65   equ $
        db _MEM,end66-$-1
        dw -147h
        db 10,81h,0C6h,020h,8,5Bh,8Eh,0C3h,8Eh,0DBh,0B0h
        db 4
        dw mesHome,8D3h
        db 2
        dw 380h
end66   equ $
        db _MEM,end67-$-1
        dw 6D6h
        db 13,'(c) v2.2 beta'
        db 4
        dw mesHome,8A1h
        db 2
        dw 380h
end67   equ $
        db _MEM,end68-$-1
        dw -0B0h
        db 13,'COMPUTER_VIRU'
        db 4
        dw mesSmall,314
        db 2
        dw 82h
end68   equ $
        db _MEM,end69-$-1
        dw 69Ch
        db 5,'XX:YY'
        db 4
        dw mesNos,5761
        db 2
        dw 48h
end69   equ $
        db _MEM,end70-$-1
        dw -0BBCh
        db 10,83h,2eh,13h,4,4,0b1h,6,0cdh,12h,0d3h
        db 4
        dw mesOne,3570
        db 2
        dw 116h
end70   equ $
        db _MEM,end71-$-1
        dw 0B4h
        db 13,'(c) Light Gen'
        db 4
        dw mesMC,512
        db 1,0E1h
end71   equ $
        db _MEM,end72-$-1
        dw 1Eh
        db 10,80h,0FCh,12h,74h,0F8h,3Dh,0,4Bh,74h,60h
        db 4
        dw light,1010
        db 2
        dw 88h
end72   equ $
        db _MEM,end73-$-1
        dw 7CCh
        db 12,'Version 2.9a'
        db 4
        dw mesNos,2500
        db 2
        dw 50h
end73   equ $
        db _MEM,end74-$-1
        dw 24h
        db 10,26h,89h,7Fh,12h,26h,8Ch,4Fh,14h,6,0Eh
        db 2
        dw mesDir20
        db 8
        dw 0
        db 0EBh,15h
        dw 1Ah
        db 0CBh,90h
end74   equ $
tableSign13 equ $
        db _MEM,end75-$-1
        dw 13Eh-1B9h
        db 2
        dw sigSpir
        db 4
        dw mesSpir,512
        db 2
        dw 1EFh-1B9h-3
end75   equ $
        db _MEM,end76-$-1
        dw -2Eh
        db 2
        dw sigUna
        db 4
        dw mesUna,512
        db 2
        dw 4Dh
end76   equ $
        db _MEM,end77-$-1
        dw 1
        db 14,0BAh,0BAh,74h,24h,80h,0FAh,0,75h,2Bh,2Eh,0A2h,7,1,80h
        db 4
        dw mesVC40,0
        db 1,-3
end77   equ $
        db _MEM,end78-$-1
        dw -317h
        db 2
        dw sigDirF
        db 4
        dw mesDirF,1024
        db 2
        dw 83h
end78   equ $
        db _MEM,end79-$-1
        dw 146h
        db 2
        dw sigMong
        db 4
        dw mesMong,1024
        db 2
        dw 7
end79   equ $
        db _MEM,end80-$-1
        dw 20h
        db 15,9Ch,2Eh,0FEh,0Eh,0Fh,21h,9Dh,0CAh,2,0,6,57h,2Eh,0C4h,3Eh
        db 0
        db 3,-2
        dw 2120h
end80   equ $
        db _MEM,end80_-$-1
        dw 5
        db 16,8Bh
        dw 0
        db 0Ch
        dw 0C415h,7D87h
        db 21h
        dw 0Ch
        db 20h
        dw 0A3EBh,0F933h
        db 0
        db 3,-2
        dw 2428h
end80_  equ $
        db _MEM,end81-$-1
        dw 0
        db 6
        dw 0CBh,0BF4Ah,85C7h
        db 0
        db 3,-2
        dw 23CCh   ;  0B07h
end81   equ $
        db _MEM,end82-$-1
        dw -44h
        db 2
        dw sigBI
        db 4
        dw mesBootIn,158h
        db 2
        dw 0Ch
end82   equ $
        db _MEM,end83-$-1
        dw 17Eh-3EAh
        db 2
        dw sig3000
        db 4
        dw mesBadDir,3000
        db 8
        dw 0,2EBh,7,14EBh
end83   equ $
        db _MEM,end84-$-1
        dw -0D94h               ; 20
        db 2
        dw sigOne44
        db 4
        dw mesOne,3544
        db 2
        dw 0ECh
end84   equ $
        db _MEM,end85-$-1
        dw 46h-0FEh             ; 21
        db 2
        dw sigHappy
        db 4
        dw mesHappy,1024
        db 8
        dw 0,3EBh,7,9090h
end85   equ $
        db _MEM,end86-$-1
        dw -9                   ; 22
        db 8,'MZ',40h,0,88h,1,37h,0Fh
        db 4
        dw mesAnti,512
        db 1,0D3h
end86   equ $
        db _MEM,end87-$-1
        dw -0DBEh               ; 23
        db 10,83h,2eh,13h,4,4,0b1h,6,0cdh,12h,0d3h
        db 4
        dw mesOne,3570
        db 2
        dw 0ECh
end87   equ $
        db _MEM,end88-$-1
        dw 8                    ; 24
        db 12,2Eh,80h,3Eh,0,2,2,75h,1Ah,50h,53h,51h,52h
        db 4
        dw mesCr,512
        db 1,0D8h
end88   equ $
        db _MEM,end89-$-1
        dw -0B7h
        db 2
        dw sigHappy2
        db 4
        dw mesHappy2,1024
        db 8
        dw 0,3EBh,7,9090h
end89   equ $
tableMbr equ $
        db _SEC,end90-$-1
        dw 3Eh
sigSpir db 15,0FAh,33h,0FFh,8Eh,0D7h,0BCh,0,7Ch,8Eh,0DFh,0BEh,14h,4,4Eh,0E8h
        db 2
        dw mesSpir
        db 4
        dw 89h,87h
end90   equ $
        db _SEC,end91-$-1
        dw 0
        db 15,0FAh,33h,0FFh,8Eh,0D7h,0BCh,0,7Ch,8Eh,0DFh,0BEh,14h,4,4Eh,0E8h
        db 2
        dw mesSpir
        db 4
        dw 89h,87h
end91   equ $
        db _SEC,end92-$-1
        dw 4Eh
sigUna  db 15,13h,88h,8Bh,84h,13h,88h,0D3h,0E0h,0B9h,0,1,8Eh,0C0h,0FCh,0ADh
        db 2
        dw mesUna
        db 2
        dw getUna
end92   equ $
        db _SEC,end93-$-1
        dw 0
        db 16,33h
        dw 0
        db 0DFh
        dw 0DF3Eh,97F7h
        db 07
        dw 0DFh
        db 0DFh
        dw 1803h,16A0h
        db 2
        dw mesSysCMbr
        db 1,-3
end93   equ $
        db _SEC,end94-$-1
        dw 0
        db 16,33h
        dw 0
        db 0DFh
        dw 0DC32h,0099h
        db 15h
        dw 0DFh
        db 0DFh
        dw 4E6Fh,6F21h
        db 2
        dw mesWinMbr
        db 1,-3
end94   equ $
        db _SEC,end94_-$-1
        dw 3Eh
        db 16,0FAh
        dw 0
        db 0E1h
        dw 0C6E2h,0E032h
        db 0F8h
        dw 0E1h
        db 0E1h
        dw 9741h,0EB29h
        db 2
        dw mesVForm
        db 1,-3
end94_  equ $
        db _SEC,end95-$-1
        dw 3Eh
        db 16,0FAh
        dw 0
        db 0E1h
        dw 1F38h,0B5B0h
        db 45h
        dw 0E1h
        db 0E1h
        dw 2D7Dh,0D7AFh
        db 2
        dw mesMWboot
        db 1,-3
end95   equ $
        db _SEC,end96-$-1
        dw 40h
        db 16,0C0h
        dw 0
        db 0E0h
        dw 83E7h,0E767h
        db 50h
        dw 0E0h
        db 0E0h
        dw 1AECh,4609h
        db 2
        dw mesPC7
        db 1,-3
end96   equ $
        db _SEC,end97-$-1
        dw 0
        db 16,33h
        dw 0
        db 0DFh
        dw 0A54Ah,0C164h
        db 0F3h
        dw 0DFh
        db 0DFh
        dw 0E43Eh,2B61h
        db 2
        dw mesSysCMbr
        db 1,-3
end97   equ $
        db _SEC,end98-$-1
        dw 44h
        db 16,0FAh
        dw 0
        db 0DEh
        dw 0B431h,3035h
        db 0B2h
        dw 0F0h
        db 0
        dw 0,0
        db 2
        dw mesDosN
        db 1,-3
end98   equ $
        db _SEC,end98_-$-1
        dw 0
        db 6
        dw 0DCh,2F04h,042Bh
        db 2
        dw mesMSmbr
        db 1,-3
end98_  equ $
        db _SEC,end99-$-1
        dw 40h
        db 6
        dw 1C0h,4D78h,0D2CAh
        db 2
        dw mesMWboot
        db 1,-3
end99   equ $
        db _SEC,end99_-$-1
        dw 3Eh
        db 6
        dw 1C2h,5923h,8985h
        db 2
        dw mesBoot
        db 1,-3
end99_  equ $
        db _SEC,end100-$-1
        dw 80h
        db 6
        dw 14h,864Ch,8C84h
        db 4
        dw mesDirF,1024
        db 2
        dw getDirF
end100  equ $
        db _SEC,end101-$-1
        dw 36h
sigMong db 15,0FAh,33h,0C0h,8Eh,0D8h,0A1h,13h,4,48h,48h,0A3h,13h,4,0B9h,40h
        db 2
        dw mesMong
        db 2
        dw getMong
end101  equ $
        db _SEC,end102-$-1
        dw 61h
sigBI   db 15,26h,81h,7Fh,3Eh,0Ah,7,74h,16h,0E8h,9Eh,00,0B2h,80h,0E8h,3
        db 2
        dw mesBootIn
        db 2
        dw getBootIn
end102  equ $
        db _SEC,end103-$-1
        dw 30h
        db 15,01,02,0BBh,0,7Ch,0CDh,13h,50h,51h,52h,0B4h,04,0CDh,1Ah,72h
        db 2
        dw mesTch
        db 2
        dw writeTch
end103  equ $
        db _SEC,end104-$-1
        dw 46h
        db 10,1Eh,56h,16h,53h,0BFh,2Bh,7Ch,0B9h,0Bh,0
        db 2
        dw mesPC
        db 1,-3
end104  equ $
        db _SEC,end105-$-1
        dw 3Eh
        db 6
        dw 1C2h,1FCCh,662Ch
        db 2
        dw mesMS
        db 1,-3
end105  equ $
        db _SEC,end106-$-1
        dw 0
        db 6
        dw 1B0h,26D8h,0D8FEh
        db 2
        dw mesAdmMbr
        db 1,-3
end106  equ $
        db _SEC,end107-$-1
        dw 46h
        db 10,0BBh,7,0,0CDh,10h,5Eh,0EBh,0F0h,32h,0E4h
        db 2
        dw mesNU
        db 1,-3
end107  equ $
        db _SEC,end108-$-1
        dw 46h
        db 10,0BCh,0,7Ch,36h,0C5h,36h,78h,0,1Eh,56h
        db 2
        dw mesPCT
        db 1,-3
end108  equ $
        db _SEC,end109-$-1
        dw 46h
        db 10,0FBh,0B8h,0C0h,7,8Eh,0D8h,0E8h,89h,0,0BEh
        db 2
        dw mesFF
        db 1,-3
end109  equ $
        db _SEC,end110-$-1
        dw 7
sigOne44        db 10,0D3h,0FBh,8Eh,0DBh,83h,2Eh,13h,4,4,0B1h
        db 2
        dw mesOne
        db 2
oneAdr  dw getOne44
end110  equ $
        db _SEC,end111-$-1
        dw 190h
        db 13,'(c) Light Gen'
        db 2
        dw mesMc
        db 2
        dw getMc
end111  equ $
        db _SEC,end112-$-1
        dw 137h
        db 11,0A3h,13h,4,0B1h,6,0D3h,0E0h,8Eh,0C0h,0A3h,4Eh
        db 2
        dw mesAnti
        db 2
        dw getAnti
end112  equ $
        db _SEC,end113-$-1
        dw 11h
        db 10,83h,2eh,13h,4,4,0b1h,6,0cdh,12h,0d3h
        db 2
        dw mesOne
        db 2
        dw getOne
end113  equ $
        db _SEC,end114-$-1
        dw 47h
        db 12,2Eh,80h,3Eh,0,2,2,75h,1Ah,50h,53h,51h,52h
        db 2
        dw mesCr
        db 2
        dw getCr
end114  equ $
        db _SEC,end115-$-1
        dw 46h
sigHappy        db 0Dh,16h,7,0BBh,13h,4,36h,83h,2Fh,2,0CDh,12h,0B1h,6
        db 2
        dw mesHappy
        db 2
        dw getHappy
end115  equ $
        db _SEC,end116-$-1
        dw 49h
sigHappy2       db 11,36h,83h,2Fh,2,0CDh,12h,0B1h,6,0D3h,0E0h,50h
        db 2
        dw mesHappy2
        db 2
        dw getHappy2
end116  equ $
        db _FILE,end117-$-1
        dw 0
sigWhite db 15,0E8h,0,0,5Bh,81h,0EBh,3,1,8Bh,0D3h,1Eh,6,0Eh,1Fh,0B8h
        db 4
        dw mesWhite,4682
        db 3,-6
        dw 0A1h
        db 4
        dw 0A1h,80A3h
        dw -10
end117  equ $
        db _MEM,end118-$-1
        dw -117Eh
        db 2
        dw sigWhite
        db 4
        dw mesWhite,4682
        db 2
        dw 0BEh
end118  equ $
        db _SEC,end119-$-1
        dw 25h
sigSex  db 15,33h,0C0h,8Eh,0D8h,0A0h,3Fh,4,0A8h,1,75h,3,0E8h,7,0,1Fh
        db 4
        dw mesSexR,512
        db 8
        dw 0FCh,100h,107h,10Bh
end119  equ $
        db _MEM,end120-$-1
        dw 10h
        db 2
        dw sigSex
        db 4
        dw mesSexR,512
        db 1,-10
end120  equ $
        dw -1
        dw 0

procDec dw 0
setKey  dw 0

mesAnti         db 'AntiExe',0
mesPC           db 'BOOT,PC-DOS',0
mesMS           db 'BOOT,MS-DOS',0
mesNU           db 'BOOT,NortonUtil',0
mesPCT          db 'BOOT,PC-Tools',0
mesFF           db 'BOOT,FFORMAT',0
mesMWboot       db 'BOOT,WINDOWS 95',0
mesBoot         db 'BOOT',0
mesPC7          db 'BOOT,PC-DOS 7.0',0
mesDosN         db 'BOOT,Dos Navigator',0
mesVForm        db 'BOOT,VFORMAT 1.5',0
baba            db 'Baba',0
mesBadDir       db 'BadDir',0
mesBootIn       db 'BootInfector',0     ; 158
mesBomb         db 'Bomber',0
mesCC           db 'CC',0
mesDirF         db 'DIR-FOREVER',0
mesDir_d        db 'Dir-d.1024.',0
mesDir20        db 'DirOct-20.1024.',0
mesHappy        db 'HappyKiller',0
mesHome         db 'HomeRun',0
mesHren         db 'Hren',0
mesIzv          db 'Izvrat31b',0
light           db 'Light',0
mesMSmbr        db 'MBR,MS-DOS',0
mesAdmMbr       db 'MBR,ADM_v1.00',0
mesSysCMbr      db 'MBR,System Commander',0
mesWinMbr       db 'MBR,WINDOWS 95',0
mesEM           db 'Maverick',0
mesMc           db 'Mc',0
mesMong         db 'Mongolain_v1.00',0
mesNazi         db 'Nazi20',0
mesNos          db 'Nostardamus',0
mesOne          db 'OneHalf',0
mesSen          db 'Sentinel',0
mesSexR         db 'SexR',0
mesSmall        db 'Small3',0
mesSpir         db 'Spirit',0
mesTch          db 'Tchechen_v2.0',0    ; 3036
mesCr           db 'ToCrazy',0
mesUna          db 'UNashamed',0
mesUkr          db 'Ukrajina',0
mesVC97         db 'VC97',0
mesVC40         db 'VC 4.00.40',0
mesVC32         db 'VC 4.00.32',0
mesWhite        db 'White',0
mesUkr2         dw 0FE01h,mesUkr
                db '2',0
mesHappy2       dw 0FE01h,mesHappy
                db '2',0
listVar         dw offset reloIP        ; 0
                dw offset myTitle       ; 2
                dw offset typeFile      ; 4
                dw offset diskType      ; 6
                dw offset tabBlock      ; 8
                dw offset posLo         ; A
                dw offset posHi         ; C
                dw offset posLoAll      ; E
                dw offset posHiAll      ; 10
end
