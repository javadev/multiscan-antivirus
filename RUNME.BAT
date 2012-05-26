@REM Copyright (c) 1998, Written by VALENTIN KOLESNIKOV
@ECHO OFF

REM С помощью этого файла вы сможете скомпилировать
REM антивирус MultiScan

ECHO ON
tasm *.asm /m9/z
tlink @files
ucexe mscan.exe
mscan mscan.exe /v+
