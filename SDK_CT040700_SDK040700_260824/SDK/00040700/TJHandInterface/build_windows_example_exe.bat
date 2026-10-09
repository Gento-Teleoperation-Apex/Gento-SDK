@echo off
REM ==========================================================================
REM  Build example_basic_hand.exe (TJHand dexterous-hand example) -- Method 2:
REM  link against the prebuilt libGentoSDK.dll in THIS folder.
REM  No SDK source compilation is needed.
REM
REM  Usage:
REM    build_windows_example.bat                 -> builds example_basic_hand
REM    build_windows_example.bat <name>          -> builds <name>.cpp
REM    build_windows_example.bat <name>.cpp      -> (.cpp optional)
REM    build_windows_example.bat all             -> builds every example_*.cpp
REM                                                 found in this folder
REM
REM  Headers:  TJHand.h comes from THIS folder, all SDK headers from ..\C_SDK.
REM  Output:   <name>.exe in this folder. libGentoSDK.dll is already next to
REM            the exe, so it can be run right away.
REM
REM  If libGentoSDK.dll is missing, run build_windows_dll.bat first.
REM  NOTE: keep this file ASCII-only, cmd.exe parses batch files in ANSI/GBK.
REM ==========================================================================
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set SDK_DIR=%SCRIPT_DIR%..\C_SDK
set EX_DIR=%SCRIPT_DIR%..\C_EXAMPLE
set DLL=%SCRIPT_DIR%libGentoSDK.dll

if not exist "%DLL%" (
    echo [FAIL] libGentoSDK.dll not found: %DLL%
    echo        Run build_windows_dll.bat first to build it.
    pause
    exit /b 1
)

REM SDK include dirs (relative to C_SDK; same set as build_windows_dll.bat).
set INC_DIRS=-I./Common -I./FXUtility -I./FXUtility/FXMath -I./FXUtility/FXCfg -I./Interf -I./Kinematics -I./Kinematics/ArmKinematics -I./Kinematics/KineCommon -I./Kinematics/MotionPlanner -I./Kinematics/SkyeBodyKinematics -I./Kinematics/LunaBodyKinematics -I./FileClient -I./L0Control -I./L1Robot -I./ToolDynaIdent
REM This folder provides TJHand.h and the dll we link against;
REM TJ_HAND_1\include provides TJHand_Types.h.
REM NOTE: SCRIPT_DIR ends with '\', so append '.' to avoid a '\"' escape
REM inside the quoted -I argument (breaks g++ argument parsing).
set HAND_DIR=%SCRIPT_DIR%.
set HAND_INC=-I"%HAND_DIR%" -I"%SCRIPT_DIR%TJ_HAND_1\include"

set TARGET=%~1
if "%TARGET%"=="" set TARGET=example_basic_hand
REM strip optional .cpp extension
if /I "!TARGET:~-4!"==".cpp" set TARGET=!TARGET:~0,-4!

if /I "%TARGET%"=="all" (
    echo Building every example_*.cpp in %SCRIPT_DIR%
    set FAIL=0
    for %%F in ("%SCRIPT_DIR%example_*.cpp") do (
        call :build_one "%%~nF" "%SCRIPT_DIR%%%~nF.cpp"
        if !ERRORLEVEL! NEQ 0 set FAIL=1
    )
    echo.
    if "!FAIL!"=="1" ( echo [DONE] Some examples FAILED. ) else ( echo [DONE] All examples built OK. )
    pause
    exit /b
)

REM resolve source: this folder first, then ..\C_EXAMPLE
set SRC=%SCRIPT_DIR%!TARGET!.cpp
if not exist "!SRC!" set SRC=%EX_DIR%\!TARGET!.cpp
call :build_one "!TARGET!" "!SRC!"
echo.
exit /b

:build_one
set NAME=%~1
set SRC=%~2
if not exist "!SRC!" (
    echo [FAIL] Not found: !SRC!
    exit /b 1
)
echo --------------------------------------------
echo Building !NAME!.cpp  ^(linked against libGentoSDK.dll^)
echo --------------------------------------------
REM -include FXCmplOpt.h : pull winsock/atomic in up front (MinGW/GCC quirk).
pushd "%SDK_DIR%"
g++ -include FXCmplOpt.h "!SRC!" %INC_DIRS% %HAND_INC% "%DLL%" -DCMPL_WIN -Wall -O2 -o "%SCRIPT_DIR%!NAME!.exe"
set RC=!ERRORLEVEL!
popd
if !RC! NEQ 0 (
    echo [FAIL] !NAME!.exe build failed ^(rc=!RC!^)
) else (
    echo [OK] !NAME!.exe    Run: "%SCRIPT_DIR%!NAME!.exe"
    echo [INFO] libGentoSDK.dll is already in this folder, next to the exe.
)
exit /b !RC!
