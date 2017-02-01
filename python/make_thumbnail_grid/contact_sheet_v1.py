#@author http://code.activestate.com/recipes/578267-use-pil-to-make-a-contact-sheet-montage-of-images/

"""
modified by arlo emerson, 1/27/2017
arlo.emerson@essencedigital.com
"""

import glob
from PIL import Image
from datetime import datetime as dt


def make_contact_sheet(fnames,(ncols,nrows),(photow,photoh),(marl,mart,marr,marb),padding):
	"""
	Make a contact sheet from a group of filenames:

	fnames       A list of names of the image files

	ncols        Number of columns in the contact sheet
	nrows        Number of rows in the contact sheet
	photow       The width of the photo thumbs in pixels
	photoh       The height of the photo thumbs in pixels

	marl         The left margin in pixels
	mart         The top margin in pixels
	marr         The right margin in pixels
	marb         The bottom margin in pixels

	padding      The padding between images in pixels

	returns a PIL image object.
	"""

	# Calculate the size of the output image, based on the
	#  photo thumb sizes, margins, and padding
	marw = marl+marr
	marh = mart+ marb

	padw = (ncols-1)*padding
	padh = (nrows-1)*padding
	isize = (ncols*photow+marw+padw,nrows*photoh+marh+padh)

	# Create the new image. The background doesn't have to be white
	white = (255,255,255)
	inew = Image.new('RGB',isize,white)

	count = 0
	# Insert each thumb:
	for irow in range(nrows):		
		for icol in range(ncols):
			left = marl + icol*(photow+padding)
			right = left + photow
			upper = mart + irow*(photoh+padding)
			lower = upper + photoh
			#bbox = (left,upper,right,lower)
			newWidth = 0
			newHeight = 0
			img = None
			try:
				# Read in an image and resize appropriately
				#img = Image.open(fnames[count]).resize((photow,photoh))

				img = Image.open(fnames[count])
				img_bbox = img.getbbox()
				width = img_bbox[2] - img_bbox[0]
				height = img_bbox[3] - img_bbox[1]

				# calculate a scaling factor depending on fitting the larger dimension into the thumbnail
				ratio = max(height/float(photoh), width/float(photow))

				newWidth = int(width/ratio)
				newHeight = int(height/ratio)
				newSize = (newWidth, newHeight)

				img = img.resize(newSize)

			except Exception as e:
				print(e)
			else: 
				pass

			#inew.paste(img,bbox)
			#count += 1
			new_left = left
			new_upper = upper

			if ( newWidth < photow):
				new_left = ( left + ((photow - newWidth)/2))

			if ( newHeight < photoh):
				new_upper = (upper + ((photoh - newHeight)/2))

			inew.paste(img, (new_left, new_upper))
			count += 1
			print("making " + str(count) + " of " + str(nrows * ncols))

	return inew





