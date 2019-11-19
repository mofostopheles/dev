#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"

"""
	• Builds templatized folder structures. 
"""

import sys, os, glob, subprocess, argparse, textwrap, datetime

KNOCKOUT = '\033[100m'
COL2 = '\033[104m'
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


class DirectoryBuilder():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.line = "----------------------------------------------------------------------------------------------------"
		self.file_to_hunt = "_proxy"
		self.destroy = False
		self.number_of_files_removed = 0
		self.errors = ""
		self.suppress_date = False
		self.verbose = False
		self.short_date = False

		parser = argparse.ArgumentParser(description='Builds the folder structure for a given project.', 
			epilog=textwrap.dedent('''Setup:
• Place this script at the root of where you want to do the work.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-s', '--suppress_date', dest='suppress_date', required=False, action='store_true', help="Top level dir will be named 'YYMMDD_NAME_EVENT' rather than dynamically dated.")
		parser.add_argument('-v', '--verbose', dest='verbose', required=False, action='store_true', help="Explain what is being done.")
		parser.add_argument('-sh', '--short_date', dest='short_date', required=False, action='store_true', help="Use YYYYMM instead of YYYYMMDD.")
		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		parser.add_argument('-m', '--mom', dest='m', required=False, action='store_false', help="Call Todd's mom when done.")
		args = parser.parse_args()
		
		if args.suppress_date:
			self.suppress_date = True
			print("Top level folder will simply be named 'YYMMDD_NAME_EVENT'.")
		if args.verbose:
			self.verbose = True
		if args.short_date:
			self.short_date = True

	def Run(self):
		print(CYAN + self.line + ENDC)
		print(COL2 + "Please enter a project name..." + ENDC) 
		project_name = raw_input()

		if project_name == None or project_name == "":
			project_name = "PROJECT_NAME"

		temp_date = str( datetime.date.today() ).replace("-","")

		arg_param = "-p"
		if self.verbose:
			arg_param += "v" #tells mkdir to run in verbose mode

		arg = "mkdir " + arg_param + " " + temp_date + "_" + project_name.upper() + "/{ASSETS/{AUDIO/{MUSIC,VO,FX},DOCS,PROJECTS/{AE,C4D,PR},FOOTAGE/{LIVE_ACTION,RENDERS/{AE,C4D,PR},STILLS/{PSD,AI}}},DELIVERY}"
		if self.verbose:
			print( arg )
		# os.system( arg ) # this doesn't work
		subprocess.call(['bash', '-c', arg])

		self.print_summary()

	def TestFileExists(self, pFilePath):
		if len( glob.glob( pFilePath ) ) == 1:
			return True
		return False

	def print_summary(self):
		print(CYAN + self.line + ENDC)
		print("Done creating directories.")
		print("\n")

c = DirectoryBuilder()
c.Run()
