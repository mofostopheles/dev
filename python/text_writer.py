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
		#if round(    sin( pInt * distillNumber(pInt) )   ) % distillNumber(pInt)==0:
		#return true

	#persian rug
	if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
		return true
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
	_newLeft = 0
	_newTop = 0
	_spacer = 2
	_numberCounter = 0
	_binaryRepresentation = ""
	_spacer = 2
	_ballRadius = 1
	_rowLength = 200

	masterList = []
	letter_a = [[247, 247, 247],[225, 227, 226],[130, 130, 130],[90, 91, 93],[116, 117, 119],[211, 211, 213],[245, 247, 246],['newRow'],
	[244, 244, 244],[108, 110, 109],[30, 30, 32],[121, 121, 123],[48, 48, 50],[61, 61, 63],[227, 229, 228],['newRow'],
	[243, 243, 243],[128, 129, 131],[141, 141, 143],[237, 237, 239],[104, 104, 106],[30, 28, 31],[208, 210, 209],['newRow'],
	[247, 247, 249],[200, 201, 203],[122, 122, 124],[49, 49, 51],[30, 30, 32],[40, 38, 41],[210, 210, 210],['newRow'],
	[232, 232, 234],[63, 64, 66],[40, 40, 42],[141, 141, 143],[104, 104, 106],[33, 31, 34],[209, 209, 209],['newRow'],
	[190, 190, 190],[30, 31, 33],[159, 159, 161],[246, 246, 248],[92, 92, 94],[31, 29, 32],[209, 211, 210],['newRow'],
	[213, 213, 213],[36, 38, 37],[87, 87, 89],[120, 120, 122],[30, 30, 32],[30, 30, 32],[207, 209, 208],['newRow'],
	[249, 249, 249],[162, 164, 163],[85, 85, 85],[94, 95, 97],[132, 133, 135],[115, 115, 117],[218, 220, 219],['newRow']
	]

	for i in range(0,100): #move Y
		_newLeft = 0;

		for j in range(0,100): #move X

			_numberCounter = _numberCounter + 1

			#ball = sphere (color = color.red, radius = _ballRadius)
			#ball.pos = vector(_newLeft,_newTop,1)

			if testNumber(_numberCounter)==true:
				masterList.append(1)
			else:
				masterList.append(0)

			if _newLeft == _rowLength:
					masterList.append("newRow")

			#_newLeft = _newLeft  + _spacer
		#_newTop = _newTop +  _spacer

	#print masterList
	#//end for

	imageCounter = 0

	okayToProceed = true


	for i in range(0, _numberCounter):
		if testNumber(i)==true:
			ball = sphere (color = color.red, radius = _ballRadius)
			ball.pos = vector(_newLeft,_newTop,1)
		else:
			ball = sphere (color = color.black, radius = _ballRadius)
			ball.pos = vector(_newLeft,_newTop,1)

		if imageCounter < len(letter_a):
			if str(letter_a[imageCounter][0]) != 'newRow':
				if okayToProceed == true:
					tmpColor_red = letter_a[imageCounter][0]
					tmpColor_red = int(tmpColor_red)/255.0

					tmpColor_green = letter_a[imageCounter][0]
					tmpColor_green = int(tmpColor_green)/255.0

					tmpColor_blue = letter_a[imageCounter][0]
					tmpColor_blue = int(tmpColor_blue)/255.0

					ball = sphere (color = (tmpColor_red,tmpColor_green,tmpColor_blue), radius = _ballRadius)
					ball.pos = vector(_newLeft,_newTop,4)

					imageCounter = imageCounter + 1
			else:
				okayToProceed = false

		if _newLeft == _rowLength:
			_newLeft = 0
			_newTop = _newTop +  _spacer
			okayToProceed = true
			imageCounter = imageCounter + 1
		else:
			_newLeft = _newLeft  + _spacer


#fire it up
displayNumberQualities()