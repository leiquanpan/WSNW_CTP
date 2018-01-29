#ifndef __DEMOAPP_SERIAL_H
#define __DEMOAPP_SERIAL_H

enum
{
        AM_DEMO_MESSAGE = 150,
};

typedef nx_struct demo_message_serial
{
        nx_int8_t   moteId;
        nx_uint16_t tempReading;
        nx_uint16_t humidityReading;
        nx_uint16_t internalTempReading;
} demo_message_serial_t;

#endif // __DEMOAPP_SERIAL_H
