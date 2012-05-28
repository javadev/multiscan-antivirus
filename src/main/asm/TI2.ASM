
; Copyright (c) 1998, Written by VALENTIN KOLESNIKOV, Kiev, Ukraine.
; éÁ•≠Ï ¢•·•´Î© ¨Æ§„´Ï - Ø•‡•¢Æ‡†Á®¢†•‚ Ì™‡†≠.

video_mode      equ     49h
video_columns   equ     4Ah
video_segment   equ     4Eh
video_page      equ     62h
video_rows      equ     84h
video_pixels    equ     85h
video_options   equ     87h
PSP_envirn_seg  equ     2Ch
data_0050_e     equ     50h
data_0060_e     equ     60h
data_0080_e     equ     80h
data_0088_e     equ     88h
d_A000_0000_e   equ     0

public          install
extrn           varSM:byte
        .model small
        .code
off8            equ     word ptr $
seg8            equ     word ptr $+2
                jmp     install
                db      00
off10           dw      00
seg10           dw      3FE6h
var_0108        dw      00
var_010A        db      01

int_08h_entry   proc    far
var_010C        equ     byte ptr $+1
                jmp     short $+2
                dec     word ptr cs:[var_0108]
                cmp     word ptr cs:[var_0108],0FFFFh
                jne     loc_0144
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                mov     al,offset jumpInt8-var_010C-1
                mov     byte ptr cs:[var_010C],al
                mov     ax,40h
                mov     ds,ax
                push    ds
                call    invertScreen
                pop     ds
                mov     ah,3
                mov     bh,ds:video_page
                int     10h                     ; Video display   ah=functn 03h
                                                ;  get cursor loc in dx, mode cx
                mov     ah,2
                int     10h                     ; Video display   ah=functn 02h
                                                ;  set cursor location in dx
                mov     ah,1
                int     10h                     ; Video display   ah=functn 01h
                                                ;  set cursor mode in cx
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
loc_0144:
                jmp     dword ptr cs:[off8]
jumpInt8:
                pushf
                call    dword ptr cs:[off8]
                push    ds
                push    ax
                mov     ax,40h
                mov     ds,ax
                cmp     byte ptr ds:video_mode,3
                ja      loc_01AA
                dec     byte ptr cs:[var_010A]
                jnz     loc_01AA
                cli
                mov     byte ptr cs:[var_010A],1
                push    cx
                push    dx
                push    si
                push    di
                mov     si,ds:video_segment
                mov     ax,ds:video_columns
                mov     cl,ds:video_rows
                inc     cl
                mul     cl
                mov     cx,ax
                shl     ax,1
                add     ax,3FFEh
                mov     di,ax
                mov     ax,0B800h
                mov     ds,ax
                mov     dx,3D4h
                mov     al,0Ch
                out     dx,al                   ; port 3D4h, CGA/EGA reg index
                                                ;  al = 0Ch, start address high
                inc     dx
                mov     al,20h                  ; ' '
                out     dx,al                   ; port 3D5h, CGA/EGA indxd data
                dec     dx
                mov     al,0Dh
                out     dx,al                   ; port 3D4h, CGA/EGA reg index
                                                ;  al = 0Dh, start address low
                inc     dx
                mov     al,0
                out     dx,al                   ; port 3D5h, CGA/EGA indxd data
                cld

locloop_019F:
                lodsw
                mov     [di],ax
                dec     di
                dec     di
                loop    locloop_019F

                pop     di
                pop     si
                pop     dx
                pop     cx
loc_01AA:
                pop     ax
                pop     ds
                iret
int_08h_entry   endp

int_10h_entry   proc    far
                cmp     ax,0BB02h
                jne     loc_01BD
                push    cs
                pop     es
                mov     ax,2020h
                mov     bx,word ptr cs:[var_0108]
                iret
int_10h_entry   endp

loc_01BD:
                cmp     word ptr cs:[var_0108],0FFFFh
                je      loc_01CA
                jmp     dword ptr cs:[off10]
loc_01CA:
                push    ax
                push    bx
                push    cx
                push    dx
                pushf
                call    dword ptr cs:[off10]
                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    bp
                mov     bp,sp
                mov     ax,40h
                mov     ds,ax
                cmp     byte ptr ds:video_mode,3
                ja      loc_01F9
                mov     ax,[bp+14h]
                or      ah,ah
                jnz     loc_0208
                and     al,7Fh
                cmp     al,3
                ja      loc_01F9
