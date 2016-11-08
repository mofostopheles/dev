#include <TFT.h>  // Arduino LCD library
#include <SPI.h>

// pin definition for the Uno
#define cs   9
#define dc   7
#define rst  8  

TFT TFTscreen = TFT(cs, dc, rst);

int oldvalue = 0;
int averagedReading = 0;
static int mCenterLine = 64;
int xPos = 160;
int mLastPlotY = 0;
static int mSamples = 16;

void setup() 
{
  Serial.begin(57600); 
  TFTscreen.begin();
  TFTscreen.background(100,0,0);
}

void loop()
{  
  TFTscreen.stroke(0,255,255);
  TFTscreen.line(0, mCenterLine, xPos, mCenterLine);
  int piezoRead = analogRead(A2);
  int plotY = map(piezoRead, 0, 500, mCenterLine, 100);
  
  TFTscreen.line(xPos, mCenterLine+2, xPos, plotY);
  
  if (xPos <= 0)   
  {
    xPos = 160;
    TFTscreen.background(100,0,0);
  } 
  else
  {
    xPos--;
  }
  delay(5);
}




