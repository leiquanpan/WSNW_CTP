COMPONENT = DemoAppC
BUILD_EXTRA_DEPS = Main.class

Main.class: DemoAppMsg.java
	javac *.java 

DemoAppMsg.java: ../DemoApp.h
	nescc-mig java -java-classname=DemoAppMsg ../DemoApp_Serial.h demo_message_serial -o $@

clean:
	rm -f DemoAppMsg.java  *.class



