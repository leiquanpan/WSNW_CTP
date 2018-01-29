#ifndef __DEMOAPP_H
#define __DEMOAPP_H

#include <AM.h>

enum
{
    SAMPLE_RATE_KEY = 0x1,
    SENDER_VALUE = 0xee,
};

typedef nx_struct demo_message
{
    nx_am_addr_t source;
    nx_uint16_t seqno;
    nx_am_addr_t parent;
    nx_uint16_t metric;
    nx_int8_t   moteId;
    nx_uint16_t tempReading;
    nx_uint16_t humidityReading;
    nx_uint16_t internalTempReading;
    nx_uint8_t hopcount;
    nx_uint16_t sendCount;
    nx_uint16_t sendSuccessCount;
} demo_message_t;

#endif // __DEMOAPP_H
