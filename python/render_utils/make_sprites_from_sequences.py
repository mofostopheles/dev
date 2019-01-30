#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.5"
__date__ = "2/15/2018"

"""
	SCRIPT: 
	make_sprites_from_sequences.py

	SYNOPSIS:
	This script makes a 1 row horizontal sprite from PNGs that are already organized into directories. Typically these would have been exported from After Effects using the built-in PNG Sequence render output module.

	USAGE:
	• Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.
	• Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.
	• Directories with names like "misc" or "processed" or "boneyard", etc, will be ignored. All other directories are globbed for *.png files.
"""

import os, sys, glob, subprocess, argparse, textwrap
import lib.png_sprite_maker as _spriteMaker
import lib.strings_EN as strings_en
import lib.TextColors as TextColors
from datetime import datetime as dt
from PIL import Image

class MakeSpritesFromSequences():

	def __init__(self):
		# print("Running '" + self.__class__.__name__ + "'...")
		print("Running " + TextColors.HEADERLEFT2 + TextColors.INVERTED + self.__class__.__name__ + " " + TextColors.ENDC)

		TextColors.printLogo()

		self.workingDir = ""
		self.workingDirShortName = ""
		self.outputType = "png"
		self.verbose = False
		self.vertical = None #default to horizontal sprites
		self.quality = 70
		self.qset = None
		self.qsetList = [50, 60, 70, 75, 80, 85, 90, 95]
		self.encoder = "pillow"
		self.extent = 600
		self.pixel3 = False

		parser = argparse.ArgumentParser(description='This script makes a 1 row horizontal sprite from ' + TextColors.WARNING + 'PNGs that are already organized into directories. ' + TextColors.ENDC + ' Typically these would have been exported from After Effects using the built-in PNG Sequence render output module.', 
			epilog=textwrap.dedent('''Setup:
• Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.

• Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.

• Directories with names like "misc" or "processed" or "boneyard", etc, will be ignored. All other directories are globbed for *.png files.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-vert', '--vertical', dest='vertical', action='store_true', help="For making vertical sprites. Default is horizontal.")
		parser.add_argument('-e', '--encoder', dest='encoder', required=False, help="The specific lib to use to encode the output. Default encoder is Pillow. Use -e imagemagic|magic to use the size constraint feature which looks something like: " + TextColors.WHITE + "python make_sprites_from_sequences.py -t jpg -e magic -x 700" + TextColors.ENDC)
		parser.add_argument('-t', '--type', dest='type', required=False, help="For JPEG output use -type jpg|JPG|jpeg|JPEG. Default output is PNG.")
		parser.add_argument('-x', '--extent', dest='extent', required=False, help="Sets the extent flag in the ImageMagick conversion.")
		parser.add_argument('-q', '--quality', dest='quality', required=False, help="e.g. For JPEG with quality 80 use -q 80. Default quality is 70.")
		parser.add_argument('-qset', dest='qset', action='store_true', help="e.g. To export a range of quality settings 50 through 100. Default quality is 70.")		
		parser.add_argument('-v','--verbose', dest='verbose', action='store_true', help="Explain what is being done.")
		parser.add_argument('-p3','--pixel3', dest='pixel3', action='store_true', help="Auto crop the sprites for Pixel 3 Q4 launch.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()
		
		print("\n----- PREFLIGHT SUMMARY -----")

		if args.type:
			self.outputType = args.type
			print("Output type is " + args.type + ".")
		else:
			if args.encoder:
				if "magic" in args.encoder:
					print(TextColors.WARNING + "No file type was specified, but assuming JPG since you invoked ImageMagick." + TextColors.ENDC)
					self.outputType = "jpg"
				else:	
					print("Will create PNG sprites.")
			else:
				print("Will create PNG sprites.")

		if args.verbose:
			self.verbose = args.verbose
			if self.verbose == True:			
				print("Verbose mode")

		if args.pixel3:
			self.pixel3 = True

		if args.encoder:
			self.encoder = args.encoder.lower()
			print("Encoder type: " + args.encoder)
		else:
			print("Will save files using Pillow. Use -e magic to use the ImageMagick library.")

		if args.extent:
			self.extent = args.extent.lower()

			if args.encoder == False: # extent was set but the encoder was not, so assume ImageMagick is desired.
				self.encoder = "magic"

			print("extent: " + args.extent)
		else:
			print("Will save at 600KB if magic was called. Use -x flag and pass in a number for KB.")

		if args.vertical:
			self.vertical = args.vertical
			print("Making vertical sprites.")
		else:
			print("Will create horizontal sprites.")

		if args.quality:
			self.quality = args.quality
			print("JPG quality set to " + str(args.quality))

			if args.encoder != None and "magic" in args.encoder:
				print( TextColors.WARNING + "You set the quality flag to " + self.quality + " but encoder is ImageMagick with the default extent flag built in. If you want to set quality use the default encoder by omitting -e magic or using -e pillow." + TextColors.ENDC)
		else:
			if self.outputType != "png":
				print("Will use JPG 70 quality.")

		if args.qset:
			self.qset = args.qset
			print("qset is " + str(args.qset))
		else:
			if self.outputType != "png":
				print("qset ommited, will use JPG 70 quality.")

		print("-----------------------------")

	def runProcess(self):
		print("-----------------------------")
		files = sorted( glob.glob( str( self.workingDir )  + '*.png') )
		
		if len( files ) == 0:
			print(TextColors.WARNING + "Found nothing to convert in " + TextColors.ENDC + TextColors.CYAN + self.workingDir + TextColors.ENDC)
			return

		numberOfFrames = len( files ) # this equates to number of frames in the sprite
		self.localPrint(TextColors.WHITE + "Number of frames: " + TextColors.ENDC + TextColors.CYAN + str( numberOfFrames ) + TextColors.ENDC)
		tmpImage=Image.open( files[0] )
		
		if self.vertical:
			processedSprite = _spriteMaker.makeVerticalSprite(files,numberOfFrames,tmpImage.size[0],tmpImage.size[1])
		else:
			processedSprite = _spriteMaker.makeSprite(files,numberOfFrames,tmpImage.size[0],tmpImage.size[1])

		strDirectory = str(self.workingDir)
		strFileName = strings_en.SPRITE + self.workingDirShortName + ".png"

		if self.outputType == "png":
			if processedSprite:
				processedSprite.save(strFileName)
				self.printSpriteComplete(strFileName)		
			else:
				print(TextColors.FAIL + "Failed to make sprite " +  TextColors.ENDC + TextColors.WHITE + strFileName + TextColors.ENDC)			
		else:
			if self.qset:
				qset = self.qsetList # 100 disables portions of the JPEG compression algorithm, and results in large files with hardly any gain in image quality.
				self.localPrint(TextColors.WHITE + "Using this qset: " + TextColors.ENDC + TextColors.CYAN + str( self.qsetList ) + TextColors.ENDC)
			else:
				qset = [self.quality]
				self.localPrint(TextColors.WHITE + "Using JPG quality of "  + TextColors.ENDC + TextColors.CYAN + str( self.quality ) + TextColors.ENDC)
			
			for q in qset:

				if self.pixel3 == True: # crop the sprite according to the pixel3 specs
					processedSprite = self.cropImageForPixel3(processedSprite)

				# if there is an alpha channel this will remove it
				dealphaImage = processedSprite.convert("RGB")
				
				if self.encoder == "pillow":
					# strFileName = strings_en.SPRITE + self.workingDirShortName + "-q" + str(q) + ".jpg"
					strFileName = strings_en.SPRITE + self.workingDirShortName + ".jpg"
					fullFilePath = strFileName
					self.localPrint(TextColors.WHITE + "Quality set to " + str(q) + TextColors.ENDC)
					dealphaImage.save(fullFilePath, format='JPEG', subsampling=0, quality=int(q), optimize=True, progressive=True)	
					self.printSpriteComplete(fullFilePath)
				
				elif self.encoder == "magic" or self.encoder == "imagemagic":
					try:
						strFileName = strings_en.SPRITE + self.workingDirShortName + ".jpg"
						fullFilePath = strFileName

						processedSprite.save(fullFilePath + ".png") # this is really a temp file
						self.localPrint(TextColors.WHITE + "Converting with " + TextColors.ENDC + TextColors.CYAN + str( self.extent ) + TextColors.ENDC + TextColors.WHITE + " KB extent" + TextColors.ENDC)
						arg = "convert " + fullFilePath + ".png -define jpeg:extent=" + str(self.extent) + "kb " + fullFilePath
						self.localPrint(TextColors.DARKGREEN + arg + TextColors.ENDC)
						os.system( arg )
						os.system( "rm " + fullFilePath + ".png" ) # remove the temp file
						self.localPrint(TextColors.WHITE + "Removed a temp PNG file." + TextColors.ENDC)
						self.printSpriteComplete(fullFilePath)

						pass
					except Exception as e:
						print("If you're seeing this error, make sure you are passing in -e magic on the command line. Does not work from within SUBLIME.")
						raise e
	
	def cropImageForPixel3(self, pImage):
		print("recropping ", pImage)

		# these must be even numbers
		croppingHeight320x480 = 422
		croppingHeight300x250 = 214
		croppingHeight160x600 = 588
		croppingHeight300x600 = 532
		croppingHeight480x320 = 292
		croppingHeight640x480 = 404
		croppingHeight120x600 = 590
		croppingHeight336x280 = 240
		croppedImage = None			
		recropImage = pImage #Image.open(pFilePath)
		if self.workingDirShortName.find("-layer1") > -1: # TOP IMAGE							
			if self.workingDirShortName.find("320x480") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight320x480))	# left top right bottom 423				
			elif self.workingDirShortName.find("300x250") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight300x250))
			elif self.workingDirShortName.find("160x600") > -1:		
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight160x600))
			elif self.workingDirShortName.find("300x600") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight300x600))
			elif self.workingDirShortName.find("480x320") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight480x320))
			elif self.workingDirShortName.find("640x480") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight640x480))
			elif self.workingDirShortName.find("120x600") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight120x600))
			elif self.workingDirShortName.find("336x280") > -1:									
				croppedImage = recropImage.crop((0, 0, recropImage.width, croppingHeight336x280))
		elif self.workingDirShortName.find("-layer0") > -1: # BOTTOM IMAGE
			if self.workingDirShortName.find("320x480") > -1:
				croppedImage = recropImage.crop((0, croppingHeight320x480, recropImage.width, recropImage.height))
			elif self.workingDirShortName.find("300x250") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight300x250, recropImage.width, recropImage.height))							
			elif self.workingDirShortName.find("160x600") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight160x600, recropImage.width, recropImage.height))							
			elif self.workingDirShortName.find("300x600") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight300x600, recropImage.width, recropImage.height))							
			elif self.workingDirShortName.find("480x320") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight480x320, recropImage.width, recropImage.height))							
			elif self.workingDirShortName.find("640x480") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight640x480, recropImage.width, recropImage.height))							
			elif self.workingDirShortName.find("120x600") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight120x600, recropImage.width, recropImage.height))							
			elif self.workingDirShortName.find("336x280") > -1:									
				croppedImage = recropImage.crop((0, croppingHeight336x280, recropImage.width, recropImage.height))							

		return croppedImage

	def printSpriteComplete(self, pName):
		print("\nThe sprite " + TextColors.KNOCKOUT + pName + TextColors.ENDC + " has been created.")	

	def openFolder(self, pDirectory):
		if sys.platform == 'darwin':
			subprocess.Popen(['open', '--', pDirectory])
		elif sys.platform == 'linux2':
			subprocess.Popen(['xdg-open', pDirectory])
		elif sys.platform == 'win32':
			subprocess.Popen(['explorer', pDirectory.replace("/", "\\")])


	def localPrint(self, pMessage):
		if self.verbose == True:
			print(pMessage)

# get our directories
# assumes this script is running at sibling level to these folders
dirs = next( os.walk('.') )[1]

f = MakeSpritesFromSequences()

for dirName in dirs:
	# important and basic check so we don't try to process the "processed" folder
	# if you have other folder titles you'd like to avoid processing, add them here
	if dirName != "processed" and \
	   dirName != "misc" and \
	   dirName != "boneyard" and \
	   dirName != "archive":
		f.workingDirShortName = dirName
		f.workingDir = dirName + "/"
		try:
			f.runProcess()
		except Exception as e:
			print("¯\\_( :-/ )_/¯  Whooops!")
			raise e 





	  
