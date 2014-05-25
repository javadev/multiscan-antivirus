
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; С самого начала этот модуль должен был обходить дерево катклогов, но
; тут еще подабавлялось чего-то.

public  printDisk,findIni,findRun,changePath,findPath,getDisk
public  addDirName,checkFlopy,outLab,mesLab,readLst,findNextP,allocMemAX
extrn   formDI_CX:near,setDta:near,delString:near,who:near,printPath:near
extrn   maskF:byte,path:byte,mesDisk:byte,varFiles:byte,device:byte
extrn   attrib:byte,varAll:byte,fPtr:word,fname:byte,varKeyOk:byte,varAm:byte
extrn   diskete:byte,myDta:word,openF:near,closeF:near
extrn   varBreak:byte,print0D0A:near,writeChar:near,printEng:near,pathIni:byte
extrn   segLst:word,amName:near,setPos:near,readF:near,pointLst:word
        .model small
        .code
fillMask proc
        push ax cx si di
        call formDI_CX
        mov si,di
        lea di,maskF
        cmp byte ptr [si],0
        je noFillM
        rep movsb
        mov varFiles,1
noFillM:
        pop di si cx ax
        ret
        endp
findPath proc
        push cx dx
        call setDta
        mov cx,00100111b
        lea dx,path
        mov ah,4Eh
        int 21h
        pop dx cx
        ret
        endp
addMaskAll proc
        push cx si di
        call formDI_CX
        dec si
        mov word ptr [si],'*\'
        mov word ptr [si+2],'*.'
        mov byte ptr [si+4],0
        pop di si cx
        ret
        endp
getDisk proc
        push ax
        mov ax,word ptr path
        cmp ah,':'
        je  printDiskP
        mov ah,19h
        int 21h
        add al,'A'
printDiskP:
        and al,0DFh
        mov device,al
        pop ax
        ret
        endp
printDisk proc
        push dx
        call print0D0A
        lea dx,mesDisk
        call printEng
        lea dx,pathIni
        call printPath
        call print0D0A
        pop  dx
        ret
        endp
setAlld proc
        push si
        lea si,pathIni
        cmp word ptr [si],'*'
        je  findAlld
        cmp word ptr [si],':*'
        jne find2
        call fillMask
findAlld:
        mov varAll,1
        mov word ptr [si  ],':C'
        mov byte ptr [si+2],0
        lea si,path
        mov word ptr [si  ],':C'
        mov byte ptr [si+2],0
find2:
        pop si
        ret
        endp
delSlash proc
        push cx si di
        call formDI_CX
        dec si
        dec si
        cmp byte ptr [si],'\'
        jne noDelSl
        mov byte ptr [si],0
noDelSl:
        pop di si cx
        ret
        endp
findIni proc
        push ax bx cx dx si di es
        push ss
        pop  es
        lea si,fptr
        lodsw
        mov word ptr [si-2],si
        mov word ptr [si],0
        lea si,pathIni
        cmp byte ptr [si],0
        je  goodExit
        lea di,path
        mov cx,32
        rep movsw
        call setAlld
        call delSlash
doDelSl:
        call addMaskToPath
        call findPath
        jnc goodExit
        cmp al,12h
        je  findAll
        call delTailName
        call fillMask
        call findPath
        jnc goodExit
        cmp al,12h
        stc
        jne goodExit
findAll:
        call delDirName
        call findDir
        clc
goodExit:
        pop es di si dx cx bx ax
        ret
        endp
delTailName proc
        push cx si di
        call formDI_CX
        mov byte ptr [di-1],0
        pop di si cx
        ret
        endp
findRun proc
        push ax cx dx si es
        push ss
        pop es
        cmp byte ptr pathIni,0
        jne oldFind
        call newFind
        jmp short fileFound
oldFind:
        mov si,fptr
        cmp word ptr [si],0
        je  findFile
findNextFile:
        call findNextP
        jnc fileFound
        jmp short findFistDir
findFile:
        inc word ptr [si]
        call findPath
        jnc  fileFound
        jmp short findFistDir
backDir:
        dec si
        dec si
        cmp si,offset fptr
        stc
        je fileFound
        call delDirName2
        mov fptr,si
findFistDir:
        call delDirName
        mov cx,[si]
        call findDir
        jc backDir
        dec cx
        jz changeDir
findNextDir:
        call findNextP
        jc  backDir
        test attrib,10h
        jz findNextDir
        loop findNextDir
changeDir:
        inc cx
        inc word ptr [si]
        cmp byte ptr fname,'.'
        je  findNextDir
        inc si
        inc si
        mov fptr,si
        mov word ptr [si],0
        call addDirName
        call addMaskToPath
        jmp findFile
