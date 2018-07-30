#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arlo.emerson@essenceglobal.com>"
__version__ = "1.1"
__date__ = "6/22/2018"

"""
	SCRIPT: 
	"metadata_writer.py"

	SYNOPSIS:
	Use this script to set the comment field on your sprites. This field should say what After Effects project was used and who authored the file.

	USAGE:
	• Place this script and the lib folder in your render/output folder.
	• To see all flags and arguments run $ python metadata_writer.py -h
"""

import os, glob, argparse, textwrap

class MetaDataWriter():

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.string = ""
		self.type = "png"
		self.mode = "w"
		self.file = ""
		self.errorMessage = 'Please set a value to use for the comment field. \nThis should be your name and the After Effects project the sprites originated from. \nYou can also include change-log type info here too. \nExample usage is -s "arlo emerson, loopable_fathersday_v10.1.aep, added chalk versons per ben."'

		parser = argparse.ArgumentParser(description='Use this script to set the comment field on your sprites. This field should say what After Effects project was used and who authored the file.', 
			epilog=textwrap.dedent('''USAGE:
	• Place this script and the lib folder in your render/output folder.
	• Example write usage is python metadata_writer.py -s "arlo emerson, loopable_fathersday_v10.1.aep, added chalk versons per ben."
	• Example read usage is python metadata_writer.py -f [your file name]
	'''), formatter_class=argparse.RawTextHelpFormatter)

		parser.add_argument('-s', '--string', dest='string', required=False, help="The string (in quotes) to be used to set the comment field on the sprites.")
		parser.add_argument('-t', '--type', dest='type', required=False, help="To process JPG use -type jpg|JPG|jpeg|JPEG. Default type is PNG.")
		parser.add_argument('-m', '--mode', dest='mode', required=False, help="To read out the comment field from your sprites use -m r. Default mode is w (write).")
		parser.add_argument('-f', '--file', dest='file', required=False, help="To process a specific file, use -f [your file name]. Omit this to process all files at this directory level.")

		args = parser.parse_args()

		if args.string:
			self.string = args.string
			print("Will overwrite the comment field with '" + args.string + "'.")
		else:
			if args.mode == "w":
				# mode is write but no string was set
				print(self.errorMessage)
				return

		if args.type:
			self.type = args.type.lower()
			print("File type is '" + args.type + "'.")

		if args.mode:
			self.mode = args.mode.lower()
			print("Mode is '" + self.mode + "'.")
		else:
			print("Mode is 'write'.")

		if args.file:
			self.file = args.file
			print("Processing '" + self.file + "'.")


	def runProcess(self):
		if not self.string and self.mode == "w":
			print(self.errorMessage)
			return

		if self.file:
			files = [self.file]
		else:
			files = sorted( glob.glob( "*." + self.type) )

		if len( files ) == 0:
			print("There are no " + self.type + " files to process here.")
			return

		# write mode
		if self.mode == "w":
			print("Setting the comment field to: " + self.string)

			for f in files:	
				print("sprite: " + f)		
				arg = "convert " + f + " -set comment '" + self.string + "' " + f
				os.system( arg )
				# newarg = "convert " + f + " -format '%c\n' info:"
				# os.system( newarg )
			
		# read mode
		elif self.mode == "r":
			for f in files:	
				print("\nsprite: " + f)			
				newarg = "convert " + f + " -format '%c\n' info:"
				os.system( newarg )

f = MetaDataWriter()
f.runProcess()




	  
