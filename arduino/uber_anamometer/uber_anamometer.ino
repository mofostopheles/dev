
//arlo emerson, 2016 for msft edu workshop
//very important: use the internal pullup for all the digital pins as we are
//running voltage through all the reed switch circuits


const int pinRotation = 2;
const int pinNorth = 3;
const int pinNorthEast = 4;
const int pinEast = 5;
const int pinSouthEast = 6;
const int pinSouth = 7;
const int pinSouthWest = 8;
const int pinWest = 9;
const int pinNorthWest = 10;
const int pinLED = 13;
const String GROUP_ID = "youtellme";
//const String DEVICE_ID = "98:76:b6:00:a7:eb";
const String DEFAULT_WIND_DIRECTION = "unknown";
String mWindDirection = DEFAULT_WIND_DIRECTION;
float mWindSpeed = 0;
unsigned long mLastMillis = 0;
int mWindSpeedCounter = 0;

void setup()
{
  Serial.begin(9600);
  pinMode(pinLED, OUTPUT);
  pinMode(pinRotation, INPUT_PULLUP);
  pinMode(pinNorth, INPUT_PULLUP);
  pinMode(pinNorthEast, INPUT_PULLUP);
  pinMode(pinEast, INPUT_PULLUP);
  pinMode(pinSouthEast, INPUT_PULLUP);
  pinMode(pinSouth, INPUT_PULLUP);
  pinMode(pinSouthWest, INPUT_PULLUP);
  pinMode(pinWest, INPUT_PULLUP);
  pinMode(pinNorthWest, INPUT_PULLUP); 
}

void loop()
{
  //get a reading from the paper cups
  int rotationSensor = digitalRead(pinRotation);
  //Serial.println(rotationSensor);

  int tmpMillis = millis();
  int tmpVal = tmpMillis - mLastMillis;
  if (tmpVal >= 1000) //one-second timer
  {
    mWindSpeed = mWindSpeedCounter * 3.1; //just whatever until later
    mWindSpeedCounter = 0;
    mLastMillis = tmpMillis;
  }

  switch(rotationSensor)
  {
    case 0:
      digitalWrite(pinLED, HIGH);
      mWindSpeedCounter++;
      break;
    case 1:
      digitalWrite(pinLED, LOW);
      break;
    default:
      break;
  }

  //get a reading from the windvane
  (digitalRead(pinNorth) == 0) ? mWindDirection = "North" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinNorthEast) == 0) ? mWindDirection = "NorthEast" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinEast) == 0) ? mWindDirection = "East" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinSouthEast) == 0) ? mWindDirection = "SouthEast" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinSouth) == 0) ? mWindDirection = "South" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinSouthWest) == 0) ? mWindDirection = "SouthWest" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinWest) == 0) ? mWindDirection = "West" : DEFAULT_WIND_DIRECTION;
  (digitalRead(pinNorthWest) == 0) ? mWindDirection = "NorthWest" : DEFAULT_WIND_DIRECTION;

  //data needs to go out in one chunk formatted as follows:
  //timestamp, groupid, deviceid, v1, v2, ...
  String tmpMessage = String(millis());
  tmpMessage.concat(",");
  tmpMessage.concat(GROUP_ID);
  tmpMessage.concat(",");
 // tmpMessage.concat(DEVICE_ID);
  tmpMessage.concat(",");
  tmpMessage.concat(mWindDirection);
  tmpMessage.concat(",");
  tmpMessage.concat(mWindSpeed);
  //Serial.println( tmpMessage ); //use the big string for EXCEL
  Serial.println( "Wind speed " + String(mWindSpeed) + " knots " + " - Wind direction " + mWindDirection );
  delay(10);
}
