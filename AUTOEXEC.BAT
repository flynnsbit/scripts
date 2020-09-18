@ECHO OFF
PROMPT $P$G
SET DIRCMD=/4
MODE CON RATE=32 DELAY=1
REM MODE CON CP PREPARE=((437)EGA.CPI)
REM MODE CON CP SELECT=437
REM KEYB US,,KEYBOARD.SYS
KILLER
DOSKEY
C:\QEMM\LOADHI /R:1 /RES=12016 /SQT=CE00-CEFF DOSLFN /Z:C:\DOS71\CP437UNI.TBL
C:\QEMM\LOADHI /R:2 MSCDEX /D:mscd001 /l:e
SHARE /L:30
REM LH NLSFUNC
C:\QEMM\LOADHI /R:0 /LO SMARTDRV
C:\QEMM\LOADHI /R:3 /LO CTMOUSE
SET BLASTER=A220 I5 D1 T4
SET PATH=c:\DOS71;c:\utils;c:\drivers;c:\vc
REM For compatiblity purpose:
CTMOUSE > NUL
ECHO.
REM For locking volumes to enable "direct disk access":
REM CALL LOCKDRV.BAT
BREAK ON
LFNFOR ON
REM cls
ECHO Now you are in MS-DOS 7.10 prompt. Type 'HELP' for help.
ECHO.
REM d:
REM runme.bat
ECHO.
ECHO Secondary VHD not mounted!
ECHO.
ECHO Please mount a games VHD to the "Mount Secondary HDD *.VHD" on your MiSTer and reset.
ECHO.
