//0ct 2016
//arloemerson@gmail.com
//code for measuring wave frequency & maybe amplitude if i have time to implement

int node1;
int node2;
static int node1InstrumentLight = 8;
static int node2InstrumentLight = 9;
static int standbyInstrumentLight = 12;
static float mFixedWavelength = 0.05; //5cm in meters
static float mNumberOfNodes = 11.0; //number of gumdrop sticks

boolean mTimerStandby = false;
boolean mTimerStarted = false;
unsigned long mMillisStart;
unsigned long mTime;


void setup()
{
  Serial.begin(9600); 
  pinMode(2, INPUT_PULLUP); 
  pinMode(3, INPUT_PULLUP); 
  pinMode(node1InstrumentLight, OUTPUT); //for lighting LED
  pinMode(node2InstrumentLight, OUTPUT); //for lighting LED
  pinMode(standbyInstrumentLight, OUTPUT); //for lighting LED
}

/*
 * put the wave demo into standby when the first node is submerged in water, closing the connection.
 * timer begins when the connection is broken.
 * timer stops when last node closes the connection.
 * then we take the number of nodes
 */
void loop()
{
  node1 = digitalRead(2);  
  node2 = digitalRead(3);  

  if(node1 == 0 && mTimerStandby == false && mTimerStarted == false) //node 1 was dunked in the water
  {
    //initialize all our variables
    mMillisStart = 0;
    mTime = 0;
    mTimerStandby = true;
    mTimerStarted = false;
    digitalWrite(standbyInstrumentLight, HIGH);
    Serial.println("\nstanding by...");
  }

  if(node1 == 1 && mTimerStandby == true) //node 1 emerged from the water, breaking the circuit
  {
    digitalWrite(standbyInstrumentLight, LOW);
    mTimerStarted = true;
    mTimerStandby = false;
    mMillisStart = millis();
    flashLED(node1InstrumentLight);
    Serial.println("--==START==--");   
  }

  if(node2 == 0 && mTimerStarted == true) //node 2 dunked in the water, we're done.
  {
    //stop the timer, calculate the wave frequency
    mTimerStarted = false;
    mTime = millis() - mMillisStart;
    
    flashLED(node2InstrumentLight);
    Serial.println("--==FINISH==--");
    Serial.println("time was: ");
    Serial.print(mTime/1000.0);
    Serial.print(" seconds\n\n");
    float calculatedFrequency = 1000.0/(mTime / mNumberOfNodes); //f=1/T, also note we are extrapolating time of 1 node from total time divided by all nodes
    
    float calculatedSpeed = mFixedWavelength * calculatedFrequency;
    Serial.println("wave speed is: ");
    Serial.print(calculatedSpeed);
    Serial.print(" meters per second, or ");
    Serial.print(calculatedFrequency);
    Serial.print(" Hertz \n");
  }      
}

void flashLED(int pPin)
{
  for (int i=0;i<5;i++)
  {
    digitalWrite(pPin, HIGH);
    delay(50);
    digitalWrite(pPin, LOW);
    delay(50);       
  } 
}


