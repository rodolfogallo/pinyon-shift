@echo off
setlocal
cd /d "%~dp0"

echo ============================================================
echo  Forza Horizon Recomp Integrado - Pinyon Shift / ReXGlue 0.10
echo ============================================================
echo.

if not exist "out\build\win-amd64-release\pinyon_shift.exe" (
  echo ERRO: a build integrada ainda nao existe.
  echo Execute tools\build-preview.ps1 antes de testar.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\tools\launch-preview.ps1" -StateRoot ".\.local\preview"
set "RUN_EXIT=%ERRORLEVEL%"

echo.
if not "%RUN_EXIT%"=="0" (
  echo O jogo terminou com erro. O bundle e os logs foram gerados em:
  echo   %~dp0.local\preview\reports
  echo   %~dp0.local\preview\logs
) else (
  echo O jogo foi fechado normalmente.
  echo Log da execucao:
  echo   %~dp0.local\preview\logs\runtime.log
)
echo.
pause
exit /b %RUN_EXIT%
