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
  
  Arlo Emerson, 2016, Microsoft Edu Workshop

*/


//Library required to init the board and access the NeoPixels
#include <Adafruit_CircuitPlayground.h>

/*
  Change this to affect the range of the sensor readings. Ideally this matches the highest 
  number the sensor will report, so that highest readings will light up all the LEDs.
  Setting this to numbers lower than the sensor readings will bias the LED meter to react
  stronger to lower readings. Play around with it to see.
*/
static int mSensorCeiling = 22;


//In millis, each LED will stay lit for this duration before turning off.
static int mDecay = 50;

/*
  A variable to hold the sensor reading. This gets set each time loop() fires and is 
  needed so we can turn off the NeoPixels one by one before lighting them up again to the 
  new sensor reading. 
*/
int mPreviousMax = 0;

//Setup function where we initialize both serial communications and the board.
void setup() 
{
  //Enable serial communications.
  Serial.begin(9600);
  
  //Init the board.
  CircuitPlayground.begin();
  
  //This turns off all the NeoPixels should anything be lit.
  CircuitPlayground.clearPixels();
}


//Main loop runs repeatedly.
void loop() 
{
  //Local variable to hold the reading coming from A7 (the pin is labeled "#6" on the board).
  int sensorReading = analogRead(A7);
  
  /*
    Local variable that holds a remapped value from the sensor (from within a range of 0 to
    whatever we set mSensorCeiling to) which is returned as something from 0 to 9 (a range of 10 possible
    numbers), allowing us to light up the 10 NeoPixels on the board.
  */
  int maxAmount = map(sensorReading, 0, mSensorCeiling, 0, 8  );  

  for (int i=mPreviousMax;i>=0;i--)
  {
    CircuitPlayground.strip.setPixelColor(i, 0,0,0 );    
    CircuitPlayground.strip.show();
    delay(mDecay);
  }

  for (int i=0;i<=maxAmount;i++)
  {
    CircuitPlayground.strip.setPixelColor(i, Wheel(   map(i, 0, 8, 30, 150)   )  );
    CircuitPlayground.strip.show();
  }

  mPreviousMax = maxAmount;
  delay(10);
}


// swiped from the demo/example...
// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
    return CircuitPlayground.strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } 
  else if(WheelPos < 170) {
    WheelPos -= 85;
    return CircuitPlayground.strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } 
  else {
    WheelPos -= 170;
    return CircuitPlayground.strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}


