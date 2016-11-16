//simple graph of serial data
import processing.serial.*;

Serial mPort;        
int mXPos = 1;         
String mInString = "";
float mInByte; 
static int mYCenterLine = 560;
int mPreviousY = 0;
int mPreviousX = 0;
static int mYFactor = 25;
static int mXDistance = 1;

void setup ()
{
  size(1920, 1080);          
  //println(Serial.list());
  //mPort = new Serial(this, Serial.list()[0], 115200);
  mPort = new Serial(this, "COM116", 115200);
  // don't generate a serialEvent() unless you get a newline character:
  mPort.bufferUntil('\n');
  background(0, 0, 0);  
  centerline();
}

void centerline()
{  
  stroke(0, 100, 255);
  strokeWeight(2);
  line(0, height/2, width, height/2);
}

void draw ()
{   
  centerline();

  // at the edge of the screen, go back to the beginning:
  if (mXPos >= width)
  {
    mXPos = 0;
    mPreviousX = 0;
    background(0, 0, 0);  
  } 
  else
  {
    // increment the horizontal position:
    mXPos+=mXDistance; 
  }
   
  stroke(255, 0, 0);
  strokeWeight(8);
  strokeCap(ROUND);
  line(mPreviousX, mPreviousY, mXPos, (mInByte * mYFactor) + mYCenterLine);
  mPreviousY = int((mInByte * mYFactor) + mYCenterLine);
  mPreviousX = mXPos;
}

void serialEvent (Serial myPort)
{
  // get the ASCII string:
  mInString = myPort.readStringUntil('\n');

  if (mInString != null)
  {    
    mInString = trim(mInString);
    String[] pulseData = split(mInString, "\t");
    mInByte = float(pulseData[0]);
  }
}