
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; Модуль рисует картинку из файла MSCAN.REC. Почему-то перестал 
; срабатывать таймер после вывода картинки.

public  readPic,outPic
extrn   openRec:near,print:near,path:near,setPos:near,segRec:word
extrn   videoSeg:word,getChar:near,readF:near
extrn   varKeyHel:byte,varSM:byte,print0D0A:near,closeRap:near
extrn   lenRec:word,delString:near,baseSeg:word,decod:near,closeF:near
extrn   segVirInf:word,varAA:byte,allocMemAX:near
        .model small
        .code
readPic proc
        cmp varKeyHel,0
        jne noOpenR
        cmp varAA,0
        je  readR
noOpenR:
        ret
        endp
readR proc
        push ax bx cx dx
        call openRec
        jnc moreRead
        jmp short exitR
delBlock:
        push es
        mov es,segRec
        mov ah,49h
        int 21h
        pop es
closeEnd:
        call closeF
        mov segRec,0
outMes:
        call print
        lea dx,path
        call print
        call print0D0A
        call print0D0A
        call delString
        jmp short exitR
moreRead:
        xchg ax,bx
        mov al,2
        call setPos
        mov lenRec,ax
        call allocMemAX
        lea dx,mesNoMem
        jc closeEnd
        mov segRec,ax
        xor al,al
        call setPos
        mov cx,lenRec
        push ds
        mov ds,segRec
        xor dx,dx
        call readF
        mov ax,ds:4
        pop ds
        lea dx,mesBadD
        jc delBlock
        lea dx,mesNoCor
        cmp ax,899Dh
        jne delBlock
        call closeF
exitR:
        pop dx cx bx ax
noReadR:
        ret
        endp
outPic proc
        cmp varKeyHel,0
        jne noReadR
        cmp segRec,0
        je  noReadR
        mov ax,1A00h
        int 10h
        cmp al,1Ah
        jne noReadR
        push ax bx cx dx bp es
        mov ah,0Fh
        int 10h
        push ax
        mov ah,3
        int 10h
        push bx dx
        mov ax,1130h
        mov bx,200h
        int 10h
        push cx
        push ds es
        mov es,segVirInf
        mov ds,videoSeg
        xor si,si
        xor di,di
        mov cx,132*60
        rep movsw
        pop es ds
        mov ax,13h
        int 10h
        call fill0
        call unpack
        push ds
        mov ax,0A000h
        mov ds,ax
        call decod
        pop ds
        jc noRunCode
        push ds es
        mov ax,baseSeg
;       add ax,1FBh
        mov es,ax
        mov ax,0A000h
        mov ds,ax
        mov si,10h
        mov di,100h
        mov cx,ds:2
        rep movsb
        push cs
        call runCod
        pop es ds
        jmp short returnOfCode
runCod:
        push es es
        pop  ds
        mov ax,100h
        push ax
        retf
noRunCode:
        cmp varSM,0
        je oldKey
        call invert
oldKey:
        call setPal
        call getChar
returnOfCode:
        pop cx dx bx ax
        push ax cx
        xor ah,ah
        int 10h
        pop cx ax
        cmp al,7
        ja noSetFont
        mov ax,1112h
        cmp cl,8
        je setFont8
        mov ax,1111h
        cmp cl,14
        jne noSetFont
setFont8:
        push bx dx
        int 10h
        pop dx bx
noSetFont:
        mov ah,2
        int 10h
        push ds
        mov es,videoSeg
        mov ds,segVirInf
        xor si,si
        xor di,di
        mov cx,132*60
        rep movsw
        pop ds
        mov ah,0Bh
        xor bx,bx
        int 10h
noOutRec:
        pop es bp dx cx bx ax
        ret
        endp
invert proc
        push ax cx si di ds
        mov ax,0A000h
        mov ds,ax
        xor si,si
        mov di,63999
        mov cx,32000
moreCh:
        mov al,[si]
        xchg al,[di]
        mov [si],al
        inc si
        dec di
        loop moreCh
        pop ds di si cx ax
        ret
        endp
fill0 proc
        push ax bx cx dx di es
        xor di,di
        mov cx,180h
        mov ax,0A000h
        mov es,ax
        xor ax,ax
        rep stosw
        xchg ax,dx
        xor bx,bx
        mov cx,100h
        mov ax,1012h
        int 10h
        pop es di dx cx bx ax
        ret
        endp
