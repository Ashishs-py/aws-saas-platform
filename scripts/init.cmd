@echo off
REM Usage: scripts\init.cmd customer-a dev
setlocal
call "%~dp0env.cmd"
if errorlevel 1 exit /b 1
if "%~2"=="" (
  echo Usage: scripts\init.cmd ^<customer-a^|customer-b^> ^<dev^|prod^>
  exit /b 1
)
pushd "%~dp0..\stack"
terraform init -reconfigure -input=false ^
  -backend-config="bucket=%STATE_BUCKET%" ^
  -backend-config="region=%STATE_REGION%" ^
  -backend-config="key=%~1/%~2/terraform.tfstate" ^
  -backend-config="encrypt=true" ^
  -backend-config="use_lockfile=true"
popd
