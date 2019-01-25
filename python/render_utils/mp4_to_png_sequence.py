#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"

"""
	• Place script in same location as video files.
	• Will make a folder of PNGs based on each MP4 it finds
"""

import sys, os, glob, subprocess

class SequenceMaker():	

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")	
		self.fileTypes = [".mp4"]

	def run(self):		
		
		for fileType in self.fileTypes:

			for fileName in sorted(glob.glob("*"+fileType)):
				
				fileName = fileName.replace(" ", "\ ").lower() # escape spaces in filename, set to LC

				dirName = fileName.replace(fileType, "")
				os.system( "mkdir " + dirName )

				arg = "ffmpeg -i " + fileName + " " + dirName + "/" + dirName + "_%04d.png"
				os.system( arg )

c = SequenceMaker()
c.run() 
