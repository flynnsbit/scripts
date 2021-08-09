:menu
@echo off
set JCHOICE_FOOTER=Shitty 1 
cls
@echo off
type logo.ans
jchoice p s
cls





echo                    [0;1;32m
echo             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo             ?    Game Selector      ?
echo             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo                    [0;37;40m 
echo Press 1 for Doom
echo Press 2 for Doom II
echo Press 3 for Heretic
echo Press 4 to Quit

jchoice /o /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 1 set GAME=DOOM1
if errorlevel = 2 set GAME=DOOM2
if errorlevel = 3 set GAME=HERETIC
goto start


:start
set GAME=DOOM1
set jchoice_footer=Doom 1
cls
echo                    [0;1;32m
echo             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo             ?    Sound Selector     ?
echo             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo                    [0;37;40m 
echo Press 1 for SoundBlaster
echo Press 2 for Gravis Ultrasound
echo Press 3 for Sound Canvas
echo Press 4 to Quit
echo.
SET JCHOICE_FOOTER=Doom/Sound
jchoice /o /C:1234 /N Please Choose:


if errorlevel = 4 goto quit
if errorlevel = 1 set SOUND=SB
if errorlevel = 2 set SOUND=GUS
if errorlevel = 3 set SOUND=SC


cls
echo                    [0;1;32m
echo             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo             ?    Mode Selector      ?
echo             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo                    [0;37;40m 
echo Press 1 for Single Player
echo Press 2 for Multiplayer
echo Press 3 to Quit
echo.
SET JCHOICE_FOOTER=Doom/Mode
jchoice /o /C:123 /N Please Choose:

echo.

if errorlevel = 3 goto quit
if errorlevel = 1 set MODE=SINGLE
if errorlevel = 2 set MODE=MULTI


if %SOUND% == SB CONFIG -set "mididevice=default"
if %SOUND% == SC CONFIG -set "mididevice=fluidsynth"
if %SOUND% == GUS CONFIG -set "mididevice=default"
if %GAME% == DOOM1 cd DOOM
if %GAME% == DOOM2 cd DOOMII
if %GAME% == HERETIC cd Heretic
del DEFAULT.CFG
if %SOUND% == SB copy .\SB16\*.*
if %SOUND% == SC copy .\SC55\*.*

cls
echo                    [0;1;32m
echo             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo             ?     Wad Selector      ?
echo             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo                    [0;37;40m 
echo Press 1 for DOOM World's top 100 WADs
echo Press 2 for Commercial WADs
echo Press 3 for Really Shitty WADs
echo Press 4 to Quit
echo.
SET JCHOICE_FOOTER=Doom/Wad
jchoice /o /C:1234 /N Please Choose:
echo.


if errorlevel = 4 goto quit
if errorlevel = 3 goto SHIT
if errorlevel = 2 goto COMM
if errorlevel = 1 goto TOP

:TOP
cls
echo.           
echo                        [0;1;32m
echo               ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
echo               ?  -=[DOOM World's Top 100 WADs]=-   ?
echo               ?          PAGE 1 - 1994             ?
echo               ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
echo                      [0;37;40m 
echo.                   
echo Press A for Crossing Acheron
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Wad Select
jchoice /o /C:ABCDEFGHIJNQ /N Please Choose:
echo.




if errorlevel = 12 goto quit
if errorlevel = 11 goto TOP2
if errorlevel = 10 goto WAD10
if errorlevel = 9 goto WAD9
if errorlevel = 8 goto WAD8
if errorlevel = 7 goto WAD7
if errorlevel = 6 goto WAD6
if errorlevel = 5 goto WAD5
if errorlevel = 4 goto WAD4
if errorlevel = 3 goto WAD3
if errorlevel = 2 goto WAD2
if errorlevel = 1 goto WAD1

:TOP2
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 2 - 1995
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
SET JCHOICE_FOOTER=Page 2

jchoice /o /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP
if errorlevel = 11 goto TOP3
if errorlevel = 10 goto WAD20
if errorlevel = 9 goto WAD19
if errorlevel = 8 goto WAD18
if errorlevel = 7 goto WAD17
if errorlevel = 6 goto WAD16
if errorlevel = 5 goto WAD15
if errorlevel = 4 goto WAD14
if errorlevel = 3 goto WAD13
if errorlevel = 2 goto WAD12
if errorlevel = 1 goto WAD11

:TOP3
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 3 - 1996
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 3

jchoice /o /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP2
if errorlevel = 11 goto TOP4
if errorlevel = 10 goto WAD30
if errorlevel = 9 goto WAD29
if errorlevel = 8 goto WAD28
if errorlevel = 7 goto WAD27
if errorlevel = 6 goto WAD26
if errorlevel = 5 goto WAD25
if errorlevel = 4 goto WAD24
if errorlevel = 3 goto WAD23
if errorlevel = 2 goto WAD22
if errorlevel = 1 goto WAD21

:TOP4
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 4 - 1997
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 4

jchoice /o /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP3
if errorlevel = 11 goto TOP5
if errorlevel = 10 goto WAD40
if errorlevel = 9 goto WAD39
if errorlevel = 8 goto WAD38
if errorlevel = 7 goto WAD37
if errorlevel = 6 goto WAD36
if errorlevel = 5 goto WAD35
if errorlevel = 4 goto WAD34
if errorlevel = 3 goto WAD33
if errorlevel = 2 goto WAD32
if errorlevel = 1 goto WAD31

:TOP5
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 5 - 1998
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 5
jchoice /o /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP4
if errorlevel = 11 goto TOP6
if errorlevel = 10 goto WAD50
if errorlevel = 9 goto WAD49
if errorlevel = 8 goto WAD48
if errorlevel = 7 goto WAD47
if errorlevel = 6 goto WAD46
if errorlevel = 5 goto WAD45
if errorlevel = 4 goto WAD44
if errorlevel = 3 goto WAD43
if errorlevel = 2 goto WAD42
if errorlevel = 1 goto WAD41

:TOP6
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 6 - 1999
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 6
jchoice /o /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP5
if errorlevel = 11 goto TOP7
if errorlevel = 10 goto WAD60
if errorlevel = 9 goto WAD59
if errorlevel = 8 goto WAD58
if errorlevel = 7 goto WAD57
if errorlevel = 6 goto WAD56
if errorlevel = 5 goto WAD55
if errorlevel = 4 goto WAD54
if errorlevel = 3 goto WAD53
if errorlevel = 2 goto WAD52
if errorlevel = 1 goto WAD51

:TOP7
cls
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 7
jchoice /o /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP6
if errorlevel = 11 goto TOP8
if errorlevel = 10 goto WAD70
if errorlevel = 9 goto WAD69
if errorlevel = 8 goto WAD68
if errorlevel = 7 goto WAD67
if errorlevel = 6 goto WAD66
if errorlevel = 5 goto WAD65
if errorlevel = 4 goto WAD64
if errorlevel = 3 goto WAD63
if errorlevel = 2 goto WAD62
if errorlevel = 1 goto WAD61

:TOP8
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 8 - 2001
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 8
jchoice /O:4 /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP7
if errorlevel = 11 goto TOP9
if errorlevel = 10 goto WAD80
if errorlevel = 9 goto WAD79
if errorlevel = 8 goto WAD78
if errorlevel = 7 goto WAD77
if errorlevel = 6 goto WAD76
if errorlevel = 5 goto WAD75
if errorlevel = 4 goto WAD74
if errorlevel = 3 goto WAD73
if errorlevel = 2 goto WAD72
if errorlevel = 1 goto WAD71

:TOP9
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 9 - 2002
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press N for the Next Page
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 9
jchoice /O:4 /C:ABCDEFGHIJNPQ /N Please Choose:

if errorlevel = 13 goto quit
if errorlevel = 12 goto TOP8
if errorlevel = 11 goto TOP10
if errorlevel = 10 goto WAD90
if errorlevel = 9 goto WAD89
if errorlevel = 8 goto WAD88
if errorlevel = 7 goto WAD87
if errorlevel = 6 goto WAD86
if errorlevel = 5 goto WAD85
if errorlevel = 4 goto WAD84
if errorlevel = 3 goto WAD83
if errorlevel = 2 goto WAD82
if errorlevel = 1 goto WAD81

:TOP10
cls
echo.
echo            -=[DOOM World's Top 100 WADs]=-
echo                    PAGE 10 - 2003
echo.
echo Press A for 
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
echo Press P for the Previous Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Page 10
jchoice /O:4 /C:ABCDEFGHIJPQ /N Please Choose:

if errorlevel = 12 goto quit
if errorlevel = 11 goto TOP9
if errorlevel = 10 goto WAD100
if errorlevel = 9 goto WAD99
if errorlevel = 8 goto WAD98
if errorlevel = 7 goto WAD97
if errorlevel = 6 goto WAD96
if errorlevel = 5 goto WAD95
if errorlevel = 4 goto WAD94
if errorlevel = 3 goto WAD93
if errorlevel = 2 goto WAD92
if errorlevel = 1 goto WAD91

:COMM
cls
echo.
echo               -=[Commercial WADs]=-
echo.
echo Press A for Stauf's Mansion (11th Guest Bonus)
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
rem echo Press P for the Next Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Commercial
jchoice /O:3 /C:ABCDEFGHIJPQ /N Please Choose:

if errorlevel = 17 goto quit
if errorlevel = 16 goto TOP2
if errorlevel = 10 goto WAD10
if errorlevel = 9 goto WAD9
if errorlevel = 8 goto WAD8
if errorlevel = 7 goto WAD7
if errorlevel = 6 goto WAD6
if errorlevel = 5 goto WAD5
if errorlevel = 4 goto WAD4
if errorlevel = 3 goto WAD3
if errorlevel = 2 goto WAD2
if errorlevel = 1 goto STAUF

:SHIT
cls
echo.
echo                -=[Really Shitty WADs]=-
echo.
echo Why include these? Because this was more than likely what
echo people actually ended up playing.
echo.
echo Press A for Stauf's Mansion (11th Guest Bonus)
echo Press B for 
echo Press C for 
echo Press D for 
echo Press E for 
echo Press F for 
echo Press G for 
echo Press H for 
echo Press I for 
echo Press J for 
rem echo Press P for the Next Page
echo Press Q to Quit
echo.
SET JCHOICE_FOOTER=Shitty
jchoice /o:6 /C:ABCDEFGHIJPQ /N Please Choose:

if errorlevel = 17 goto quit
if errorlevel = 16 goto menu2
if errorlevel = 10 goto WAD10
if errorlevel = 9 goto WAD9
if errorlevel = 8 goto WAD8
if errorlevel = 7 goto WAD7
if errorlevel = 6 goto WAD6
if errorlevel = 5 goto WAD5
if errorlevel = 4 goto WAD4
if errorlevel = 3 goto WAD3
if errorlevel = 2 goto WAD2
if errorlevel = 1 goto STAUF

:STAUF
SET WAD=C:\COMM\STAUF.WAD
IF %MODE% == MULTI goto network
goto LAUNCH

:WAD1
SET WAD=doom -devparm -file c:\100\acheron.wad -warp 1 3 -skill 2
cls
MORE < c:\100\ACHERON.TXT
pause
IF %MODE% == MULTI goto network
goto LAUNCH

:launch
cls
if %GAME% == DOOM1 %WAD%
if %GAME% == DOOM2 DOOM2 -file %WAD%
if %GAME% == HERETIC HERETIC -file %WAD%
pause
goto quit

:network
echo name = "Enter Name Here!" > DOOMATIC.CFG
echo color = 0 >> DOOMATIC.CFG
echo autojoin = 0 >> DOOMATIC.CFG
echo alphasort = 1 >> DOOMATIC.CFG
echo usagesort = 0 >> DOOMATIC.CFG
echo maxdemo = 2048 >> DOOMATIC.CFG
echo lmpmast = 3 >> DOOMATIC.CFG
echo palette = 2 >> DOOMATIC.CFG
echo addparm = "" >> DOOMATIC.CFG
echo maxplayers = 4 >> DOOMATIC.CFG
echo localparm = "" >> DOOMATIC.CFG
echo. >> DOOMATIC.CFG
echo #WADSET >> DOOMATIC.CFG
echo desc = "-STAUF'S MANSION-" >> DOOMATIC.CFG
echo exe = "DOOM" >> DOOMATIC.CFG
echo wads = "%WAD%" >> DOOMATIC.CFG
cls
network

:quit
cls
