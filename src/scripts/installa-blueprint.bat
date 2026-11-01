@echo off
setlocal
rem Copia il blueprint in una cartella di progetto, senza sovrascrivere nulla di esistente.
rem Uso: scripts\installa-blueprint.bat <cartella-progetto>

if "%~1"=="" goto uso

set "SRC=%~dp0.."
for %%I in ("%SRC%") do set "SRC=%%~fI"
if not exist "%~1" mkdir "%~1"
for %%I in ("%~1") do set "DEST=%%~fI"

rem CLAUDE.md: se esiste gia, non lo tocca
if not exist "%DEST%\CLAUDE.md" goto claude_nuovo
fc /b "%SRC%\CLAUDE.md" "%DEST%\CLAUDE.md" >nul 2>&1
if not errorlevel 1 goto claude_identico
copy /y "%SRC%\CLAUDE.md" "%DEST%\CLAUDE.blueprint.md" >nul
echo ! CLAUDE.md esiste gia: copiato come CLAUDE.blueprint.md, da unire a mano
goto claude_fine
:claude_identico
echo - CLAUDE.md gia presente e identico al blueprint
goto claude_fine
:claude_nuovo
call :copia "%SRC%\CLAUDE.md" "%DEST%\CLAUDE.md"
:claude_fine

call :copia "%SRC%\.claude\workflow.yml" "%DEST%\.claude\workflow.yml"
call :albero "%SRC%\.claude\skills" "%DEST%\.claude\skills"
if errorlevel 1 exit /b 1
call :albero "%SRC%\.claude\agents" "%DEST%\.claude\agents"
if errorlevel 1 exit /b 1
call :albero "%SRC%\docs\_templates" "%DEST%\docs\_templates"
if errorlevel 1 exit /b 1
call :copia "%SRC%\scripts\setup.sh" "%DEST%\scripts\setup.sh"
call :copia "%SRC%\scripts\setup.bat" "%DEST%\scripts\setup.bat"
call :copia "%SRC%\README.md" "%DEST%\docs\MANUALE-WORKFLOW.md"

echo.
echo Blueprint installato in: %DEST%
echo Passi successivi:
echo   1. cd /d "%DEST%"
echo      scripts\setup.bat "nome-progetto" --installa-backlog
echo      (senza il flag se backlog e gia installato)
echo   2. Apri Claude Code nella cartella ed esegui /setup-progetto
echo   Manuale: docs\MANUALE-WORKFLOW.md
exit /b 0

:uso
echo Uso: scripts\installa-blueprint.bat cartella-progetto
exit /b 1

:copia
rem %1 = sorgente, %2 = destinazione (non sovrascrive)
if exist "%~2" goto copia_esiste
if not exist "%~dp2" mkdir "%~dp2"
copy "%~1" "%~2" >nul
echo + %~2
goto :eof
:copia_esiste
echo - esiste gia, non sovrascrivo: %~2
goto :eof

:albero
rem %1 = cartella sorgente, %2 = cartella destinazione (i file esistenti non vengono toccati)
robocopy "%~1" "%~2" /E /XC /XN /XO /NJH /NJS /NP /NFL /NDL >nul
if %errorlevel% GEQ 8 goto albero_errore
echo + %~2  (file esistenti non sovrascritti)
exit /b 0
:albero_errore
echo ERRORE durante la copia di %~1
exit /b 1
