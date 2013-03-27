@echo off
set binpath=c:\emacs\bin
if "%~1"=="" (
  set filename=c:\
) else (
  set filename=%~1
)
"%binpath%\emacsclientw.exe" --no-wait --alternate-editor="%binpath%\runemacs.exe" "%filename%"