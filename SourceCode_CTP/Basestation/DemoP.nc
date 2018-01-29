#include <AM.h>
#include "Ctp.h"

module DemoP
{
	uses interface Boot;

    uses interface StdControl as DisseminationControl;
    uses interface StdControl as RoutingControl;
    uses interface DisseminationValue<uint32_t> as DisseminationPeriod;
    uses interface DisseminationUpdate<uint32_t> as Update;
    uses interface Read<uint16_t> as IntTemp;
	uses interface Read<uint16_t> as Temp;
    uses interface RootControl;

	uses interface SplitControl as RadioControl;
    uses interface Send;
	uses interface Receive;
	uses interface Packet;

    uses interface CollectionPacket;
    uses interface CtpInfo;
    uses interface CtpCongestion;

	uses interface SplitControl as SerialControl;
    uses interface Packet as SerialPacket;
    uses interface AMSend as SerialAMSend;
    uses interface Receive as SerialReceive;

	uses interface Leds;
	uses interface Timer<TMilli>;
}
implementation
{
	message_t buf;
	message_t *receivedBuf;

	uint16_t intTempPayload  = 0;
	uint16_t tempPayload     = 0;
	uint32_t Dissemination_value   = 0;
	task void sendSerialPacket();
	
	event void Boot.booted()
	{
		call RadioControl.start();
		call SerialControl.start();
	}
	
	event void RadioControl.startDone(error_t err)
	{
        	call DisseminationControl.start();
        	call RoutingControl.start();
		if(TOS_NODE_ID == 0)
			call RootControl.setRoot();
	}

    event void DisseminationPeriod.changed()//for changing sampling period
    {
        const uint32_t* newVal = call DisseminationPeriod.get();
        call Timer.stop();
        call Timer.startPeriodic(*newVal);
    }

	task void sendSerialPacket()
	{
		call Leds.led0Toggle();
		if(call SerialAMSend.send(AM_BROADCAST_ADDR, &buf, sizeof(demo_message_serial_t)) != SUCCESS)
			post sendSerialPacket();
	}	
	
	event void SerialAMSend.sendDone(message_t * msg, error_t err)
	{
		if(err != SUCCESS)
			post sendSerialPacket();
		//call Leds.led0Toggle();
	}
	
	event message_t * Receive.receive(message_t * msg, void * payload, uint8_t len)
	{
		if (TOS_NODE_ID == 0)
		{
			demo_message_t * demoPayload = (demo_message_t *)payload;
			demo_message_serial_t * serial_payload = (demo_message_serial_t *)call SerialPacket.getPayload(&buf, sizeof(demo_message_serial_t));
			call Leds.led1Toggle();
			serial_payload -> moteId = demoPayload -> moteId;
			serial_payload -> tempReading = demoPayload -> tempReading;
			serial_payload -> humidityReading = demoPayload -> humidityReading;
			serial_payload -> internalTempReading = demoPayload -> internalTempReading;
			post sendSerialPacket();
			return msg;
		}
		else
		{
			return msg;
		}
	}

    event message_t * SerialReceive.receive(message_t * msg, void * payload, uint8_t len)
    {
	
        if (TOS_NODE_ID == 0)
        {
            demo_message_serial_t * demoPayload = (demo_message_serial_t *)payload;
            call Leds.led0Toggle();
	    Dissemination_value = demoPayload -> internalTempReading;
            call Update.change(&Dissemination_value);
            return msg;
        }
        else
        {
            return msg;
        }
    }

        event void Timer.fired(){}
	event void Send.sendDone(message_t* ptr, error_t success){}	
        event void Temp.readDone(error_t err, uint16_t value){}
	event void IntTemp.readDone(error_t err, uint16_t value){}
	event void SerialControl.startDone(error_t err){}
	event void RadioControl.stopDone(error_t err) {}
	event void SerialControl.stopDone(error_t err) {}
}

