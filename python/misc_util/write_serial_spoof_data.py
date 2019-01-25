import serial
import random

ser = serial.Serial('COM89', 9600)
targetSpeed = 80
currentSpeed = 0

targetAngle = 1
currentAngle = 1

def doSerial():

	global ser, currentSpeed

	spoofString = "10,10,10,"
	spoofString += str( setSpeed() )
	spoofString += ",10,10,"
	spoofString += str( setAngle() )
	spoofString += ",\n"
	print spoofString

	ser.write(spoofString)


def setSpeed():
	global targetSpeed, currentSpeed

	if ( targetSpeed == currentSpeed ):
		targetSpeed = getSomeRandomNumber()

	if (currentSpeed < targetSpeed):
		currentSpeed += 1
	elif (currentSpeed > targetSpeed):
		currentSpeed -= 1

	return currentSpeed


def setAngle():
	global targetAngle, currentAngle

	if ( targetAngle == currentAngle ):
		targetAngle = random.randrange(1,180)

	if (currentAngle < targetAngle):
		currentAngle += 1
	elif (currentAngle > targetAngle):
		currentAngle -= 1

	return currentAngle





#using this to get a random wind direction number
def getSomeRandomNumber():
	random.seed()
	return random.randrange(80,255)




while 1==1:
	doSerial()