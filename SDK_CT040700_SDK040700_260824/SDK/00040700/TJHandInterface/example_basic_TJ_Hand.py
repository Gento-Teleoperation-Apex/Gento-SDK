"""
@file example_basic_TJ_Hand.py
@brief Example demonstrating how to establish and terminate communication
       with the L1 robot controller system.

Workflow overview:
    1. Initialize communication with the robot controller
    2. Retrieve SDK and controller versions
    3. Test dexterous hand (right hand) functionality

This is the most fundamental example and should be executed before
any other robot control examples.
"""
import sys
import time
from pathlib import Path
root_dir = Path(__file__).parent.parent
if str(root_dir) not in sys.path:
    sys.path.insert(0, str(root_dir))
# from PYTHON_SDK.GentoRobot import GentoRobot, FXLogMask, FXObjType, state_map, TJHandedness, TJSendMode, TJFingerIndex
from GentoRobot import GentoRobot, FXLogMask, FXObjType, state_map, TJHandedness, TJSendMode, TJFingerIndex


def test_right_hand(robot):
    """Test right dexterous hand functionality."""
    print("\n" + "="*60)
    print("Testing Right Dexterous Hand")
    print("="*60)
    
    # Step 1: Enable right hand motors
    print("\nEnabling right hand motors...")
    ret = robot.hand_motor_enable(TJHandedness.TJ_HANDEDNESS_RIGHT)
    if ret == 0:
        print("✓ Right hand motors enabled successfully")
    else:
        print(f"✗ Failed to enable right hand motors: {ret}")
        return False
    time.sleep(0.5)
    
    # Step 2: Clear any existing errors
    print("\nClearing error codes...")
    ret = robot.hand_clear_error(TJHandedness.TJ_HANDEDNESS_RIGHT)
    if ret == 0:
        print("✓ Error codes cleared")
    else:
        print(f"✗ Failed to clear error codes: {ret}")
    time.sleep(0.5)
    
    # Step 3: Get initial hand data
    print("\nReading initial hand data...")
    ret, data = robot.hand_get_all_data(TJHandedness.TJ_HANDEDNESS_RIGHT)
    if ret == 0:
        print(f"  Initial positions: {data['pos_value']}")
        print(f"  Initial temperatures: {data['temperature']}")
        print(f"  Error codes: {data['error_code']}")
    else:
        print(f"✗ Failed to get hand data: {ret}")
    time.sleep(0.5)
    
    # Step 4: Open hand (spread all fingers)
    print("\nOpening right hand (spreading fingers)...")
    ret = robot.hand_send_finger_positions(
        TJHandedness.TJ_HANDEDNESS_RIGHT,
        0, 0, 0, 0, 0, 0  
    )
    if ret == 0:
        print("✓ Hand opening command sent")
    else:
        print(f"✗ Failed to send open command: {ret}")
        return False
    time.sleep(1.0)
    
    # Step 5: Close hand (curl all fingers)
    print("\nClosing right hand (curling fingers)...")
    ret = robot.hand_send_finger_positions(
        TJHandedness.TJ_HANDEDNESS_RIGHT,
        1500, 1500, 1500, 1500, 500, 1500  
    )
    if ret == 0:
        print("✓ Hand closing command sent")
    else:
        print(f"✗ Failed to send close command: {ret}")
        return False
    time.sleep(1.0)
    
    # Step 6: Test single finger control (index finger)
    print("\nTesting individual finger control (index finger)...")
    
    # Get current index finger position
    ret, index_pos = robot.hand_get_finger_pos_value(
        TJHandedness.TJ_HANDEDNESS_RIGHT,
        TJFingerIndex.FINGER_INDEX
    )
    if ret == 0:
        print(f"  Current index finger position: {index_pos}")
    else:
        print(f"✗ Failed to get index finger position: {ret}")
    
    # Wiggle index finger (open and close)
    for pos in [2000, 500, 2000]:
        ret = robot.hand_send_single_finger_data(
            TJHandedness.TJ_HANDEDNESS_RIGHT,
            TJFingerIndex.FINGER_INDEX,
            pos
        )
        if ret == 0:
            print(f"  Index finger moved to: {pos}")
        else:
            print(f"✗ Failed to move index finger to {pos}: {ret}")
        time.sleep(0.3)
    
    # Read final hand data
    print("\n  Reading final hand data...")
    ret, data = robot.hand_get_all_data(TJHandedness.TJ_HANDEDNESS_RIGHT)
    if ret == 0:
        print(f"  Final positions: {data['pos_value']}")
        print(f"  Final temperatures: {data['temperature']}")
    else:
        print(f"✗ Failed to get final hand data: {ret}")
    
    # Step 7: Disable right hand motors
    print("\nDisabling right hand motors...")
    ret = robot.hand_motor_disable(TJHandedness.TJ_HANDEDNESS_RIGHT)
    if ret == 0:
        print("✓ Right hand motors disabled successfully")
    else:
        print(f"✗ Failed to disable right hand motors: {ret}")
    
    print("\n" + "="*60)
    print("Right hand test completed!")
    print("="*60)
    return True


