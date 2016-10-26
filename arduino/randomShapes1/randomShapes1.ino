// testshapes demo for Adafruit RGBmatrixPanel library.
// Demonstrates the drawing abilities of the RGBmatrixPanel library.
// For 16x32 RGB LED matrix:
// http://www.adafruit.com/products/420

// Written by Limor Fried/Ladyada & Phil Burgess/PaintYourDragon
// for Adafruit Industries.
// BSD license, all text above must be included in any redistribution.

#include <Adafruit_GFX.h>   // Core graphics library
#include <RGBmatrixPanel.h> // Hardware-specific library

#define PI 3.1415926535897932384626433832795

#define CLK 8  // MUST be on PORTB! (Use pin 11 on Mega)
#define LAT A3
#define OE  9
#define A   A0
#define B   A1
#define C   A2
RGBmatrixPanel matrix(A, B, C, CLK, LAT, OE, false);

float _piCounter = .005;
int _globalCounter = 2;

void setup()
{
  Serial.begin(9600);
  matrix.begin();
  matrix.fillScreen(matrix.Color333(0, 0, 0));

  //initSpiral();
  //simpleTest();
  //printWelcomeText();
}

void loop()
{
  //
  
  initSpiral();
  _piCounter += .001;
  delay(200);
  _globalCounter += 1;
  //Serial.println(_globalCounter);
  
  /*
  if (_globalCounter == 50)
  {
    printWelcomeText();
   _globalCounter = 0;
  }
  */
}

void simpleTest()
{
  int posX = 0;
  int posY = 0;
  int ordinalDirectionIndex = 0;
  int numberCounter = 1;

  String order = "ruld";
  int _spacer = 1;

  for (int i=0;i<16;i++)
  {
    for (int x=0;x<32;x++)
    {
      numberCounter+=1;
      testNumber(numberCounter, posX, posY); 
      if (x == 31)
      {
        posX = 0;
      }
      else
      {
        posX += 1;
      }
    }
    posY += 1;
  }
}

void initSpiral()
{
  int posX = 15;
  int posY = 7;
  int ordinalDirectionIndex = 0;
  int numberCounter = 1;

  String order = "ruld";
  int _spacer = 1;

  //establish the first dot
  //matrix.drawPixel(x, y, matrix.Color333(r, g, b));
  matrix.drawPixel(posX, posY, matrix.Color333(3, 4, 5));
  int legLength = 0;

  for (int i=1;i<10;i++)
  {
    //numberCounter += 1;
    //if (order.indexOf("r") == ordinalDirectionIndex)
    //{
      for (int k=0;k<=legLength;k++)
      {
        numberCounter += 1;
        posX += _spacer;
        testNumber(numberCounter, posX, posY);
      }
      ordinalDirectionIndex+=1;
    //}    
    //if (order.indexOf("u") == ordinalDirectionIndex)
    //{  
      for (int k=0;k<=legLength;k++)
      {
        numberCounter += 1;
        posY -= _spacer;
        testNumber(numberCounter, posX, posY);
      }
      ordinalDirectionIndex+=1;      
    //}
    legLength += 1;
    //if (order.indexOf("l") == ordinalDirectionIndex)
    //{
      for (int k=0;k<=legLength;k++)
      {
        numberCounter += 1;
        posX -= _spacer;
        testNumber(numberCounter, posX, posY);
      }
      ordinalDirectionIndex+=1;
    //}
    //if (order.indexOf("d") == ordinalDirectionIndex)
    //{
      for (int k=0;k<=legLength;k++)
      {
        numberCounter += 1;
        posY += _spacer;
        testNumber(numberCounter, posX, posY);
      }
      //reset ordinalDirectionIndex
      ordinalDirectionIndex=0;
    //} 
  }
}

void testNumber(int pNumber, int pX, int pY)
{
  //delay(1);
  //int tmpMultiplier = _piCounter * 1.1;
  //if (round(sqrt(pow(pNumber,2))*(1.6180339887*PI)/2)%2==0)
  //if (round(  pow(sqrt(pNumber)/PI, tmpGradient) )%2==0)
  //Serial.println(_piCounter);
  if (round( sqrt( pow(pNumber, 2 ))*_piCounter*PI)%2==0)
  {
    matrix.drawPixel(pX, pY, matrix.Color333(0, 7, 1));
  }
  else
  {
    matrix.drawPixel(pX, pY, matrix.Color333(3, 0, 2));
  }
}

void printWelcomeText()
{
  // fill the screen with 'black'
  matrix.fillScreen(matrix.Color333(0, 0, 0));
  matrix.setCursor(1, 0);   // start at top left, with one pixel of spacing
  matrix.setTextSize(0);    // size 1 == 8 pixels high
  matrix.setTextColor(matrix.Color333(7,0,0));
  matrix.print(' ');
  matrix.print('I');
  delay(50);
  matrix.print('O');
  delay(50);
  matrix.print('T');
  delay(50);
  matrix.setCursor(1, 9);   // next line
  matrix.setTextColor(matrix.Color333(5, 0, 4));
  matrix.print(' ');
  matrix.print('L');
  delay(50);
  matrix.setTextColor(matrix.Color333(3,6,2));
  matrix.print('A');
  delay(50);
  matrix.setTextColor(matrix.Color333(1,5,6)); 
  matrix.print('B');
  delay(3000);
}


