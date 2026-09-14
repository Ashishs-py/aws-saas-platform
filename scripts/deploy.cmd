@echo off
REM Usage: scripts\deploy.cmd customer-a dev
setlocal
call "%~dp0init.cmd" %1 %2
if errorlevel 1 exit /b 1
pushd "%~dp0..\stack"
terraform apply -var-file="../customers/%~1/%~2.tfvars"
echo.
echo ================== APPLICATION URL ==================
terraform output application_url
echo =====================================================
popd
