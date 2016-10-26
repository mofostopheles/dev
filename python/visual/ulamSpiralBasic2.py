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
	#persian rug
	#if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
	return isPrime(pInt)

def getNumberSelfAffinity(pInt):
	# 2-layer z-zone
	#return sin(  pInt * pInt/ pInt )

	#pyramid
	#return (sqrt(pInt)/pi)*2

	return 1

#
#main spiral function
#
def logSpiral(centerX, centerY, radius, sides, coils, rotation):
	_ballRadius = 5
	# How far to rotate around center for each side.
	aroundStep = coils/sides
	# Convert aroundStep to radians.
	aroundRadians = aroundStep * 2 * pi
	# Convert rotation to radians.
	rotation=rotation*(2 * pi)
	# For every side, step around and away from center.

	numberCounter = 1

	for i in range(1,sides):
		# How far away from center
		#away = pow(radius, i/sides)
		away = radius*i/sides

		# How far around the center.
		around = i * aroundRadians + rotation
		# Convert 'around' and 'away' to X and Y.
		posX = centerX + cos(around) * away
		posY = centerY + sin(around) * away

		if testNumber(numberCounter)==true:
			ball = sphere (color = color.red, radius = _ballRadius)
			ball.pos = vector(posX,posY,getNumberSelfAffinity(numberCounter))
		else:
			ball = sphere (color = (0.5,0.5,0.5), radius = _ballRadius)
			ball.pos = vector(posX,posY,pow(-getNumberSelfAffinity(numberCounter),2))

		numberCounter = numberCounter + 1

#fire it up
#logSpiral(0,0,250,250.0,28.0,0)
logSpiral(0,0,300.0,500.0,28.0,0)