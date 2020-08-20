# -*- coding: utf8 -*-
'''
	• This is v1 prototype of an image combiner.
	• Intention is to develop this into something that batch converts thousands
		of images, where we will select the best candidates for upload.

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

from PIL import Image, ImageOps, ImageFont, ImageDraw

class RothkoCombiner():
	"""
	use this
	https://pillow.readthedocs.io/en/3.1.x/reference/ImageOps.html
	"""
	def __init__(self):
		print("asdf")

	def main(self):
		'''Main method of class.'''

		top_image = Image.open('img1.jpg')
		bot_image = Image.open('img2.jpg')

		top_image = top_image.resize((2000,2000))
		bot_image = bot_image.resize((2000,2000))

		cropped_top_image = top_image.crop((0, 0, top_image.width, round(top_image.height/2)))
		cropped_bot_image = bot_image.crop((0, round(bot_image.height/2), bot_image.width, bot_image.height))

		cutoff = 1000
		# cropped_top_image = ImageOps.posterize(cropped_top_image, bits=5)
		# cropped_bot_image = ImageOps.posterize(cropped_bot_image, bits=5)

		tmp_transparency_mask = Image.new('RGBA', (2000, 1000), (255, 255, 255))
		new_image = Image.new('RGBA', (2000, 2000))

		new_image.paste(cropped_top_image, (0, 0), tmp_transparency_mask)
		new_image.paste(cropped_bot_image, (0, 1000), tmp_transparency_mask)


		new_image.save( "rothko_1.png" )

# Instantiate the class
WORKER = RothkoCombiner()
WORKER.main() # call main on WORKER
