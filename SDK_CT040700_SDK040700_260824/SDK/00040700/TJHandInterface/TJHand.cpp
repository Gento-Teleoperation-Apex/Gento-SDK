#include "TJHand.h"
#include "TJHand_Logic.h"
#include "L1Robot.h"
#include "FXCommon.h"
#include <string.h>
#include <stdio.h>

static FXObjType HandToFXObj(TJHandedness eHand)
{
    if (eHand == TJ_HANDEDNESS_LEFT) {
        return FX_OBJ_ARM0;
    } else {
        return FX_OBJ_ARM1;
    }
}

static int SendToHand(TJHandedness eHand, unsigned char* data)
{
    if (data == NULL) {
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    FXObjType obj = HandToFXObj(eHand);
    return FX_L1_Hand_SetData(obj, data);
}

static int ReceiveFromHand(TJHandedness eHand, unsigned char* out_data, int* serial)
{
    if (out_data == NULL) {
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    FXObjType obj = HandToFXObj(eHand);
    int local_serial = 0;
    int* pSerial = (serial != NULL) ? serial : &local_serial;
    
    return FX_L1_Hand_GetData(obj, pSerial, out_data);
}

int sendData(TJHandedness eHand, TJSendMode sendMode, const Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] sendData: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};    
    
    TJHand_Logic_PackSendData(sendMode, array, hand_data);    
    
    int ret = SendToHand(eHand, hand_data);
    if (ret != 0) {
        printf("[TJHand] sendData failed, error: %d, hand: %d, mode: %d\n", 
               ret, eHand, sendMode);
    }
    
    return ret;
}

int clearErrCode(TJHandedness eHand)
{
    unsigned char hand_data[512] = {0};    
    
    TJHand_Logic_PackCommand((uint16_t)10, hand_data);
    
    int ret = SendToHand(eHand, hand_data);
    if (ret != 0) {
        printf("[TJHand] clearErrCode failed, error: %d, hand: %d\n", ret, eHand);
    }
    
    return ret;
}

int motorEnable(TJHandedness eHand)
{
    unsigned char hand_data[512] = {0};    
    
    TJHand_Logic_PackCommand((uint16_t)11, hand_data);
    
    int ret = SendToHand(eHand, hand_data);
    if (ret != 0) {
        printf("[TJHand] motorEnable failed, error: %d, hand: %d\n", ret, eHand);
    }
    
    return ret;
}

int motorDisable(TJHandedness eHand)
{
    unsigned char hand_data[512] = {0};    
    
    TJHand_Logic_PackCommand((uint16_t)12, hand_data);
    
    int ret = SendToHand(eHand, hand_data);
    if (ret != 0) {
        printf("[TJHand] motorDisable failed, error: %d, hand: %d\n", ret, eHand);
    }
    
    return ret;
}

int getPosTargetValue(TJHandedness eHand, Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] getPosTargetValue: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractPosTarget(hand_data, array);
    } else {
        printf("[TJHand] getPosTargetValue failed, error: %d, hand: %d\n", ret, eHand);
        memset(array->data, 0, sizeof(uint16_t) * 8);
    }
    
    return ret;
}

int getPosValue(TJHandedness eHand, Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] getPosValue: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractPosValue(hand_data, array);
    } else {
        printf("[TJHand] getPosValue failed, error: %d, hand: %d\n", ret, eHand);
        memset(array->data, 0, sizeof(uint16_t) * 8);
    }
    
    return ret;
}

int getMotorTempValue(TJHandedness eHand, Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] getMotorTempValue: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractTemperature(hand_data, array);
    } else {
        printf("[TJHand] getMotorTempValue failed, error: %d, hand: %d\n", ret, eHand);
        memset(array->data, 0, sizeof(uint16_t) * 8);
    }
    
    return ret;
}

int getCurrentValue(TJHandedness eHand, Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] getCurrentValue: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractCurrent(hand_data, array);
    } else {
        printf("[TJHand] getCurrentValue failed, error: %d, hand: %d\n", ret, eHand);
        memset(array->data, 0, sizeof(uint16_t) * 8);
    }
    
    return ret;
}

int getSpeedValue(TJHandedness eHand, Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] getSpeedValue: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractSpeed(hand_data, array);
    } else {
        printf("[TJHand] getSpeedValue failed, error: %d, hand: %d\n", ret, eHand);
        memset(array->data, 0, sizeof(uint16_t) * 8);
    }
    
    return ret;
}

int getErrCode(TJHandedness eHand, Uint16Array8* array)
{
    if (array == NULL) {
        printf("[TJHand] getErrCode: array is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractErrorCode(hand_data, array);
    } else {
        printf("[TJHand] getErrCode failed, error: %d, hand: %d\n", ret, eHand);
        memset(array->data, 0, sizeof(uint16_t) * 8);
    }
    
    return ret;
}

int sendSingleFingerData(TJHandedness eHand, int fingerIndex, uint16_t value)
{
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] sendSingleFingerData: invalid finger index %d\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    array.data[fingerIndex] = value;
    return sendData(eHand, TJ_SEND_MODE_POS, &array);
}

