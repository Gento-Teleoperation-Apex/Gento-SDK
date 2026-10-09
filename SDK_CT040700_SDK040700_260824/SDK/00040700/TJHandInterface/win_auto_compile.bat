@echo off
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
REM SDK and output folders are siblings of this TJHandInterface folder.
set SDK_DIR=%SCRIPT_DIR%..\C_SDK
set PYTHON_DIR=%SCRIPT_DIR%..\PYTHON_SDK
set C_DLL_DIR=%SCRIPT_DIR%..\C_EXAMPLE_USE_DLL_SO
set HAND_LIB_DIR=%SCRIPT_DIR%TJ_HAND_1\lib

REM TJHand sources live in this folder; no need to copy them into C_SDK\L1Robot.
REM They are appended to the SDK sources below so the hand API is exported
REM directly from the generated libGentoSDK.dll / libGentoSDKPY.dll.
set HAND_SRC=%SCRIPT_DIR%TJHand.cpp
set HAND_INC_DIR=%SCRIPT_DIR%TJ_HAND_1\include

set CPP_FILES=./L0Control/*.cpp ./FileClient/*.cpp ./L1Robot/*.cpp ./FXUtility/FXMath/*.cpp ./FXUtility/FXCfg/*.cpp ./Interf/*.cpp ./ToolDynaIdent/*.cpp ./Kinematics/*.cpp ./Kinematics/LunaBodyKinematics/*.cpp ./Kinematics/ArmKinematics/*.cpp ./Kinematics/KineCommon/*.cpp ./Kinematics/MotionPlanner/*.cpp ./Kinematics/SkyeBodyKinematics/*.cpp

set INC_DIRS=-I./Common -I./FXUtility/ -I./FXUtility/FXMath -I./FXUtility/FXCfg -I./Interf -I./ToolDynaIdent -I./Kinematics -I./Kinematics/LunaBodyKinematics -I./Kinematics/ArmKinematics -I./Kinematics/KineCommon -I./Kinematics/MotionPlanner -I./Kinematics/SkyeBodyKinematics -I./FileClient -I./L0Control -I./L1Robot -I"%HAND_INC_DIR%"

set HAND_LIB=%HAND_LIB_DIR%\libTJHandLogic.a

cd /d "%SDK_DIR%"

echo ============================================
echo [1/3] Building libGentoSDKPY.dll (Python)
echo ============================================
set HAND_ARGS=
if exist "%HAND_LIB%" (
    echo Linking with TJHand static library...
    set HAND_LINK=%HAND_LIB%
) else (
    echo [WARN] TJHand library not found at %HAND_LIB%
    echo        Building without hand support...
    set HAND_LINK=
)
if exist "%HAND_SRC%" (
    if exist "%HAND_LIB%" (
        set HAND_ARGS=%HAND_SRC%
    )
)
g++ %CPP_FILES% !HAND_ARGS! %INC_DIRS% -Wall -O2 -shared -o libGentoSDKPY.dll -DL1_SDK_EXPORTS -DCMPL_WIN -static -static-libgcc -static-libstdc++ -lws2_32 -lwinmm !HAND_LINK!
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] libGentoSDKPY.dll build failed!
    pause
    exit /b 1
)
echo [OK] libGentoSDKPY.dll built.

echo.
echo ============================================
echo [2/3] Building libGentoSDK.dll (C/C++ link)
echo ============================================
if exist "%HAND_LIB%" (
    echo Linking with TJHand static library...
    set HAND_LINK=%HAND_LIB%
) else (
    set HAND_LINK=
)
g++ %CPP_FILES% !HAND_ARGS! %INC_DIRS% -Wall -O2 -shared -o libGentoSDK.dll -DL1_SDK_EXPORTS -DCMPL_WIN -lws2_32 -lwinmm !HAND_LINK!
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] libGentoSDK.dll build failed!
    pause
    exit /b 1
)
echo [OK] libGentoSDK.dll built.

cd /d "%SCRIPT_DIR%"

echo.
echo ============================================
echo [3/3] Copying DLLs to target folders...
echo ============================================

if not exist "%SDK_DIR%\libGentoSDKPY.dll" (
    echo [FAIL] Source file not found: %SDK_DIR%\libGentoSDKPY.dll
    pause
    exit /b 1
)
copy /Y "%SDK_DIR%\libGentoSDKPY.dll" "%PYTHON_DIR%\"
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Copy libGentoSDKPY.dll failed!
    pause
    exit /b 1
)
echo [OK] libGentoSDKPY.dll copied to PYTHON_SDK\
copy /Y "%SDK_DIR%\libGentoSDKPY.dll" "%SCRIPT_DIR%\" >nul
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Copy libGentoSDKPY.dll to TJHandInterface failed!
    pause
    exit /b 1
)
echo [OK] libGentoSDKPY.dll copied to TJHandInterface\

if not exist "%SDK_DIR%\libGentoSDK.dll" (
    echo [FAIL] Source file not found: %SDK_DIR%\libGentoSDK.dll
    pause
    exit /b 1
)
copy /Y "%SDK_DIR%\libGentoSDK.dll" "%C_DLL_DIR%\"
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Copy libGentoSDK.dll failed!
    pause
    exit /b 1
)
echo [OK] libGentoSDK.dll copied to C_EXAMPLE_USE_DLL_SO\
copy /Y "%SDK_DIR%\libGentoSDK.dll" "%SCRIPT_DIR%\" >nul
if !ERRORLEVEL! NEQ 0 (
    echo [FAIL] Copy libGentoSDK.dll to TJHandInterface failed!
    pause
    exit /b 1
)
echo [OK] libGentoSDK.dll copied to TJHandInterface\

del /F /Q "%SDK_DIR%\libGentoSDK.dll" 2>nul
del /F /Q "%SDK_DIR%\libGentoSDKPY.dll" 2>nul
echo [OK] Delete C_SDK/libGentoSDK.dll and C_SDK/libGentoSDKPY.dll

REM ---- [4/4] Build executable(s) from existing sources + the fresh dll ----
REM Links example sources against the freshly built libGentoSDK.dll (Method 2).
REM   win_auto_compile.bat                  -> builds example_basic_hand
REM   win_auto_compile.bat example_basic_Position
REM   win_auto_compile.bat all              -> builds every ..\C_EXAMPLE\example_*.cpp
REM   win_auto_compile.bat none             -> skip executable build
set EX_TARGET=%~1
if /I "%EX_TARGET%"=="" set EX_TARGET=example_basic_hand
if /I "!EX_TARGET:~-4!"==".cpp" set EX_TARGET=!EX_TARGET:~0,-4!

if /I "%EX_TARGET%"=="none" (
    echo [INFO] Skipping executable build.
    goto :done
)

set GENTO_DLL=%C_DLL_DIR%\libGentoSDK.dll
if not exist "%GENTO_DLL%" (
    echo [WARN] %GENTO_DLL% not found, skip executable build.
    goto :done
)

REM SDK include dirs, plus the hand include dir for example_basic_hand.
set EX_INC_DIRS=%INC_DIRS% -I"%SCRIPT_DIR%"

if /I "%EX_TARGET%"=="all" (
    echo.
    echo ============================================
    echo [4/4] Building every example_*.cpp with the fresh dll
    echo ============================================
    set EXFAIL=0
    for %%F in ("%SCRIPT_DIR%example_*.cpp") do (
        call :build_exe "%%~nF" "%%F"
        if !ERRORLEVEL! NEQ 0 set EXFAIL=1
    )
    for %%F in ("%SCRIPT_DIR%..\C_EXAMPLE\example_*.cpp") do (
        call :build_exe "%%~nF" "%%F"
        if !ERRORLEVEL! NEQ 0 set EXFAIL=1
    )
    if "!EXFAIL!"=="1" ( echo [FAIL] Some executables FAILED. ) else ( echo [OK] All executables built. )
    goto :done
)

REM resolve source: this folder first, then ..\C_EXAMPLE
set EX_SRC=%SCRIPT_DIR%!EX_TARGET!.cpp
if not exist "!EX_SRC!" set EX_SRC=%SCRIPT_DIR%..\C_EXAMPLE\!EX_TARGET!.cpp
echo.
echo ============================================
echo [4/4] Building executable from existing sources + fresh dll
echo ============================================
call :build_exe "!EX_TARGET!" "!EX_SRC!"

:done
echo.
echo ============================================
echo All done!
echo ============================================
pause
exit /b 0

:build_exe
set NAME=%~1
set SRC=%~2
if not exist "!SRC!" (
    echo [FAIL] Not found: !SRC!
    exit /b 1
)
echo --------------------------------------------
echo Building !NAME!.exe against the fresh dll
echo --------------------------------------------
pushd "%SDK_DIR%"
g++ -include FXCmplOpt.h "!SRC!" !EX_INC_DIRS! "!GENTO_DLL!" -DCMPL_WIN -O2 -o "%SCRIPT_DIR%!NAME!.exe"
set RC=!ERRORLEVEL!
popd
if !RC! NEQ 0 (
    echo [FAIL] !NAME!.exe build failed ^(rc=!RC!^)
    exit /b 1
)
echo [OK] !NAME!.exe    Run: "%SCRIPT_DIR%!NAME!.exe"
echo [INFO] Copy libGentoSDK.dll next to the exe before running it.
exit /b 0