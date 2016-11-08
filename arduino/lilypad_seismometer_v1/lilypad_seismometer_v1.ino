const int _delayTime = 20;
const String _delimiter = ",";
const String GROUP_ID = "groupID";
const String DEVICE_ID = "deviceID";
String _serialMessage = "";

void setup()
{
  pinMode(13, OUTPUT);
  Serial.begin(9600); 
}

void loop()
{
  _serialMessage = getHeaderMessage(); //init the string with our header data
  
  int tmpFoo = analogRead(A2);
  analogWrite(13,  tmpFoo * 2);
  
  _serialMessage += tmpFoo;
  _serialMessage += _delimiter;
  _serialMessage += "0";
  _serialMessage += getBodyMessage(); //this will fill out the remaining available data slots with zeros.
  
  Serial.println(_serialMessage);
  
  delay(_delayTime);
}

/*
 * each message to the Excel add-in needs to have these parameters
 */
String getHeaderMessage()
{
  String tmpString = GROUP_ID;
  tmpString += _delimiter;
  tmpString += DEVICE_ID;
  tmpString += _delimiter;
  tmpString += millis();
  tmpString += _delimiter;
  return tmpString;
}

/*
 * fill out the body of the message.
 * the excel add-in may or may not handle an incomplete message so we're adding them here.
 */
String getBodyMessage()
{
  String tmpString = _delimiter;
  int loopLength = 14; //we are spoofing the values for N data points
  for (int i=0;i<loopLength;i++) 
  {    
    tmpString += ("0" + (i<loopLength-1 ? _delimiter : "")); 
  }
  return tmpString;
}
