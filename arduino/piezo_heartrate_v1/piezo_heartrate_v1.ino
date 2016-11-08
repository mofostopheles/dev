#include <TFT.h>  // Arduino LCD library
#include <SPI.h>

// pin definition for the Uno
#define cs   9
#define dc   7
#define rst  8  

TFT TFTscreen = TFT(cs, dc, rst);

int threshold = 60;
int oldvalue = 0;
int averagedReading = 0;
unsigned long oldmillis = 0;
unsigned long newmillis = 0;
int cnt = 0;
int timings[16];
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
  oldvalue = averagedReading;
  averagedReading = 0;
  int sampleCount = 0;


  for(int i=0; i<mSamples; i++)
  { 
    // Average over mSamples measurements
    averagedReading += analogRead(A2);
  }

  averagedReading = averagedReading/mSamples;
 
  //averagedReading = analogRead(A2);
  
  Serial.println(averagedReading);
  int sensitivity = map(analogRead(A0),0,1024,1,60);


  int bottomMargin = 20;
  int plotY = 0;
  /*
  if (averagedReading < 5)
  {
    plotY = mLastPlotY - 2;
  }
  else
  {
    plotY = map(averagedReading,sensitivity,30,0,TFTscreen.height());
    mLastPlotY = plotY;
  }
  */
  
  plotY = map(averagedReading,sensitivity,30,0,TFTscreen.height());

  TFTscreen.stroke(0,255,255);
  TFTscreen.line(xPos, TFTscreen.height(), xPos, TFTscreen.height()-plotY);

  if (xPos >= 160)   
  {
    xPos = 0;
    TFTscreen.background(100,0,0);
//    char labelTmpText[4];
//  dtostrf(sensitivity, 4, 4, labelTmpText);
//  TFTscreen.stroke(0,0,255);
//  TFTscreen.setTextSize(1); 
//  TFTscreen.text( labelTmpText, 2, 2);
//  
  } 
  else
  {
    xPos++;
    

 
  }

  delay(5);
}




