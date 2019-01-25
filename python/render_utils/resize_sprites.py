#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.1"

"""
	• Place script in same location as png files.
	• Resize PNGs to 75% of original size. This is useful for down-rezzing 2x sprites.
	• Run from command line with arg -s SCALE or leave blank for 75% scaling (i.e. 1.5x).
	• Run from command line with arg -i INPUT_FILE or leave blank to process all PNGs.
	
	Example usage:
		For making 1.5x versions of your sprites simply run:
		$ python resize_sprites.py

		For 50% scale on "somefile.png" run:
		$ python resize_sprites.py -s .5 -i somefile.png

	change log:
	10/25/2018 - added filter so we don't resize already resized sprites
			   - gzip files when done
"""

import sys, os, glob, subprocess, argparse, textwrap

class SpriteResizer():

	def __init__(self, pArgs):
		print("Running '" + self.__class__.__name__ + "'...")
		self.scaleFactor = 0.75
		self.input_file = None
		self.batch = False

		parser = argparse.ArgumentParser(description='Defaults will resize all PNGs to 75% of original size. This is useful for down-rezzing 2x sprites.', 
			epilog=textwrap.dedent('''If you don't supply SCALE or INPUT_FILE, all PNG files in this directory will be processed at 75% scale of an assumed 2x size. 

Example usage:
	For making 1.5x versions of your sprites simply run:
	$ python resize_sprites.py

	For 50% scale on "somefile.png" run:
	$ python resize_sprites.py -s .5 -i somefile.png

	'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-s', dest='scale', required=False, help="Omit for 1.5x (or 75 percent). Set to .5 for 50 percent reduction.")
		parser.add_argument('-i', dest='input_file', required=False, help="Omit this flag for the entire working directory to be processed.")
		parser.add_argument('-b', '--batch', dest='batch', action='store_true', help="Will batch convert 1.5x and 1.0x automatically.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()
		
		if args.input_file:
			self.input_file = args.input_file
			print("Input file: " + args.input_file)
		else:
			print("No input file specified, will attempt to process all available .png or .jpg files.")
		
		if args.scale:
			self.scaleFactor = float( args.scale )
			print("A scaling factor of " + args.scale + " will be applied.")
		else:
			print("No scaling factor specified, will reduce by 75% (default). This equates to 1.5x.")

		if args.batch:
			self.batch = True
			print("Will batch convert 1.5x and 1.0x automatically.")

	def run(self):		
		fileTypes = [".png", ".jpg"]

		if self.input_file:
			self.convert(self.input_file)
		else:
			dirty = False
			for fileType in fileTypes:
				for fileName in sorted(glob.glob("*"+fileType)):
					if self.notConvertedYet( fileName ):
						self.convert(fileName, fileType)
						dirty = True
				
				if dirty:
					self.gzipThisGroup(fileName, fileType)
				else:
					print("Sorry, I did not convert anything.")

	def convert(self, pFileName, pFileType):
		if pFileName:
			fileName = pFileName.replace(" ", "\ ")

		densityFactors = [0.75, 0.5]
		if self.batch:
			for d in densityFactors:
				calculatedDensity = str( 2.0 * d )
				arg = "ffmpeg -i " + fileName + " -vf scale=iw*" + str( d ) + ":ih*" + str( d ) + " -y " + fileName.replace(pFileType, "-" + calculatedDensity + "x" + pFileType)
				os.system( arg )
		else:
			# construct the argument
			calculatedDensity = str( 2.0 * self.scaleFactor )
			arg = "ffmpeg -i " + fileName + " -vf scale=iw*" + str( self.scaleFactor ) + ":ih*" + str( self.scaleFactor ) + " -y " + fileName.replace(pFileType, "-" + calculatedDensity + "x" + pFileType)
			os.system( arg )

	def gzipThisGroup(self, pFileName, pFileType):
		if self.batch:
			theseSprites = pFileName[0:pFileName.rfind('-')]
			zipName = theseSprites + "-batch.tar.gz"
			# arg = "tar -cvzf " + zipName + " " + theseSprites + "*.png" 
			arg = "tar -cvzf " + zipName + " " + "sprite*" + pFileType
			print("zipping sprites with arg " + arg)
			os.system( arg )
			print("checking zip contents " + "tar -tf " + zipName)
			os.system( "tar -tf " + zipName )

		else:
			calculatedDensity = str( 2.0 * self.scaleFactor )
			zipName = pFileName[0:pFileName.rfind('-')] + "-" + calculatedDensity + "x" + ".tar.gz"			
			arg = "tar -cvzf " + zipName + " *" + calculatedDensity + "x" + pFileType
			print("zipping sprites for scale factor " + calculatedDensity + "x with arg " + arg)
			os.system( arg )
			print("checking zip contents " + "tar -tf " + zipName)
			os.system( "tar -tf " + zipName )

	def notConvertedYet(self, pFileName):
		listOfResolutions = [".0x", ".1x", ".2x", ".3x", ".4x", ".5x", ".6x", ".7x", ".8x", ".9x"]

		for item in listOfResolutions:
			if item in pFileName:
				return False

		return True

c = SpriteResizer(sys.argv[1:])
c.run()