//this is a prototype for the hot-air balloon troposphere demo
//as the balloon moves through the levels various triggers will be fired 
//and we'll tell excel to "do something neat" on the screen

//2 values: wind and temperature

//level values
const int level1 = 2;
const int level2 = 3;
const int level3 = 4;
const int level4 = 5;
const int level5 = 6;

//default instrument readings
int mPing = 1;
double mTemperature = 15.1;
double mWindspeed = 12.3;

double mTempResolution = 1.3;
double mWindspeedResolution = 1.7;

//level stuff
int mPreviousLevel = 0;
int mCurrentLevel = 0;

//median values for each level
int mLevel1MedianValue = 11;
int mLevel2MedianValue = 22;
int mLevel3MedianValue = 33;
int mLevel4MedianValue = 44;
int mLevel5MedianValue = 55;

void setup()
{
  Serial.begin(9600);
  pinMode(level1, INPUT);
  pinMode(level2, INPUT);
  pinMode(level3, INPUT);
  pinMode(level4, INPUT);
  pinMode(level5, INPUT);
}

void loop()
{
  getRandNumber();
  
  int levelDifference = 0;
  
  if (digitalRead(level1) == 1)
  {
    //level 1 has a median value of 20   
    //Serial.println( 1 );    
    //set mCurrentLevel to store the new level we are at
    mCurrentLevel = 1;
    
    //this will run once every time we enter this level from a different level
    if ( mPreviousLevel != mCurrentLevel)
    {         
      //ramp up the mTemperature value to this new level, in this case 20
      levelDifference = abs(mPing - mLevel1MedianValue); //get a positive number representing our differential
    }   
  }
  else if (digitalRead(level2) == 1)
  {
    mCurrentLevel = 2;    
    if ( mPreviousLevel != mCurrentLevel)
    {         
      levelDifference = abs(mPing - mLevel2MedianValue);          
    }
  }
  else if (digitalRead(level3) == 1)
  {
    mCurrentLevel = 3;    
    if ( mPreviousLevel != mCurrentLevel)
    {         
      levelDifference = abs(mPing - mLevel3MedianValue);          
    }
  }
  else if (digitalRead(level4) == 1)
  {
    mCurrentLevel = 4;    
    if ( mPreviousLevel != mCurrentLevel)
    {         
      levelDifference = abs(mPing - mLevel4MedianValue);          
    }
  }
  else if (digitalRead(level5) == 1)
  {
    mCurrentLevel = 5;    
    if ( mPreviousLevel != mCurrentLevel)
    {         
      levelDifference = abs(mPing - mLevel5MedianValue);          
    }
  }
  else
  {
   //don't do anything
  }


  if (mPreviousLevel < mCurrentLevel) //then we are going to ramp UPWARDS
  {
    incrementPing1(levelDifference);
  }
  else if (mPreviousLevel > mCurrentLevel) //then we are going to ramp DOWNWARDS
  {
    decrementPing1(levelDifference);
  }

  //update this last
  mPreviousLevel = mCurrentLevel;
      
  //ping simply prints out a "data packet" containing our fake sensor readings
  ping();
  delay(100);
}

void decrementPing1(int pLevelDifference)
{
  for (int x = pLevelDifference; x > 0; x--)
  {                 
    mPing -= 1;
    mTemperature -= mTempResolution;
    mWindspeed -= mWindspeedResolution;
    ping();
    delay(200);
  }
}

void incrementPing1(int pLevelDifference)
{
  for (int x = 0; x < pLevelDifference; x++)
  {        
    mPing += 1;    
    mTemperature += mTempResolution;
    mWindspeed += mWindspeedResolution;
    ping();
    delay(200);
  } 
}

float getRandNumber()
{
  randomSeed(analogRead(0));
  float x = float(random(17))/float((13/1.7));
  return x;  
}

//this constructs a data packet with the following form
//LEVEL, temp, windspeed
void ping()
{  
  //String dataPacket = String(mPing) + "," + String(mTemperature + getRandNumber()) + "," + String(mWindspeed + getRandNumber());
  
  String dataPacket = String(millis()) + "," + String(mCurrentLevel) + "," + String(mPing) + "," + String(mTemperature + getRandNumber()) + "," + String(mWindspeed + getRandNumber());
  writePacketToSerial(dataPacket);
}


void writePacketToSerial(String pPacket)
{
  Serial.println(pPacket);
}



