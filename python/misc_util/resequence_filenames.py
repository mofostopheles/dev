#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

"""
	• A file sequence resequencer. 
	• Used for renumbering a sequence that has been gapped or has missing frames.
"""

import glob, argparse, textwrap, os, re

class ResequenceNames():

	def __init__(self):	
	
		self.title = ""
		self.file_extensions = ["png"]
		self.verbose = False

		parser = argparse.ArgumentParser(description='asdf', epilog=textwrap.dedent('''Setup: 
			• Place in same directory as work.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-f', '--file_extension', dest='file_extension', required=False, help="File type to glob for, default is JPG")
		parser.add_argument('-v', '--verbose', dest='verbose', action='store_true', required=False, help="Explain what is being done.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()

		if args.file_extension:
			self.file_extension = args.file_extension

		if args.verbose:
			self.verbose = True
			self.verbose_print("Verbose mode")

		fileType = ".png"

		path = os.getcwd()
		index = 0

		for fileName in sorted(glob.glob("*"+fileType)):
			num = str(index).zfill(3)
			print(num)
			# test before running...
			# os.rename(os.path.join(path, fileName), os.path.join(path, fileName.replace(fileType, "_" + num + fileType)))
			# print( fileName.replace("asdf", "hummingbird") )
			# os.rename(os.path.join(path, fileName), os.path.join(path, fileName.replace(fileName[4:10], "_")  ))
			# os.rename(os.path.join(path, fileName), os.path.join(path, fileName.replace("asdf", "hummingbird")  ))
			index += 1

c = ResequenceNames()