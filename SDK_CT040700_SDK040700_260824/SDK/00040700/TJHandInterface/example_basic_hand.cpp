/**
 * @file example_basic_hand.cpp
 * @brief Example demonstrating how to control the right hand (dexterous hand)
 *        with the FX robot controller system.
 *
 */

#include "L1Robot.h"
#include "TJHand.h"
#include <thread>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#define SLEEP_MS(ms) Sleep(ms)
#else
#include <unistd.h>
#define SLEEP_MS(ms) usleep((ms) * 1000)
#endif

int exit_thread = 0; ///< Global flag to request all threads to exit


static const char* FINGER_NAMES[] = {
    "Pinky",     
    "Ring",       
    "Middle",     
    "Index",      
    "Thumb1",     
    "Thumb2",     
    "Unused",    
    "Unused"      
};

void CheckLinkState()
{
    int link_state = FX_L1_System_GetLinkState();
    if (link_state == 0)
    {
        printf("Link is not established\n");
    }
    else if (link_state == -1)
    {
        printf("Link is established, but no data arrived in 100ms\n");
    }
    else if (link_state == 1)
    {
        printf("Link is established\n");
    }
    else
    {
        printf("Link state is unknown(%d)\n", link_state);
    }
}

/**
 * @brief Thread for receiving message from controller.
 */
void MSG_thread()
{
    char msg[1024] = { 0 };

    while (exit_thread == 0)
    {
        if (FX_L1_Fbk_GetSystemMsg(msg, 1024) > 0)
        {
            printf("Receive message from controller: %s\n", msg);
        }
        SLEEP_MS(100);
    }
}

/**
 * @brief Check and clear finger errors (clear if any finger error code is non-zero)
 * @param eHand Left or right hand
 * @return 1 if errors were cleared, 0 if no errors, -1 if check failed
 */
int CheckAndClearHandError(TJHandedness eHand)
{
    const char* hand_name = (eHand == TJ_HANDEDNESS_LEFT) ? "Left hand" : "Right hand";
    int has_error = 0;
    
    // Use new interface to check each finger error
    for (int i = 0; i < 6; i++) {
        uint16_t error_code = 0;
        int ret = getFingerErrorCode(eHand, i, &error_code);
        if (ret != 0) {
            printf("[ERROR] Failed to get error code for %s finger %s: %d\n", hand_name, FINGER_NAMES[i], ret);
            return -1;
        }
        if (error_code != 0) {
            has_error = 1;
            printf("[INFO] %s finger %s error code: 0x%04X\n", hand_name, FINGER_NAMES[i], error_code);
        }
    }
    
    if (has_error) {
        printf("[INFO] %s has errors, clearing...\n", hand_name);
        int ret = clearErrCode(eHand);
        if (ret != 0) {
            printf("[ERROR] Failed to clear %s errors: %d\n", hand_name, ret);
            return -1;
        }
        SLEEP_MS(500);
        printf("[OK] %s error cleared\n", hand_name);
        return 1;
    }
    
    return 0;
}

/**
 * @brief Print hand status information using new interfaces
 */
void PrintHandStatus(TJHandedness eHand)
{
    const char* hand_name = (eHand == TJ_HANDEDNESS_LEFT) ? "Left hand" : "Right hand";
    
    // Use new interface to get data for each finger
    uint16_t pos[6] = {0};
    uint16_t target[6] = {0};
    uint16_t temp[6] = {0};
    uint16_t current[6] = {0};
    uint16_t speed[6] = {0};
    uint16_t err[6] = {0};
    
    for (int i = 0; i < 6; i++) {
        getFingerPosValue(eHand, i, &pos[i]);
        getFingerTargetValue(eHand, i, &target[i]);
        getFingerTemperature(eHand, i, &temp[i]);
        getFingerCurrent(eHand, i, &current[i]);
        getFingerSpeed(eHand, i, &speed[i]);
        getFingerErrorCode(eHand, i, &err[i]);
    }
    
    printf("\n========== %s Status ==========\n", hand_name);
    
    printf("Target Pos: ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", target[i]);
    }
    printf("\n");
    
    printf("Actual Pos: ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", pos[i]);
    }
    printf("\n");
    
    printf("Current:    ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", current[i]);
    }
    printf("\n");
    
    printf("Temperature:");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", temp[i]);
    }
    printf("\n");
    
    printf("Speed:      ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", speed[i]);
    }
    printf("\n");
    
    printf("Error Code: ");
    int has_err = 0;
    for (int i = 0; i < 6; i++) {
        if (err[i] != 0) {
            printf("%s:0x%04X ", FINGER_NAMES[i], err[i]);
            has_err = 1;
        }
    }
    if (!has_err) {
        printf("No error");
    }
    printf("\n");
    printf("====================================\n\n");
}