fileFound:
        pop es si dx cx ax
        ret
        endp
addDirName proc
        push cx si di
        call formDI_CX
        lea si,fname
        mov cx,7
        rep movsw
        pop di si cx
        ret
        endp
delDirName2 proc
        call delTailName
delDirName:
        call delTailName
        call addMaskAll
        ret
        endp
addMaskToPath proc
        push cx si di
        call formDI_CX
        mov di,si
        dec si
        mov byte ptr [si],'\'
        lea si,maskF
        mov cx,7
        rep movsw
        pop di si cx
        ret
        endp
findDir proc
        push cx dx
        call setDta
        mov cx,3Fh
        lea dx,path
        mov ah,4Eh
        int 21h
        pop dx cx
        jc dirFound
checkDir:
        test attrib,10h
        jne dirFound
        call findNextP
        jnc checkDir
dirFound:
        ret
        endp
findNextP proc
        push ax
        call setDta
        mov ah,4Fh
        int 21h
        pop ax
        ret
        endp
getHD proc
        push ax bx dx
        mov bl,pathIni
        xor bh,bh
        sub bl,40h
nextHD:
        inc bx
        cmp bl,26
        cmc
        jb notFound
        mov ax,4409h
        int 21h
        jc  nextHD
        test dh,92h
        jnz nextHD
        mov ax,4408h
        int 21h
        dec ax
        jnz nextHD
        xchg ax,bx
        or al,40h
        mov pathIni,al
        clc
notFound:
        pop dx bx ax
        ret
        endp
changePath proc
        push ax si
        cmp varBreak,1
        clc
        je  exitChPath
        cmp varAll,1
        jne checkFlopy
        call getHD
        jmp short changeHD
checkFlopy:
        mov ax,word ptr path
        cmp ah,':'
        clc
        jne exitChPath
        or al,20h
        cmp al,'b'
        ja exitChPath
        mov al,varKeyOk
        mov varKeyOk,0
        lea dx,diskete
        call who
        mov varKeyOk,al
changeHD:
        pushf
        call delString
        popf
        cmc
exitChPath:
        pop si ax
        ret
        endp
outLab proc
        push ax cx dx si
        lea dx,pathL
        mov ax,word ptr path
        cmp ah,':'
        je itDis
        inc dx
        inc dx
        jmp short findLab
itDis:
        mov word ptr pathL,ax
findLab:
        push [myDta+0Fh]
        mov cx,8
        mov ah,4Eh
        int 21h
        pop [myDta+0Fh]
        jc noLab
        lea dx,mesLab
        call printEng
        lea si,fname
noPoint:
        lodsb
        cmp al,'.'
        je noPoint
        or al,al
        je endOutL
        mov dl,al
        call writeChar
        jmp noPoint
endOutL:
        call print0D0A
noLab:
        pop si dx cx ax
        ret
        endp
readLst proc
        cmp varAm,0
        stc
        je noReadL
        cmp segLst,0
        stc
        jne noReadL
        mov byte ptr pathIni,0
        push ax bx cx dx
        lea dx,amName
        call openF
        jc badOpenL
        call readMore
badOpenL:
        mov varAm,0
normOpen:
        pop dx cx bx ax
noReadL:
        ret
        endp
allocMemAX proc
        push bx
        shr ax,1
        shr ax,1
        shr ax,1
        shr ax,1
        inc ax
        xchg ax,bx
        mov ah,48h
        int 21h
        pop bx
        ret
        endp
readMore proc
        push ax bx cx dx
        mov al,2
        call setPos
        or dx,dx
        stc
        jne exitReadM
        call allocMemAX
        jc  exitReadM
        mov segLst,ax
        xor al,al
        call setPos
        mov pointLst,ax
        mov varFiles,1
        push ds
        mov ds,segLst
        xor dx,dx
        mov cx,60000
        call readF
        mov ax,ds:0
        pop ds
        mov word ptr path,ax
exitReadM:
        call closeF
        pop dx cx bx ax
        ret
        endp
newFind proc
        cmp varAm,0
        je noNew
        push ax cx si di ds
        mov si,pointLst
        mov ds,segLst
nextChar:
        lodsb
        cmp al,' '
        jbe nextChar
findIt:
        lea dx,[si-1]
        xor cx,cx
nextChar1:
        inc cx
        lodsb
        cmp al,' '
        ja nextChar1
        lea di,path
        mov si,dx
        rep movsb
        xor al,al
        stosb
        pop ds
        mov pointLst,si
        call findPath
        pop di si cx ax
noNew:
        ret
        endp
        .data
pathL           db 'X:\*.*',0
mesLab          db 1,9,'Метка диска : ',0
                db 1,9,'Volume label : ',0
                dw 0EE01h,mesLab
end
