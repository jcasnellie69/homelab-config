@echo off
setlocal EnableExtensions

set "DEST_ARG=%~1"
for /f "tokens=1* delims==" %%A in ("%DEST_ARG%") do if /I "%%~A"=="dest" set "DEST_ARG=%%~B"
if "%DEST_ARG%"=="" set "DEST_ARG=test"

set "DEST_DIR=%TEMP%\EuUpdater_EPM"
set "DEST_PATH=%DEST_DIR%\epm_free_setup.exe"

if not exist "%DEST_DIR%" (
  mkdir "%DEST_DIR%"
)

echo [1/2] Downloading installer...
where curl >nul 2>&1
if %errorlevel%==0 (
  set "USE_CURL=1"
) else (
  set "USE_CURL=0"
)

for %%H in (d1 d2 d3) do (
  if exist "%DEST_PATH%" del /f /q "%DEST_PATH%" >nul 2>&1
  echo Trying mirror %%H...
  if "%USE_CURL%"=="1" (
    curl -fL --retry 3 --retry-delay 2 -o "%DEST_PATH%" "https://%%H.easeus.com/epm/free/epm_free_ob.exe?source=skills&dest=%DEST_ARG%"
  ) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://%%H.easeus.com/epm/free/epm_free_ob.exe?source=skills&dest=%DEST_ARG%' -OutFile '%DEST_PATH%'"
  )

  if not errorlevel 1 if exist "%DEST_PATH%" goto :download_ok
)

echo Download failed from all mirrors.
exit /b 1

:download_ok

if not exist "%DEST_PATH%" (
  echo Installer was not found: "%DEST_PATH%"
  exit /b 1
)

echo [2/2] Running silent install...
start "" /wait "%DEST_PATH%" /verysilent /suppressmsgboxes /norestart /log
set "INSTALL_EXIT_CODE=%errorlevel%"

if not "%INSTALL_EXIT_CODE%"=="0" (
  echo Installer exited with code %INSTALL_EXIT_CODE%.
) else (
  echo Installation completed.
)

exit /b %INSTALL_EXIT_CODE%