/**
 * @brief Print hand status using getAllHandData interface
 */
void PrintHandStatusWithAllData(TJHandedness eHand)
{
    const char* hand_name = (eHand == TJ_HANDEDNESS_LEFT) ? "Left hand" : "Right hand";
    TJHandAllData allData = {0};
    
    int ret = getAllHandData(eHand, &allData);
    if (ret != 0) {
        printf("[ERROR] Failed to get all data for %s: %d\n", hand_name, ret);
        return;
    }
    
    printf("\n========== %s Status (Batch Get) ==========\n", hand_name);
    
    printf("Target Pos: ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", allData.posTarget.data[i]);
    }
    printf("\n");
    
    printf("Actual Pos: ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", allData.posValue.data[i]);
    }
    printf("\n");
    
    printf("Current:    ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", allData.current.data[i]);
    }
    printf("\n");
    
    printf("Temperature:");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", allData.temperature.data[i]);
    }
    printf("\n");
    
    printf("Speed:      ");
    for (int i = 0; i < 6; i++) {
        printf("%4d ", allData.speed.data[i]);
    }
    printf("\n");
    
    printf("Error Code: ");
    int has_err = 0;
    for (int i = 0; i < 6; i++) {
        if (allData.errorCode.data[i] != 0) {
            printf("%s:0x%04X ", FINGER_NAMES[i], allData.errorCode.data[i]);
            has_err = 1;
        }
    }
    if (!has_err) {
        printf("No error");
    }
    printf("\n");
    printf("============================================\n\n");
}

/**
 * @brief Print hand status and check error
 */
void PrintHandStatusWithErrorCheck(TJHandedness eHand)
{
    PrintHandStatus(eHand);
    CheckAndClearHandError(eHand);
}

/**
 * @brief Safe send data with error checking
 */
int SafeSendData(TJHandedness eHand, TJSendMode sendMode, const Uint16Array8* array)
{
    int ret = sendData(eHand, sendMode, array);
    if (ret != 0) {
        printf("[ERROR] sendData failed, error: %d\n", ret);
        CheckAndClearHandError(eHand);
        ret = sendData(eHand, sendMode, array);
        if (ret != 0) {
            printf("[ERROR] sendData retry failed, error: %d\n", ret);
        } else {
            printf("[OK] sendData retry succeeded\n");
        }
    }
    return ret;
}

/**
 * @brief Test single finger movement using sendSingleFingerData interface
 */
void TestSingleFinger(TJHandedness eHand)
{
    printf("\n=== Test 1: Single Finger Control (using sendSingleFingerData) ===\n");
    printf("Finger order: Pinky -> Ring -> Middle -> Index -> Thumb1 -> Thumb2\n");
    
    for (int finger = 0; finger < 6; finger++) {
        printf("\nMoving %s...\n", FINGER_NAMES[finger]);

        /*
        if(finger == 4)
        {
            SLEEP_MS(1000);
            continue;
        } */ 
        
        int ret = sendSingleFingerData(eHand, finger, 1000);
        if (ret != 0) {
            printf("Failed to send single finger data, error code: %d\n", ret);
            // Retry
            CheckAndClearHandError(eHand);
            ret = sendSingleFingerData(eHand, finger, 1000);
            if (ret != 0) {
                printf("Retry failed, error code: %d\n", ret);
                return;
            }
        }
        
        SLEEP_MS(500);
        PrintHandStatus(eHand);
        SLEEP_MS(500);
    }
}

