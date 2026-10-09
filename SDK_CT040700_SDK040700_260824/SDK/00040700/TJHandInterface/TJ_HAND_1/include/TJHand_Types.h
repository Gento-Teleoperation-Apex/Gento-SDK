#ifndef TJ_HAND_TYPES_H_
#define TJ_HAND_TYPES_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

    /**
     * @brief Dexterous hand send mode enumeration
     */
    enum TJSendMode
    { 
        TJ_SEND_MODE_NO_SEND = 0,   // No data send
        TJ_SEND_MODE_POS = 1,       // Send position target data
        TJ_SEND_MODE_SPEED = 2,     // Send speed target data
        TJ_SEND_MODE_CURRENT = 3,   // Send current target data
        TJ_SEND_MODE_KP = 4,        // Send KP value
        TJ_SEND_MODE_KD = 5,        // Send KD value
        TJ_SEND_MODE_LIMIT_I = 6,   // Send limit_i value
    };

    /**
     * @brief Dexterous hand left/right handedness enumeration
     */
    enum TJHandedness
    { 
        TJ_HANDEDNESS_LEFT = 0,     // Left hand
        TJ_HANDEDNESS_RIGHT = 1,    // Right hand
    };

    /**
     * @brief Structure for an array of 8 16-bit data items
     */
    typedef struct {
        uint16_t data[8]; 
    } Uint16Array8;   
    
    #define FINGER_PINKY    0   // Pinky finger
    #define FINGER_RING     1   // Ring finger
    #define FINGER_MIDDLE   2   // Middle finger
    #define FINGER_INDEX    3   // Index finger
    #define FINGER_THUMB1   4   // Thumb 1
    #define FINGER_THUMB2   5   // Thumb 2

#ifdef __cplusplus
}
#endif

#endif // TJ_HAND_TYPES_H_