@echo off
REM ==========================================================================
REM  Build libGentoSDK.dll WITH the TJHand (dexterous hand) static library
REM  compiled in -- directly from SDK sources, no manual file moves needed.
REM
REM  What it does:
REM    1. compiles all C_SDK sources + TJHand.cpp (in this folder)
REM    2. links TJ_HAND_1\lib\libTJHandLogic.a (hand protocol static library)
REM    3. outputs libGentoSDK.dll here, with all hand APIs exported
REM       (sendData / motorEnable / getFinger* / getAllHandData ...)
REM
REM  Optional usage (after the dll is built):
REM    build_windows_dll.bat example_basic_hand
REM    build_windows_dll.bat all
REM      -> additionally builds an example against the freshly built dll
REM
REM  If TJHand.cpp or TJ_HAND_1\lib\libTJHandLogic.a is missing, falls back
REM  to a plain libGentoSDK.dll build without hand support.
REM  NOTE: keep this file ASCII-only, cmd.exe parses batch files in ANSI/GBK.
REM ==========================================================================
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set SDK_DIR=%SCRIPT_DIR%..\C_SDK
set EX_DIR=%SCRIPT_DIR%..\C_EXAMPLE
set DLL_DIR=%SCRIPT_DIR%..\C_EXAMPLE_USE_DLL_SO
set HAND_INC_DIR=%SCRIPT_DIR%TJ_HAND_1\include
set HAND_LIB_DIR=%SCRIPT_DIR%TJ_HAND_1\lib
set HAND_SRC=%SCRIPT_DIR%TJHand.cpp
set HAND_LIB=%HAND_LIB_DIR%\libTJHandLogic.a

REM SDK include dirs (relative to C_SDK; same set as ..\win_auto_compile.bat).
set INC_DIRS=-I./Common -I./FXUtility -I./FXUtility/FXMath -I./FXUtility/FXCfg -I./Interf -I./Kinematics -I./Kinematics/ArmKinematics -I./Kinematics/KineCommon -I./Kinematics/MotionPlanner -I./Kinematics/SkyeBodyKinematics -I./Kinematics/LunaBodyKinematics -I./FileClient -I./L0Control -I./L1Robot -I./ToolDynaIdent -I"%HAND_INC_DIR%"

REM SDK sources (relative to C_SDK).
set SDK_CPP=./L0Control/*.cpp ./FileClient/*.cpp ./L1Robot/*.cpp ./FXUtility/FXMath/*.cpp ./FXUtility/FXCfg/*.cpp ./Interf/*.cpp ./ToolDynaIdent/*.cpp ./Kinematics/*.cpp ./Kinematics/LunaBodyKinematics/*.cpp ./Kinematics/ArmKinematics/*.cpp ./Kinematics/KineCommon/*.cpp ./Kinematics/MotionPlanner/*.cpp ./Kinematics/SkyeBodyKinematics/*.cpp

REM ---- hand support check --------------------------------------------------
set HAND_LINK=
set HAND_ARGS=
if exist "%HAND_LIB%" (
    echo [INFO] Found TJHand static library: %HAND_LIB%
    set HAND_LINK=%HAND_LIB%
    if exist "%HAND_SRC%" (
        echo [INFO] Hand source  : %HAND_SRC%
        set HAND_ARGS=%HAND_SRC%
    ) else (
        echo [WARN] TJHand.cpp not found: %HAND_SRC%
        echo        Building without hand API export...
    )
) else (
    echo [WARN] TJHand library not found at %HAND_LIB%
    echo        Building libGentoSDK.dll without hand support...
)

echo ============================================
echo [1/2] Building libGentoSDK.dll with hand support
echo ============================================
pushd "%SDK_DIR%"
g++ %SDK_CPP% !HAND_ARGS! %INC_DIRS% -Wall -O2 -shared -o "%SCRIPT_DIR%libGentoSDK.dll" -DL1_SDK_EXPORTS -DCMPL_WIN -lws2_32 -lwinmm !HAND_LINK!
set RC=!ERRORLEVEL!
popd
if !RC! NEQ 0 (
    echo [FAIL] libGentoSDK.dll build failed ^(rc=!RC!^)
    pause
    exit /b 1
)
echo [OK] libGentoSDK.dll built at %SCRIPT_DIR%libGentoSDK.dll

REM ---- deploy like win_auto_compile.bat does -------------------------------
echo ============================================
echo Deploying dll to target folders...
echo ============================================
copy /Y "%SCRIPT_DIR%libGentoSDK.dll" "%DLL_DIR%\" >nul && echo [OK] copied to C_EXAMPLE_USE_DLL_SO\

REM ---- optional: also build one example against the fresh dll --------------
set TARGET=%~1
if "%TARGET%"=="" (
    echo.
    echo ============================================
    echo All done! libGentoSDK.dll now includes the hand APIs.
    echo To build an example against it:
    echo   build_windows_dll.bat example_basic_hand
    echo   build_windows_dll.bat all
    echo ============================================
    exit /b 0
)
if /I "!TARGET:~-4!"==".cpp" set TARGET=!TARGET:~0,-4!

if /I "%TARGET%"=="all" (
    echo Building every example_*.cpp from %EX_DIR%
    set FAIL=0
    for %%F in ("%EX_DIR%\example_*.cpp") do (
        call :build_one "%%~nF" "%EX_DIR%\%%~nF.cpp"
        if !ERRORLEVEL! NEQ 0 set FAIL=1
    )
    echo.
    if "!FAIL!"=="1" ( echo [DONE] Some examples FAILED. ) else ( echo [DONE] All examples built OK. )
    exit /b
)

REM resolve source: this folder first, then ..\C_EXAMPLE
set SRC=%SCRIPT_DIR%!TARGET!.cpp
if not exist "!SRC!" set SRC=%EX_DIR%\!TARGET!.cpp
call :build_one "!TARGET!" "!SRC!"
exit /b

:build_one
set NAME=%~1
set SRC=%~2
if not exist "!SRC!" (
    echo [FAIL] Not found: !SRC!
    exit /b 1
)
echo --------------------------------------------
echo Building !NAME!.cpp against the fresh dll
echo --------------------------------------------
REM -include FXCmplOpt.h : pull winsock/atomic in up front (MinGW/GCC quirk).
pushd "%SDK_DIR%"
g++ -include FXCmplOpt.h "!SRC!" %INC_DIRS% "%SCRIPT_DIR%libGentoSDK.dll" -DCMPL_WIN -Wall -O2 -o "%SCRIPT_DIR%!NAME!.exe"
set RC=!ERRORLEVEL!
popd
if !RC! NEQ 0 (
    echo [FAIL] !NAME!.exe build failed ^(rc=!RC!^)
) else (
    echo [OK] !NAME!.exe    Run: "%SCRIPT_DIR%!NAME!.exe"
    echo [INFO] Copy libGentoSDK.dll next to the exe before running it.
)
exit /b !RC!