/**
 * @brief Test all fingers synchronized movement using sendFingerPositions
 */
void TestAllFingersSync(TJHandedness eHand)
{
    printf("\n=== Test 2: All Fingers Synchronized Movement (using sendFingerPositions) ===\n");
    
    for (int cycle = 0; cycle < 2; cycle++) {
        printf("\nCycle %d: Closing fingers\n", cycle + 1);
        // Use sendFingerPositions to set all fingers at once
        int ret = sendFingerPositions(eHand, 1500, 1500, 1500, 1500, 1500, 1500);
        if (ret != 0) {
            printf("Failed to send finger positions, error code: %d\n", ret);
            return;
        }
        SLEEP_MS(1000);
        PrintHandStatus(eHand);
        
        printf("\nOpening fingers\n");
        ret = sendFingerPositions(eHand, 0, 0, 0, 0, 0, 0);
        if (ret != 0) {
            printf("Failed to send finger positions, error code: %d\n", ret);
            return;
        }
        SLEEP_MS(1000);
        PrintHandStatus(eHand);
    }
}

/**
 * @brief Test predefined gestures using sendFingerPositions
 */
void TestGestures(TJHandedness eHand)
{
    printf("\n=== Test 3: Predefined Gestures (using sendFingerPositions) ===\n");
    
    printf("\nGesture: Open\n");
    sendFingerPositions(eHand, 0, 0, 0, 0, 0, 0);
    SLEEP_MS(1500);
    PrintHandStatus(eHand);
    
    printf("\nGesture: Fist\n");
    sendFingerPositions(eHand, 2000, 2000, 2000, 2000, 1000, 1000);
    SLEEP_MS(1500);
    PrintHandStatus(eHand);
    
    printf("\nGesture: Pinch (Index + Thumb1)\n");
    sendFingerPositions(eHand, 0, 0, 0, 1500, 0, 1500);
    SLEEP_MS(1500);
    PrintHandStatus(eHand);
    
    printf("\nGesture: OK (Index + Thumb1 forming a circle)\n");
    sendFingerPositions(eHand, 0, 0, 0, 1000, 0, 1000);
    SLEEP_MS(1500);
    PrintHandStatus(eHand);
    
    printf("\nGesture: Point (Index + Thumb extended)\n");
    sendFingerPositions(eHand, 2000, 2000, 2000, 0, 0, 0);
    SLEEP_MS(1500);
    PrintHandStatus(eHand);
}

/**
 * @brief Test wave motion using sendSingleFingerData
 */
void TestWaveMotion(TJHandedness eHand)
{
    printf("\n=== Test 4: Wave Motion (Pinky -> Thumb) ===\n");
    
    for (int wave = 0; wave < 3; wave++) {
        printf("\nWave %d...\n", wave + 1);
        
        // Close fingers from 0 to 5
        for (int finger = 0; finger < 6; finger++) {
			if(finger != 4)
				sendSingleFingerData(eHand, finger, 2000);
            SLEEP_MS(200);
        }
        
        // Open fingers from 5 to 0
        for (int finger = 5; finger >= 0; finger--) {
			if(finger != 4)
				sendSingleFingerData(eHand, finger, 0);
            SLEEP_MS(200);
        }
        
        PrintHandStatus(eHand);
    }
}

/**
 * @brief Test hand enable/disable
 */
