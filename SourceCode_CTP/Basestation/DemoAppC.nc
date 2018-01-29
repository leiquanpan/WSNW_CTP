#include "DemoApp.h"
#include "DemoApp_Serial.h"
#include "Ctp.h"
configuration DemoAppC
{
}
implementation
{
	components DemoP, MainC;
    components DisseminationC;
    components new DisseminatorC(uint32_t, SAMPLE_RATE_KEY) as Object32C;
    components CollectionC as Collector;
    components new CollectionSenderC(SENDER_VALUE);

	components new Msp430InternalTemperatureC() as InternalTempC;
	components new SensirionSht11C() as TempC;
	components ActiveMessageC;
	components SerialActiveMessageC as SerialC;
	components LedsC;
	components new TimerMilliC();
	
	DemoP.Boot     -> MainC;
    DemoP.RoutingControl -> Collector;
    DemoP.Receive -> Collector.Receive[SENDER_VALUE];
    DemoP.CollectionPacket -> Collector;
    DemoP.CtpInfo -> Collector;
    DemoP.CtpCongestion -> Collector;
    DemoP.Send -> CollectionSenderC;
    DemoP.RootControl -> Collector;
    DemoP.DisseminationControl -> DisseminationC;
	DemoP.IntTemp  -> InternalTempC;
    DemoP.Temp     -> TempC.Temperature;
	DemoP.DisseminationPeriod -> Object32C;
	DemoP.Update -> Object32C;
	DemoP.RadioControl -> ActiveMessageC;
	DemoP.Packet -> ActiveMessageC;

	DemoP.SerialControl -> SerialC;
  	DemoP.SerialAMSend -> SerialC.AMSend[AM_DEMO_MESSAGE];
    DemoP.SerialReceive -> SerialC.Receive[AM_DEMO_MESSAGE];
  	DemoP.SerialPacket -> SerialC;

	DemoP.Leds -> LedsC;
	DemoP.Timer -> TimerMilliC;
}
