import Image
import string

im = Image.open("a_helv.jpg")
im = im.convert()
seq = im.getdata()

imSize = im.size
imX = imSize[0]
imY = imSize[1]

#start
f = file("a.htm","w")
imgSeqLen = len(seq)
pixel = 0


myList = []
intRow = 0
intColumn = 0
blnStartRow = 1

#myList.append(strTableHeader)
myList.append("letter_a = [")

while pixel < imgSeqLen:
	intColumn = intColumn + 1
	# start row
	if blnStartRow == 1:
		blnStartRow = 0


	sRGB = seq[pixel]

	sRed = sRGB[0]
	sGrn = sRGB[1]
	sBlu = sRGB[2]

	sNewRGB = []
	sNewRGB.append(sRed)
	sNewRGB.append(sGrn)
	sNewRGB.append(sBlu)

	myList.append(str(sNewRGB) + ",")

	# close row
	if intRow < imY:
		if intColumn == imX:
			intColumn = 0 #reset column counter
			myList.append("'newRow',\n")
			blnStartRow = 1
			intRow = intRow + 1
	pixel = pixel + 1

myList.append("]")

f.writelines(myList)
