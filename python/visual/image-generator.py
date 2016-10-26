from visual import *

print """

"""

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


			_newLeft = _newLeft + _spacer;

		_newTop = _newTop + _spacer;


def testNumber(pInt):
	if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
		return true

	return false

def colorizeDot(pDot):
	pDot.color = color.red

drawRegion(0)

"""
side = 4.0
thk = 0.3
s2 = 2*side - thk
s3 = 2*side + thk
wallR = box (pos=( side, 0, 0), length=thk, height=s2,  width=s3,  color = color.red)
wallL = box (pos=(-side, 0, 0), length=thk, height=s2,  width=s3,  color = color.red)
wallB = box (pos=(0, -side, 0), length=s3,  height=thk, width=s3,  color = color.blue)
wallT = box (pos=(0,  side, 0), length=s3,  height=thk, width=s3,  color = color.blue)
wallBK = box(pos=(0, 0, -side), length=s2,  height=s2,  width=thk, color = (0.7,0.7,0.7))

ball = sphere (color = color.green, radius = 0.4)
ball.mass = 1.0
ball.p = vector (-0.15, -0.23, +0.27)

side = side - thk*0.5 - ball.radius

dt = 0.5
t=0.0
while 1:
  rate(100)
  t = t + dt
  ball.pos = ball.pos + (ball.p/ball.mass)*dt
  if not (side > ball.x > -side):
    ball.p.x = -ball.p.x
  if not (side > ball.y > -side):
    ball.p.y = -ball.p.y
  if not (side > ball.z > -side):
    ball.p.z = -ball.p.z
"""