setPal proc

        push ax bx cx dx es
        mov ax,0A000h
        mov es,ax
        mov dx,64000
        xor bx,bx
        mov cx,100h
        mov ax,1012h
        int 10h
        pop es dx cx bx ax
        ret
        endp
unpack proc
        push ax bx cx dx si di ds es
        mov ax,0A000h
        mov es,ax
        mov ds,segRec
        mov si,6
        xor di,di
        xor cx,cx
        lodsw               ; пропустить слово
        lodsw               ; взять слово в ax
        mov bp,ax           ; скопировать его в bp
        mov dl,10h          ; заслать в dl 10h
        jmp short entryPoint
s_0146:
        shr bp,1
        dec dl
        jnz l_0151
        lodsw
        mov bp,ax
        mov dl,10h
l_0151:
        ret
l_0152:
        call s_0146         ; вызвать подпрограмку
        rcl bh,1            ; покрутим bh
        call s_0146         ; вызвать подпрограмку
        jc  l_0170          ; проверим флажок
        mov dh,2            ; dh=2
        mov cl,3            ; cl=3
l_0160:
        call s_0146         ; вызвать подпрограмку
        jc  l_016E          ; проверить флажок
        call s_0146         ; вызвать подпрограмку
        rcl bh,1            ; покрутить bh
        shl dh,1            ; сдвинуть dh
        loop l_0160         ; повторить 3 раза
l_016E:
        sub bh,dh           ; bh=bh-dh
l_0170:
        mov dh,2            ; dh=2
        mov cl,4            ; cl=4
l_0174:
        inc dh              ; dh++
        call s_0146         ; вызвать подпрограмку
        jc  l_018B          ; проверить флажок
        loop l_0174         ; повторить 4 раза
        call s_0146         ; вызвать подпрограмку
        jnc l_018F          ; проверить флажок
        inc dh              ; dh++
        call s_0146         ; вызвать подпрограмку
        jnc l_018B          ; проверить флажок
        inc dh              ; dh++
l_018B:
        mov cl,dh           ; cl=dh
        jmp short l_01B9    ; прыгнуть
l_018F:
        call s_0146         ; вызвать подпрограмку
        jc  l_01A4          ; проверить флажок
        mov cl,3            ; cl=3
        mov dh,0            ; dh=0
l_0198:
        call s_0146         ; вызвать подпрограмку
        rcl dh,1            ; покрутить dh
        loop l_0198         ; повторить 3 раза
        add dh,9            ; dh=dh+9
        jmp short l_018B    ; прыгнуть
l_01A4:
        lodsb               ; захавать байт
        mov cl,al           ; теперь это счетчик
        add cx,11h          ; cx=cx+17
        jmp short l_01B9    ; перейти на 1B9
l_01AC:
        mov cl,3            ; cl=3
l_01AE:
        call s_0146         ; вызвать подпрограмку
        rcl bh,1            ; покрутить bh
        loop l_01AE         ; повторить 3 раза
        dec bh              ; dh--
l_01B7:
        mov cl,2            ; cl=2
l_01B9:
        mov al,es:[bx+di]   ; исхитриться
        stosb               ; передать байт
        loop l_01B9         ; повторить 2 раза
entryPoint:
l_01BF:
        call s_0146         ; вызвать подпрограмку
        jnc l_01C7          ; проверить флажок
        movsb               ; передать байтик
        jmp short l_01BF    ; прыгнуть дальше
l_01C7:
        call s_0146         ; вызвать подпрограмку
        lodsb               ; схватить байт
        mov bh,0FFh         ; bh=FF
        mov bl,al           ; bl=al
        jc  l_0152          ; проверить флажок
        call s_0146         ; вызвать подпрограмку
        jc  l_01AC          ; проверить флажок
        cmp bh,bl           ; сравнить регистрики
        jne l_01B7          ; подпрыгнуть выше
        call s_0146
        jnc  endUnp
        mov cl,4
        push di
        shr di,cl
        mov ax,es
        add ax,di
        sub ah,2
        mov es,ax
        pop di
        and di,0Fh
        add di,2000h
        push si
        shr si,cl
        mov ax,ds
        add ax,si
        mov ds,ax
        pop si
        and si,0Fh
        jmp entryPoint
endUnp:
        pop es ds di si dx cx bx ax
        ret
        endp
        .data
mesNoMem        db 1,0BFh,' No enogth memory to load ',0
mesBadD         db 1,0BFh,' Read error ',0
mesNoCor        db 1,0BCh,' Incorrect ',0
end
