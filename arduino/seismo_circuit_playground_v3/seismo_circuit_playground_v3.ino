/*

  Simple seismograph code designed for the Adafruit Circuit Playground board.
  See https://learn.adafruit.com/circuit-playground-lesson-number-0/intro
  for board specific details and tutorials.

  Basically this code just listens to analog pin 7 (#6 on the board) and
  lights up the onboard LEDs (NeoPixels).

  Code is written to be more or less as simple as possible while still making use
  of the NeoPixels which require a bit more syntax.

  Students are encouraged to hack this to make it more interesting, i.e. experiment
  with different colors or implement other features of the board.

  v3 contains serial function for talking to Excel plug-in.

  Arlo Emerson, 2016, Microsoft Edu Workshop

*/


// Library required to init the board and access the NeoPixels
#include <Adafruit_CircuitPlayground.h>

// Constants that appear in the serial message.
const String mDelimiter = ",";
const String GROUP_ID = "groupID";
const String DEVICE_ID = "deviceID";

// Will contain the string we send out to serial.
String mSerialMessage = "";

/*
  Change this to affect the range of the sensor readings. Ideally this matches the highest
  number the sensor will report, so that highest readings will light up all the LEDs.
  Setting this to numbers lower than the sensor readings will bias the LED meter to react
  stronger to lower readings. Play around with it to see.
  Note: the values returned from your seismometer depend among other things, the strength of the magnet, 
  number of coil windings and any hysteresis and energy loss effects present in the circuit.
*/
static int mSensorCeiling = 22;


// In millis, each LED will stay lit for this duration before turning off.
static int mDecay = 50;

/*
  A variable to hold the sensor reading. This gets set each time loop() fires and is
  needed so we can turn off the NeoPixels one by one before lighting them up again to the
  new sensor reading.
*/
int mPreviousMax = 0;

// Setup function where we initialize both serial communications and the board.
void setup()
{
  // Enable serial communications.
  Serial.begin(9600);

  // Init the board.
  CircuitPlayground.begin();

  // This turns off all the NeoPixels should anything be lit.
  CircuitPlayground.clearPixels();
}


// Main loop runs repeatedly.
void loop()
{
  // Local variable to hold the reading coming from A7 (the pin is labeled "#6" on the board).
  int sensorReading = analogRead(A7);

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
  }

  /*
    Local variable that holds a remapped value from the sensor (from within a range of 0 to
    whatever we set mSensorCeiling to) which is returned as something from 0 to 9 (a range of 10 possible
    numbers), allowing us to light up the 10 NeoPixels on the board.
  */
  int maxAmount = map(sensorReading, 0, mSensorCeiling, 0, 9  );

  /*
    Starting with the maximum number of lights that were previously lit
    (and presumably still lit), turn them off one by one.
  */
  for (int i = mPreviousMax; i >= 0; i--) // count backwards starting at mPreviousMax
  {
    // Set the pixel color to 0,0,0 (no light) for each LED (i).
    CircuitPlayground.strip.setPixelColor(i, 0, 0, 0 );

    // Call show() after setting color.
    CircuitPlayground.strip.show();

    // Introduce a delay so the lights animate off rather than all at once
    delay(mDecay);
  }

  // Light up each LED starting with the first LED and working up to whatever the maxAmount is.
  for (int i = 0; i <= maxAmount; i++)
  {
    /*
      Set the pixel color using the color wheel.
      The Wheel function takes a byte as its sole parameter and returns an unsigned int, 
      the format setPixelColor needs to set the color.
      Note we are deriving the input value to Wheel using the map function. Here we use i
      as our input, 0 through 9 as our boundary, and returning a proportional number between 30 and 150.
      Experiment with changing the last two value to tweak the colors.
    */
    CircuitPlayground.strip.setPixelColor(i, Wheel(   map(i, 0, 9, 30, 150)   )  );

    // Call show() after setting color.
    CircuitPlayground.strip.show();
  }

  // Set member variable mPreviousMax to hold whatever maxAmount is.
  mPreviousMax = maxAmount;

  // Introduce a 10 millisecond delay to regulate timing of the main loop.
  delay(10);
}


// Input a value 0 to 255 to get a color value. A byte holds values from 0 to 255.
// The colors are a transition r - g - b - back to r.
// Wheel returns an unsigned int which could be any number in this range:
// [0-4294967295] or equivalently [0x00000000-0xFFFFFFFF]
uint32_t Wheel(byte pWheelPos)
{
  if (pWheelPos < 85)
  {
    return CircuitPlayground.strip.Color(pWheelPos * 3, 255 - pWheelPos * 3, 0);
  }
  else if (pWheelPos < 170)
  {
    pWheelPos -= 85;
    return CircuitPlayground.strip.Color(255 - pWheelPos * 3, 0, pWheelPos * 3);
  }
  else
  {
    pWheelPos -= 170;
    return CircuitPlayground.strip.Color(0, pWheelPos * 3, 255 - pWheelPos * 3);
  }
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
  int loopLength = 16; //we are spoofing the values for N data point
  for (int i = 0; i < loopLength; i++)
  {
    tmpString += ("0" + (i < loopLength - 1 ? mDelimiter : ""));
  }
  return tmpString;
}


