/*
  super simple seismograph code.
  basically it just listens to analog pin 7 (#6 on the board)
  the code is designed to be absolutely bare minimum.
  students are encouraged to hack this to make it more interesting.
  
  arlo emerson, 2016
 */
#include <Adafruit_CircuitPlayground.h>

static int mSensorCeiling = 22; //change this to affect sensitivity of LED display based on the sensor reading
static int mDecay = 50; //millis that each LED will stay lit before turning off

void setup() 
{
  Serial.begin(9600);
  CircuitPlayground.begin();
  CircuitPlayground.clearPixels();
}

int mPreviousMax = 0;

void loop() 
{
  int sensorReading = analogRead(A7);
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


