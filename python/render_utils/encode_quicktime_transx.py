#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"

"""
	• Place script in same location as video files.
	• Run this against uncompressed AVIs or MOVs.
	• Creates MOV files with alpha channel.
"""

import sys, os, glob, subprocess

class Transcoder():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")	
		self.fileTypes = [".mov", ".avi"]

	def run(self):		
		
		for fileType in self.fileTypes:

			for fileName in sorted(glob.glob("*"+fileType)):
				
				fileName = fileName.replace(" ", "\ ") # escape spaces in filename 

				# arg = "ffmpeg -i " + fileName + " -c:v prores -profile:v 3 -vcodec png -c:a pcm_s16le -b:v 80000 -y " + fileName.replace(fileType, "_transx.mov")
				arg = "ffmpeg -i " + fileName + " -vcodec png -c:a pcm_s16le -b:v 80000 -y " + fileName.replace(fileType, "_transx.mov")

				os.system( arg )

c = Transcoder()
c.run() 