loc_01F6:
                call    invertScreen
loc_01F9:
                pop     bp
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf
                cli
                add     sp,8
                sti
                retf    2
loc_0208:
                cmp     ah,1
                jne     loc_0212
                call    setNewCursor
                jmp     short loc_01F9
loc_0212:
                cmp     ah,2
                jne     loc_022E
                mov     bx,[bp+12h]
                cmp     bh,ds:video_page
                jne     loc_01F9
                mov     dx,[bp+0Eh]
                cmp     dh,ds:video_rows
                ja      loc_01F9
                call    sub_02DD
                jmp     short loc_01F9
loc_022E:
                cmp     ah,5
                jne     loc_0238
                call    sub_02D1
                jmp     short loc_01F9
loc_0238:
                cmp     ah,11h
                jne     loc_01F9
                and     al,0EFh
                cmp     al,4
                jne     loc_024A
                mov     al,10h
loc_0245:
                mov     ds:video_pixels,al
                jmp     short loc_01F6
loc_024A:
                cmp     al,2
                ja      loc_01F9
                cmp     al,1
                jb      loc_025A
                mov     al,0Eh
                jz      loc_0245
                mov     al,8
                jmp     short loc_0245
loc_025A:
                mov     ax,[bp+12h]
                mov     ds:video_pixels,ah
                mov     ax,1F9h
                push    ax
                push    si
                call    outTab1toPort
                mov     ah,[bp+12h]
                and     ax,300h
                mov     cl,6
                shl     ax,cl
                add     ax,[bp+0Eh]
                mov     si,ax
                mov     cx,[bp+10h]
                jmp     short loc_0287

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

invertScreen    proc    near
                push    si
                call    outTab1toPort
                mov     cx,100h
                mov     si,d_A000_0000_e
loc_0287:
                mov     dx,ds:video_pixels
                dec     dx
                mov     ax,0A000h
                mov     ds,ax

locloop_0291:
                push    si
                mov     bx,si
                add     bx,dx
loc_0296:
                mov     al,[si]
                mov     ah,[bx]
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                rcl     ah,1
                rcr     al,1
                mov     [si],al
                mov     [bx],ah
                inc     si
                dec     bx
                cmp     si,bx
                jbe     loc_0296
                pop     si
                add     si,20h
                loop    locloop_0291

                call    outTabToPort
                pop     si
                retn
invertScreen    endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_02D1        proc    near
                mov     al,ds:video_page
                shl     al,1
                cbw
                mov     bx,ax
                mov     dx,ds:data_0050_e[bx]

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_02DD:
                mov     ah,ds:video_rows
                mov     al,ds:video_columns
                dec     al
                sub     ax,dx
                mov     cl,al
                mov     al,ah
                mul     byte ptr ds:video_columns
                mov     ch,0
                add     cx,ax
                add     cx,2000h
                mov     bx,0E0Fh

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

setUpPort:
loc_02FB:
                mov     dx,3D4h
                mov     al,bh
                out     dx,al                   ; port 3D4h, CGA/EGA reg index
                                                ;  al = 0Ah, cursor start, mode
                inc     dx
                mov     al,ch
                out     dx,al                   ; port 3D5h, CGA/EGA indxd data
                dec     dx
                mov     al,bl
                out     dx,al                   ; port 3D4h, CGA/EGA reg index
                                                ;  al = 0Bh, cursor end
                inc     dx
                mov     al,cl
                out     dx,al                   ; port 3D5h, CGA/EGA indxd data

loc_ret_030D:
                retn
sub_02D1        endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

setNewCursor    proc    near
                mov     ax,ds:data_0060_e
                and     ah,60h                  ; '`'
                cmp     ah,20h                  ; ' '
                je      loc_ret_030D
                call    sub_0332
                call    sub_0324
                mov     bx,0A0Bh
                jmp     short loc_02FB
setNewCursor    endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0324        proc    near
                mov     al,ds:video_pixels
                dec     al
                mov     ah,al
                sub     ax,cx
                xchg    al,ah
                mov     cx,ax
                retn
