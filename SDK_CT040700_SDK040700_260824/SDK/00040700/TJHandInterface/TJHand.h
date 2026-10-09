#ifndef TJ_HAND_H_
#define TJ_HAND_H_

#include "TJHand_Types.h"
#include "FXCommon.h"
#include "FXErrorCode.h"

/* Platform-specific export/import macros */
#if defined(_WIN32) || defined(_WIN64)
#ifdef L1_SDK_EXPORTS
#define FX_L1_SDK_API __declspec(dllexport)
#else
#define FX_L1_SDK_API __declspec(dllimport)
#endif
#elif defined(__linux__)
#ifdef L1_SDK_EXPORTS
#define FX_L1_SDK_API __attribute__((visibility("default")))
#else
#define FX_L1_SDK_API
#endif
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    typedef struct {
	    Uint16Array8 posTarget;
	    Uint16Array8 posValue;
	    Uint16Array8 temperature;
	    Uint16Array8 current;
	    Uint16Array8 speed;
	    Uint16Array8 errorCode;
    } TJHandAllData;

    //basic
    FX_L1_SDK_API int sendData(TJHandedness eHand, TJSendMode sendMode, const Uint16Array8* array);
    FX_L1_SDK_API int clearErrCode(TJHandedness eHand);
    FX_L1_SDK_API int motorEnable(TJHandedness eHand);
    FX_L1_SDK_API int motorDisable(TJHandedness eHand);
    FX_L1_SDK_API int getPosTargetValue(TJHandedness eHand, Uint16Array8* array);
    FX_L1_SDK_API int getPosValue(TJHandedness eHand, Uint16Array8* array);
    FX_L1_SDK_API int getMotorTempValue(TJHandedness eHand, Uint16Array8* array);
    FX_L1_SDK_API int getCurrentValue(TJHandedness eHand, Uint16Array8* array);
    FX_L1_SDK_API int getSpeedValue(TJHandedness eHand, Uint16Array8* array);
    FX_L1_SDK_API int getErrCode(TJHandedness eHand, Uint16Array8* array);

	//ext
	FX_L1_SDK_API int sendSingleFingerData(TJHandedness eHand, int fingerIndex, uint16_t value);
	FX_L1_SDK_API int sendFingerPositions(TJHandedness eHand, uint16_t finger1, uint16_t finger2, 
	                                       uint16_t finger3, uint16_t finger4, uint16_t finger5,
                                           uint16_t finger6);
    FX_L1_SDK_API int getAllHandData(TJHandedness eHand, TJHandAllData* allData);
    FX_L1_SDK_API int getFingerPosValue(TJHandedness eHand, int fingerIndex, uint16_t* value);    
    FX_L1_SDK_API int getFingerTargetValue(TJHandedness eHand, int fingerIndex, uint16_t* value);
    FX_L1_SDK_API int getFingerTemperature(TJHandedness eHand, int fingerIndex, uint16_t* value);
    FX_L1_SDK_API int getFingerCurrent(TJHandedness eHand, int fingerIndex, uint16_t* value);
    FX_L1_SDK_API int getFingerSpeed(TJHandedness eHand, int fingerIndex, uint16_t* value);
    FX_L1_SDK_API int getFingerErrorCode(TJHandedness eHand, int fingerIndex, uint16_t* value);	


#ifdef __cplusplus
}
#endif

#endif // TJ_HAND_H_