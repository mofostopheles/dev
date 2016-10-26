from visual import *
import random

_nRand = 4
_aRand = pow(2,31)-1
_gaussAdd = sqrt(3*_nRand)
_gaussFac = 2*_gaussAdd/_nRand*_aRand
_delta = []

def initGauss(pSeed):
	gauss()

def gauss():
	_sum = 0
	_i = 0
	for _i in range(_nRand):
		_sum = _sum + random.randrange(1,9)
	return _gaussFac * _sum - _gaussAdd

def whiteNoiseBM(pInt):
	foo = pInt + gauss()/(500)
	newFoo = foo/50000
	return newFoo


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

	if (round(sqrt(pow(pInt,2))*(1.6180339887*3.14159265)/2)%distillNumber(pInt)==0):
		return true

	if round(pInt/pi)%2==0:
		return true

	"""
	if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
		return true

	newRand = random.randrange(3,9)
	"""
	#print newRand

	#return false

	return isPrime(pInt)

	if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
		return true


	if (round((sqrt(pow(pInt,2))*(1.6180339887*3.14159265)/2)) %2)==0:
		return true

	#if round(pInt/pi)%2==0^pInt%5==true:
	#	return true

	#if round(pInt/pi)%3==0^pInt%5==0:
	#	return true

	#return isPrime(pInt)

	#if round(pInt/2.71828)*pInt%12==0:
	#	return true

	#if round(sqrt(pow(pInt, 2.71828 ))*2.71828)%2==0:
	#	return true

	#if (round(sqrt(pow(pInt, pi ))*2.71828)%2==0):
	#	return true




	return false

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

#
#color the dot
#
def setColor(pDot, pColor):
	pDot.color = color.red

def distillNumber(rawNumber):
	distilledNumber = 0

	tmpList = split_len(str(rawNumber))

	for k in range (len(tmpList)):
		distilledNumber = distilledNumber + int(tmpList[k])

	if len(str(distilledNumber))>1:
		distilledNumber = distillNumber(distilledNumber)

	#print distilledNumber
	return distilledNumber

def split_len(seq):
    return [seq[i:i+1] for i in range(0, len(seq), 1)]

def getSpacer(pInt):
	#return whiteNoiseBM(pInt)
	return 3
	"""
	if pInt%2==0: #even
		return sin(distillNumber(pInt))
	else:
		return tan(distillNumber(pInt))

	"""
	#(distillNumber(pInt)*pi)
	#spaced out squares
	#return (sin(pInt)*100) + distillNumber(pInt)/pi
	#yields a strange spiral
	#return ((distillNumber(pInt)*pi)/pInt)*2.7
	return distillNumber(pInt)*(pi+sin(pInt)) * sin(distillNumber(pInt))
	return distillNumber(pInt)*pow(sin(pInt),5)*pi
	#return  cos( pInt*pi )
	#red light district
	return distillNumber(pInt)*pow(sin(pInt),9)*pi
	return distillNumber(pInt)/pi

def getAltitude(pInt):

	#carefull with white noise, it can be a processor killer
	#return whiteNoiseBM(pInt)

	if isPrime(pInt):
		return 100
	else:
		return 2

	#return 1
	#return sin(pInt/10)+2
	#return pInt
	return (distillNumber(pInt)*(pi+sin(pInt))*pi)
	#return distillNumber(pInt)*pow(sin(pInt),10)*pi
	#return (pInt/pi)*cos( pow(distillNumber(pInt),2)/pi )
	#
	#return distillNumber(pInt)/5

	#return (sqrt(pInt)*distillNumber(pInt))/pi
	#return distillNumber(pInt)*pi+pInt
	return pInt/pi
	#return 100

def getNewX(pX,pY):
	return pX
	return pX + (pX-pY)

def getNewY(pX,pY):
	return pY
	return pY + (pY-pX)

def getNewColor(pInt):
	#return color.red
	#print (distillNumber(pInt))*.1
	return (
			(distillNumber(pInt))*.1,
			(distillNumber(pInt))*.1,
			(distillNumber(pInt))*.12
			)

def getSize(pInt):
	return 2
	#return distillNumber(pInt)
	return 1
	#fooNum = distillNumber(pInt)
	#return ((pInt/pi)*cos( distillNumber(pInt)/pi ))/fooNum
	return distillNumber(pInt)*cos( distillNumber(pInt) )

#used by the icecube maker
def getAltitudeAlternate(pInt):
	return whiteNoiseBM(pInt)
	return distillNumber(pInt)*(pi+sin(pInt))*pi

