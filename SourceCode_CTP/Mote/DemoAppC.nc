#include "DemoApp.h"
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
	components LedsC;
	components new TimerMilliC();

    DemoP.RoutingControl -> Collector;
    DemoP.CollectionPacket -> Collector;
    DemoP.CtpInfo -> Collector;
    DemoP.CtpCongestion -> Collector;
    DemoP.Send -> CollectionSenderC;
    DemoP.DisseminationControl -> DisseminationC;
	DemoP.Boot     -> MainC;
	DemoP.IntTemp  -> InternalTempC;
    DemoP.Temp     -> TempC.Temperature;
	DemoP.DisseminationPeriod -> Object32C;
	DemoP.RadioControl -> ActiveMessageC;
	DemoP.Packet -> ActiveMessageC;

	DemoP.Leds -> LedsC;
	DemoP.Timer -> TimerMilliC;
}