def main():
    log_mask = FXLogMask.FX_LOG_INFO_FLAG

    robot = GentoRobot()

    print(f"\nConnecting...")
    ret = robot.link(192, 168, 1, 190, log_level=log_mask)
    if not robot._connected:
        print(f"Link failed. Error msg: {robot._get_operate_error_msg(ret)}")
        return

    print(f"\nChecking link state...")
    ret_link = robot.check_link_state()
    if ret_link == -1:
        print("Link is established, but no data arrived in 100ms,\n please check the cables and firewall ")
        return
    elif ret_link == 0:
        print(f"Link is not established")
        return

    print(f"\nGetting versions...")
    print(f"Controller version: {robot.get_controller_version()}")
    print(f"SDK version: {robot.get_sdk_version()}")
    print(f"Robot type: {robot.get_robot_type()}")

    # Test right dexterous hand
    print(f"\nTesting right hand...")
    test_right_hand(robot)

    # PD mode: set PD parameters, then switch into PD mode
    print(f"\nPD mode test...")
    # set_pd_mode(robot)



    

    print(f"\nTask finished.")
    robot.unlink()


def set_pd_mode(robot):
    """Set PD gains, switch ARM0 into PD mode, verify, then switch back to IDLE.

    Follows the same flow as PYTHON_EXAMPLE/example_basic_PD.py:
      1. Check and recover the arm state (ERROR -> reset / non-IDLE -> IDLE)
      2. Set the PD command cycle time
      3. Switch to PD mode with PD parameters (k, d)
      4. Verify the parameters were applied via get_sg_dict()
      5. Send one position command at the mechanical home
      6. Switch back to IDLE
    """
    ctrl_obj = FXObjType.OBJ_ARM0
    arm_idx = 0

    # PD parameters (same defaults as example_basic_PD.py)
    k = [3.0, 3.0, 3.0, 2.0, 1.0, 1.0, 1.0]   # proportional gains, 7 joints
    d = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]   # derivative gains, 7 joints
    vel_ratio = 100                            # velocity ratio 1-100 %
    acc_ratio = 100                            # acceleration ratio 1-100 %
    pd_cycle_time = 0                          # 0 = use default cycle time
    mechanical_home = [0.0] * 7

    # Step 1: recover arm state before switching (ERROR -> reset, else -> IDLE)
    print("\n[1/6] Checking and recovering arm state...")
    arm_state = robot.current_state(ctrl_obj)
    if state_map[arm_state] == "Error":
        ret, system_errorcode = robot.reset_error(ctrl_obj, 2000)
        if ret != 0:
            print(f"✗ Reset error failed: {system_errorcode}")
            return False
        print("✓ Error state reset")
    elif state_map[arm_state] != "IDLE":
        ret = robot.switch_to_idle(ctrl_obj, 2000)
        if ret != 0:
            print(f"✗ Switch to IDLE failed: {robot._get_operate_error_msg(ret)}")
            return False
        print("✓ Switched to IDLE")
    else:
        print("✓ Arm already in IDLE state")

    # Step 2: set the PD command cycle time
    print("\n[2/6] Setting PD command cycle time...")
    ret = robot.config_set_pd_cmd_cycle_time(pd_cycle_time)
    if ret != 0:
        print(f"✗ Set PD command cycle time failed: {robot._get_operate_error_msg(ret)}")
        return False
    print(f"✓ PD command cycle time set to {pd_cycle_time} ms")

    # Step 3: switch to PD mode with PD parameters
    print("\n[3/6] Switching to PD mode with PD parameters...")
    ret = robot.switch_to_pd_mode(ctrl_obj, 2000, vel_ratio, acc_ratio, k, d)
    if ret != 0:
        print(f"✗ Switch to PD failed: {robot._get_operate_error_msg(ret)}")
        return False
    print("✓ Now in PD state")

    # Step 4: verify the parameters were applied
    print("\n[4/6] Verifying PD parameters...")
    sg_dict = robot.get_sg_dict()
    print(f"  current vel: {sg_dict['arms'][arm_idx]['set']['vel_ratio']}")
    print(f"  current acc: {sg_dict['arms'][arm_idx]['set']['acc_ratio']}")
    print(f"  current k  : {sg_dict['arms'][arm_idx]['set']['joint_k']}")
    print(f"  current d  : {sg_dict['arms'][arm_idx]['set']['joint_d']}")

    # Step 5: send one PD position command to the mechanical home
    print("\n[5/6] Sending mechanical home position command...")
    ret = robot.runtime_set_joint_pos_pd_cmd(ctrl_obj, mechanical_home)
    if ret != 0:
        print(f"✗ Set joint PD command failed: {robot._get_operate_error_msg(ret)}")
        return False
    time.sleep(0.5)
    rt_dict = robot.get_rt_dict()
    print(f"  Arm0 position: {rt_dict['arms'][arm_idx]['fb']['fb_pos']}")

    # # Step 6: switch back to IDLE
    # print("\n[6/6] Switching back to IDLE...")
    # ret = robot.switch_to_idle(ctrl_obj, 2000)
    # if ret != 0:
    #     print(f"✗ Switch to IDLE failed: {robot._get_operate_error_msg(ret)}")
    #     return False
    # print("✓ Back in IDLE state")

    # print("\n" + "="*60)
    # print("PD mode test completed!")
    # print("="*60)
    return True


if __name__ == "__main__":
    main()
    input("Press Enter to exit...")