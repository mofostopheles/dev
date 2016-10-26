from visual import *
import random

def testNumber(pInt):
	return true
	if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
		return true
	return false

def getFactors(pInt):
	numberIsDirty = false

	dirtCounter = 0

	for i in range(2, pInt):
		remainder = pInt%i
		if remainder==0:
			numberIsDirty = true
			dirtCounter += 1

	return dirtCounter

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
	return 3

def getAltitude(pInt):
	return 1

def getNewX(pX,pY):
	return pX# + (pX-pY)

def getNewY(pX,pY):
	return pY# + (pY-pX)

def getNewColor(pInt):
	numberOfFactors = getFactors(pInt)
	_colorList = [(int(255)/255.0,0,0),(int(27)/255.0,int(20)/255.0,int(4)/255.0),
(int(124)/255.0,int(176)/255.0,int(161)/255.0),
(int(106)/255.0,int(93)/255.0,int(27)/255.0),
(int(201)/255.0,int(255)/255.0,int(229)/255.0),
(int(113)/255.0,int(70)/255.0,int(147)/255.0),
(int(134)/255.0,int(86)/255.0,int(10)/255.0),
(int(212)/255.0,int(196)/255.0,int(168)/255.0),
(int(255)/255.0,int(255)/255.0,int(255)/255.0),
(int(245)/255.0,int(233)/255.0,int(211)/255.0),
(int(155)/255.0,int(71)/255.0,int(30)/255.0),
(int(118)/255.0,int(163)/255.0,int(144)/255.0),
(int(123)/255.0,int(113)/255.0,int(175)/255.0),
(int(143)/255.0,int(44)/255.0,int(219)/255.0),
(int(219)/255.0,int(219)/255.0,int(169)/255.0),(int(27)/255.0,int(20)/255.0,int(4)/255.0),
(int(124)/255.0,int(176)/255.0,int(161)/255.0),
(int(106)/255.0,int(93)/255.0,int(27)/255.0),
(int(201)/255.0,int(255)/255.0,int(229)/255.0),
(int(113)/255.0,int(70)/255.0,int(147)/255.0),
(int(134)/255.0,int(86)/255.0,int(10)/255.0),
(int(212)/255.0,int(196)/255.0,int(168)/255.0),
(int(255)/255.0,int(255)/255.0,int(255)/255.0),
(int(245)/255.0,int(233)/255.0,int(211)/255.0),
(int(155)/255.0,int(71)/255.0,int(30)/255.0),
(int(118)/255.0,int(163)/255.0,int(144)/255.0),
(int(123)/255.0,int(113)/255.0,int(175)/255.0),
(int(143)/255.0,int(44)/255.0,int(219)/255.0),
(int(219)/255.0,int(219)/255.0,int(169)/255.0),(int(27)/255.0,int(20)/255.0,int(4)/255.0),
(int(124)/255.0,int(176)/255.0,int(161)/255.0),
(int(106)/255.0,int(93)/255.0,int(27)/255.0),
(int(201)/255.0,int(255)/255.0,int(229)/255.0),
(int(113)/255.0,int(70)/255.0,int(147)/255.0),
(int(134)/255.0,int(86)/255.0,int(10)/255.0),
(int(212)/255.0,int(196)/255.0,int(168)/255.0),
(int(255)/255.0,int(255)/255.0,int(255)/255.0),
(int(245)/255.0,int(233)/255.0,int(211)/255.0),
(int(155)/255.0,int(71)/255.0,int(30)/255.0),
(int(118)/255.0,int(163)/255.0,int(144)/255.0),
(int(123)/255.0,int(113)/255.0,int(175)/255.0),
(int(143)/255.0,int(44)/255.0,int(219)/255.0),
(int(219)/255.0,int(219)/255.0,int(169)/255.0)]

	if numberOfFactors <= 1:
		return color.black
	else:
		print numberOfFactors
		return _colorList[numberOfFactors]

def getSize(pInt):
	return 2

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
	_order = ["r","u","l","d"]
	_ballRadius = 1
	_floor = 1
	_headroom = 50

	#establish the first dot
	ball = sphere (color = color.red, radius = _ballRadius)
	ball.pos = vector(0,0,-10)

	for i in range(_floor,_headroom):
		if _order[ordinalDirectionIndex] == "r":
			tmpRange = (2*i)-1

			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX + getSpacer(numberCounter)

				if testNumber(numberCounter)==true:
					ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					ball.pos = vector( getNewX(posX,posY),getNewY(posX,posY) ,getAltitude(numberCounter))
			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "u":
			tmpRange = (2*i)-1
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY - getSpacer(numberCounter)
				if testNumber(numberCounter)==true:
					ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					ball.pos = vector(getNewX(posX,posY),getNewY(posX,posY),getAltitude(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "l":
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX - getSpacer(numberCounter)
				if testNumber(numberCounter)==true:
					ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					ball.pos = vector(getNewX(posX,posY),getNewY(posX,posY),getAltitude(numberCounter))

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "d":
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY + getSpacer(numberCounter)
				if testNumber(numberCounter)==true:
					ball = sphere (color = getNewColor(numberCounter), radius = getSize(numberCounter))
					ball.pos = vector(getNewX(posX,posY),getNewY(posX,posY),getAltitude(numberCounter))

			#reset ordinalDirectionIndex
			ordinalDirectionIndex=0

#fire it up
initSpiral()