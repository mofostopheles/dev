/*
   modified combination of our anemometer RPM/KPH code and the original SparkFun demo code
   MicroOLED_Demo.ino
   david myka, arlo emerson and...

   SFE_MicroOLED Library Demo
   Jim Lindblom @ SparkFun Electronics
*/

#include <SPI.h>  // Include SPI if you're using SPI
#include <SFE_MicroOLED.h>  // Include the SFE_MicroOLED library

//////////////////////////
// MicroOLED Definition //
//////////////////////////
#define PIN_RESET 9  // Connect RST to pin 9
#define PIN_DC    8  // Connect DC to pin 8
#define PIN_CS    10 // Connect CS to pin 10
#define DC_JUMPER 0

//////////////////////////////////
// MicroOLED Object Declaration //
//////////////////////////////////
MicroOLED oled(PIN_RESET, PIN_DC, PIN_CS); // SPI declaration

//////////////////////////////////
// WindDriven-Anemometer
//////////////////////////////////
unsigned long mTimeCurrent = 0;
unsigned long mTimePrevious = 0;
unsigned long mTimeInterval = 0;
int mRevolutions = 0;
float mCalculatedRPMs = 0.0;
static float mDiameter = 100.0; // diameter based on magnet position, not the total diameter
static float mCircumference = mDiameter * PI;  // PI * D = circumference
static float millisPerMinute = 60000;
static unsigned long mTimerWindow = 3000; //seconds in millis
static float mTimerWindowDivisionFactor = mTimerWindow / 1000;
bool mSensorTriggered = false;
float mRPM = 0;    // revolutions per minute
float mKPM = 0;
float mKPH = 0;    // kilometers per hour
float mWindSpeed = 0;

void setup()
{
  oled.begin();    // Initialize the OLED
  oled.clear(ALL); // Clear the display's internal memory
  //oled.display();  // Display what's in the buffer (splashscreen)
  //delay(1000);     // Delay 1000 ms
  oled.clear(PAGE); // Clear the buffer.

  pong(); //run something while our time buffer is created
  //oled.setCursor(0, 0);
  //oled.setFontType(2);
  //randomSeed(analogRead(A0) + analogRead(A1));
  Serial.begin(9600);

}

void loop()
{
  //new algo....
  //yes, it's laggy by about 2 seconds
  //yes, it's more accurate because we can take an actual RPM sample and extrapolate it.
  //also, we are measuring RPMs when the sensor turns off, that way you can't trick 
  //the software that it's being triggered.

  mTimeCurrent = millis();
  mTimeInterval = mTimeCurrent - mTimePrevious;

  if (mTimeInterval < mTimerWindow)
  {
    if (digitalRead(2) == HIGH && mSensorTriggered == false)
    {
      //set a flag that the sensor was triggered
      mSensorTriggered = true;
    }

    //we only count a RPM if the sensor turns off. 
    //otherwise you can park the magnet on the sensor and get really inaccurate numbers
    if (digitalRead(2) == LOW && mSensorTriggered == true)
    {
      mRevolutions++;
      mSensorTriggered = false;
    }
  }
  else if (mTimeInterval >= mTimerWindow)
  {
    //we're done counting revolutions so let's extrapolate the RPMs
    float tmpRPM = mRevolutions / mTimerWindowDivisionFactor;
    mCalculatedRPMs = tmpRPM * 60.0;
    mKPH = ((mCalculatedRPMs * mCircumference) * .00001);

    //reset our timekeeping variables
    //Serial.println(mRevolutions);
    mTimePrevious = millis();
    mRevolutions = 0;

    //printTitle( String( mKPH ) + " \nkph", 1);
  }
  oled.clear(PAGE);     // Clear the screen
  oled.setFontType(0);  // Set font to type 0
  oled.setCursor(0, 0); // Set cursor to top-left
  oled.print("RPM " + String( int(mCalculatedRPMs) ) + "\n\nKPH " + String( mKPH ));
  oled.display();
}


void pixelExample()
{
  printTitle("Pixels", 1);

  for (int i = 0; i < 512; i++)
  {
    oled.pixel(random(oled.getLCDWidth()), random(oled.getLCDHeight()));
    oled.display();
  }
}

