/*

 based on work by:
 Created 15 April 2013 by Scott Fitzgerald
 http://arduino.cc/en/Tutorial/TFTGraph
 
 
 
 Nov 2016 - modded
 arloemerson@gmail.com
 code for measuring wave frequency
 
 */

#include <TFT.h>  // Arduino LCD library
#include <SPI.h>

// pin definition for the Uno
#define cs   9
#define dc   7
#define rst  8  

TFT TFTscreen = TFT(cs, dc, rst);

// position of the line on screen
int xPos = 0;

int node1;
int node2;
//static int node1InstrumentLight = 8;
//static int node2InstrumentLight = 9;
//static int standbyInstrumentLight = 12;
static float mFixedWavelength = 0.05; //5cm in meters
static float mNumberOfNodes = 11.0; //number of gumdrop sticks

boolean mTimerStandby = false;
boolean mTimerStarted = false;
unsigned long mMillisStart;
unsigned long mTime;

char mBuffer[32];
char mIntroText[] = "To begin, push the leftmost skewer down and hold.";
  
void setup()
{
  // initialize the serial port
  Serial.begin(9600);

  // initialize the display
  TFTscreen.begin();

  // clear the screen with a pretty color
  TFTscreen.background(250,16,200); 

  pinMode(2, INPUT_PULLUP); 
  pinMode(3, INPUT_PULLUP);
  
  TFTscreen.stroke(255,255,255);
  TFTscreen.setTextSize(1);
  String("hello").toCharArray(mBuffer, 16);
  TFTscreen.text( foo, 0, 0);
  TFTscreen.setTextSize(5); 
  
}

void loop()
{
  // read the sensor and map it to the screen height
  int sensor = analogRead(A0);
  int drawHeight = map(sensor,0,1023,0,TFTscreen.height());

  // print out the height to the serial monitor
  //Serial.println(drawHeight);

  // draw a line in a nice color
  TFTscreen.stroke(250,180,10);
  TFTscreen.line(xPos, TFTscreen.height()-drawHeight, xPos, TFTscreen.height());

  // if the graph has reached the screen edge
  // erase the screen and start again
  if (xPos >= 160) {
    xPos = 0;
    TFTscreen.background(250,16,200); 
  } 
  else {
    // increment the horizontal position:
    xPos++;
  }

  delay(16);

  /////////////

  node1 = digitalRead(2);  
  node2 = digitalRead(3); 

  if(node1 == 0 && mTimerStandby == false && mTimerStarted == false) //node 1 was dunked in the water
  {
    //initialize all our variables
    mMillisStart = 0;
    mTime = 0;
    mTimerStandby = true;
    mTimerStarted = false;
    //digitalWrite(standbyInstrumentLight, HIGH);
    Serial.println("\nstanding by...");
  }

  if(node1 == 1 && mTimerStandby == true) //node 1 emerged from the water, breaking the circuit
  {
    //digitalWrite(standbywriteToScreen( "--==START==--" );InstrumentLight, LOW);
    mTimerStarted = true;
    mTimerStandby = false;
    mMillisStart = millis();
    //flashLED(node1InstrumentLight);
    Serial.println("--==START==--");
    writeToScreen( "--==START==--" );
  }

  if(node2 == 0 && mTimerStarted == true) //node 2 dunked in the water, we're done.
  {
    //stop the timer, calculate the wave frequency
    mTimerStarted = false;
    mTime = millis() - mMillisStart;

    //flashLED(node2InstrumentLight);
    Serial.println("--==FINISH==--");
    Serial.println("time was: ");
    Serial.print(mTime/1000.0);
    Serial.print(" seconds\n\n");
    float calculatedFrequency = 1000.0/(mTime / mNumberOfNodes); //f=1/T, also note we are extrapolating time of 1 node from total time divided by all nodes

    float calculatedSpeed = mFixedWavelength * calculatedFrequency;
    Serial.println("wave speed is: ");
    Serial.print(calculatedSpeed);
    Serial.print(" meters per second, or ");
    Serial.print(calculatedFrequency);
    Serial.print(" Hertz \n");
  }    

}



void writeToScreen(String pText)
{
  TFTscreen.stroke(255,255,255);TFTscreen.stroke(255,255,255);
  TFTscreen.setTextSize(2);
  pText.toCharArray(foo, 16);
  TFTscreen.text( foo, 0, 0);
  TFTscreen.setTextSize(5); 
}

void flashLED(int pPin)
{
  for (int i=0;i<5;i++)
  {
    digitalWrite(pPin, HIGH);
    delay(50);
    digitalWrite(pPin, LOW);
    delay(50);       
  } 
}



