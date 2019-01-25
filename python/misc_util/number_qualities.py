from visual import *

def isPrime(pInt):
	weArePrime = false
	numberIsDirty = false

	for i in range(2, pInt):
		remainder = pInt%i
		if remainder==0:
			numberIsDirty = true

	if numberIsDirty != true:
		weArePrime = true

	return weArePrime

def testNumber(pInt):
	#if round(  pow(sqrt(pInt)/distillNumber(pInt), distillNumber(pInt)) )%distillNumber(pInt)==0:
	if round(    sin( pInt * distillNumber(pInt) )   ) % distillNumber(pInt)==0:
		return true

	#persian rug
	#if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
	#return isPrime(pInt)

#
#color the dot
#
def setColor(pDot, pColor):
	pDot.color = color=(0,.6, 1) #color.red

def getNumberSelfAffinity(pInt):
	return (sqrt(pInt)*distillNumber(pInt))/pi

def displayNumberQualities():

	#f=open("number_qualities.txt", "w")

	#mystring = 36

	#print distillNumber(mystring)

	initSpiral()


def distillNumber(rawNumber):
	distilledNumber = 0

	tmpList = split_len(str(rawNumber))

	for k in range (len(tmpList)):
		distilledNumber = distilledNumber + int(tmpList[k])

	if len(str(distilledNumber))>1:
		distilledNumber = distillNumber(distilledNumber)

	return distilledNumber


def split_len(seq):
    return [seq[i:i+1] for i in range(0, len(seq), 1)]


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

	for i in range(1,60):
		if _order[ordinalDirectionIndex] == "r":
			#move an odd number based on i
			tmpRange = (2*i)-1

			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX + _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = (distillNumber(numberCounter)/pi,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,1)
				#else:
				#	ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
				#	ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "u":
			tmpRange = (2*i)-1
			print str(tmpRange)
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY - _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = (distillNumber(numberCounter)/pi,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,1)
				#else:
				#	ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
				#	ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "l":
			#move an even number based on i
			#(2*i)
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX - _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = (distillNumber(numberCounter)/pi,0.5,0.5), radius = _ballRadius)
					ball.pos = vector(posX,posY,1)
				#else:
				#	ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
				#	ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "d":
			#(2*i)
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY + _spacer
				if testNumber(numberCounter)==true:
					ball = sphere (color = color.red, radius = _ballRadius)
					ball.pos = vector(posX,posY,1)
				#else:
				#	ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
				#	ball.pos = vector(posX,posY,-getNumberSelfAffinity(numberCounter))

			#reset ordinalDirectionIndex
			ordinalDirectionIndex=0

#fire it up
displayNumberQualities()