int sendFingerPositions(TJHandedness eHand, uint16_t finger1, uint16_t finger2, 
                        uint16_t finger3, uint16_t finger4, uint16_t finger5, uint16_t finger6)
{
    Uint16Array8 array = {0};    
    array.data[0] = finger1;  
    array.data[1] = finger2;  
    array.data[2] = finger3;  
    array.data[3] = finger4;  
    array.data[4] = finger5;  
	array.data[5] = finger6;
    return sendData(eHand, TJ_SEND_MODE_POS, &array);
}

int getAllHandData(TJHandedness eHand, TJHandAllData* allData)
{
    if (allData == NULL) {
        printf("[TJHand] getAllHandData: allData is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    unsigned char hand_data[512] = {0};
    int serial = 0;
    
    int ret = ReceiveFromHand(eHand, hand_data, &serial);
    if (ret == 0) {
        TJHand_Logic_ExtractPosTarget(hand_data, &allData->posTarget);
        TJHand_Logic_ExtractPosValue(hand_data, &allData->posValue);
        TJHand_Logic_ExtractTemperature(hand_data, &allData->temperature);
        TJHand_Logic_ExtractCurrent(hand_data, &allData->current);
        TJHand_Logic_ExtractSpeed(hand_data, &allData->speed);
        TJHand_Logic_ExtractErrorCode(hand_data, &allData->errorCode);
    } else {
        printf("[TJHand] getAllHandData failed, error: %d, hand: %d\n", ret, eHand);
        memset(allData, 0, sizeof(TJHandAllData));
    }
    
    return ret;
}

int getFingerPosValue(TJHandedness eHand, int fingerIndex, uint16_t* value)
{
    if (value == NULL) {
        printf("[TJHand] getFingerPosValue: value is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] getFingerPosValue: invalid finger index %d, must be 0-7\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    int ret = getPosValue(eHand, &array);
    if (ret == 0) {
        *value = array.data[fingerIndex];
    } else {
        printf("[TJHand] getFingerPosValue failed, error: %d, hand: %d, finger: %d\n", 
               ret, eHand, fingerIndex);
        *value = 0;
    }
    return ret;
}

int getFingerTargetValue(TJHandedness eHand, int fingerIndex, uint16_t* value)
{
    if (value == NULL) {
        printf("[TJHand] getFingerTargetValue: value is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] getFingerTargetValue: invalid finger index %d, must be 0-7\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    int ret = getPosTargetValue(eHand, &array);
    if (ret == 0) {
        *value = array.data[fingerIndex];
    } else {
        printf("[TJHand] getFingerTargetValue failed, error: %d, hand: %d, finger: %d\n", 
               ret, eHand, fingerIndex);
        *value = 0;
    }
    
    return ret;
}

int getFingerTemperature(TJHandedness eHand, int fingerIndex, uint16_t* value)
{
    if (value == NULL) {
        printf("[TJHand] getFingerTemperature: value is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] getFingerTemperature: invalid finger index %d, must be 0-7\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    int ret = getMotorTempValue(eHand, &array);
    if (ret == 0) {
        *value = array.data[fingerIndex];
    } else {
        printf("[TJHand] getFingerTemperature failed, error: %d, hand: %d, finger: %d\n", 
               ret, eHand, fingerIndex);
        *value = 0;
    }
    
    return ret;
}

int getFingerCurrent(TJHandedness eHand, int fingerIndex, uint16_t* value)
{
    if (value == NULL) {
        printf("[TJHand] getFingerCurrent: value is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] getFingerCurrent: invalid finger index %d, must be 0-7\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    int ret = getCurrentValue(eHand, &array);
    if (ret == 0) {
        *value = array.data[fingerIndex];
    } else {
        printf("[TJHand] getFingerCurrent failed, error: %d, hand: %d, finger: %d\n", 
               ret, eHand, fingerIndex);
        *value = 0;
    }
    
    return ret;
}

int getFingerSpeed(TJHandedness eHand, int fingerIndex, uint16_t* value)
{
    if (value == NULL) {
        printf("[TJHand] getFingerSpeed: value is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] getFingerSpeed: invalid finger index %d, must be 0-7\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    int ret = getSpeedValue(eHand, &array);
    if (ret == 0) {
        *value = array.data[fingerIndex];
    } else {
        printf("[TJHand] getFingerSpeed failed, error: %d, hand: %d, finger: %d\n", 
               ret, eHand, fingerIndex);
        *value = 0;
    }
    
    return ret;
}

int getFingerErrorCode(TJHandedness eHand, int fingerIndex, uint16_t* value)
{
    if (value == NULL) {
        printf("[TJHand] getFingerErrorCode: value is NULL\n");
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    if (fingerIndex < 0 || fingerIndex >= 8) {
        printf("[TJHand] getFingerErrorCode: invalid finger index %d, must be 0-7\n", fingerIndex);
        return FUNC_RET_INVALID_INPUT_ARG;
    }
    
    Uint16Array8 array = {0};
    int ret = getErrCode(eHand, &array);
    if (ret == 0) {
        *value = array.data[fingerIndex];
    } else {
        printf("[TJHand] getFingerErrorCode failed, error: %d, hand: %d, finger: %d\n", 
               ret, eHand, fingerIndex);
        *value = 0;
    }
    
    return ret;
}

