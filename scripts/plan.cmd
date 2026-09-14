@echo off
REM Usage: scripts\plan.cmd customer-b dev
setlocal
call "%~dp0init.cmd" %1 %2
if errorlevel 1 exit /b 1
pushd "%~dp0..\stack"
terraform plan -var-file="../customers/%~1/%~2.tfvars"
popd
