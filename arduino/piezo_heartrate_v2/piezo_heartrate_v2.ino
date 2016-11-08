#include <TFT.h>  // Arduino LCD library
#include <SPI.h>

// pin definition for the Uno
#define cs   9
#define dc   7
#define rst  8  

TFT TFTscreen = TFT(cs, dc, rst);

int oldvalue = 0;
int averagedReading = 0;
  

int xPos = 0;
int mLastPlotY = 0;

static int mSamples = 16;

void setup() 
{
  Serial.begin(57600); 
  TFTscreen.begin();
  TFTscreen.background(100,0,0);
}

int xPrevPos = 0;
int yPrevPos = 0;
void loop()
{  
  TFTscreen.stroke(0,255,255);
  TFTscreen.line(0, 72, xPos, 72);
  
  int plotY = map(analogRead(A2), 0, 100, 0, 36);  
  TFTscreen.line(0, 73, xPos, plotY);
  
  if (xPos >= 160)   
  {
    xPos = 0;
    TFTscreen.background(100,0,0);
   
  } 
  else
  {
    xPos++;
    

 
  }


  delay(5);
}




