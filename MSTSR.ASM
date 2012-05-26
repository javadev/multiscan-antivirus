
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Резидентный модуль, вызывающий главный файл перед запускоп программ.
        .model tiny
        .code
        .startup
        jmp setup
int21:
        pushf
        nop
        sti
        cmp ax,0FB62h
        je exitOk
        push ax
        sub ax,4B00h
        pop ax
        jne exit21
        cmp cs:flagRun,0                ;+
        jne exit21
        push ax
        call checkName
        je end21
        inc cs:flagRun
        call runProg
        dec cs:flagRun
        cmp al,0FFh
        je end21
        cmp al,0
end21:
        pop ax
        je exit21
exitOk:
        mov ax,5
        popf
        stc
        retf 2
exit21:
        popf
                db 0EAh
off21           dw ?                            ;+
seg21           dw ?                            ;+
tabRun          dw 0
                dw comstr,0
                dw 0,0
                dw 0,0
flagRun         db 0
badName         db 11,'COMMAND.COM'
                db 6,'DN.PRG'
                db 6,'VC.COM',0
progComm        db 'H:\ASM\MSCAN.EXE',30 dup (0)
comstr          db 0,'/',10,10,'/c- '
fileName        db 100 dup (?)
makeDI:
        push ax si
        mov si,dx
        mov di,si
        cld
nextChar:
        lodsb
        cmp al,'\'
        je saveSI
        cmp al,':'
        jne cmp0
saveSI:
        mov di,si
cmp0:
        or al,al
        jne nextChar
        pop si ax
        ret
checkName:
        push ax bx cx si di ds es
        mov ah,0Fh
        int 10h
        and al,7Fh
        cmp al,4
        jb modeOk
        cmp al,1Bh
        jb endName
modeOk:
        call makeDI
        push ds
        pop  es
        push cs
        pop  ds
        lea si,badName          ;+
        xor ah,ah
nextName:
        lodsb
        xchg cx,ax
        or si,si
        jcxz endName
        push di
        rep cmpsb
        pop di
        pushf
        add si,cx
        popf
        jne nextName
endName:
        pop es ds di si cx bx ax
        ret
moveFname:
        push ax cx si di es
        mov cx,99
        push cs
        pop  es
        mov si,dx
        lea di,fileName
nextCh:
        lodsb
        stosb
        or al,al
        loopne nextCh
        pop es di si cx ax
        ret
calcCstr:
        push ax cx si ds
        mov cx,110
        push cs
        pop  ds
        lea si,comstr
        push si
        inc si
nextCh1:
        lodsb
        or al,al
        loopne nextCh1
        dec si
        mov 1 ptr [si],0Dh
        dec si
        sub si,offset comstr
        xchg si,ax
        pop si
        mov [si],al
        pop ds si cx ax
        ret
runProg:
        push bx cx dx bp si di ds es
        call moveFname
        call calcCstr
        push cs cs
        pop  ds es
        lea bx,tabRun
        mov [bx+4],cs
        lea dx,progComm
        mov ax,4B00h
        pushf
        call dword ptr off21
        mov al,0
        jc exitRun
        mov ah,4Dh
        pushf
        call dword ptr cs:off21
exitRun:
        pop es ds di si bp dx cx bx
        ret
checkMSexe:
        push ax bx cx dx si di ds
        mov ds,ds:2Ch
        mov si,1
nextWord:
        dec si
        lodsw
        or ax,ax
        jne nextWord
        lodsw
        lea di,progComm
nextByteC:
        lodsb
        stosb
        or al,al
        jne nextByteC
        pop ds
        lea si,progComm
        mov di,si
nextChar1:
        lodsb
        cmp al,'\'
        jne check00
        mov di,si
check00:
        or al,al
        jne nextChar1
        lea si,mesName
nextB:
        lodsb
        stosb
        or al,al
        jne nextB
        lea dx,progComm
        mov ax,3D00h
        int 21h
        jc error
        xchg bx,ax
        mov ah,3Eh
        int 21h
error:
        pop di si dx cx bx ax
        ret
setup:
        lea dx,mesHel
        mov ah,9
        int 21h
        call checkMSexe
        jc printErr
        lea dx,mesOk
        mov ah,9
        int 21h
        mov ax,0FB62h
        int 21h
        cmp ax,5
        je quit
        mov ax,3521h
        int 21h
        mov off21,bx
        mov seg21,es
        lea dx,int21
        mov ax,2521h
        int 21h
        lea dx,setup
        int 27h
quit:
        int 20h
printErr:
        lea dx,mesErr
        mov ah,9
        int 21h
        jmp quit
mesHel          db 'MultiScan TSR program (c) 1997 by Valentin Kolesnikov.',13,10,36
mesOk           db 'Program intstalled into memory.',13,10,36
mesErr          db 'File not found MSCAN.EXE',13,10,36
mesName         db 'MSCAN.EXE',0
        end