void TestEnableDisable(TJHandedness eHand)
{
    printf("\n=== Test 5: Enable/Disable Test ===\n");
    
    const char* hand_name = (eHand == TJ_HANDEDNESS_LEFT) ? "Left hand" : "Right hand";
    
    CheckAndClearHandError(eHand);
    
    printf("\nDisabling %s...\n", hand_name);
    int ret = motorDisable(eHand);
    if (ret != 0) {
        printf("Disable failed, error code: %d\n", ret);
        CheckAndClearHandError(eHand);
    } else {
        printf("Disable succeeded\n");
    }
    SLEEP_MS(1000);
    
    printf("\nEnabling %s...\n", hand_name);
    ret = motorEnable(eHand);
    if (ret != 0) {
        printf("Enable failed, error code: %d\n", ret);
        CheckAndClearHandError(eHand);
    } else {
        printf("Enable succeeded\n");
    }
    SLEEP_MS(1000);
}

/**
 * @brief Test single finger data retrieval
 */
void TestFingerDataRetrieval(TJHandedness eHand)
{
    printf("\n=== Test 6: Single Finger Data Retrieval Test ===\n");
    
    const char* hand_name = (eHand == TJ_HANDEDNESS_LEFT) ? "Left hand" : "Right hand";
    
    for (int i = 0; i < 6; i++) {
        uint16_t pos, target, temp, current, speed, error;
        
        int ret1 = getFingerPosValue(eHand, i, &pos);
        int ret2 = getFingerTargetValue(eHand, i, &target);
        int ret3 = getFingerTemperature(eHand, i, &temp);
        int ret4 = getFingerCurrent(eHand, i, &current);
        int ret5 = getFingerSpeed(eHand, i, &speed);
        int ret6 = getFingerErrorCode(eHand, i, &error);
        
        if (ret1 == 0 && ret2 == 0 && ret3 == 0 && ret4 == 0 && ret5 == 0 && ret6 == 0) {
            printf("%s %s: Target=%d, Actual=%d, Temp=%d, Current=%d, Speed=%d, Error=0x%04X\n",
                   hand_name, FINGER_NAMES[i], target, pos, temp, current, speed, error);
        } else {
            printf("[ERROR] Failed to get data for %s %s\n", hand_name, FINGER_NAMES[i]);
        }
    }
}

int main(int argc, char** argv)
{
    int sdk_version = 0;
    int controller_version = 0;

    TJHandedness  hand = TJ_HANDEDNESS_RIGHT;

    sdk_version = FX_L1_System_GetSDKVersion();
    printf("SDK version is 0x%08x\n", sdk_version);

#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
#endif
    
    std::thread msg_thread(MSG_thread);
    SLEEP_MS(500);

    printf("\n[Step 1] Connecting to robot controller...\n");
    if (FX_L1_System_Link(192, 168, 1, 190, FX_LOG_ALL_FLAG) < 0)
    {
        printf("Failed to link system\n");
        goto WAIT_EXIT;
    }
    printf("Connection succeeded!\n");
    
    printf("\n[Step 2] Checking link state...\n");
    CheckLinkState();

    printf("\n[Step 3] Getting controller version...\n");
    controller_version = FX_L1_System_GetControllerVersion();
    printf("Controller version is 0x%08x\n", controller_version);

    printf("\n============================================================\n");
    printf("Starting Right Hand Test\n");
    printf("============================================================\n");

    

    printf("\n[Init] Checking right hand error status...\n");
    CheckAndClearHandError(hand);

    PrintHandStatus(hand);  

    TestEnableDisable(hand);
    printf("Press any key to continue...\n");
    getchar();


    // TestAllFingersSync(TJ_HANDEDNESS_LEFT);
    // printf("Press any key to continue...\n");
    // getchar();

    sendFingerPositions(hand, 0, 0, 0, 0, 0, 0);
    SLEEP_MS(1000);
    getchar();

    sendFingerPositions(hand, 800, 800, 800, 800, 500, 500);
    SLEEP_MS(1000);
    getchar();

    sendFingerPositions(hand, 0, 0, 0, 0, 0, 0);
    SLEEP_MS(1000);
    getchar();
            
    if(  0  )
    {
        for (int cycle = 0; cycle < 5 ; cycle++) 
        {
            printf("\nCycle %d: Closing fingers\n", cycle + 1);
            // Use sendFingerPositions to set all fingers at once
            int ret = sendFingerPositions(hand, 800, 800, 800, 800, 500, 500);
            if (ret != 0) {
                printf("Failed to send finger positions, error code: %d\n", ret);
                return -1;
            }
            SLEEP_MS(1000);
            PrintHandStatus(hand);
            
            printf("\nOpening fingers\n");
            ret = sendFingerPositions(hand, 0, 0, 0, 0, 0, 0);
            if (ret != 0) {
                printf("Failed to send finger positions, error code: %d\n", ret);
                return -2;
            }
            SLEEP_MS(1000);
            PrintHandStatus(hand);
        }
    }
    

    printf("\n[Step 6] Disabling right hand...\n");
    motorDisable(hand);
    printf("Disable completed\n");

    printf("\n[Step 7] Disconnecting...\n");
    FX_L1_System_Unlink();
    printf("Unlink system\n");

    printf("\n[Step 8] Checking link state...\n");
    CheckLinkState();

WAIT_EXIT:
    printf("\nPress any key to exit...\n");
    // getchar();
    exit_thread = 1;
    msg_thread.join();
    
    printf("Program ended\n");
    return 0;
}



