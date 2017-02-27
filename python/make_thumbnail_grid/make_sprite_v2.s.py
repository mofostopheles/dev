"""
	1/30/2017 
	@author Arlo Emerson
	arloemerson@gmail.com

	based on a the thumbnail maker script, this one just makes a 1 row sprite 
"""

__author__ = "Arlo Emerson"
__version__ = "2.0"
__email__ = "arloemerson@gmail.com"
__license__ = "GPL 3.0"

from Tkinter import *
import ttk
import json
from pprint import pprint
from tkFileDialog import askopenfilename, askdirectory
from thumbs_gen_v2 import ThumbnailMaker
import contact_sheet_v1 as cs
import glob
from datetime import datetime as dt
import strings_EN as strings_en
import subprocess
import sys
import os


class MakeSpriteImage():

	def __init__(self):
		print("init")
		# ________________________ SET THIS _____________________________
		self.workingDir = "/home/PATH TO PNGs HERE/"

	def runProcess(self):
		
		files = sorted( glob.glob( str( self.workingDir )  + '*.png') )

		numberOfFrames = len( files ) # this equates to number of frames in the sprite
		from PIL import Image
		im=Image.open( files[0] )


		# These are all in terms of pixels:
		photow, photoh = im.size[0], im.size[1]
		photo = (photow,photoh)
		margin =  0

		# TODO make individual GUI fields for margin, not sure the value of this feature at this point
		margins = [margin,margin,margin,margin]
		padding = 0
		
		ncols = numberOfFrames #this equates to number of frames when making sprites, FPS is determined in After Effects
		nrows = 1

		inew = cs.make_contact_sheet(files,(ncols,nrows),photo,margins,padding)

		strDirectory = str(self.workingDir)
		strFileName = strings_en.SPRITE + \
						str(photow) + "x" + \
						str(photoh) + "x" + \
						str(ncols) + "_" + \
						str(dt.now().month) + "-" + \
						str(dt.now().day) + "_" + \
						str(dt.now().hour) + "-" + \
						str(dt.now().minute) + "-" + \
						str(dt.now().second) + \
						".jpg"

		inew.save(strDirectory + strFileName)

		# print("file '" + strDirectory + strFileName + "' has been created.")
		#askopenfilename(initialdir=strDirectory, initialfile=strFileName)
		self.openFolder(strDirectory)
		
	def openFolder(self, pDirectory):
		if sys.platform == 'darwin':
			subprocess.Popen(['open', '--', pDirectory])
		elif sys.platform == 'linux2':
			subprocess.Popen(['xdg-open', pDirectory])
		elif sys.platform == 'win32':
			subprocess.Popen(['explorer', pDirectory.replace("/", "\\")])


# kick off the app here...
f = MakeSpriteImage()
f.runProcess()
    

