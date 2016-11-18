/*

  Simple seismograph code designed for the Arduino Uno board (or equivalent).
  v2 contains serial function for talking to Excel plug-in.

  Arlo Emerson, 2016, Microsoft Edu Workshop

*/

static int mLED = 11; // The pin where the long leg of your LED is inserted. Insert the other leg into GND.
// Note: pin 13s onboard LED does not support PWM (so no fading is possible, must use an external LED).

// Constants that appear in the serial message.
const String mDelimiter = ",";
const String GROUP_ID = "groupID";
const String DEVICE_ID = "deviceID";

// Will contain the string we send out to serial.
String mSerialMessage = "";

// Setup function where we initialize serial communications.
void setup()
{
  // Enable serial communications.
  Serial.begin(9600);

  // Sets this pin to be OUTPUT so we can send HIGHs and LOWs to it.
  pinMode(mLED, OUTPUT);
}

// Main loop runs repeatedly.
void loop()
{
  // Local variable to hold the reading coming from pin A0.
  int sensorReading = analogRead(A0);

  // This stuff is for setting up the packet of data we need to send to Excel via the serial port
  mSerialMessage = getHeaderMessage(); // init the string with our header data
  mSerialMessage += sensorReading; // add the sensor reading
  mSerialMessage += getBodyMessage(); // this will fill out the remaining available data slots with zeros.

  /*
    No activity will probably be 0, so lets filter on that and only print
    when the sensorReading is 1 or more.
  */
  if (sensorReading > 0)
  {
    Serial.println( mSerialMessage ); // Print out the sensor reading.

    /*
      Light up the LED depending on strength of sensorReading.
      Use map() to proportionally map our reading to a value that will light the LED (0 --> 255).
      Note highSensorReading is set to 100. Experiment with changing this value and see how it
      effects the apparent sensitivity as displayed by the LED.
    */
    int lowSensorReading = 1; // The lower bound of the value's current range.
    int highSensorReading = 9; // The upper bound of the value's current range.
    int lowBrightness = 50; // The lower bound of the value's target range.
    int fullBrightness = 255; // The upper bound of the value's target range. 255 is the max we need to light the LED fully.
    // See https://www.arduino.cc/en/Reference/Map for full documentation of this very useful function.
    int brightnessValue = map( sensorReading, lowSensorReading, highSensorReading, lowBrightness, fullBrightness );

    // Send our calculated brightness value to the pin. Since analogWrite can send one of 1024 values, we can
    // simulate a fading effect.
    analogWrite( mLED, brightnessValue );

    // Hold onto that level of brightness and fade it back to 0 over time.
    for (int i = brightnessValue; i >= 0; i--) // The higher brightnessValue is the longer this will take.
    {
      analogWrite(mLED, i);
      delay(15);
    }
  }

  // Regulate the speed of the loop with a 10 millisecond delay
  delay(10);
}

/*
   Each message to the Excel add-in needs to have these parameters
*/
String getHeaderMessage()
{
  String tmpString = GROUP_ID;
  tmpString += mDelimiter;
  tmpString += DEVICE_ID;
  tmpString += mDelimiter;
  tmpString += millis();
  tmpString += mDelimiter;
  return tmpString;
}

/*
   Fill out the body of the message.
   The excel add-in may or may not handle an incomplete message so we're adding them here.
*/
String getBodyMessage()
{
  String tmpString = mDelimiter;
  int loopLength = 16; //we are spoofing the values for N data points
  for (int i = 0; i < loopLength; i++)
  {
    tmpString += ("0" + (i < loopLength - 1 ? mDelimiter : ""));
  }
  return tmpString;
}


