#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

"""
	• Walks the directory tree beginning at the location of this python script.
	• Creates an HTML page with embedded video players of each proxy.
"""

import sys, os, glob, subprocess, argparse, textwrap, fnmatch
from datetime import datetime

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

TAB_1 = "\t"
TAB_2 = "\t\t"
TAB_3 = "\t\t\t"
TAB_4 = "\t\t\t\t"
DOUBLE_BREAK = "\n\n"
SINGLE_BREAK = "\n"


class VideoTearsheetBuilder():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.line = "----------------------------------------------------------------------------------------------------"
		self.identifier = "_proxy"
		self.errors = ""
		self.file_types = [".mp4"]
		self.html_file_name = "video_previews.html"
		self.videos_embedded_count = 0
		self.html_files_count = 0

		parser = argparse.ArgumentParser(description='Creates an HTML page with embedded video players of each proxy.', 
			epilog=textwrap.dedent('''Setup:
• Place this script at the root of where you want to do the work. See help for commands.'''), formatter_class=argparse.RawTextHelpFormatter)

		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()
		print(self.line)
		
	def Run(self):			
		for root, dirs, files in os.walk('./'):

			if "(" in root:
					self.errors += "" + SINGLE_BREAK + root

			for file_type in self.file_types:
				temp_root = root.replace(" ", "\ ")
				temp_root = temp_root.replace("(", "\(")
				temp_root = temp_root.replace(")", "\)")
				glob_path = temp_root + "/" + "*" + file_type
				file_list = sorted( glob.glob(glob_path))
				html_chunk = ""
				
				for file_name in file_list:
					file_name = file_name.replace(" ", "\ ") # escape spaces in file_name
					truncated_file_name = file_name[file_name.rindex("/")+1:]
					html_chunk += self.get_html_guts( truncated_file_name )
					print(TAB_1 + "Adding {0} to HTML.".format(truncated_file_name))

				if len(file_list) > 0:
					html_file = open(root + "/" + self.html_file_name, "w")
					write_sequence = [self.get_html_header(), html_chunk, self.get_html_footer()]
					html_file.writelines( write_sequence )
					html_file.close()
					print(TAB_1 + "Saving HTML file at {0}".format(root))
					print(self.line)
					self.videos_embedded_count += len(file_list)
					self.html_files_count += 1

		self.print_summary()

	def print_summary(self):
		print(SINGLE_BREAK)
		print(OKBLUE + self.line)
		print(TAB_4 + self.__class__.__name__ + " summary of changes")
		print(self.line + ENDC)
		print(OKGREEN + "I created {0} html pages".format(self.html_files_count) + ENDC)
		print(OKGREEN + "I embedded {0} video file players".format(self.videos_embedded_count) + ENDC)
		if len(self.errors) > 0:
			print(self.errors)
		print(OKBLUE + self.line + ENDC)
		print(SINGLE_BREAK)

	def get_html_guts(self, p_video_name):
		html_string = TAB_2 + "<div>" + SINGLE_BREAK
		html_string += TAB_3 + "<video width=\"100%\" controls>" + SINGLE_BREAK
		html_string += TAB_4 + "<source src=\"" + p_video_name + "\" type=\"video/mp4\" />" + SINGLE_BREAK
		html_string += TAB_3 + "</video>" + SINGLE_BREAK
		html_string += TAB_3 + "<p>File name: <b>" + p_video_name + "</b></p>" + SINGLE_BREAK
		html_string += TAB_2 + "</div>" + SINGLE_BREAK

		return html_string

	def get_html_header(self):
		html_string = "<!DOCTYPE html>" + SINGLE_BREAK
		html_string += "<html lang=\"en-US\">" + SINGLE_BREAK
		html_string += TAB_1 + "<head>" + SINGLE_BREAK
		html_string += TAB_2 + "<title>Video Previewer</title>" + SINGLE_BREAK
		html_string += TAB_2 + "<meta charset=\"utf-8\">" + SINGLE_BREAK
		html_string += DOUBLE_BREAK
		html_string += TAB_2 + "<style>" + SINGLE_BREAK
		html_string += TAB_3 + "video " + SINGLE_BREAK
		html_string += TAB_3 + "{" + SINGLE_BREAK
		html_string += TAB_4 + "margin-top: 10px;" + SINGLE_BREAK
		html_string += TAB_3 + "}" + SINGLE_BREAK
		html_string += DOUBLE_BREAK
		html_string += TAB_3 + "body" + SINGLE_BREAK
		html_string += TAB_3 + "{" + SINGLE_BREAK
		html_string += TAB_4 + "background-color: #000;" + SINGLE_BREAK
		html_string += TAB_3 + "}" + SINGLE_BREAK
		html_string += DOUBLE_BREAK
		html_string += TAB_3 + "p " + SINGLE_BREAK
		html_string += TAB_3 + "{" + SINGLE_BREAK
		html_string += TAB_4 + "font-family: sans-serif;" + SINGLE_BREAK
		html_string += TAB_4 + "font-size: 12px;" + SINGLE_BREAK
		html_string += TAB_4 + "color: white;" + SINGLE_BREAK
		html_string += TAB_3 + "}" + SINGLE_BREAK
		html_string += DOUBLE_BREAK
		html_string += TAB_3 + "div" + SINGLE_BREAK
		html_string += TAB_3 + "{" + SINGLE_BREAK
		html_string += TAB_4 + "border:solid 1px white;" + SINGLE_BREAK
		html_string += TAB_4 + "padding: 10px;" + SINGLE_BREAK
		html_string += TAB_4 + "margin-top:10px;" + SINGLE_BREAK
		html_string += TAB_3 + "}" + SINGLE_BREAK
		html_string += DOUBLE_BREAK
		html_string += TAB_3 + "#content" + SINGLE_BREAK
		html_string += TAB_3 + "{" + SINGLE_BREAK
		html_string += TAB_4 + "border:none;" + SINGLE_BREAK
		html_string += TAB_4 + "padding: 0;" + SINGLE_BREAK
		html_string += TAB_4 + "margin-top: 0;" + SINGLE_BREAK
		html_string += TAB_3 + "}" + SINGLE_BREAK
		html_string += TAB_2 + "</style>" + SINGLE_BREAK
		html_string += DOUBLE_BREAK
		html_string += TAB_1 + "</head>" + SINGLE_BREAK
		html_string += TAB_1 + "<body>" + SINGLE_BREAK
		html_string += TAB_2 + "<!-- auto-generated by 'html_vid_tearsheet_genny_v1.py' -->" + SINGLE_BREAK
		html_string += TAB_2 + "<div id=\"content\">" + SINGLE_BREAK

		return html_string

	def get_html_footer(self):
		html_string = TAB_2 + "</div>" + SINGLE_BREAK
		html_string += TAB_1 + "</body>" + SINGLE_BREAK
		html_string += "</html>" + SINGLE_BREAK
		return html_string

c = VideoTearsheetBuilder()
c.Run()
