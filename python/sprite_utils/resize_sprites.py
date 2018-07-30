#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arlo.emerson@essenceglobal.com>"
__version__ = "1.0"

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
"""

import sys, os, glob, subprocess, argparse, textwrap

class SpriteResizer():

	def __init__(self, pArgs):
		print("Running '" + self.__class__.__name__ + "'...")
		self.scaleFactor = 0.75
		self.input_file = None

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
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()
		
		if args.input_file:
			self.input_file = args.input_file
			print("Input file: " + args.input_file)
		else:
			print("No input file specified, will attempt to process all available .avi and .mov files.")
		
		if args.scale:
			self.scaleFactor = float( args.scale )
			print("A scaling factor of " + args.scale + " will be applied.")
		else:
			print("No scaling factor specified, will reduce by 75% (default). This equates to 1.5x.")


	def run(self):		
		fileTypes = [".png"]

		if self.input_file:
			self.convert(self.input_file)
		else:
			for fileType in fileTypes:
				for fileName in sorted(glob.glob("*"+fileType)):
					self.convert(fileName)

	def convert(self, pFileName):
		if pFileName:
			fileName = pFileName.replace(" ", "\ ")

		# construct the argument
		calculatedDensity = str( 2.0 * self.scaleFactor )
		arg = "ffmpeg -i " + fileName + " -vf scale=iw*" + str( self.scaleFactor ) + ":ih*" + str( self.scaleFactor ) + " " + fileName.replace(".png", "-" + calculatedDensity + "x.png")
		os.system( arg )

c = SpriteResizer(sys.argv[1:])
c.run()