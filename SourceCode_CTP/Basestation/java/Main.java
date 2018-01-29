import java.io.*;
import java.util.*;
import net.tinyos.message.*;
public class Main implements MessageListener
{
	MoteIF mote;
	PrintStream outputFile = null;

	String Root_path;
        String Cert_path;
        String Key_path;
	public Main(int frequency)
	{
		try 
		{
			//register a listener
                        mote = new MoteIF();
                        mote.registerListener(new DemoAppMsg(), this);
			
			//packet a package in order to set Dissemination value
			DemoAppMsg ctr_msg = new DemoAppMsg();
                        ctr_msg.set_moteId((byte)0);
			ctr_msg.set_tempReading(0);
			ctr_msg.set_humidityReading(0);
                        ctr_msg.set_internalTempReading(frequency);
			//send this packet
			if(frequency > 0)
                        	mote.send(0, ctr_msg);

                        System.out.println("Connection Successful");
                }
                catch(Exception e) {}
		try
                {
                        outputFile = new PrintStream(new FileOutputStream("output.txt"));
                }
                catch (Exception e){}
		
	}
	public void messageReceived(int dest, Message m)
        {
		// Interpret msg as a DemoAppMsg
		DemoAppMsg msg = (DemoAppMsg)m;
		
		// Create time string
		long epochTime = System.currentTimeMillis()/1000;

		// Most values need to be scaled from their uint valeus
		double x, y, z, internalTempC, tempC, humidity;
		x = msg.get_internalTempReading();
		y = msg.get_tempReading();
		z = msg.get_humidityReading(); 

		internalTempC = ((((x/4096.0)*1.5)-0.986)/0.00355);
		tempC         = -39.5   + 0.01*y;
		humidity      = -2.0468 + 0.0367*z - 0.0000015955*z*z;
		
		// Adjust humidity for temp
		humidity      = (tempC-25)*(0.01 + 0.00008*tempC) + humidity;
		// Get temp in F
		double tempF    = (1.8*tempC) + 32.0;
		double intTempF = (1.8*internalTempC) + 32.0;
		// Get photo reading. No scaling necess

		// Create map for mote numbers to rooms
		Map<Integer, String> moteLoc = new HashMap<Integer, String>();
		moteLoc.put(18, "18");
		moteLoc.put(6, "6");
		moteLoc.put(13, "13");
		moteLoc.put(7, "7");
		moteLoc.put(5, "5");
		moteLoc.put(3, "3");
		moteLoc.put(11, "11");
		moteLoc.put(16, "16");
		moteLoc.put(4, "4");
                moteLoc.put(9, "9");
                moteLoc.put(15, "15");
                moteLoc.put(8, "8");
                moteLoc.put(14, "14");
                moteLoc.put(1, "1");
                moteLoc.put(0, "0");


		String moteId;
		Byte b1 = msg.get_moteId();
		int moteI = b1.intValue();
		if (moteLoc.containsKey(moteI))
		{
			moteId = moteLoc.get(moteI);
		}
		else
		{
		        moteId = "unknownMote";	
		}
		
		//packet information into jason file
	        String json;
		json = "{" + "\"sensorId"+"\""+":"+moteId+","+
			"\"timeStamp"+"\":"+epochTime+","+
			"\"temp"+"\":"+tempC + "}";
		System.out.println(json);

		// Create command string, run it, read output*		
		String[] command = {"java", "-jar", "aws-iot-java-client.jar", json, "./root-CA.crt", "./sensor_01-certificate.pem.crt", "./sensor_01-private.pem.key"};
		if (tempF < 100.0 && tempF > 0.0)
		{
			try{
				Process p = Runtime.getRuntime().exec(command);
				BufferedReader in = new BufferedReader(
						new InputStreamReader(p.getInputStream()));
				String line = null;
				while ((line = in.readLine()) != null) {
					System.out.println(line);
				}
			} catch (IOException e) {
			    e.printStackTrace();
			}
		}
		else
		{
			System.out.println("Invalid data in packet: ");
			System.out.println(json);
		}
	}

	public static void main(String args[])
  	{
		if (args.length < 1)
			System.out.println("Usage: java Main <Frequency times/per minute>");
		int frequency = Integer.parseInt(args[0]);

		new Main(frequency);
	}
}
