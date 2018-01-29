#include <AM.h>
#include "Ctp.h"

module DemoP
{
	uses interface Boot;

    uses interface StdControl as DisseminationControl;
    uses interface StdControl as RoutingControl;
    uses interface DisseminationValue<uint32_t> as DisseminationPeriod;

    uses interface Read<uint16_t> as IntTemp;
	uses interface Read<uint16_t> as Temp;

	uses interface SplitControl as RadioControl;

    uses interface Send;
	uses interface Packet;

    uses interface CollectionPacket;
    uses interface CtpInfo;
    uses interface CtpCongestion;

	uses interface Leds;
	uses interface Timer<TMilli>;
}

implementation
{
	message_t buf;

    bool sendBusy = FALSE;
    uint16_t seqno = 0;
    uint8_t msglen;

	uint16_t intTempPayload  = 0;
	uint16_t tempPayload     = 0;
	
	task void readSensors();
	task void sendPacket();
	
	event void Boot.booted()
	{
		call RadioControl.start();
            //call SerialControl.start();
	}
	
	event void RadioControl.startDone(error_t err)
	{
        call DisseminationControl.start();
        call RoutingControl.start();
		if(TOS_NODE_ID != 0)
		{
			//call Timer.startPeriodic(307200);
			call Timer.startPeriodic(5096);
                }
	}

    event void DisseminationPeriod.changed()//for changing sampling period
    {
        const uint32_t* newVal = call DisseminationPeriod.get();
        call Timer.stop();
        call Timer.startPeriodic(*newVal);
    }


	task void readSensors()
	{
        uint16_t metric;
        am_addr_t parent = 0;
		demo_message_t * payload = (demo_message_t *)call Send.getPayload(&buf, sizeof(demo_message_t));

        call CtpInfo.getParent(&parent);
        call CtpInfo.getEtx(&metric);


		if(call IntTemp.read() != SUCCESS){
			post readSensors();
                }
		payload->internalTempReading = intTempPayload;

		if(call Temp.read() != SUCCESS){
			post readSensors();
                }
		payload->tempReading = tempPayload;


	payload->moteId = TOS_NODE_ID;
        payload->seqno = seqno;
        payload->parent = parent;
        payload->metric = metric;
        payload->hopcount = 0;

        post sendPacket();
	}

	event void Timer.fired()
	{
	call Leds.led1Toggle();
        if (!sendBusy)
            post readSensors();
	}

	event void IntTemp.readDone(error_t err, uint16_t value)
	{
		if(err != SUCCESS)
			post readSensors();
		else
		{
			intTempPayload = value;
		}
	}
	
	event void Temp.readDone(error_t err, uint16_t value)
	{
		if(err != SUCCESS)
			post readSensors();
		else
		{
                        // Scale to Celsius
			tempPayload = value;
		}
	}

	task void sendPacket()
	{
		if (call Send.send(&buf, sizeof(demo_message_t)) != SUCCESS){
			call Leds.led0Toggle();
			post sendPacket();
		}
        else {
            sendBusy = TRUE;
	    call Leds.led2Toggle();
            seqno++;
        }
	}

    event void Send.sendDone(message_t* m, error_t err) {
        if (err != SUCCESS) {
            call Leds.led0On();
        }
	call Leds.led0On();
        sendBusy = FALSE;
    }

    event void RadioControl.stopDone(error_t err) {}
}
