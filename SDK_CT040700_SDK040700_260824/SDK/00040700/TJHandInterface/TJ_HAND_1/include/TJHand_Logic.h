#ifndef TJ_HAND_LOGIC_H_
#define TJ_HAND_LOGIC_H_

#include <stdint.h>
#include "TJHand_Types.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /**
    * @brief Write a uint16_t value to a byte buffer
    * @param value Value to convert
    * @param bytes Output buffer (at least 16 bytes)
    * @param len Buffer length
    */
    void TJHand_Logic_Uint16ToBytes(uint16_t value, unsigned char* bytes, int len);

    /**
    * @brief Convert a Uint16Array8 structure to a byte array
    * @param array Input data
    * @param bytes Output buffer (at least 16 bytes)
    * @param len Buffer length
    */
    void TJHand_Logic_Uint16ArrayToBytes(const Uint16Array8* array, unsigned char* bytes, int len);

    /**
    * @brief Convert a byte array to a Uint16Array8 structure
    * @param bytes Input buffer (at least 16 bytes)
    * @param len Buffer length
    * @param array Output data
    */
    void TJHand_Logic_BytesToUint16Array(const unsigned char* bytes, int len, Uint16Array8* array);

    /**
    * @brief Pack send data
    * @param sendMode Send mode
    * @param array Data array
    * @param out_data Output buffer (512 bytes)
    */
    void TJHand_Logic_PackSendData(TJSendMode sendMode, const Uint16Array8* array, unsigned char* out_data);

    /**
    * @brief Pack a control command
    * @param command Command value
    * @param out_data Output buffer (512 bytes)
    */
    void TJHand_Logic_PackCommand(uint16_t command, unsigned char* out_data);

    /**
    * @brief Extract data at a specified offset from received data
    * @param hand_data Received 512-byte data
    * @param data_offset Offset
    * @param data_len Data length
    * @param out_data Output buffer
    * @return Actual copied data length
    */
    int TJHand_Logic_ExtractData(const unsigned char* hand_data, int data_offset, int data_len, unsigned char* out_data);

    /**
    * @brief Extract position target values from received data
    * @param hand_data Received 512-byte data
    * @param array Output data
    */
    void TJHand_Logic_ExtractPosTarget(const unsigned char* hand_data, Uint16Array8* array);

    /**
    * @brief Extract actual position values from received data
    * @param hand_data Received 512-byte data
    * @param array Output data
    */
    void TJHand_Logic_ExtractPosValue(const unsigned char* hand_data, Uint16Array8* array);

    /**
    * @brief Extract temperature values from received data
    * @param hand_data Received 512-byte data
    * @param array Output data
    */
    void TJHand_Logic_ExtractTemperature(const unsigned char* hand_data, Uint16Array8* array);

    /**
    * @brief Extract current values from received data
    * @param hand_data Received 512-byte data
    * @param array Output data
    */
    void TJHand_Logic_ExtractCurrent(const unsigned char* hand_data, Uint16Array8* array);

    /**
    * @brief Extract speed values from received data
    * @param hand_data Received 512-byte data
    * @param array Output data
    */
    void TJHand_Logic_ExtractSpeed(const unsigned char* hand_data, Uint16Array8* array);

    /**
    * @brief Extract error codes from received data
    * @param hand_data Received 512-byte data
    * @param array Output data
    */
    void TJHand_Logic_ExtractErrorCode(const unsigned char* hand_data, Uint16Array8* array);

#ifdef __cplusplus
}
#endif

#endif // TJ_HAND_LOGIC_H_