
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Этот модули сообщает об упаковщиках. Если б он еще и распаковывал...
;

public  unp
extrn   posLo:word,posHi:word,regIP:word,scanChSum:near,baseSeg:word
extrn   mesPack:near,print:near,printEng:near,readF:near,color:byte
extrn   print0D0A1:near,varNP:byte,hand:word,writeF:near,myTitle:word
extrn   scanChSumB:near
        .model small
        .code
unp proc
        call readTitle
        jc noUnp
        cmp varNP,0
        je noUnp
        call scanPack
noUnp:
        ret
        endp
;offset len chs1 chs2 - 8*4 =32+4
scanPack proc
        push ax bx cx dx bp di es
        mov es,baseSeg
        mov di,regIP
        lea si,sigUnp
noLastSig:
        push si
scanMore:
        call scanChSumB ;1
        jne nextSig
        lodsw
        push di
        add di,ax
        call scanChSumB ;2
        pop di
        jne nextSig
        lodsw
        inc ax
        jz printPack
        dec ax
        push di
        add di,ax
        call scanChSumB ;3
        pop di
        jne nextSig
        lodsw
        inc ax
        jz printPack
        dec ax
        push di
        add di,ax
        call scanChSum  ;4
        pop di
        je printPack
nextSig:
        pop si
        call getNameOff
        cmp word ptr [si],-1
        jne noLastSig
endScanS:
        pop es di bp dx cx bx ax
        ret
        endp
getNameOff proc
        add si,1+6+1+4
        lodsw
        inc ax
        je checkSigS
        add si,1+4
        lodsw
        inc ax
        je checkSigS
        add si,2+4
checkSigS:
        lodsw
        ret
        endp
printPack proc
        pop si
        mov color,9
        call getNameOff
        lea dx,mesPack
        call printEng
        mov color,11
        mov dx,[si+22h]
        xchg dx,ax
        call print
        call print0D0A1
        jmp endScanS
        endp
readTitle proc
        push ax bx cx dx
        xor ax,ax
        mov dx,posLo
        xor cx,cx
        cmp posHi,0
        jns readBegin
        mov ax,dx
        neg ax
        xor dx,dx
readBegin:
        push ax
        mov ax,4200h
        int 21h
        pop dx
        mov cx,800h
        push ds
        mov ds,baseSeg
        call readF
        pop ds
        pop dx cx bx ax
        ret
        endp
;code    ends
;data    segment byte public stack
        .data
