#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arlo.emerson@essenceglobal.com>"
__version__ = "1.1"

"""
	• Place script in same location as video files.
	• Makes animated GIFs from AVI or MOV files.
	• Uses the video's own filename, swaps extension with ".gif".
	• Uses the source width divided by 2 (default behavior).
	• Run from command line with arg -s SCALE or leave blank for 50% scaling
	• Run from command line with arg -i INPUT_FILE or leave blank to process all AVI and MOV.
	
	Example usage
	For making test GIFs without scaling, and no looping, run:
	$ python make_gifs.py -s 1 -loop -1

	For infinite loop and 50% scale, use only the default:
	$ python make_gifs.py
"""

import sys, os, glob, subprocess, argparse, textwrap

class GIFMaker():

	def __init__(self, pArgs):
		print("Running '" + self.__class__.__name__ + "'...")
		self.scaleFactor = 0.5
		self.input_file = None
		self.paletteFile = "palette.png"
		self.loop = "0" # 0=infinite, -1=none

		parser = argparse.ArgumentParser(description='Make GIFs from .mov or .avi files in current working directory.', 
			epilog=textwrap.dedent('''If you don't supply SCALE or INPUT_FILE, all .avi and .mov in this directory will be processed at 50% scale. 
Setting LOOP will override the default of infinite.

Example usage:
	For making test GIFs without scaling, and no looping, run:
	$ python make_gifs.py -s 1 -loop -1

For infinite loop and 50% scale, use only the default:
	$ python make_gifs.py '''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-s', dest='scale', required=False, help="Set to 1 for no scaling. Set to .5 for 50 percent reduction.")
		parser.add_argument('-i', dest='input_file', required=False, help="Omit this flag for the entire working directory to be processed.")
		parser.add_argument('-loop', dest='loop', required=False, help="Use -loop -1 for no looping. Omit for infinite looping.")
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
			print("No scaling factor specified, will reduce by 50% (default).")

		if args.loop:
			self.loop = args.loop
			print("GIF will be looped " + self.loop + " cycles.")
		else:
			print("No loop argument specified, will loop infinitely.")


	def run(self):		
		fileTypes = [".avi", ".mov"]

		if self.input_file:
			self.convert(self.input_file, None)
		else:
			for fileType in fileTypes:
				for fileName in sorted(glob.glob("*"+fileType)):
					self.convert(fileName, fileType)

		os.system( "rm " + self.paletteFile )
		print("Removing temporary file '" + self.paletteFile + "' from directory.")

	def convert(self, pFileName, pFileType):
		# obtain the width and frame rate from the source
		if pFileName:
			fileName = pFileName.replace(" ", "\ ")

		if not pFileType: # need to derive filetype from file name
			if ".avi" in pFileName.lower():
				pFileType = ".avi"
			elif ".mov" in pFileName.lower():
				pFileType = ".mov"
		
		# do this to obtain the coded_width		
		arg = "ffprobe -i " + fileName + " -show_streams -hide_banner | grep -m 1 ""coded_width"""
		result = subprocess.check_output( arg + "; exit 0", stderr=subprocess.STDOUT, shell=True)
		print( result.split("coded_width=") )
		coded_width = abs( int( result.split("coded_width=")[1] ) )

		# do this to obtain the r_frame_rate
		arg = "ffprobe -i " + fileName + " -show_streams -hide_banner | grep -m 1 ""r_frame_rate"""
		result = subprocess.check_output( arg + "; exit 0", stderr=subprocess.STDOUT, shell=True)
		r_frame_rate = result.split("r_frame_rate=")[1]
		r_frame_rate = r_frame_rate.split("/")[0]
			
		# make the palette
		arg = "ffmpeg -y -i " + fileName + " -vf fps=" + str(r_frame_rate) + ",scale=" + str(coded_width * self.scaleFactor) + ":-1:flags=lanczos,palettegen " + self.paletteFile
		os.system( arg )

		# make the GIF
		arg = "ffmpeg -y -i " + fileName + " -i " + self.paletteFile + " -filter_complex \"fps=" + str(r_frame_rate) + ",scale=" + str(coded_width * self.scaleFactor ) + ":-1:flags=lanczos[x];[x][1:v]paletteuse\" -loop " + self.loop + " " + fileName.replace(pFileType, ".gif")
		os.system( arg )

c = GIFMaker(sys.argv[1:])
c.run()