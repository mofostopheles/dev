#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"

"""
	• Place script in same location as video files.
	• Uses the video's own filename, swaps extension with ".png" or ".jpg"
"""

import sys, os, glob, subprocess

class MakeEndframeStills():

	def __init__(self):
		self.saveAsType = ".jpg"
		print("Running '" + self.__class__.__name__ + "'...")

	def makeStills(self):		

		fileTypes = [".avi", ".mov"]

		for fileType in fileTypes:

			for fileName in sorted(glob.glob("*"+fileType)):

				arg = "ffprobe -i " + fileName + " -show_streams -hide_banner | grep -m 1 ""nb_frames"""
				result = subprocess.check_output( arg + "; exit 0", stderr=subprocess.STDOUT, shell=True)

				numberOfFrames = abs( int( result.split("nb_frames=")[1] ))

				print( "numberOfFrames=" + str(numberOfFrames-1)) 

				arg = "ffmpeg -i " + fileName + " -strict -2 -vf " + "\"select='eq(n," + str(numberOfFrames-1) + ")'\" -vframes 1 -y " + fileName.replace(fileType, self.saveAsType)
				# print(arg)
				os.system( arg )

c = MakeEndframeStills()
c.makeStills() 