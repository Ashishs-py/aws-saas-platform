@echo off
REM ===================================================================
REM  Edit these two values ONCE, after you run the bootstrap step.
REM  They come from the bootstrap outputs: state_bucket / state_region
REM ===================================================================

set STATE_BUCKET=ashish-platform-tfstate-176150914805-eu-west-2
set STATE_REGION=eu-west-2

if "%STATE_BUCKET%"=="PUT-YOUR-STATE-BUCKET-NAME-HERE" (
  echo.
  echo  ERROR: open scripts\env.cmd and set STATE_BUCKET first.
  echo.
  exit /b 1
)
