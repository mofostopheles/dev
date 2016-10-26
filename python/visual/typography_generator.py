import os, sys
import Tkinter
import Image, ImageTk
from visual import *
from random import *
from random import *

"""
im = Image.open(pasteImage,'r').rotate(90, expand=1) #.save("_new_img.png", "PNG")
im2 = Image.open(pasteImage,'r')
im.paste(im2, (0,0))
im.save("_new_img.png", "PNG")
"""

def testNumber(pInt):
	#persian rug

	if round(  pow(sqrt(pInt)/pi, pi) )%7==0:
		return true
	return false

def modifyCoordPoint(pNum):
	return pNum

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

	posX = 800
	posY = 800
	ordinalDirectionIndex = 0
	numberCounter = 1
	_order = ["r","u","l","d"]
	imageList = ["you.png"] #, "moon4.png", "moon5.png", "moon6.png", "moon7.png", "moon8.png", "moon9.png", "moon10.png", "moon11.png", "moon12.png"]
	_spacer = 16  #use 45 for perfect tiling
	pasteImage = "cap_e.png"
	imgListIndex = 0

	#establish the first dot
	#ball = sphere (color = color.red, radius = _ballRadius)
	#ball.pos = vector(0,0,-10)

	base_image = Image.open('base_image_1600_black.png','r')

	for i in range(1,30):

		if _order[ordinalDirectionIndex] == "r":
			#move an odd number based on i
			tmpRange = (2*i)-1

			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX + _spacer

				if testNumber(numberCounter)==true:
					posX = modifyCoordPoint(posX)
					im2 = Image.open(imageList[imgListIndex],'r')#.resize((20,20))
					if imgListIndex == len(imageList)-1:
						imgListIndex = 0
					else:
						imgListIndex += 1
					#im2 = Image.open(pasteImage,'r')
					base_image.paste(im2, (posX,posY), im2)

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "u":
			tmpRange = (2*i)-1
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY - _spacer

				if testNumber(numberCounter)==true:
					posY = modifyCoordPoint(posY)
					im2 = Image.open(imageList[imgListIndex],'r').rotate(90)#.resize((20,20))
					if imgListIndex == len(imageList)-1:
						imgListIndex = 0
					else:
						imgListIndex += 1
					#im2 = Image.open(pasteImage,'r').rotate(90)
					base_image.paste(im2, (posX,posY), im2)

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "l":
			#move an even number based on i
			#(2*i)
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posX = posX - _spacer

				if testNumber(numberCounter)==true:
					posX = modifyCoordPoint(posX)
					im2 = Image.open(imageList[imgListIndex],'r').rotate(180)#.resize((20,20))
					if imgListIndex == len(imageList)-1:
						imgListIndex = 0
					else:
						imgListIndex += 1
					#im2 = Image.open(pasteImage,'r').rotate(180)
					base_image.paste(im2, (posX,posY), im2)

			ordinalDirectionIndex=ordinalDirectionIndex+1

		if _order[ordinalDirectionIndex] == "d":
			#(2*i)
			tmpRange = 2*i
			for k in range(tmpRange):
				numberCounter=numberCounter+1
				posY = posY + _spacer

				if testNumber(numberCounter)==true:
					posY = modifyCoordPoint(posY)
					im2 = Image.open(imageList[imgListIndex],'r').rotate(270)#.resize((20,20))
					if imgListIndex == len(imageList)-1:
						imgListIndex = 0
					else:
						imgListIndex += 1
					#im2 = Image.open(pasteImage,'r').rotate(270)
					base_image.paste(im2, (posX,posY), im2)

			#reset ordinalDirectionIndex
			ordinalDirectionIndex=0

	#last thing...
	base_image.save("__new_img.png", "PNG")

#fire it up
initSpiral()


