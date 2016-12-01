/*

  This code accesses the accelerometer on the Adafruit Circuit Playground, sending the "Y" data
  to the serial port for talking to the Excel plug-in.

  Arlo Emerson, 2016, Microsoft Edu Workshop

*/

#include <Adafruit_CircuitPlayground.h>
#include <Wire.h>
#include <SPI.h>

// Constants that appear in the serial message.
const String DELIMITER = ",";
const String GROUP_ID = "groupID";
const String DEVICE_ID = "deviceID";

// A variable to hold the current seismograph reading.
int mCurrentRead = 0;

// A time interval in milliseconds used as a delay between each iteration of the main loop.
static int mDelayTime = 75;


void setup()
{
  Serial.begin(115200);
  CircuitPlayground.begin();
}

void loop()
{
  mCurrentRead = CircuitPlayground.motionY();
  sendToSerial();
  delay(mDelayTime);
}


void sendToSerial()
{
  /*

    Formats the data for use with the Cordoba Excel Add-In.
    The format:
    groupID, deviceID, time, data1, data2, ...

    To customize the worksheet you can send any data you want. Just add another comma and data point
    following the existing format. Be sure to end with a line feed as this defines the end of the
    serial message.

  */
  
  Serial.print(GROUP_ID);
  Serial.print(DELIMITER);
  Serial.print(DEVICE_ID);
  Serial.print(DELIMITER);

  // Current timestamp in milliseconds.
  Serial.print(millis());
  Serial.print(DELIMITER);

  // data1
  Serial.print(mCurrentRead);
  Serial.print(DELIMITER);
  
  // Add a line break to define the end of the serial message.
  Serial.println();
}


