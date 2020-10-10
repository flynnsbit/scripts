@echo off
Echo Setting Config.SYS and Autoexec.BAT to HIMEM Settings.  Hit any key to reboot.
pause
copy config.hi config.sys
copy autoexec.hi autoexec.bat
imgset r
