#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arlo.emerson@essenceglobal.com>"
__version__ = "1.1"
__date__ = "2/15/2018"

"""
	SCRIPT: 
	make_jpg_sprites_from_sequences.py"

	SYNOPSIS:
	This script makes a 1 row horizontal sprite from PNGs organized into directories. Typically these would have been exported from After Effects using the built-in PNG Sequence render output module.

	USAGE:
	• Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.
	• Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.
	• Directories with names like "misc" or "processed" or "boneyard", etc, will be ignored. All other directories are globbed for *.png files.
	• Add JPEG quality settings to the qset list. All-around default suggested 70.
"""

import os, sys, glob, subprocess
import lib.png_sprite_maker as _spriteMaker
import lib.strings_EN as strings_en
from datetime import datetime as dt
from PIL import Image


class MakeSpritesFromSequences():

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")

		self.workingDir = ""
		self.workingDirShortName = ""

	def runProcess(self):
		
		files = sorted( glob.glob( str( self.workingDir )  + '*.png') )
		
		if len( files ) == 0:
			print("nothing to convert in " + self.workingDir)
			return

		numberOfFrames = len( files ) # this equates to number of frames in the sprite
		tmpImage=Image.open( files[0] )
		
		processedSprite = _spriteMaker.makeJPGSprite(files,numberOfFrames,tmpImage.size[0],tmpImage.size[1])
		strDirectory = str(self.workingDir)
		# qset = [60, 100]
		qset = [70]
		for q in qset:
			strFileName = strings_en.SPRITE + self.workingDirShortName + "_q" + str(q) + ".jpg"
			processedSprite.save(os.getcwd() + "/" + strFileName, "JPEG", quality=q, optimize=True, progressive=True)
		
		print("sprite '" + strFileName + "' created.")
		
	def openFolder(self, pDirectory):
		if sys.platform == 'darwin':
			subprocess.Popen(['open', '--', pDirectory])
		elif sys.platform == 'linux2':
			subprocess.Popen(['xdg-open', pDirectory])
		elif sys.platform == 'win32':
			subprocess.Popen(['explorer', pDirectory.replace("/", "\\")])


# get our directories
# assumes this script is running at sibling level to these folders
dirs = next( os.walk('.') )[1]

f = MakeSpritesFromSequences()

for dirName in dirs:
	# print(os.getcwd() + "/" + dirName + "/")

	# important and basic check so we don't try to process the "processed" folder
	# if you have other folder titles you'd like to avoid processing, add them here
	if dirName != "processed" and \
	   dirName != "misc" and \
	   dirName != "boneyard" and \
	   dirName != "archive":
		f.workingDirShortName = dirName
		f.workingDir = os.getcwd() + "/" + dirName + "/" 
		f.runProcess()




	  
