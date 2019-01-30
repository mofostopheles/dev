#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"

"""
	• Place script in same location as video files.
	• Run this against uncompressed AVIs or Apple ProRes files.
	• Creates transcoded versions of videos to YouTube/CBS/VAST specs. 
	  This typically includes:
		• 1920x1080 30 mbps
		• 1920x1080	2000 kbps
		• 1280x720 1000 kbps
		• 1280x720 800 kbps
		• 1280x720 700 kbps
		• 1280x720 500 kbps
		• audio only
"""

import sys, os, glob, subprocess

class Transcoder():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.outputs = [ ["1000K", "1280x720"] ]		
		self.fileTypes = [".avi"]

		# maintain for testing/fine-tuning problem videos
		# self.outputs = [ ["2000K", "1920x1080"] ]
		# self.tuneSettings = ["film", "animation", "grain", "stillimage", "psnr", "ssim", "fastdecode", "zerolatency"]
		# self.speeds = ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow", "placebo"]

		# optimized settings
		self.tuneSettings = ["zerolatency"]
		self.speeds = ["medium"]
		
		self.showDetails = False

	def run(self):		
		
		for fileType in self.fileTypes:

			for fileName in sorted(glob.glob("*"+fileType)):
				
				fileName = fileName.replace(" ", "\ ") # escape spaces in filename 

				for output in self.outputs:

					for tune in self.tuneSettings:

						for speed in self.speeds:

							bitRate = output[0]
							size = output[1]

							fileDetails = ""
							if self.showDetails == True:
								fileDetails = tune + "_" + speed + "_"

							arg = "ffmpeg -i " + fileName + " -s " + size + " -c:v libx264 -x264-params \"nal-hrd=cbr\" -pix_fmt yuv420p -probesize 5000000 -b:v " + bitRate + " -minrate " + bitRate + " -maxrate " + bitRate + " -bufsize " + bitRate + " -acodec aac -strict -2 -tune " + tune + " -preset " + speed + " -movflags faststart -y -force_key_frames 1 " + fileName.replace(fileType, "_" + fileDetails + bitRate + ".mp4")

							os.system( arg )

			


c = Transcoder()
c.run() 