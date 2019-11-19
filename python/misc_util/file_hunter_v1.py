#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

"""
	• Walks the directory tree beginning at the location of this python script
	• Hunt and remove a given file
"""

import sys, os, glob, subprocess, argparse, textwrap

KNOCKOUT = '\033[100m'
FOO2 = '\033[104m'
WHITE = '\033[97m'
CYAN = '\033[96m'
HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'
INVERTED = '\033[7m'
BLINK = '\033[5m'
UNDERLINE = '\033[4m'
DARKGREEN = '\033[32m'
BOLD = '\033[1m'


class FileHunter():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.line = "----------------------------------------------------------------------------------------------------"
		self.file_to_hunt = "_proxy"
		self.destroy = False
		self.number_of_files_removed = 0
		self.errors = ""

		parser = argparse.ArgumentParser(description='Hunt and removes user defined files. Useful if you have done something bad like pollute a directory tree with scripts or need to remove dot or tmp files, etc.', 
			epilog=textwrap.dedent('''Setup:
• Place this script at the root of where you want to do the work. See help for commands.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-f', '--file', dest='file_to_hunt', required=True, help="The file to hunt for.")
		parser.add_argument('-d', '--destroy', dest='destroy', required=False, action='store_true', help="Equivalent to rm. Omitting this is equivalent to ls.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()
		
		if args.file_to_hunt:
			self.file_to_hunt = args.file_to_hunt
			print("Hunting for the file '" + args.file_to_hunt + "'.")
		if args.destroy:
			self.destroy = args.destroy
			print("You have chosen to remove file '" + args.file_to_hunt + "'.")

	def Run(self):			
		for root, dirs, files in os.walk('./'):

			if "(" in root:
					self.errors += "\n" + root

			# temp_root = root.replace(" ", "\ ")
			temp_root = root
			temp_root = temp_root.replace("(", "\(")
			temp_root = temp_root.replace(")", "\)")

			glob_path = temp_root + "/" + self.file_to_hunt
			
			if self.TestFileExists(glob_path):
				if self.destroy:			
					arg = "rm " + glob_path.replace(" ", "\ ")
					print(glob_path + " exists and will be removed.")
				else:
					arg = "ls " + glob_path.replace(" ", "\ ")

				os.system( arg )
				self.number_of_files_removed += 1

		self.print_summary()
		self.number_of_files_removed = 0

	def TestFileExists(self, pFilePath):
		if len( glob.glob( pFilePath ) ) == 1:
			return True

		return False

	def print_summary(self):
		print("\n")
		print(OKBLUE + self.line)
		print("                                  " + self.__class__.__name__ + " summary of changes")
		print(self.line + ENDC)
		if self.destroy:
			print(OKGREEN + "I removed %s files named %s" % (self.number_of_files_removed, self.file_to_hunt) + ENDC)
		else:
			print(OKGREEN + "I found %s files named %s and did not do anything. Use -d to remove found items permanently." % (self.number_of_files_removed, self.file_to_hunt) + ENDC)
		print(FAIL + "I could not access these folders: " + self.errors + ENDC)
		print(OKBLUE + self.line + ENDC)
		print("\n")


c = FileHunter()
c.Run()