sub_0324        endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0332        proc    near
                test    byte ptr ds:video_options,1
                jnz     loc_ret_037D
                mov     al,ds:data_0088_e
                and     al,0Fh
                cmp     al,9
                jne     loc_0368
                cmp     byte ptr ds:video_mode,3
                ja      loc_0368
                mov     ah,ds:video_pixels
                sub     ah,5
                cmp     ch,ah
                jg      loc_035C
                cmp     ch,5
                jb      loc_035C
                add     ch,5
loc_035C:
                cmp     cl,ah
                jg      loc_0368
                cmp     cl,5
                jb      loc_0368
                add     cl,5
loc_0368:
                inc     cl
                cmp     ch,0
                je      loc_0377
                cmp     cl,ds:video_pixels
                jb      loc_0377
                xor     cl,cl
loc_0377:
                cmp     cl,ch
                jne     loc_ret_037D
                inc     cl

loc_ret_037D:
                retn
sub_0332        endp

portTable1      db      02, 04, 04, 07, 05, 00, 06, 04, 04, 02
portTable2      db      02, 03, 04, 03, 05, 10h,06, 0Eh,04, 00

outTab1toPort:
                lea     si,portTable1
                jmp     short loc_039A

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

outTabToPort    proc    near
                lea     si,portTable2
loc_039A:
                mov     cx,2
                mov     dx,3C4h
                call    outToPort
                mov     cl,3
                mov     dl,0CEh

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

outToPort:

locloop_03A7:
                mov     al,cs:[si]
                inc     si
                out     dx,al                   ; port 3C4h, EGA sequencr index
                                                ;  al = 2, map mask register
                inc     dx
                mov     al,cs:[si]
                inc     si
                out     dx,al                   ; port 3C5h, EGA sequencr func
                dec     dx
                loop    locloop_03A7

                retn
outTabToPort    endp

install proc
                cmp     varSM,0
                je      noActive
                push    ax bx cx dx ds es
                push    cs
                pop     ds
                call    checkAdap
                jz      adapterOk
endInst:
                pop     es ds dx cx bx ax
noActive:
                ret
                endp
adapterOk:
                mov     ax,0BB02h
                int     10h                     ; ??int non-standard interrupt
                cmp     ax,2020h
                jne     installFirst
                lds     dx,dword ptr cs:[off8]
                mov     ax,2508h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                lds     dx,dword ptr cs:[off10]
                mov     ax,2510h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                cmp     bx,0FFFFh
                jnz     noInvertScreen
                mov     ax,40h
                mov     ds,ax
                mov     cx,ds:video_segment
                shr     cx,1
                mov     bx,0C0Dh
                call    setUpPort
                call    invertScreen
noInvertScreen:
                jmp     endInst
installFirst:
                call    scanComStr
                mov     ax,3508h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     word ptr cs:[seg8],es
                mov     word ptr cs:[off8],bx
                mov     ax,3510h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     word ptr cs:[seg10],es
                mov     word ptr cs:[off10],bx
                mov     ax,2508h
                mov     dx,offset int_08h_entry
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                mov     ax,2510h
                mov     dx,offset int_10h_entry
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     endInst

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

checkAdap       proc    near
                push    ds
                mov     ax,40h
                mov     ds,ax
                mov     dl,ds:video_options
                mov     dh,ds:video_mode
                pop     ds
                mov     ax,1A00h
                int     10h                     ; Video display   ah=functn 1Ah
                                                ;  get display type in bx
                cmp     al,1Ah
                jne     loc_0487
                cmp     bl,7
                je      loc_049C
                cmp     bl,8
                je      loc_049C
loc_0487:
                mov     ah,12h
                mov     bl,10h
                int     10h                     ; Video display   ah=functn 12h
                                                ;  EGA/VGA special, bl=function
                cmp     bl,10h
                jne     loc_0497
loc_0492:
                xor     al,al
                inc     al
                retn
loc_0497:
                test    dl,8
                jnz     loc_0492
loc_049C:
                cmp     dh,3
                ja      loc_0492
                cmp     al,al
                retn
checkAdap       endp

scanComStr      proc    near
                xor     bx,bx
                xor     cx,cx
loc_04D4:
                mov     ax,3Ch
                mul     cx
                add     ax,bx
                mov     bx,91
                mul     bx
                mov     bx,5
                div     bx
                mov     word ptr cs:[var_0108],ax
                mov     byte ptr cs:[var_010C],0
                retn
scanComStr      endp
                end
