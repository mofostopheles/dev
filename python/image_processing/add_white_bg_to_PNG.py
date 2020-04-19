# -*- coding: utf8 -*-
'''
	arlo emerson
	adds a white BG to a PNG


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

from PIL import Image
import glob

class AddBackgroundToImage():

	def main(self):
		'''Main method of class.'''

		image_set = sorted(glob.glob( '*.png' ))

		# loop again, add the background
		for image_path in image_set:
			image = Image.open( image_path )
			new_image = Image.new('RGB', (image.width, image.height), (255, 255, 255))
			new_image.paste(image, (0, 0), image)
			image_path = image_path.replace(".png", ".png")
			new_image.save( image_path )


# Instantiate the class
WORKER = AddBackgroundToImage()
WORKER.main() # call main on WORKER
