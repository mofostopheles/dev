#include <TFT.h>  // Arduino LCD library
#include <SPI.h>

// pin definition for the Uno
#define cs   9
#define dc   7
#define rst  8  

TFT TFTscreen = TFT(cs, dc, rst);

int oldvalue = 0;
int averagedReading = 0;
int mCenterLine = 12;
int xPos = 160;
int mLastPlotY = 0;
int mSamples = 4;

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
  
  int sampleHeight = map(analogRead(A0),0,1024,1,1024);
  
  //int mCenterLine = map(analogRead(A1),0,1024,1,128);
  //
  
  //int mCenterLine = map(analogRead(A1),0,1024,1,128);
  //Serial.println(mCenterLine);
  
  int averagedReading = 0;
  for(int i=0; i<sampleHeight; i++)
  { 
    // Average over mSamples measurements
    averagedReading += analogRead(A2);
  }
  //int piezoRead = analogRead(A2);
  averagedReading = averagedReading/sampleHeight;
   //Serial.println(sampleHeight);
    
  int plotY = map(averagedReading, 0, 50, mCenterLine, 100);
  
  TFTscreen.line(xPos, mCenterLine+2, xPos, plotY);
  
  

  
  
  if (xPos <= 0)   
  {
    xPos = 160;
    TFTscreen.background(100,0,0);
    
    mStartCounting = 
    /*
    char labelTmpText[4];
  dtostrf(sampleHeight, 2, 2, labelTmpText);
  TFTscreen.stroke(255,255,255);
  TFTscreen.setTextSize(1); 
  TFTscreen.text( labelTmpText, 2, 2);
  */
    

  } 
  else
  {
    xPos--;
  }
  delay(5);
}




