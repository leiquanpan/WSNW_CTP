There are four pieces of source code contained in this directory. 

1.The Mote program is a TinyOS application that can be loaded onto a mote platform using the command:
	cd Sourcecode_CTP
	cd Mote
	make telosb reinstall.(Node ID)
	(For example make telosb reinstall.5)

2.The Basestation program is a TinyOS application that can be loaded onto a base platform using the command:
	cd Sourcecode_CTP
	cd Basestation
	make telosb reinstall.0
	(The Receiver ID must be set to 0)
  The mote with Basestation being run on it should be plugged into the PC running the java application. Before running, you should set MOTECOM by following command:

	export MOTECOM=serial@/dev/ttyUSB0:telosb

3.The java application designed to be run on the basestation PC is contained in the Basestation directory. It is called Main.java and just run it with the measurement frequency, your certificate(root-CA) address, and your private key address, run by following command:

	java Main (Measurement Frequency)(Address to Root.CA)(address to certificate) (address to private key) 
	(You first need to identify the measurement frequency: timeval*1000, for example, if you need to measure temperature per 5 secs, you need to input 5000.)
	(The address can be relative address)

4.The User_Interface.py is a script that was designed for read data from AWS DynamoDB and display them, run by following command:
	
	python User_Interface.py
	(You need to provide three informations, Start Time, End Time and Nodes’ ID. The input format of your data time should be as follows: 2010-12-29 12:22:45. You need to identify correct nodes’ IDs. Make sure that you have data during your specified time, unless the program will fail)






Hints:

Whenever you want to run Main.java, you first need to put three documents under the same directory with Main.java. They are AWS IoT things’ credentials and private key. (Such as Root-CA.crt, sensor_0x-credentials.pem.crt, sensor_0x-private.key.pem)

Whenver you want to run User_Interface.py, you need to modify one sentence in the program, which is 
	client = boto3.client('dynamodb',region_name='uswest-2',aws_access_key_id='AKIAI4V7PJJGQ******',aws_secret_access_key='69a/sfegtKXMHbVreSHFW*********')
Just inputs the correct area and access key.





