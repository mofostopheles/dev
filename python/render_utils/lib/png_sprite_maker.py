#!/usr/bin/env python
# -*- coding: utf8 -*-

"""
arlo emerson, 9/08/2017
arloemerson@gmail.com
Code embraced and extended from an original script by:
"""
__author__ = "http://code.activestate.com/recipes/578267-use-pil-to-make-a-contact-sheet-montage-of-images/"

import glob
from PIL import Image
from datetime import datetime as dt
import TextColors as TextColors

def makeSprite(pFilenames,pFrameCount,pImageWidth,pImageHeight):

	isize = ((pFrameCount*pImageWidth),pImageHeight)


	tmpTransparancyMask = Image.new('RGBA', (pImageWidth, pImageHeight), (255, 255, 255) )

	# print(tmpTransparancyMask)
	# print((pImageWidth, pImageHeight))
	inew = Image.new('RGBA', (isize[0], isize[1]) )
	xPos = 0
	tmpCounter = 0

	for i in range(pFrameCount):

		newWidth = 0
		newHeight = 0
		img = None
		try:
			img = Image.open(pFilenames[tmpCounter])
			tmpCounter += 1
			img_bbox = img.getbbox()

			width = img_bbox[2] - img_bbox[0]
			height = img_bbox[3] - img_bbox[1]

			newSize = (width, height)

		except Exception as e:
			print(e)
		else: 
			pass

		xPos = (pImageWidth * i)
		
		# there's an intermittant bug with the mask.
		# it actually might have to do with more than one sized PNG sneaking into the collection.
		# anyway, sometimes that line fails so a temp workaround is presented:
		try:
			inew.paste(img, (xPos, 0), tmpTransparancyMask)
		except ValueError:
			inew.paste(img, (xPos, 0))
			printTransMaskError()
			return None
		
	return inew

def printTransMaskError():
	print("¯\\_( :-/ )_/¯  Whooops!")
	print(TextColors.FAIL +  "Error pasting the transparency mask. " + TextColors.ENDC + \
				"This is usually caused when the source PNGs are not the same size. Check that the PNGs from each comp in their own individual folders, either in your render folder or in the __sprite_staging_area folder. ")

def makeVerticalSprite(pFilenames,pFrameCount,pImageWidth,pImageHeight):

	isize = (pImageWidth,(pFrameCount*pImageHeight))

	# test area, trying to use this for all 
	tmpTransparancyMask = Image.new('RGBA', (pImageWidth, pImageHeight), (255, 255, 255) )
	inew = Image.new('RGBA', (isize[0], isize[1]) )

	# inew = Image.new('RGB', (isize[0], isize[1]) )
	yPos = 0
	tmpCounter = 0

	for i in range(pFrameCount):

		newWidth = 0
		newHeight = 0
		img = None
		try:
			img = Image.open(pFilenames[tmpCounter])
			tmpCounter += 1
			img_bbox = img.getbbox()

			width = img_bbox[2] - img_bbox[0]
			height = img_bbox[3] - img_bbox[1]

			newSize = (width, height)

		except Exception as e:
			print(e)
		else: 
			pass

		yPos = (pImageHeight * i)		
		# inew.paste(img, (0, yPos))		
		
		# there's an intermittant bug with the mask.
		# it actually might have to do with more than one sized PNG sneaking into the collection.
		# anyway, sometimes that line fails so a temp workaround is presented:
		try:
			inew.paste(img, (0, yPos), tmpTransparancyMask)
		except ValueError:
			inew.paste(img, (0, yPos))
			printTransMaskError()
			return None

	return inew

# this is maintained for backwards compat with older scripts calling here
def makeJPGSprite(pFilenames,pFrameCount,pImageWidth,pImageHeight):

	isize = ((pFrameCount*pImageWidth),pImageHeight)

	inew = Image.new('RGB', (isize[0], isize[1]) )
	xPos = 0
	tmpCounter = 0

	for i in range(pFrameCount):

		newWidth = 0
		newHeight = 0
		img = None
		try:
			img = Image.open(pFilenames[tmpCounter])
			tmpCounter += 1
			img_bbox = img.getbbox()

			width = img_bbox[2] - img_bbox[0]
			height = img_bbox[3] - img_bbox[1]

			newSize = (width, height)

		except Exception as e:
			print(e)
		else: 
			pass

		xPos = (pImageWidth * i)		
		inew.paste(img, (xPos, 0))		
		
	return inew


