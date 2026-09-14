@echo off
REM Usage: scripts\destroy.cmd customer-a dev
REM Run this the moment the demo is over. This is what keeps the bill at zero.
setlocal
call "%~dp0init.cmd" %1 %2
if errorlevel 1 exit /b 1
pushd "%~dp0..\stack"
terraform destroy -var-file="../customers/%~1/%~2.tfvars"
popd
echo.
echo Now run: scripts\whats-running.cmd %STATE_REGION%
