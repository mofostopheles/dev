//changing the graph to be more sine wavy rather than histogrammy

#include <TFT.h>
#include <SPI.h>

#define cs   9
#define dc   7
#define rst  8  

TFT mTFTscreen = TFT(cs, dc, rst);

//int mAveragedReading = 0;
const int mCenterLine = 64;
int mXPos = 160;
int mXPosPrev = 160;
int mYPosPrev = mCenterLine;

void setup() 
{
  Serial.begin(57600); 
  mTFTscreen.begin();
  mTFTscreen.background(100,0,0);
}

void loop()
{ 
  mTFTscreen.stroke(0,255,255);
  //mTFTscreen.line(0, mCenterLine, mXPos, mCenterLine);

  int sampleHeight = map(analogRead(A0),0,100,1,50);
  int averagedReading = 0;

  for(int i=0; i<sampleHeight; i++)
  { 
    // Average over sampleHeight measurements
    averagedReading += analogRead(A2);
  }

  averagedReading = averagedReading/sampleHeight;

  int plotY = averagedReading; //map(averagedReading, 0, 50, mCenterLine, 100);  
  mTFTscreen.line(mXPosPrev, mYPosPrev, mXPos, plotY + mCenterLine);
  mXPosPrev = mXPos;
  mYPosPrev = plotY + mCenterLine;

  if (mXPos <= 0)   
  {
    mXPos = 160; //reset
    mXPosPrev = 160; //reset
    mTFTscreen.background(100,0,0); //black out the screen

    //running this messes with the refresh rate big time 
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
    mXPos--;
  }
  delay(5);
}





