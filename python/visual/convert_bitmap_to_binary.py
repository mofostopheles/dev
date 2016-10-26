
"""

	converts 32x16 images to sets of binary chars
	for use by matrix.drawBitmap function.
	pixelIndexs need to be broken into groups of 8
	like so:

	B01100011, B00001100, B01100001, B10001100,
	B11110111, B10011110, B11110011, B11011110,
	B11111111, B10011111, B11110011, B11111110,
	B01111111, B00001111, B11100001, B11111100,
	B00111110, B00000111, B11000000, B11111000,
	B00011100, B00000011, B10000000, B01110000,
	B00001000, B00000001, B00000000, B00100000


	arlo emerson, 8/4/2015

	PIL docs:
	http://pillow.readthedocs.org/reference/Image.html


"""

from PIL import Image as _imaging

filename = "na2"

im = _imaging.open(filename + ".png")
seq = im.getdata()

imSize = im.size
imX = imSize[0]
imY = imSize[1]

#start
f = file("test_"+filename+".txt","w")
imgSeqLen = len(seq) #will always be 512 for 16x32 images
pixelIndex = 0

strHeader = "static const unsigned char PROGMEM "+filename+"[] = {"

imageMap = []
intRow = 0
intColumn = 0
blnStartRow = 1

imageMap.append(strHeader)

#we don't need to loop row by row, just need to break this in 8 bit chunks

_8bitCounter = 0
while pixelIndex < imgSeqLen:

	_8bitCounter = _8bitCounter + 1

	if (_8bitCounter == 1):
		imageMap.append("B")

	if (str(seq[pixelIndex]) == "(255, 255, 255)"):
		imageMap.append("1")
	else:
		imageMap.append("0")

	if (_8bitCounter == 8):
		_8bitCounter = 0
		if (pixelIndex < imgSeqLen-1):
			imageMap.append(",")

	pixelIndex = pixelIndex + 1

imageMap.append("};")


f.writelines(imageMap)
f.close()