sigUnp  equ $
        db       03h
        dw      0C800h, 00E8h, 0023h
        db       20h
        dw       1399h, 998Ah, 005Fh
        db       40h
        dw      0B726h,0A0D1h, -1
        dw       mesCPAV
        db       03h
        dw      0C800h, 00E8h, 0023h
        db       20h
        dw      169Ch, 9C8Ah, 005Fh
        db       40h
        dw      0B309h, 8FFAh, -1
        dw       mesCPAV
        db      03h
        dw      0C800h, 00E8h, 0023h
        db      20h
        dw       0D87h, 878Ah, 005Fh
        db      40h
        dw      0B32Ch,0AADFh, -1
        dw       mesCPAV
        db      20h
        dw      1F10h, 15E1h, 0038h
        db      40h
        dw      0B0C0h, 4630h, -1
        dw       mesCPAV
        db      03h
        dw      0C800h, 00E8h, 0023h
        db      20h
        dw       0C86h, 868Ah, 005Fh
        db      40h
        dw       38FDh, 142Fh, -1
        dw       mesCPAV
        db      03h
        dw      0C800h, 00E8h, 0023h
        db      20h
        dw      0B81h, 818Ah, 005Bh
        db      40h
        dw      5B95h, 8D3Fh, -1
        dw       mesCPAV
        db      04h
        dw      0A521h, 501Eh, 0029h
        db      20h
        dw      0DA98h, 1398h, 0075h
        db      30h
        dw      70D8h, 82EDh, -1
        dw       mesCPAV
        db      0Dh
        dw      0C205h, 001Ah, 0019h
        db      30h
        dw       7667h, 46FDh, -1
        dw       mesFXLOCK
        db      01h
        dw      00BFh, 0000h, 0003h
        db      09h
        dw      0EDC8h, 76BAh, 0011h
        db      10h
        dw       8CCAh, 23BFh, -1
        dw       mesDIET
        db      01h
        dw      00BEh, 0000h, 0003h
        db      01h
        dw      00BFh, 0000h, 0011h
        db      10h
        dw      8CCAh, 23BFh, -1
        dw       mesDIET
        db      04h
        dw      8EF3h,0F99Ch, 000Eh
        db      1Ah
        dw      9B49h,0F7ACh, 0030h
        db      0Fh
        dw      2AF2h, 1B21h, -1
        dw       mesDIET
        db      0Bh
        dw      63C5h, 7F1Dh, 0014h
        db      1Fh
        dw      7315h,0FF9Ch, -1
        dw       mesDIET
        db      0Bh
        dw      63C5h, 7F1Dh, 0014h
        db      1Fh
        dw      730Eh,0E487h, -1
        dw       mesDIET
        db      0Bh
        dw      6EC5h, 7F10h, 0014h
        db      1Fh
        dw      730Dh,0E784h, -1
        dw       mesDIET
        db      04h
        dw      8EF0h,0F99Ch, 000Dh
        db      12h
        dw      5EEDh, 5709h, 0028h
        db      1Fh
        dw      7339h,0D3B0h, -1
        dw       mesDIET
        db      04h
        dw      8EF0h,0F99Ch, 000Dh
        db      0Dh
        dw      0A74Dh,0F798h, 002Dh
        db      1Fh
        dw      7319h,0D2B1h, -1
        dw       mesDIET
        db      2Fh
        dw      07E8h,0E497h, 0070h
        db      9Dh
        dw      5BF8h, 072Eh, -1
        dw       mesLZEXE
        db      0E9h
        dw      2125h,0DA89h, 00EEh
        db      5Ch
        dw      0EC4Ah, 6576h, -1
        dw       mesLZEXE
        db      0E9h
        dw      952Fh,0D037h, 00EEh
        db      5Ch
        dw      2521h, 0ED4h, -1
        dw       mesLZEXE
        db      01h
        dw      00BEh, 0000h, 0003h
        db      11h
        dw      903Fh, 0BE9h, 0014h
        db      12h
        dw      0ECFFh, 3C22h, -1
        dw       mesCOMPACK
        db      01h
        dw      00BEh, 0000h, 0003h
        db      12h
        dw      4F87h, 498Dh, 0015h
        db      14h
        dw      0F760h,0A3A9h, -1
        dw       mesCOMPACK
        db      01h
        dw      00BDh, 0000h, 0003h
        db      2Eh
        dw       4D45h, 8E3Ah, -1
        dw       mesCOMPACK
        db      01h
        dw      00B8h, 0000h, 0003h
        db      36h
        dw      0C093h, 58C8h, 0039h
        db      86h
        dw       3E91h, 5A34h, -1
        dw       mesPKLITE
        db      01h
        dw       00BAh, 0000h, 0003h
        db      20h
        dw      12DDh,0FD22h, 006Ch
        db      0FFh
        dw      6FE9h, 9CB9h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0003h
        db       01h
        dw       00BAh, 0000h, 0006h
        db       26h
        dw       2F75h,0BEC2h, 0071h
        dw      128h
        dw      0EDC3h, 081Dh
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0003h
        db       01h
        dw       00BAh, 0000h, 0006h
        db       0026h
        dw       2F75h,0BEC2h, 0071h
        dw       0127h
        dw      0AED9h, 1244h
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0003h
        db       01h
        dw       00BAh, 0000h, 0006h
        db       28h
        dw      0E08Ch, 47F4h, 0073h
        dw       127h
        dw       90A7h, 6C04h
        dw       mesPKLITE
        db       02h
        dw       50B8h, 0000h, 0004h
        db       01h
        dw       00BAh, 0000h, 0007h
        db       26h
        dw       299Ch, 572Dh, 0084h
        dw       0125h
        dw       2DA4h, 6FB9h
        dw       mesPKLITE
        db       0Bh
        dw       95B6h, 6C75h, 0022h
        db       30h
        dw       2845h,0C4FCh, 0070h
        db       0FFh
        dw       45D9h, 32FCh, -1
        dw       mesPKLITE
        db       0Bh
        dw       94E3h, 3921h, 0022h
        db       30h
        dw       477Ah, 7AD7h, 0076h
        db       0FFh
        dw       36DAh,0DA33h, -1
        dw       mesPKLITE
        db       0Ch
        dw       2998h, 19EAh, 001Bh
        db       55h
        dw       66EBh, 33DBh, 0070h
        db       0FFh
        dw       7AB7h, 6D09h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 007Eh
        db       0C0h
        dw       7944h,0FB08h, 013Eh
        db       0F0h
        dw      0DB90h, 3D0Dh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0083h
        db       41h
        dw      0AAB2h,0A2BAh, 00C4h
        db       0F0h
        dw       7CFBh,0F8F0h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0006h
        db       27h
        dw       7EC7h, 0CD7h, 0075h
        db       0FFh
        dw       78E2h, 01E8h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0006h
        db       27h
        dw       9FFAh, 310Bh, 0082h
        db       0FFh
        dw      0C9D0h, 3B2Dh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0006h
        db       27h
        dw       7AC7h, 0CD3h, 0075h
        db       0FFh
        dw       0EBBDh, 6E0Eh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0085h
        db       0D0h
        dw      0BB8Eh, 29E0h, 0155h
        db       0D0h
        dw       846Dh, 97D0h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 006Ch
        db       061h
        dw       1EE4h, 37F8h, 00CDh
        db       0D5h
        dw       45FFh, 3489h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 007Ah
        db       0C0h
        dw       19BAh,0B88Dh, 013Ah
        db       0F0h
        dw       7A09h,0CAB3h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 006Ch
        db       61h
        dw       1EE4h, 37F8h, 00CDh
        db       0D5h
        dw      0D474h,0FFDBh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 007Ah
        db       0C0h
        dw       19BAh,0B88Dh, 013Ah
        db       0F0h
        dw      0D599h, 5A8Ch, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0042h
        db       0ADh
        dw       3075h, 3FE2h, 00EFh
        db       0B4h
        dw       01E2h, 29D0h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 006Ch
        db       50h
        dw      0F944h, 860Bh, 00BCh
        db       0EEh
        dw       5753h, 9837h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0071h
        db       90h
        dw       9216h,0FBB8h, 0101h
        db       90h
        dw       336Ah,0E17Fh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0083h
        db       41h
        dw      0C231h, 9B9Bh, 00C4h
        db       0F0h
        dw      0EB32h,0FA13h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0083h
        db       41h
        dw      0C231h, 9B9Bh, 00C4h
        db       0F0h
        dw       8692h, 90BAh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0009h
        db       0Fh
        dw       1532h, 12CAh, 002Ah
        db       1Eh
        dw      0AE0Eh,0F8BDh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0009h
        db       0Fh
        dw       1532h, 12CAh, 002Ah
        db       01Eh
        dw       38A4h, 5281h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0009h
        db       0Fh
        dw       1532h, 12CAh, 0030h
        db       16h
        dw      0C3A2h, 547Ch, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 004Bh
        db       8Fh
        dw      0B3C4h, 6E1Fh, 00DAh
        db       90h
        dw      0EFF8h, 022Eh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0009h
        db       11h
        dw       215Dh, 7C90h, 002Ch
        db       24h
        dw       25D8h, 2EE0h, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0009h
        db       0Fh
        dw       1532h, 12CAh, 002Ah
        db       1Ch
        dw       1644h,0B24Fh, -1
        dw       mesPKLITE
        db       02h
        dw       50B8h, 0000h, 0042h
        db       14h
        dw       35A7h, 1F78h, 000Ah
        db       12h
        dw       75A3h, 823Ah, 0067h
        dw       02h
        dw       740Fh, 0000h
        dw       mesPKLITE
        db       02h
        dw       50B8h, 0000h, 0042h
        db       14h
        dw       09A7h, 1F44h, 000Ah
        db       12h
        dw       75A3h, 823Ah, 0067h
        dw       02h
        dw       740Fh, 0000h
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0081h
        db       40h
        dw       5E58h,0B53Ah, 00C1h
        db       0F0h
        dw       02B0h, 30FAh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0077h
        db       40h
        dw       0F92Bh, 6175h, 00B7h
        db       0E0h
        dw       0ADECh,0DFAFh, -1
        dw       mesPKLITE
        db       01h
        dw       00B8h, 0000h, 0084h
        db       42h
        dw       168Eh,0C43Fh, 00C6h
        db       0F0h
        dw      0F259h, 8CFEh, -1
        dw       mesPKLITE
        db       02h
        dw       50B8h, 0000h, 003Ah
        db       55h
        dw      0AE37h, 9A1Fh, 008Fh
        db       94h
        dw       9984h, 9278h, 0123h
        dw       93h
        dw       8ABFh, 7405h
        dw       mesPKLITE
        db       02h
        dw       50B8h, 0000h, 003Ah
        db       55h
        dw       62E7h,0E184h, 008Fh
        db       0DFh
        dw      0ACD5h, 0CD2h, 016Eh
        dw       0F0h
        dw      0C2E3h, 2811h
        dw       mesPKLITE
        db       22h
        dw       88D8h, 13CBh, 0022h
        db       0A4h
        dw       4122h,0C06Ah, -1
        dw       mesEXEPACK
        db       22h
        dw       88D8h, 13CBh, 0022h
        db       0A4h
        dw       0E96Ah, 6A93h, -1
        dw       mesEXEPACK
        db       22h
        dw       88D8h, 13CBh, 0022h
        db       0A4h
        dw      0D87Eh,0BEE8h, -1
        dw       mesEXEPACK
        db       26h
        dw       8674h,0BF69h, 0026h
        db       0A6h
        dw       4CAFh, 4DEAh, -1
        dw       mesEXEPACK
        db       24h
        dw       0536h,0FDA8h, 0024h
        db      0ADh
        dw       96F4h, 166Bh, -1
        dw       mesEXEPACK
        db       24h
        dw      0C560h,0AB3Eh, 0024h
        db       0ADh
        dw       96F4h, 166Bh, -1
        dw       mesEXEPACK
        db       03h
        dw      0A800h, 00E9h, 0044h
        db       02h
        dw      0EB4Eh, 0000h, 0094h
        db       21h
        dw       4280h, 3B86h, 00B7h
        dw       96h
        dw      0E090h, 5353h
        dw       mesTINYPROG
        db       1Bh
        dw       0DE7h, 5C93h, 002Dh
        db       30h
        dw       5A86h, 3209h, 005Eh
        db       5Dh
        dw       0B617h, 1163h, 00C1h
        dw       50h
        dw       0E778h, 7983h
        dw       mesCryptEXE
        db      0C0h
        dw      0E76Ch,0B763h, 00C0h
        db      0C0h
        dw       5BD8h,0AAE1h, -1
        dw      mesUCEXE
        db      0C0h
        dw      5E96h,5481h,00C0h
        db      0C0h
        dw      8BD5h,4A4Bh, -1
        dw      mesUCEXE
        dw      0FFFFh
mesDIET           db      'DIET',0 
mesLZEXE          db      'LZEXE',0 
mesPKLITE         db      'PKLITE',0 
mesFXLOCK         db      'F-XLOCK',0
mesCOMPACK        db      'COMPACK',0 
mesCryptEXE       db      'CryptEXE',0 
mesEXEPACK        db      'EXEPACK',0 
mesTINYPROG       db      'TINYPROG',0 
mesCPAV           db      'CPAV',0 
mesUCEXE          db      'UCEXE',0
end
