/*

 based on work by:
 Created 15 April 2013 by Scott Fitzgerald
 http://arduino.cc/en/Tutorial/TFTGraph
 
 
 
 Nov 2016 - modded
 arloemerson@gmail.com
 code for measuring wave frequency
 
 implemented a TFT screen
 
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
static int node1InstrumentLight = 13;
static int node2InstrumentLight = 13; //these used to be different hardware lights
static int standbyInstrumentLight = 13; //but we've got a screen now so just use pin 13
static float mFixedWavelength = 0.05; //5cm in meters
static float mNumberOfNodes = 11.0; //number of gumdrop sticks

boolean mTimerStandby = false;
boolean mTimerStarted = false;
unsigned long mMillisStart;
unsigned long mTime;

//char mBuffer[32];
char mIntroTextLine1[] = "To begin, push the leftmost";
char mIntroTextLine2[] = "skewer down so the contact";
char mIntroTextLine3[] = "is in the water.";
char mIntroTextLine4[] = "Release the skewer and the";
char mIntroTextLine5[] = "wave speed measurement";
char mIntroTextLine6[] = "will start automatically.";


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
  pinMode(13, OUTPUT);
  writeIntroScreen();
}


void drawGraph()
{
  
  int sensor = analogRead(A0);
  int drawHeight = map(sensor,0,1023,0,TFTscreen.height());
  
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

  //delay(16);
}

void loop()
{
  node1 = digitalRead(2);  
  node2 = digitalRead(3); 

  if(node1 == 0 && mTimerStandby == false && mTimerStarted == false) //node 1 was dunked in the water
  {
    //initialize all our variables
    mMillisStart = 0;
    mTime = 0;
    mTimerStandby = true;
    mTimerStarted = false;
    digitalWrite(standbyInstrumentLight, HIGH);
    Serial.println("\nstanding by...");
    clearScreen();
  }
  
  if(mTimerStandby == true)
  {
    writeToScreen( " STANDBY", 0, 50  );
    drawGraph();
  }

  if(node1 == 1 && mTimerStandby == true) //node 1 emerged from the water, breaking the circuit
  {
    digitalWrite(standbyInstrumentLight, LOW);
    mTimerStarted = true;
    mTimerStandby = false;
    mMillisStart = millis();
    flashLED(node1InstrumentLight);
    Serial.println("START");
    clearScreen();
    writeToScreen( "  START", 0, 50  );
  }

  if(node2 == 0 && mTimerStarted == true) //node 2 dunked in the water, we're done.
  {
    checkeredFlag();
    
    //stop the timer, calculate the wave frequency
    mTimerStarted = false;
    mTime = millis() - mMillisStart;

    flashLED(node2InstrumentLight);
    Serial.println("--==FINISH==--");
    clearScreen();
    writeToScreen( " FINISH", 0, 50 );
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

void checkeredFlag()
{
  TFTscreen.stroke(0,0,0);
  int counter = 0;
  
    for (int i=0; i<10; i++)
    {        
      if (counter%2==0)
      {
        TFTscreen.fill(255,255,255);
        
      }
      else
      {
        TFTscreen.fill(0,0,0);
      }
      TFTscreen.rect(0, i*10, 10, i*10);
      counter++;
    }
    
    
    for (int i=0; i<10; i++)
    {        
      if (counter%2==0)
      {
        TFTscreen.fill(255,255,255);
        
      }
      else
      {
        TFTscreen.fill(0,0,0);
      }
      TFTscreen.rect(0, i*10, 10, i*10);
      counter++;
    }
   
}

void clearScreen()
{
  TFTscreen.background(0, 0, 0);  
}

void writeIntroScreen()
{
  TFTscreen.stroke(255,255,255);
  TFTscreen.setTextSize(1);
  TFTscreen.text( mIntroTextLine1, 0, 0);
  TFTscreen.text( mIntroTextLine2, 0, 15);
  TFTscreen.text( mIntroTextLine3, 0, 30);
  TFTscreen.text( mIntroTextLine4, 0, 60);
  TFTscreen.text( mIntroTextLine5, 0, 75);
  TFTscreen.text( mIntroTextLine6, 0, 90);
  TFTscreen.setTextSize(5);

  delay(100);
}

void writeToScreen(String pText, int pX, int pY)
{
  //TFTscreen.background(0, 0, 0);
  
  char charBuf[32];
  pText.toCharArray(charBuf, 32);
  
  TFTscreen.stroke(255,255,255);
  TFTscreen.setTextSize(3);
  TFTscreen.text( charBuf, pX, pY);
  TFTscreen.setTextSize(2);

  //delay(1000);
  
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