void pong()
{
  // Silly pong demo. It takes a lot of work to fake pong...
  int paddleW = 3;  // Paddle width
  int paddleH = 15;  // Paddle height
  // Paddle 0 (left) position coordinates
  int paddle0_Y = (oled.getLCDHeight() / 2) - (paddleH / 2);
  int paddle0_X = 2;
  // Paddle 1 (right) position coordinates
  int paddle1_Y = (oled.getLCDHeight() / 2) - (paddleH / 2);
  int paddle1_X = oled.getLCDWidth() - 3 - paddleW;
  int ball_rad = 2;  // Ball radius
  // Ball position coordinates
  int ball_X = paddle0_X + paddleW + ball_rad;
  int ball_Y = random(1 + ball_rad, oled.getLCDHeight() - ball_rad);//paddle0_Y + ball_rad;
  int ballVelocityX = 1;  // Ball left/right velocity
  int ballVelocityY = 1;  // Ball up/down velocity
  int paddle0Velocity = -1;  // Paddle 0 velocity
  int paddle1Velocity = 1;  // Paddle 1 velocity

  //while(ball_X >= paddle0_X + paddleW - 1)
  while ((ball_X - ball_rad > 1) &&
         (ball_X + ball_rad < oled.getLCDWidth() - 2))
  {
    // Increment ball's position
    ball_X += ballVelocityX;
    ball_Y += ballVelocityY;
    // Check if the ball is colliding with the left paddle
    if (ball_X - ball_rad < paddle0_X + paddleW)
    {
      // Check if ball is within paddle's height
      if ((ball_Y > paddle0_Y) && (ball_Y < paddle0_Y + paddleH))
      {
        ball_X++;  // Move ball over one to the right
        ballVelocityX = -ballVelocityX; // Change velocity
      }
    }
    // Check if the ball hit the right paddle
    if (ball_X + ball_rad > paddle1_X)
    {
      // Check if ball is within paddle's height
      if ((ball_Y > paddle1_Y) && (ball_Y < paddle1_Y + paddleH))
      {
        ball_X--;  // Move ball over one to the left
        ballVelocityX = -ballVelocityX; // change velocity
      }
    }
    // Check if the ball hit the top or bottom
    if ((ball_Y <= ball_rad) || (ball_Y >= (oled.getLCDHeight() - ball_rad - 1)))
    {
      // Change up/down velocity direction
      ballVelocityY = -ballVelocityY;
    }
    // Move the paddles up and down
    paddle0_Y += paddle0Velocity;
    paddle1_Y += paddle1Velocity;
    // Change paddle 0's direction if it hit top/bottom
    if ((paddle0_Y <= 1) || (paddle0_Y > oled.getLCDHeight() - 2 - paddleH))
    {
      paddle0Velocity = -paddle0Velocity;
    }
    // Change paddle 1's direction if it hit top/bottom
    if ((paddle1_Y <= 1) || (paddle1_Y > oled.getLCDHeight() - 2 - paddleH))
    {
      paddle1Velocity = -paddle1Velocity;
    }

    // Draw the Pong Field
    oled.clear(PAGE);  // Clear the page
    // Draw an outline of the screen:
    oled.rect(0, 0, oled.getLCDWidth() - 1, oled.getLCDHeight());
    // Draw the center line
    oled.rectFill(oled.getLCDWidth() / 2 - 1, 0, 2, oled.getLCDHeight());
    // Draw the Paddles:
    oled.rectFill(paddle0_X, paddle0_Y, paddleW, paddleH);
    oled.rectFill(paddle1_X, paddle1_Y, paddleW, paddleH);
    // Draw the ball:
    oled.circle(ball_X, ball_Y, ball_rad);
    // Actually draw everything on the screen:
    oled.display();
    delay(25);  // Delay for visibility
  }
  delay(500);
  oled.clear(PAGE);
}





// Center and print a small title
// This function is quick and dirty. Only works for titles one
// line long.
void printTitle(String title, int font)
{
  int middleX = oled.getLCDWidth() / 2;
  int middleY = oled.getLCDHeight() / 2;

  oled.clear(PAGE);
  oled.setFontType(font);
  // Try to set the cursor in the middle of the screen
  oled.setCursor(middleX - (oled.getFontWidth() * (title.length() / 2)),
                 middleY - (oled.getFontWidth() / 2));
  // Print the title:
  oled.print(title);
  oled.display();
  //delay(1500);
  oled.clear(PAGE);
}

