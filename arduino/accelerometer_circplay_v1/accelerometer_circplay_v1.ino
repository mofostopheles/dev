
#include <Adafruit_CircuitPlayground.h>

#include <Wire.h>
#include <SPI.h>


//  A variable to hold the previous seismograph reading.
int mPreviousRead = 0;

// A variable to hold the current seismograph reading.
int mCurrentRead = 0;

// A variable used to hold the difference between the previous and current readings.
float mDifference = 0;

// A variable used to hold the calulated percentage difference between the previous and current readings.
float mPercentChange = 0;

// Multiplier of 100 to convert calculated value to a percentage
static int mConvertToPercentage = 100;

// Multiplier to set the scale of the output. Increase if the results are too small to graph well.
static int mScale = 10;

// A time interval in milliseconds used as a delay between each iteration of the main loop.
static int mDelayTime = 75;


void setup()
{
  Serial.begin(115200);
  CircuitPlayground.begin();
}

void loop()
{
  // Read the raw seismograph from the Arduino on analog input pin A0.
  //mCurrentRead = CircuitPlayground.motionY();
  Serial.println(CircuitPlayground.motionY(), 2);

/*
  // Find the difference between the previous and current readings.
  mDifference = mCurrentRead - mPreviousRead;

  // Divide the difference by the previous reading and multiply by 100 to convert to a percentage.
  mPercentChange = mDifference / mPreviousRead * mConvertToPercentage;

  // Multiply by the scale factor. Increase to amplify the signal values, and decrease to diminish them.
  mPercentChange *= mScale;

  // Send the collected data to the computer via the serial connection.
  sendToSerial();

  // Set the previous reading (for the next loop) to be equal to the current reading.
  mPreviousRead = mCurrentRead;
*/
  // Pause to increase stability and to allow for serial communications to be processed.
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
  /*
    Serial.print(groupID);
    Serial.print(",");
    Serial.print(deviceID);
    Serial.print(",");

    // Current timestamp in milliseconds.
    Serial.print(millis());
    Serial.print(",");

    // data1
    Serial.print(0);
    Serial.print(",");
  */
  // data2
  Serial.print(mPercentChange, 2);
  //Serial.print(",");

  // Add a line break to define the end of the serial message.
  Serial.println();
}