def getBoxHeight(pInt):
	return whiteNoiseBM(pInt)
	return distillNumber(pInt)
	return 1
	return distillNumber(pInt)/pi

def getBoxWidth(pInt):
	return whiteNoiseBM(pInt)
	return distillNumber(pInt)*10
	return round(sqrt(pow(pInt,2))*(1.6180339887*3.14159265)/2)/1000
	return distillNumber(pInt)*pi

def turnOnOpposite():
	return false

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
	_ballRadius = 2
	_floor = 1
	_headroom = 20

	#establish the first dot
	ball = sphere (color = color.red, radius = _ballRadius)
	ball.pos = vector(0,0,-10)

	spaghetti = curve( color = color.red, radius=1)

	#newbox = box(pos=(0,0,0),length=1,height=1,width=1, color=color.red)


	for i in range(_floor,_headroom):
		if _order[ordinalDirectionIndex] == "r":
			tmpRange = (2*i)-1

			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX + getSpacer(numberCounter)

				if testNumber(numberCounter)==true:
					#ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					#ball.pos = vector( getNewX(posX,posY),getNewY(posX,posY) ,getAltitude(numberCounter))

					#newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color=color.red)
					#newbox.pos  = vector(posX,posY,getAltitude(numberCounter))

					spaghetti.append( vector( getNewX(posX,posY),getNewY(posX,posY) ,getAltitude(numberCounter)), color = getNewColor(numberCounter) )

				elif turnOnOpposite() == true:
					#ball = sphere (color = (0.5,0.5,0.5), radius = getSize(numberCounter))
					#ball.pos = vector(posX,posY,-getAltitude(numberCounter))

					newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color = (0.5,0.5,0.5))
					newbox.pos  = vector(posX,posY,-getAltitudeAlternate(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "u":
			tmpRange = (2*i)-1
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY - getSpacer(numberCounter)
				if testNumber(numberCounter)==true:
					#ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					#ball.pos = vector(getNewX(posX,posY),getNewY(posX,posY),getAltitude(numberCounter))

					#newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color=color.red)
					#newbox.pos  = vector(posX,posY,getAltitude(numberCounter))

					spaghetti.append( vector( getNewX(posX,posY),getNewY(posX,posY) ,getAltitude(numberCounter)), color = getNewColor(numberCounter) )

				elif turnOnOpposite() == true:
					#ball = sphere (color = (0.5,0.5,0.5), radius = getSize(numberCounter))
					#ball.pos = vector(posX,posY,-getAltitude(numberCounter))

					newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color = (0.5,0.5,0.5))
					newbox.pos  = vector(posX,posY,-getAltitudeAlternate(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "l":
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX - getSpacer(numberCounter)
				if testNumber(numberCounter)==true:
					#ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					#ball.pos = vector(getNewX(posX,posY),getNewY(posX,posY),getAltitude(numberCounter))

					#newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color=color.red)
					#newbox.pos  = vector(posX,posY,getAltitude(numberCounter))

					spaghetti.append( vector( getNewX(posX,posY),getNewY(posX,posY) ,getAltitude(numberCounter)), color = getNewColor(numberCounter) )

				elif turnOnOpposite() == true:
					#ball = sphere (color = (0.5,0.5,0.5), radius = getSize(numberCounter))
					#ball.pos = vector(posX,posY,-getAltitude(numberCounter))

					newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color = (0.5,0.5,0.5))
					newbox.pos  = vector(posX,posY,-getAltitudeAlternate(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "d":
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY + getSpacer(numberCounter)
				if testNumber(numberCounter)==true:
					#ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					#ball.pos = vector(getNewX(posX,posY),getNewY(posX,posY),getAltitude(numberCounter))

					#newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color=color.red)
					#newbox.pos  = vector(posX,posY,getAltitude(numberCounter))


					spaghetti.append( vector( getNewX(posX,posY),getNewY(posX,posY) ,getAltitude(numberCounter)), color = getNewColor(numberCounter) )

				elif turnOnOpposite() == true:
					#ball = sphere (color = (0.5,0.5,0.5), radius = getSize(numberCounter))
					#ball.pos = vector(posX,posY,-getAltitude(numberCounter))

					newbox = box(length=getSize(numberCounter),height=getBoxHeight(numberCounter),width=getBoxWidth(numberCounter), color = (0.5,0.5,0.5))
					newbox.pos  = vector(posX,posY,-getAltitudeAlternate(numberCounter))

			#reset ordinalDirectionIndex
			ordinalDirectionIndex=0

#fire it up
initGauss(3)
initSpiral()