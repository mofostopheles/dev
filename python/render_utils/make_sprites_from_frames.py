#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.2"
__date__ = "5/23/2018"

"""
	SCRIPT: 
	"make_sprites_from_frames.py"

	SYNOPSIS:
	This script makes a 1 row horizontal sprite from loose, unorganized PNGs that have been exported from After Effects using the "__render_tagged_layers_from_selected_comps.jsx" script. 
	
	In After Effects the comp would be named e.g. "home-mini-ao-loopable-coral-[frame]-300x600" where "[frame]" is dynamically replaced by however many guide layers with a hashtag-string name e.g. "#intro" (see any Home Mini project for examples). This hashtag-string convention replaces the older naming convention of simply numbering these guide layers, as titles make more sense when frames are reordered by dev.

	USAGE:
	• Place this script and the lib folder in your render/output folder.
	• Nothing to set, you just run the script. If there are PNGs present, a sprite will be constructed for each unique set of PNGs (based on the filenames).
	• A temp folder "__sprite_staging_area" will be created at this script's location to hold sorted PNGs. Organizing the PNGs into folders is something normally done by After Effects, however our hashtag-string script obliterates the inherant foldering mechanism, and the ability to make a directory is not exposed in a JSX script. 
	• The temp folder "__sprite_staging_area" will be removed at the end of this script's execution.
	• Use args -vert to create vertical sprites.
	• Use -t jpg to set output type to JPG.
	• Use -q to set JPG quality, default is 70
	• Use -qset to export a range of qualities	
	• To see all flags and arguments run $ python make_sprites_from_frames.py -h
        
	TROUBLESHOOTING:
	• If you end up with wonky looking filenames for your sprites, make sure your render folder is clean, only containing PNGs you wish to convert. Stray PNGs can cause trouble. 
"""

import os, sys, glob, subprocess, shutil, argparse, textwrap
import lib.png_sprite_maker as _spriteMaker
import lib.strings_EN as strings_en
import lib.TextColors as TextColors
from lib.BuildSpriteStagingArea import BuildSpriteStagingArea
from datetime import datetime as dt
from PIL import Image

