//arlo emerson, 2016 x

unsigned long mTimeCurrent = 0;
unsigned long mTimePrevious = 0;

unsigned long mTimeCurrentLight = 0;
unsigned long mTimePreviousLight = 0;


int mLightState = 0;
int mListening = 0;
static int mThreshhold = 300;
static int LAMP_PIN = 5;
static int LISTENING_INDICATOR = 13;

void setup()
{
  Serial.begin(9600); 
  pinMode(LAMP_PIN, OUTPUT); //pin we will trigger the relay with
  pinMode(LISTENING_INDICATOR, OUTPUT); //onboard indicator light
  Serial.println("MS EDU WORKSHOP");
}


void loop()
{
  delay(250);
  int tmpRead = analogRead(A0);

  mTimeCurrent = millis(); 
  
  Serial.println(tmpRead);
  
  if (mListening == 0 && tmpRead > mThreshhold) //start timer for listening
  {
    mListening = 1;
    mTimePrevious = mTimeCurrent;
    Serial.println("listening");
    digitalWrite(13, HIGH);
  }

  if (
  mListening == 1 &&
    tmpRead > mThreshhold &&
    ( mTimeCurrent - mTimePrevious > 250) &&
    ( mTimeCurrent - mTimePrevious < 2000)
    )
  {
    toggleLight();         
  }

  if ( mTimeCurrent - mTimePrevious > 2000 && mListening == 1)
  {
    Serial.println("done listening");
    digitalWrite(13, LOW);
    mListening = 0;
  }
}


void toggleLight()
{
  mTimeCurrentLight = millis();

  if ( mTimeCurrentLight - mTimePreviousLight > 3000)
  {
    //Serial.println( "toggle light" );
    if ( mLightState == 0 )
    {
      mLightState = 1; 
      digitalWrite(LAMP_PIN, HIGH);
      Serial.println("light on");
    }
    else
    {
      mLightState = 0;
      digitalWrite(LAMP_PIN, LOW);
      Serial.println("light off");
    }
  }

  mTimePreviousLight = mTimeCurrentLight;
}








