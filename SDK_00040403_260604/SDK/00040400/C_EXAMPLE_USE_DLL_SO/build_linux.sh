#!/bin/bash
# Build and run test_link on Linux
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_DIR="$SCRIPT_DIR/../C_SDK"

INC_DIRS="
  -I$SDK_DIR/Common
  -I$SDK_DIR/L0Control
  -I$SDK_DIR/L1Robot
  -I$SDK_DIR/Kinematics
  -I$SDK_DIR/Kinematics/ArmKinematics
  -I$SDK_DIR/Kinematics/BaseMath
  -I$SDK_DIR/Kinematics/DynaIdent
  -I$SDK_DIR/Kinematics/KineCommon
  -I$SDK_DIR/Kinematics/MotionPlanner
  -I$SDK_DIR/Kinematics/SkyeBodyKinematics
  -I$SDK_DIR/FileClient
"

echo "=== Building test_link ==="
g++ "$SCRIPT_DIR/test_link.cpp" \
    $INC_DIRS \
    -L"$SDK_DIR" -lGentoSDKPY \
    -Wl,-rpath,"$SDK_DIR" \
    -DCMPL_LIN \
    -o "$SCRIPT_DIR/test_link" \
    -Wall -O2

echo "Build OK.  Binary: $SCRIPT_DIR/test_link"
echo ""
echo "Usage:"
echo "  $SCRIPT_DIR/test_link [ip1 ip2 ip3 ip4] [log_level]"
echo "  Example: $SCRIPT_DIR/test_link 192 168 1 100 0xFF"
