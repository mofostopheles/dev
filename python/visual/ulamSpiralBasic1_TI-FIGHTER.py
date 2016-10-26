from visual import *

def drawRegion(cmd):

	_newLeft = 0
	_newTop = 0
	_spacer = 4
	_numberCounter = 0

	#move Y
	for i in range(50):
		_newLeft = 0
		#print i

		#move X
		for j in range(50):
			_numberCounter = _numberCounter+1

			if testNumber(_numberCounter)==true:
				ball = sphere (color = color.red, radius = 2)
				ball.mass = .5
				ball.pos = vector(_newLeft,_newTop,-10)
			else:
				ball = sphere (color = (0.5,0.5,0.5), radius = 2)
				ball.mass = .5
				ball.pos = vector(_newLeft,_newTop,10)


			_newLeft = _newLeft + _spacer

		_newTop = _newTop + _spacer


def testNumber(pInt):
	if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
		return true

	return false

#
#color the dot
#
def setColor(pDot, pColor):
	pDot.color = color.red

def getNumberSelfAffinity(pInt):
	#return sin(  pInt * pInt/ pInt ) 2-layer z-zone
	return (sqrt(pInt)/pi)*2

#
#main spiral function
#
def initSpiral():

	posX = 0
	posY = 0
	ordinalDirectionIndex = 0
	numberCounter = 1
	_primeColor = color.red
	_order = ["r","u","l","d"]
	_spacer = 2
	_ballRadius = 1

	#establish the first dot
	ball = sphere (color = color.red, radius = _ballRadius)
	ball.pos = vector(0,0,-10)

	for i in range(1,40):
		if _order[ordinalDirectionIndex] == "r":
			#move an odd number based on i
			tmpRange = (2*i)-1

			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX + _spacer
				#print str(posX) + " " + str(posY)
				if testNumber(numberCounter)==true:
					ball = sphere (color = color.red, radius = _ballRadius)
					ball.pos = vector(posX,posY,getNumberSelfAffinity(numberCounter))
				else:
					ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "u":
			tmpRange = (2*i)-1
			print str(tmpRange)
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY - _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = color.red, radius = _ballRadius)
					ball.pos = vector(posX,posY,getNumberSelfAffinity(numberCounter))
				else:
					ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "l":
			#move an even number based on i
			#(2*i)
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX - _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = color.red, radius = _ballRadius)
					ball.pos = vector(posX,posY,getNumberSelfAffinity(numberCounter))
				else:
					ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "d":
			#(2*i)
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY + _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = color.red, radius = _ballRadius)
					ball.pos = vector(posX,posY,getNumberSelfAffinity(numberCounter))
				else:
					ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			#reset ordinalDirectionIndex
			ordinalDirectionIndex=0

#fire it up
initSpiral()