/**
 * @brief Entry point of the hand control example.
 */
int main_old(int argc, char** argv)
{
    int sdk_version = 0;
    int controller_version = 0;

    sdk_version = FX_L1_System_GetSDKVersion();
    printf("SDK version is 0x%08x\n", sdk_version);

#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
#endif
    
    std::thread msg_thread(MSG_thread);
    SLEEP_MS(500);

    printf("\n[Step 1] Connecting to robot controller...\n");
    if (FX_L1_System_Link(6, 6, 7, 190, FX_LOG_ALL_FLAG) < 0)
    {
        printf("Failed to link system\n");
        goto WAIT_EXIT;
    }
    printf("Connection succeeded!\n");
    
    printf("\n[Step 2] Checking link state...\n");
    CheckLinkState();

    printf("\n[Step 3] Getting controller version...\n");
    controller_version = FX_L1_System_GetControllerVersion();
    printf("Controller version is 0x%08x\n", controller_version);

    printf("\n============================================================\n");
    printf("Starting Right Hand Test\n");
    printf("============================================================\n");

    printf("\n[Init] Checking right hand error status...\n");
    CheckAndClearHandError(TJ_HANDEDNESS_LEFT);

    TestEnableDisable(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();

    printf("\n[Step 4] Reading initial status (using batch get interface)...\n");
    PrintHandStatusWithAllData(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();

    TestSingleFinger(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();

    TestAllFingersSync(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();

    TestGestures(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();

    TestWaveMotion(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();
    
    printf("\n[Step 4.5] Testing single finger data retrieval...\n");
    TestFingerDataRetrieval(TJ_HANDEDNESS_LEFT);
    printf("Press any key to continue...\n");
    getchar();

    printf("\n[Step 5] Returning to initial state (Open)...\n");
    sendFingerPositions(TJ_HANDEDNESS_LEFT, 0, 0, 0, 0, 0, 0);
    SLEEP_MS(1000);
    PrintHandStatusWithAllData(TJ_HANDEDNESS_LEFT);

    printf("\n[Step 6] Disabling right hand...\n");
    motorDisable(TJ_HANDEDNESS_LEFT);
    printf("Disable completed\n");

    printf("\n[Step 7] Disconnecting...\n");
    FX_L1_System_Unlink();
    printf("Unlink system\n");

    printf("\n[Step 8] Checking link state...\n");
    CheckLinkState();

WAIT_EXIT:
    printf("\nPress any key to exit...\n");
    getchar();
    exit_thread = 1;
    msg_thread.join();
    
    printf("Program ended\n");
    return 0;
}

