@echo off
setlocal
rem Prepara git, Backlog.md e le cartelle del flusso in un progetto che contiene gia i file del blueprint.
rem Uso: scripts\setup.bat [nome-progetto] [--installa-backlog]

set "NOME="
set "INSTALLA=0"

:args
if "%~1"=="" goto fineargs
if /I "%~1"=="--installa-backlog" goto arg_installa
if /I "%~1"=="-h" goto uso
if /I "%~1"=="--help" goto uso
set "NOME=%~1"
shift
goto args

:arg_installa
set "INSTALLA=1"
shift
goto args

:uso
echo Uso: scripts\setup.bat [nome-progetto] [--installa-backlog]
exit /b 0

:fineargs
if "%NOME%"=="" for %%I in ("%CD%") do set "NOME=%%~nxI"

echo == Setup flusso spec-driven: %NOME% ==

rem 1. Git
git --version >nul 2>&1
if errorlevel 1 goto manca_git
git rev-parse --is-inside-work-tree >nul 2>&1
if not errorlevel 1 goto git_ok
echo - Repository git non trovato: eseguo git init
git init -q
:git_ok

rem 2. Backlog.md
where backlog >nul 2>&1
if not errorlevel 1 goto backlog_ok
if "%INSTALLA%"=="1" goto installa_backlog
echo ERRORE: CLI 'backlog' non trovata.
echo Installala con: npm install -g backlog.md   oppure rilancia con --installa-backlog
exit /b 1

:installa_backlog
where npm >nul 2>&1
if errorlevel 1 goto manca_npm
call npm install -g backlog.md
if errorlevel 1 exit /b 1
where backlog >nul 2>&1
if errorlevel 1 goto riapri_terminale

:backlog_ok
if exist backlog\config.yml goto init_ok
echo - Inizializzo Backlog.md.
echo   Se chiede di creare o modificare file di istruzioni per agenti, rispondi NO:
echo   le istruzioni sono gia in CLAUDE.md e .claude\
call backlog init "%NOME%"
if errorlevel 1 exit /b 1
:init_ok

rem 3. Stati della board: aggiunge 'Verify' e 'Change Review' (UTF-8 senza BOM)
powershell -NoProfile -Command "$f=(Resolve-Path 'backlog\config.yml').Path; $q=[char]34; $n='statuses: ['+$q+'To Do'+$q+', '+$q+'In Progress'+$q+', '+$q+'Verify'+$q+', '+$q+'Change Review'+$q+', '+$q+'Done'+$q+']'; $c=@(Get-Content -LiteralPath $f); if ($c -match '^statuses:') { $c = $c -replace '^statuses:.*', $n } else { $c += $n }; [System.IO.File]::WriteAllLines($f, $c)"
if errorlevel 1 goto errore_stati
echo - Stati della board: To Do, In Progress, Verify, Change Review, Done

rem 4. Cartelle della documentazione
if not exist docs\changes mkdir docs\changes
if not exist docs\adr mkdir docs\adr
if not exist docs\changes\.gitkeep type nul > docs\changes\.gitkeep
if not exist docs\adr\.gitkeep type nul > docs\adr\.gitkeep

echo == Fatto ==
echo Prossimo passo: apri Claude Code in questa cartella ed esegui /setup-progetto
exit /b 0

:manca_git
echo ERRORE: git non trovato. Installa Git for Windows e riprova.
exit /b 1

:manca_npm
echo ERRORE: npm non trovato. Installa Node.js e riprova.
exit /b 1

:riapri_terminale
echo Backlog.md installato, ma 'backlog' non e ancora nel PATH di questo terminale.
echo Chiudi e riapri il terminale, poi rilancia scripts\setup.bat
exit /b 1

:errore_stati
echo ERRORE: impossibile aggiornare gli stati in backlog\config.yml
exit /b 1