class MakeSpritesFromFrames():

	def __init__(self):
		print("Running " + TextColors.HEADERLEFT3 + TextColors.INVERTED + self.__class__.__name__ + " " + TextColors.ENDC)
		
		self.workingDir = ""
		self.workingDirShortName = ""
		self.stageingAreaDir = ""
		self.spriteStagingArea = "__sprite_staging_area"
		self.vertical = None #default to horizontal sprites
		self.qset = None
		self.qsetList = [50, 60, 70, 75, 80, 85, 90, 95]
		self.outputType = "png"
		self.quality = 70
		self.encoder = "pillow"
		self.extent = 600
		self.verbose = False

		helpMessage = 'This script makes a 1 row sprite from PNGs that' + TextColors.WARNING + ' HAVE NOT ' + TextColors.ENDC + 'been output into specific directories. Typically these would have been exported from After Effects as PNGs using ' + TextColors.WHITE + '__render_frames_from_selected_comps.jsx.' + TextColors.ENDC

		parser = argparse.ArgumentParser(description=helpMessage, 
			epilog=textwrap.dedent('''Setup:
• Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.

• Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-vert', '--vertical', dest='vertical', action='store_true', help="For making vertical sprites. Default is horizontal.")
		parser.add_argument('-t', '--type', dest='type', required=False, help="For JPEG output use -type jpg|JPG|jpeg|JPEG. Default output is PNG.")
		parser.add_argument('-e', '--encoder', dest='encoder', required=False, help="The specific lib to use to encode the output. Default encoder is Pillow. Use -e imagemagic|magic to use the size constraint feature which looks something like: " + TextColors.WHITE + "python make_sprites_from_frames.py -t jpg -e magic -x 700" + TextColors.ENDC)
		parser.add_argument('-x', '--extent', dest='extent', required=False, help="Sets the extent flag in the ImageMagick conversion.")
		parser.add_argument('-q', '--quality', dest='quality', required=False, help="e.g. For JPEG with quality 80 use -q 80. Default quality is 70.")
		parser.add_argument('-qset', dest='qset', action='store_true', help="e.g. To export a range of quality settings 50 through 100. Default quality is 70.")
		parser.add_argument('-v','--verbose', dest='verbose', action='store_true', help="Explain what is being done.")		
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)

		args = parser.parse_args()
		
		print("\n----- PREFLIGHT SUMMARY -----")

		if args.type:
			self.outputType = args.type.lower()
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

		if args.encoder:
			self.encoder = args.encoder.lower()
			print("Encoder type: " + args.encoder)
		else:
			print("Will save files using Pillow. Use -e magic to use the ImageMagick library.")

		if args.extent:
			self.extent = args.extent.lower()
			print("extent: " + args.extent)
		else:
			print("Will save at 600KB if magic was called. Use -x flag and pass in a number for KB.")

		if args.verbose:
			self.verbose = args.verbose
			if self.verbose == True:			
				print("Verbose mode")

		if args.qset:
			self.qset = args.qset
			print("qset is " + str(args.qset))
		else:
			if self.outputType != "png":
				print("qset ommited, will use JPG 70 quality.")

		if args.vertical:
			self.vertical = args.vertical
			print("Making vertical sprites.")
		else:
			print("Will create horizontal sprites.")

		if args.quality:
			self.quality = args.quality
			print("JPG quality set to " + str(args.quality))

			if "magic" in args.encoder:
				print( TextColors.WARNING + "You set the quality flag to " + self.quality + " but encoder is ImageMagick with the default extent flag built in. If you want to set quality use the default encoder by omitting -e magic or using -e pillow." + TextColors.ENDC)
		else:
			if self.outputType != "png":
				print("Will use JPG 70 quality.")

		# TextColors.printLogo()

		print("-----------------------------")

	def runProcess(self):
		print("-----------------------------")
		files = sorted( glob.glob( self.workingDir  + '*.png') )
		
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
		strFileName = strings_en.SPRITE + self.workingDirShortName + "." + self.outputType

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
				# if there is an alpha channel this will remove it
				dealphaImage = processedSprite.convert("RGB")

				if self.encoder == "pillow":
					strFileName = strings_en.SPRITE + self.workingDirShortName + "-q" + str(q) + ".jpg"
					fullFilePath = strFileName
					self.localPrint(TextColors.WHITE + "Quality set to " + str(q) + TextColors.ENDC)
					dealphaImage.save(fullFilePath, "JPEG", quality=int(q), optimize=True, progressive=True)	
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
					
	def openFolder(self, pDirectory):
		if sys.platform == 'darwin':
			subprocess.Popen(['open', '--', pDirectory])
		elif sys.platform == 'linux2':	
			subprocess.Popen(['xdg-open', pDirectory])
		elif sys.platform == 'win32':
			subprocess.Popen(['explorer', pDirectory.replace("/", "\\")])

	def printSpriteComplete(self, pName):
		print("\nThe sprite " + TextColors.KNOCKOUT + pName + TextColors.ENDC + " has been created.")	

	def localPrint(self, pMessage):
		if self.verbose == True:
			print(pMessage)

# instantiate the sprite making class
f = MakeSpritesFromFrames()

# first thing we do is sort the PNGs into folders
bssa = BuildSpriteStagingArea()
bssa.sortImages("png")

# get our directories
# assumes this script is running at sibling level to these folders
try:
	dirs = next( os.walk('./' + f.spriteStagingArea) )[1]
except Exception as e:
	print("¯\\_( :-/ )_/¯  Whooops!")
	print( TextColors.WARNING + "I couldn't find a __sprite_staging_area directory, so I failed here. " + TextColors.ENDC + TextColors.CYAN + "Things to try: Re-render your sprites using  __render_frames_from_selected_comps or  __render_tagged_layers_from_selected_comps WITHOUT folders." + TextColors.ENDC )
	raise e


# loop our dirs and make sprites
for dir in dirs:
	f.workingDirShortName = dir
	f.workingDir = f.spriteStagingArea + "/" + dir + "/" 
	try:
		f.runProcess()
	except Exception as e:
		print("¯\\_( :-/ )_/¯  Whooops!")
		raise e
	

# delete the __sprite_staging_area directory
# print("Deleting the temp director " + TextColors.CYAN + f.spriteStagingArea + TextColors.ENDC)
# shutil.rmtree("__sprite_staging_area")
