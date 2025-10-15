@echo off
:: fixTS.bat — патч для termsrv.dll
:: Запускать от имени администратора!

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please run this script as Administrator.
    pause
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
$url = 'https://github.com/kubiksoft/tsnew/raw/refs/heads/main/termsrv.dll'; ^
$src = \"$env:TEMP\\termsrv.dll\"; ^
$dst = 'C:\Windows\System32\termsrv.dll'; ^
$bak = 'C:\Windows\System32\termsrv.dll_backup'; ^
Write-Output 'Downloading termsrv.dll...'; ^
Invoke-WebRequest -Uri $url -OutFile $src; ^
if (-Not (Test-Path $src)) { Write-Error 'Download failed.'; exit 1 }; ^
Write-Output 'Stopping TermService...'; ^
Stop-Service TermService -Force; ^
Write-Output 'Backing up original file...'; ^
Copy-Item $dst $bak -Force; ^
Write-Output 'Taking ownership...'; ^
takeown /F $dst /A; ^
icacls $dst /grant '*S-1-5-32-544:F'; ^
Write-Output 'Replacing termsrv.dll...'; ^
Copy-Item $src $dst -Force; ^
Write-Output 'Starting TermService...'; ^
Start-Service TermService; ^
Write-Output 'Done.'; ^
exit