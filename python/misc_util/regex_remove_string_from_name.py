#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

"""
	• Removes strings from a filename and then renames the file.
"""

import glob, argparse, textwrap, os, re

class ResequenceNames():

	def __init__(self):	
	
		self.title = ""
		self.verbose = False

		parser = argparse.ArgumentParser(description='asdf', epilog=textwrap.dedent('''Setup: 
			• Place in same dir as work.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-v', '--verbose', dest='verbose', action='store_true', required=False, help="Explain what is being done.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()

		if args.verbose:
			self.verbose = True
			self.verbose_print("Verbose mode")

		fileType = ".png"

		print(os.getcwd())
		index = 0

		for fileName in sorted(glob.glob("*"+fileType)):
			# prefix, num = filename[:-4].split('_')
			# num = str(index).zfill(3)
			# print(num)
			# print( fileName[:-4] + "_" + num + ".png" )
			# x = re.search("\(*\)", fileName)

			# this finds any numbers within parens
			x = re.findall("(\(\d+\))", fileName)

			if x:
				print( x[0])
				newName = fileName.replace(x[0], "")
				print(newName)
				os.rename(os.path.join(os.getcwd(), fileName), os.path.join(os.getcwd(), newName))

			index += 1

c = ResequenceNames()