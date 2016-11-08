// Graphing sketch
 
 
 // This program takes ASCII-encoded strings
 // from the serial port at 9600 baud and graphs them. It expects values in the
 // range 0 to 1023, followed by a newline, or newline and carriage return
 
 // Created 20 Apr 2005
 // Updated 18 Jan 2008
 // by Tom Igoe
 // This example code is in the public domain.
 
import processing.serial.*;
 
Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
int windowHeight = 500;
int windowWidth = 500;
String inString = "";
float inByte; 
int counter = 0;

void setup ()
{
  size(500, 500);        
  
  //println(Serial.list());

   //myPort = new Serial(this, Serial.list()[1], 115200);
  myPort = new Serial(this, Serial.list()[1], 57600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  // set inital background:
  background(235);
}


void draw ()
{
  
    //You may need to change 0.25 and 0.45 to fit your
    //pulse waveform better
    inByte = map(inByte, 10.0, 65.0, 0, height);
        
    // draw the line:
    stroke(255,0,0);    
    line(xPos, height, xPos, height - inByte);
    
    // at the edge of the screen, go back to the beginning:
    if (xPos >= width)
    {
      xPos = 0;
      background(223); 
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
    counter++;
    println(counter + "  " + inByte);          
  }
}