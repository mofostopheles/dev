from visual import *
from random import uniform, randint
from Numeric import *



import random

print """
hello
"""

_nRand = 4
_aRand = pow(2,31)-1
_gaussAdd = sqrt(3*_nRand)
_gaussFac = 2*_gaussAdd/_nRand*_aRand
_delta = []
_lastPos = vector()

def initGauss(pSeed):

	#srand(seed)
	#print str(_gaussFac)
	gauss()



def gauss():
	_sum = 0
	_i = 0

	for _i in range(_nRand):
		_sum = _sum + random.randrange(1,9)
		#newRand = random.randrange(3,9)

	#print str( _gaussFac * _sum - _gaussAdd)
	return _gaussFac * _sum - _gaussAdd


def whiteNoiseBM():
	_lastPos = [1,1,1]
	pX = 1000
	initGauss(3)
	for _i in range(500):
		foo = _i + gauss()/(500)
		newFoo = foo/2550000
		#print str(newFoo)
		ball = sphere (color = color.red, radius = 1)
		ball.mass = 1
		ball.pos = vector(_i,newFoo,1)


		#line = canvas.create_line(x0, y0, x1, y1)
		links = []
		for l in range(50):
			#i = randint(0,10)
			#j = randint(0,10)
			c = curve( ends=[ball.pos,_lastPos], radius=1 )
			c.red = 0
			c.green = uniform(0.3,1)
			c.blue = 0
			c.pos = c.ends
			links.append(c)

		_lastPos = ball.pos

def midPointBrownianMotion():
	sigma = 2 # what the hay?
	maxLevel = 64
	_lastPos = [1,1,1]
	initGauss(3)

	for i in range(maxLevel):
		_delta.append(sigma * pow(0.5, (i+1)/2))
		#print str(_delta[i])

	n = pow(maxLevel, 2)
	x = []

	#populate our list with placeholder values
	for j in range(int(n)):
		x.append(0)

	x.insert(int(n), sigma * gauss())

	midPointRecursion(x,0,n,1,maxLevel)

def midPointRecursion(pX, pIndex0, pIndex2, pLevel, pMaxLevel):
	global _lastPos
	index1 = int((pIndex0 + pIndex2)/2)
	amplitudeContainer = 100550000
	pX[index1] = (0.5*(pX[int(pIndex0)] + pX[int(pIndex2)]) + _delta[pLevel] * gauss())/amplitudeContainer

	ball = sphere (color = color.red, radius = 1)
	ball.mass = 1
	print pX[index1]
	ball.pos = vector(pLevel,pX[index1],1)



	links = []
	for l in range(pLevel):
		c = curve( ends=[ball.pos,_lastPos], radius=1 )
		c.red = 0
		c.green = uniform(0.3,1)
		c.blue = 0
		c.pos = c.ends
		links.append(c)

	_lastPos = ball.pos


	if pLevel < pMaxLevel-1:
		midPointRecursion(pX, pIndex0, index1, pLevel+1, pMaxLevel)
		#midPointRecursion(pX, index1, pIndex2, pLevel+1, pMaxLevel)




midPointBrownianMotion()