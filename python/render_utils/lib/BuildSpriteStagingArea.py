#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.2"
__date__ = "2/6/2018"

'''This is a sorting and filing routine. I would have liked to use After Effects's built in subfolders for image sequences, except you can't modify the folder name from the code. So we do this, build folders from the filenames. Bad things start happening with malformed collections of images. 

A temp directory named "__sprite_staging_area" is created and where sub folders for each image sequence are moved to. This folder is later trashed by a higher-level script.'''

import os, glob
import TextColors as TextColors

class BuildSpriteStagingArea():

	def __init__(self):
		self.sprite_staging_area = "__sprite_staging_area"
		print("Running " + TextColors.HEADERLEFT + TextColors.INVERTED + self.__class__.__name__ + " " + TextColors.ENDC)

	def rename(path, old, new):
	    for f in os.listdir(path):
	        os.rename(os.path.join(path, f), 
	                  os.path.join(path, f.replace(old, new)))

	def makeDir(self, pDirName):
		print(TextColors.OKGREEN + "Making directory " + TextColors.ENDC + TextColors.CYAN + pDirName + TextColors.ENDC)

		if not os.path.exists(pDirName):
			os.makedirs(pDirName)

	def sortImages(self, pImageType="png"):
		# loop a list of image sequences
		# identify unique groups of "frameN"

		try:
			previousFrameString = ""
			imageList = []
			
			sortedCount = 0
			for name in sorted(glob.glob('*.'+pImageType)):
				currentFrameString = name[ 0: -10 ]
				# print(currentFrameString)

				if previousFrameString != currentFrameString: 
					#first item in a group, let's make a folder
					dirName = name[ 0:name.find("_") ]
					self.makeDir( self.sprite_staging_area + "/" + dirName )				

				os.rename( name,  self.sprite_staging_area + "/" + dirName + "/" + name )
				print(TextColors.OKGREEN + "Moving " + name + " to " + TextColors.ENDC + TextColors.CYAN + dirName + TextColors.ENDC)
				previousFrameString = currentFrameString
				sortedCount += 1

			print(TextColors.WARNING + str(sortedCount) + TextColors.ENDC + TextColors.CYAN + " files were sorted." + TextColors.ENDC)
			return sortedCount
		except Exception as e:
			print("¯\\_( :-/ )_/¯  Whooops!")
			raise e

# uncomment to just test this class, else it is called by higher level function
# sm = BuildSpriteStagingArea()
# sm.sortImages()


