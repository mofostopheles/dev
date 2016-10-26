
void setup()
{
    Serial.begin(9600); 
    pinMode(2, OUTPUT); 
    pinMode(3, OUTPUT); 
    pinMode(4, OUTPUT); 
    pinMode(5, OUTPUT); 
}

int pin0;
int pin1;
int pin2;
int pin3;

void loop()
{
    pin0 = analogRead(A0);  
    pin1 = analogRead(A1);  
    pin2 = analogRead(A2);  
    pin3 = analogRead(A3);  
    
    analogWrite(2, pin0/3);
    analogWrite(3, pin1/3);
    analogWrite(4, pin2/3);
    analogWrite(5, pin3/3);
     
    Serial.println(String( pin0 ) + "," + String( pin1 ) + "," + String( pin2 ) + "," + String( pin3 )); 
}
