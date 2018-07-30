#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arlo.emerson@essenceglobal.com>"
__version__ = "1.2"
__date__ = "2/13/2018"

"""
	SCRIPT: 
	"make_jpg_sprites_from_frames.py"

	SYNOPSIS:
	This script makes a 1 row horizontal sprite from loose, unorganized PNGs that have been exported from After Effects using the "__render_tagged_layers_from_selected_comps.jsx" script. 
	
	In After Effects the comp would be named e.g. "home-mini-ao-loopable-coral-[frame]-300x600" where "[frame]" is dynamically replaced by however many guide layers with a hashtag-string name e.g. "#intro" (see any Home Mini project for examples). This hashtag-string convention replaces the older naming convention of simply numbering these guide layers, as titles make more sense when frames are reordered by dev.

	USAGE:
	• Place this script and the lib folder in your render/output folder.
	• Nothing to set, you just run the script. If there are PNGs present, a sprite will be constructed for each unique set of PNGs (based on the filenames).
	• A temp folder "__sprite_staging_area" will be created at this script's location to hold sorted PNGs. Organizing the PNGs into folders is something normally done by After Effects, however our hashtag-string script obliterates the inherant foldering mechanism, and the ability to make a directory is not exposed in a JSX script. 
	• The temp folder "__sprite_staging_area" will be removed at the end of this script's execution.

	TROUBLESHOOTING:
	• If you end up with wonky looking filenames for your sprites, make sure your render folder is clean, only containing PNGs you wish to convert. Stray PNGs can cause trouble. 
"""

import os, sys, glob, subprocess, shutil
import lib.png_sprite_maker as _spriteMaker
import lib.strings_EN as strings_en
from lib.BuildSpriteStagingArea import BuildSpriteStagingArea
from datetime import datetime as dt
from PIL import Image

class MakeSpritesFromFrames():

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")

		self.workingDir = ""
		self.workingDirShortName = ""
		self.stageingAreaDir = ""
		self.spriteStagingArea = "__sprite_staging_area"

	def runProcess(self):
		
		files = sorted( glob.glob( self.workingDir  + '*.png') )
		
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

# first thing we do is sort the PNGs into folders
bssa = BuildSpriteStagingArea()
sortedCount = bssa.sortImages("png")

if sortedCount == 0:
	raise NameError("No PNGs were available to process.")

# instantiate the sprite making class
f = MakeSpritesFromFrames()

# get our directories
# assumes this script is running at sibling level to these folders
dirs = next( os.walk('./' + f.spriteStagingArea) )[1]

# loop our dirs and make sprites
for dir in dirs:
	# print(os.getcwd() + "/" + dir + "/")
	f.workingDirShortName = dir
	f.workingDir = os.getcwd() + "/" + f.spriteStagingArea + "/" + dir + "/" 
	f.runProcess()

# delete the __sprite_staging_area directory
print("deleting " + f.spriteStagingArea )
shutil.rmtree("__sprite_staging_area")