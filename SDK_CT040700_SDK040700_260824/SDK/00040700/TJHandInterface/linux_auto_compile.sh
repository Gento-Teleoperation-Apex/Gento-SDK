#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_DIR="$SCRIPT_DIR/C_SDK"
PYTHON_DIR="$SCRIPT_DIR/PYTHON_SDK"
C_SO_DIR="$SCRIPT_DIR/C_EXAMPLE_USE_DLL_SO"
HAND_LIB_DIR="$SCRIPT_DIR/TJ_HAND_1/lib"

# TJHand sources live in this folder; no need to copy them into C_SDK/L1Robot.
# They are appended to the SDK sources below so the hand API is exported
# directly from the generated libGentoSDK.so / libGentoSDKPY.so.
HAND_SRC="$SCRIPT_DIR/TJHand.cpp"
HAND_INC_DIR="$SCRIPT_DIR/TJ_HAND_1/include"

CPP_FILES="
  ./L0Control/*.cpp
  ./FileClient/*.cpp
  ./L1Robot/*.cpp
  ./FXUtility/FXMath/*.cpp
  ./FXUtility/FXCfg/*.cpp
  ./Interf/*.cpp
  ./ToolDynaIdent/*.cpp
  ./Kinematics/*.cpp
  ./Kinematics/LunaBodyKinematics/*.cpp
  ./Kinematics/ArmKinematics/*.cpp
  ./Kinematics/KineCommon/*.cpp
  ./Kinematics/MotionPlanner/*.cpp
  ./Kinematics/SkyeBodyKinematics/*.cpp
"

INC_DIRS="
  -I./Common
  -I./FXUtility
  -I./FXUtility/FXMath
  -I./FXUtility/FXCfg
  -I./Interf
  -I./ToolDynaIdent
  -I./Kinematics
  -I./Kinematics/LunaBodyKinematics
  -I./Kinematics/ArmKinematics
  -I./Kinematics/KineCommon
  -I./Kinematics/MotionPlanner
  -I./Kinematics/SkyeBodyKinematics
  -I./FileClient
  -I./L0Control
  -I./L1Robot
  -I$HAND_INC_DIR
"

HAND_LIB="$HAND_LIB_DIR/libTJHandLogic.a"

mkdir -p "$PYTHON_DIR" "$C_SO_DIR"

cd "$SDK_DIR"

# check hand library and hand source
HAND_ARGS=""
if [ -f "$HAND_LIB" ]; then
    echo "[INFO] Found TJHand static library: $HAND_LIB"
    HAND_LINK="$HAND_LIB"
    if [ -f "$HAND_SRC" ]; then
        HAND_ARGS="$HAND_SRC"
    fi
else
    echo "[WARN] TJHand library not found at $HAND_LIB"
    echo "       Building without hand support..."
    HAND_LINK=""
fi

echo "============================================"
echo "[1/3] Building libGentoSDK.so (C/C++ link)"
echo "============================================"
g++ $CPP_FILES $HAND_ARGS $INC_DIRS \
  -Wall -Wno-unused-result -std=gnu++17 -O2 -fPIC -shared \
  -o libGentoSDK.so \
  -Wl,--no-undefined \
  -lpthread -lrt -DCMPL_LIN $HAND_LINK
echo "[OK] libGentoSDK.so built."

echo ""
echo "============================================"
echo "[2/3] Building libGentoSDKPY.so (Python, glibc-compatible)"
echo "============================================"
g++ $CPP_FILES $HAND_ARGS $INC_DIRS \
  -Wall -Wno-unused-result -std=gnu++17 -O2 -fPIC -shared \
  -Wl,-soname,libGentoSDKPY.so \
  -Wl,--hash-style=both \
  -o libGentoSDKPY.so \
  -DL1_SDK_EXPORTS -DCMPL_LIN \
  -static-libgcc -static-libstdc++ \
  -Wl,--no-undefined \
  -lpthread -ldl -lm -lrt $HAND_LINK
echo "[OK] libGentoSDKPY.so built."

cd "$SCRIPT_DIR"

echo ""
echo "============================================"
echo "[3/3] Copying SOs to target folders..."
echo "============================================"

if [ -f "$SDK_DIR/libGentoSDK.so" ]; then
    cp -v "$SDK_DIR/libGentoSDK.so" "$C_SO_DIR/"
    echo "[OK] libGentoSDK.so -> C_EXAMPLE_USE_DLL_SO/"
    cp -v "$SDK_DIR/libGentoSDK.so" "$SCRIPT_DIR/"
    echo "[OK] libGentoSDK.so -> TJHandInterface/"
    rm -f "$SDK_DIR/libGentoSDK.so"
    echo "[OK] Delete C_SDK/libGentoSDK.so"
else
    echo "[FAIL] Source file not found: $SDK_DIR/libGentoSDK.so"
    exit 1
fi

if [ -f "$SDK_DIR/libGentoSDKPY.so" ]; then
    cp -v "$SDK_DIR/libGentoSDKPY.so" "$PYTHON_DIR/"
    echo "[OK] libGentoSDKPY.so -> PYTHON_SDK/"
    cp -v "$SDK_DIR/libGentoSDKPY.so" "$SCRIPT_DIR/"
    echo "[OK] libGentoSDKPY.so -> TJHandInterface/"
    rm -f "$SDK_DIR/libGentoSDKPY.so"
    echo "[OK] Delete C_SDK/libGentoSDKPY.so"
else
    echo "[FAIL] Source file not found: $SDK_DIR/libGentoSDKPY.so"
    exit 1
fi

echo ""
echo "============================================"
echo "All done!"
echo "============================================"