//simple graph of serial data
import processing.serial.*;
 
Serial myPort;        
int xPos = 1;         
String inString = "";
float inByte; 
int yCenterline = 100;

void setup ()
{
  size(500, 200);        
  
  //println(Serial.list());

  //myPort = new Serial(this, Serial.list()[0], 115200);
  myPort = new Serial(this, "COM112", 115200);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  // set inital background:
  background(0,0,0);
  
  centerline();
  
}

void centerline()
{
  
 stroke(0,100,255);
  line(0,100,500,100); 
}

void draw ()
{  
  
  centerline();
    //You may need to change 0.25 and 0.45 to fit your
    //pulse waveform better
    //inByte = map(inByte, 10.0, 65.0, 0, height);
        
    // draw the line:
    stroke(255,0,0);
    
    
    line(xPos, height, xPos, height - (inByte *2 ) - yCenterline);
    
    // at the edge of the screen, go back to the beginning:
    if (xPos >= width)
    {
      xPos = 0;
      background(0,0,0);
    }
    else
    {
      // increment the horizontal position:
      xPos+=4;
    } 
    
}

void serialEvent (Serial myPort)
{
  // get the ASCII string:
  inString = myPort.readStringUntil('\n');
 
 
  if (inString != null)
  {    
    
    
    // trim off any whitespace:
    inString = trim(inString);
    //println(inString);
    String[] pulseData = split(inString, "\t");
    // convert to an int and map to the screen height:
    inByte = float(pulseData[0]);
            
  }
}