#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "5.0"
__email__ = "arloemerson@gmail.com"

"""

	• Walks the directory tree beginning at the location of this python script
	• Makes a downgraded copy of videos found
	• Burn timecode and add filename

	TODO: FIX THESE ERRORS
	 overread end of atom 'mak' by 2 bytes
	[mov,mp4,m4a,3gp,3g2,mj2 @ 0x7fffdf352ae0] overread end of atom 'swr' by 3 bytes
	deprecated pixel format used, make sure you did set range correctly
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


class Transcoder():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.outputs = ["10M", "1920x1080"]
		self.file_types = [".avi", ".mov", ".mxf", ".AVI", ".MOV", ".MXF"]			
		self.tune_settings = "film"
		self.speed = "fast"
		self.line = "----------------------------------------------------------------------------------------------------"
		self.show_details = False
		self.number_of_proxies_created = 0
		self.number_of_proxies_skipped = 0
		self.identifier = "_proxy"
		self.errors = ""
		self.overwrite = False
		# self.timecode = False
		self.date_filter = ""

		parser = argparse.ArgumentParser(description='Creates downgraded proxy videos from existing videos.', 
			epilog=textwrap.dedent('''Setup:
• Place this script at the root of where you want to do the work. See help for commands.'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-t', '--timecode', dest='timecode', required=False, action='store_true', help="Adds timecode overlay to video.")
		parser.add_argument('-o', '--overwrite', dest='overwrite', required=False, action='store_true', help="Overwrites existing proxy files.")
		parser.add_argument('-df', '--date_filter', dest='date_filter', required=False, help="Render proxy file only if an existing proxy file is older than this date e.g. '2019-05-17'. To overwrite proxies older than this example date, run " + CYAN + " python hd_proxy_transcoder_v5.py -df 2019-05-17 -o" + ENDC)

		parser.add_argument('--version', action='version', version='%(prog)s ' + __version__)
		args = parser.parse_args()
		
		if args.overwrite:
			self.overwrite = args.overwrite
			print("Will overwrite existing proxy videos.")
		# if args.timecode:
		# 	self.timecode = args.timecode
		# 	print("Will add timecode overlay to proxy videos.")
		if args.date_filter:
			if args.date_filter != "":
				self.date_filter = args.date_filter
				print("Will render proxy files if existing proxy file is older than this date: " + self.date_filter )


	def Run(self):			
		for root, dirs, files in os.walk('./'):

			if "(" in root:
					self.errors += "\n" + root

			for file_type in self.file_types:
				temp_root = root.replace(" ", "\ ")
				temp_root = temp_root.replace("(", "\(")
				temp_root = temp_root.replace(")", "\)")

				glob_path = temp_root + "/" + "*" + file_type
				
				# file_list = sorted( glob.glob1(glob_path , "*" + file_type))
				file_list = sorted( glob.glob(glob_path))

				for file_name in file_list:
					file_name = file_name.replace(" ", "\ ") # escape spaces in file_name 

					if not self.test_proxy_exists(file_name, file_type):						

						if self.render_based_on_date_filter(file_name, file_type):
							bitRate = self.outputs[0]
							size = self.outputs[1]

							draw_text1 = "drawtext=fontfile='/mnt/c/Windows/Fonts/tahoma.ttf':text='" + file_name + "':x=10:y=lh:fontsize=30:fontcolor=white:shadowcolor=black:shadowx=1:shadowy=1, "

							# get the FPS from the video
							arg = "ffprobe -i " + file_name + " -show_entries stream=r_frame_rate -select_streams v:0 -of compact=p=0:nk=1"
							result = subprocess.check_output( arg + "; exit 0", stderr=subprocess.STDOUT, shell=True)
							# print("bitrate: N/A" in result)

							if not "Invalid data found when processing input" in result and not "bitrate: N/A" in result:
								filtered = fnmatch.filter(result.split(","), "*fps")
								fps = filtered[0][1:-4]

								draw_text2 = "drawtext=fontfile='/mnt/c/Windows/Fonts/tahoma.ttf':x=w/2-200:y=h-lh-200:fontsize=70:fontcolor=white:shadowcolor=black:shadowx=1:shadowy=1:timecode='00\:00\:00\:00':timecode_rate=" + fps

								vf_format = "format=rgb24, " + draw_text1 + draw_text2

								arg = 'ffmpeg -i ' + file_name + ' -s ' + size + ' -vf "' + vf_format + '" -pix_fmt yuv420p -c:v libx264 -x264-params \'nal-hrd=cbr\' -probesize 5000000 -b:v ' + bitRate + ' -minrate ' + bitRate + ' -maxrate ' + bitRate + ' -bufsize ' + bitRate + ' -acodec aac -strict -2 -tune ' + self.tune_settings + ' -preset ' + self.speed + ' -movflags faststart -y -force_key_frames 1 ' + file_name.replace(file_type, self.identifier + '.mp4')

								os.system( arg )
								self.number_of_proxies_created += 1
							else:
								print(file_name + " appears to be corrupt. Can't be processed.")
								self.errors += "\n" + file_name
								print(self.line)

		self.print_summary()

	def get_years_from_epoch_from_seconds(self, p_seconds):
		return_value = (p_seconds/60/60/24/365)
		# print(return_value)
		return return_value

	def render_based_on_date_filter(self, p_file_name, p_file_type):		

		if self.date_filter != "":
			tmp_file_name = p_file_name.replace(p_file_type, "_proxy.mp4")
			
			if len( glob.glob( tmp_file_name ) ) == 1:	
				modified_date = os.path.getmtime(tmp_file_name)							
				proxy_seconds = modified_date
				year = int(self.date_filter.split("-")[0])
				month = int(self.date_filter.split("-")[1])
				day = int(self.date_filter.split("-")[2])
				date_filter_in_seconds = (datetime(year, month, day, 0, 0) - datetime(1970,1,1)).total_seconds()
				# print(datetime.fromtimestamp(os.path.getmtime(tmp_file_name)).strftime('%Y-%m-%d'))

				if (self.get_years_from_epoch_from_seconds( proxy_seconds ) < self.get_years_from_epoch_from_seconds( date_filter_in_seconds )): # if proxy file is older than the date_filter, render it
					print(self.line)
					print("older proxy file " + tmp_file_name + " will be re-rendered")
					print(self.line)
					return True
				else: # else, proxy file is newer than date_filter so we'll skip it
					return False
			else:
				return True # no filter provided so YES, render this

		return True # no filter provided so YES, render this

	def print_summary(self):
		print("\n")
		print(OKBLUE + self.line)
		print("                                  " + self.__class__.__name__ + " summary of changes")
		print(self.line + ENDC)
		print(OKGREEN + "I created %s proxy videos" % (self.number_of_proxies_created) + ENDC)
		print(FAIL + "I could not access these folders or files: " + self.errors + ENDC)
		print(OKGREEN + "I skipped making proxies for %s videos" % (self.number_of_proxies_skipped) + ENDC)
		print(OKBLUE + self.line + ENDC)
		print("\n")

	def test_proxy_exists(self, p_file_name, p_file_type):

		tmp_file_name = p_file_name.replace(p_file_type, "_proxy.mp4")

		if len( glob.glob( tmp_file_name ) ) == 1:
			if self.overwrite:
				print(OKGREEN + "proxy file " + tmp_file_name + " already exists. Will overwrite if date_filter requirements are met." + ENDC)
				return False
			else:
				print(FAIL + "proxy file " + tmp_file_name + " already exists. To overwrite use -o" + ENDC)
				self.number_of_proxies_skipped += 1

		else:
			print(self.line)
			print(OKGREEN + "proxy file for " + p_file_name + " will be created" + ENDC)
			print(self.line)
			return False

		return True

c = Transcoder()
c.Run()
