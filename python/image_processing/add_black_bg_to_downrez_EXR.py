# -*- coding: utf8 -*-
'''
	arlo emerson
	down sample EXRs and add a black (or white) background

	LICENSE
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.
	You should have received a copy of the GNU Lesser General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
'''

from PIL import Image, ImageOps, ImageFont, ImageDraw, ImageFilter, ImageChops
import os
import sys
import glob
import subprocess
import random
import time
import datetime

class EXRDownrez():

	def main(self):
		'''Main method of class.'''

		image_set = sorted(glob.glob( '*.exr' ))
		for image_path in image_set:

			new_image_path = image_path.replace("exr", "png")
			arg = "convert " + image_path + " -colorspace sRGB -alpha on PNG48:" + new_image_path
			os.system( arg )

		# loop again, down-rex to 16 bit depth
		image_set = sorted(glob.glob( '*.png' ))
		for image_path in image_set:
			new_image_path =  image_path.replace(".png", "_x.png")
			arg = "convert " + image_path + " -colorspace sRGB PNG16:" + new_image_path
			os.system( arg )

		# loop again, add the background
		image_set = sorted(glob.glob( '*_x.png' ))
		for image_path in image_set:
			new_image = Image.new('RGB', (1920, 1920), (0, 0, 0))
			image = Image.open( image_path )
			image = image.resize( (1920, 1920) )
			new_image.paste(image, (0, 0))
			new_image.save( image_path )


# Instantiate the class
WORKER = EXRDownrez()
WORKER.main() # call main on WORKER
