#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

"""
	ABOUT:
	• Walks the directory tree beginning at the location of this python script
	• Hunt and rename files per hardcoded string

	SETUP:
	• place this script at the root of the server path
	• set up a mount of this directory: sudo mount -t drvfs '\\server_path\\' /mnt/tmp
	• change path_append to "mnt/tmp"
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


class FileRenamer():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.line = "----------------------------------------------------------------------------------------------------"
		self.path_append = os.getcwd() # path of where this script is located, should be the top level of where to perform work
		# self.path_append = "/mnt/tmp" # on the server
		self.name_to_replace = "asdf"
		self.replace_with_name = "testdude"
		self.rename = False
		self.status_report = False
		self.number_of_files_renamed = 0
		self.errors = ""

		parser = argparse.ArgumentParser(description='Hunt and renames user defined files.', 
			epilog=textwrap.dedent('''Setup:
• Place this script at the root of where you want to do the work. See help for commands.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-s', '--status', dest='status', required=False, action='store_true', help="Print a list of all files found matching the pattern.")
		parser.add_argument('-r', '--rename', dest='rename', required=False, action='store_true', help="Include this to actually rename files.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + str(__version__) )
		args = parser.parse_args()
		
		if args.rename:
			self.rename = True
			print("You have chosen to rename files named " + self.name_to_replace + " with " + self.replace_with_name + ".")

		if args.status:
			self.status_report = True
			print("You have chosen to print a status report of files matching the pattern " + self.name_to_replace + "/" + self.replace_with_name + ".")

	def rreplace(self, s, old, new, occurrence):
		li = s.rsplit(old, occurrence)
		return new.join(li)

	def Run(self):

		for root, dirs, files in os.walk('./'):

			for f in files:

				if (self.name_to_replace.lower() in f.lower() ):
					
					tmpFilePath = self.path_append + root.replace("./", "/") + "/" + f

					if self.status_report == True and self.rename == False: # print a report of found files
						self.number_of_files_renamed += 1
						print( tmpFilePath )

					else:

						arg_prefix = "rename -v -n 's/"
						if self.rename == True:
							arg_prefix = "rename -v 's/"

						string_index = tmpFilePath.lower().rfind(self.name_to_replace.lower())
						actual_spelling = tmpFilePath[ string_index:string_index+len(self.name_to_replace) ]

						arg = arg_prefix + actual_spelling + "/" + self.replace_with_name + "/' '" + tmpFilePath + "'"
						confirm = raw_input(arg + " Enter 'y' to confirm: ")

						if confirm == "y":
							os.system( arg )
							self.number_of_files_renamed += 1
						# temp override:
						# os.system( arg )
						# self.number_of_files_renamed += 1

		self.print_summary()
		self.number_of_files_renamed = 0

	def TestFileExists(self, pFilePath):
		if len( glob.glob( pFilePath ) ) == 1:
			return True
		return False

	def print_summary(self):
		print("\n")
		print(OKBLUE + self.line)
		print("                                  " + self.__class__.__name__ + " summary of changes")
		print(self.line + ENDC)
		if self.rename:
			print(OKGREEN + "I attempted to rename %s files named %s" % (self.number_of_files_renamed, self.name_to_replace) + ENDC)
		else:
			print(OKGREEN + "I found %s files named %s and did not do anything." % (self.number_of_files_renamed, self.name_to_replace) + ENDC)

		if self.errors:
			print(FAIL + "I could not access these folders: " + self.errors + ENDC)
		
		print(OKBLUE + self.line + ENDC)
		print("\n")

c = FileRenamer()
c.Run()