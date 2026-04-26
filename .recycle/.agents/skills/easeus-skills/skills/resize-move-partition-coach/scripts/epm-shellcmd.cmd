@echo off
setlocal EnableExtensions DisableDelayedExpansion

if "%~1"=="" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="--help" goto :usage

set "SHELLCMD=%~1"
shift

set "SHELLPARAM_CONTENT="
:collect_args
if "%~1"=="" goto :collect_done
if defined SHELLPARAM_CONTENT (
	set "SHELLPARAM_CONTENT=%SHELLPARAM_CONTENT% %1"
) else (
	set "SHELLPARAM_CONTENT=%1"
)
shift
goto :collect_args

:collect_done
if not defined SHELLPARAM_CONTENT goto :usage_error

set "TMP_FILE=%TEMP%\epm-shellparam-%RANDOM%%RANDOM%.tmp"

where powershell >nul 2>&1
if %errorlevel%==0 (
	powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Set-Content -LiteralPath $env:TMP_FILE -Value $env:SHELLPARAM_CONTENT -NoNewline -Encoding utf8" >nul
) else (
	> "%TMP_FILE%" <nul set /p ="%SHELLPARAM_CONTENT%"
)

if not exist "%TMP_FILE%" (
	echo [ERROR] Failed to create shell parameter temp file.
	exit /b 1
)

set "EPMUI_PATH=C:\Program Files\EaseUS\EaseUS Partition Master\bin\EPMUI.exe"

echo [INFO] shellcmd=%SHELLCMD%
echo [INFO] shellparam file=%TMP_FILE%
echo [INFO] shellparam raw=%SHELLPARAM_CONTENT%

if not exist "%EPMUI_PATH%" (
	echo [ERROR] EPMUI.exe not found.
	echo Expected at:
	echo   C:\Program Files\EaseUS\EaseUS Partition Master\bin\EPMUI.exe
	exit /b 2
)

start "" "%EPMUI_PATH%" startByEpm0 "shellcmd=%SHELLCMD%" shellparam="%TMP_FILE%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
	echo [ERROR] Failed to launch EPMUI.exe. (exit code %EXIT_CODE%)
	exit /b %EXIT_CODE%
)

echo [OK] Launch request sent.
exit /b 0

:usage
echo Usage:
echo   %~nx0 "Resize Partition" C:\
echo   %~nx0 "Split Partition" D:\
echo.
echo Notes:
echo   - The first argument is mapped to shellcmd.
echo   - Remaining arguments are written into a temp file and passed as shellparam.
exit /b 0

:usage_error
echo [ERROR] Missing shell parameters.
echo.
echo Usage:
echo   %~nx0 "Resize Partition" C:\
echo   %~nx0 "Split Partition" D:\
exit /b 1
