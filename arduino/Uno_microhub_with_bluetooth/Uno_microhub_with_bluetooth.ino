/*
 * flash the uno with this code for the 2-channel uno hub.
 * channel 1 = windmill power generator
 * channel 2 = seismometer
 */

const int _delayTime = 20;
const int _windmillInput = A0;
const int _seismoInput = A1;
const String _delimiter = ",";
const String GROUP_ID = "groupID";
const String DEVICE_ID = "deviceID";
String _serialMessage = "";

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  _serialMessage = getHeaderMessage(); //init the string with our header data
  //the following two data points are for power generator and seismometer
  _serialMessage += analogRead(_windmillInput);
  _serialMessage += _delimiter;
  _serialMessage += analogRead(_seismoInput);
  _serialMessage += getBodyMessage(); //this will fill out the remaining available data slots with zeros.

  Serial.println(_serialMessage);
  
  // add some delay (and reverb)
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

